pro diff

files = file_search('18-apr-2000/*')

mreadfits, files, index, data

sz = size( data, /dim )

diff = fltarr( sz[0], sz[1], sz[2]-1 )
ssigdiff = diff

for i=1,sz[2]-1 do begin

	diff(*,*,i-1) = data(*,*,i) - data(*,*,i-1)

	ssigdiff(*,*,i-1) = smooth( sigrange( diff(*,*,i-1) ), 5, /ed )

;	window, i
;	plot_image, ssigdiff(*,*,i-1)

endfor

for i=0, sz[2]-2 do begin
	
	window, i+sz[2]

	plot_image, ssigdiff(*,*,i)
	
	contour, ssigdiff(*,*,i), /xstyle, /ystyle, levels=1, /over, $
		path_info=info, path_xy=xy, /path_data_coords

	plots, xy[ *, info[0].offset : (info[0].offset + info[0].n -1) ], $
		linestyle=0, /data
endfor




end
