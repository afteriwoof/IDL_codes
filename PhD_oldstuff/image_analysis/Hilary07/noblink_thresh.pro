; Code which produces normalised exposure time data array and byte-scaling of same from Alex's data 18-apr-2000.
; Also removes disk surrounding Solar disk.


; This code uses fmedian before it applies the normalisation or bytscl.
; fmedian calls fmedian_slow which takes a long time to run!!!


; The bottom part now includes code to try and contour the CME front as in pg.pro


pro noblink_thresh, danb, diffn, diffnb

fls = file_search('../18-apr-2000/*')

mreadfits, fls, in, da

;restore, '~/PhD/18apr2000.sav'

;restore, '~/PhD/in.sav'

; Convert INT array to FLOAT
da = float(da)

da_norm = da

danb = da

sz = size(da, /dim)

; Remove inner disk
for i=0,sz[2]-1 do begin
	im = da(*,*,i)
	rm_inner, im, in[i], dr, thr=2.1
	
	;plot_image, im	
	;stop

	da(*,*,i) = fmedian(im, 5, 3)

	da_norm(*,*,i) = da(*,*,i) / in[i].exptime

	danb(*,*,i) = bytscl(da_norm(*,*,i), 25, 225)
endfor

; Now computing Running Difference

diffn = fltarr(sz[0],sz[1],sz[2]-1)

diffnb = diffn

for i=0,sz[2]-2 do begin

	diffn(*,*,i) = da_norm(*,*,i+1) - da_norm(*,*,i)

	diffnb(*,*,i) = bytscl( diffn(*,*,i), -10, 18)

endfor

szd = size(diffn, /dim)

; Contour / Thresholding

!p.multi = [0,1,2]

for i=0,szd[2]-1 do begin

	mu = moment( diffn(50:200, 200:950, i), sdev=sdev)
	thresh = mu[0] + 3.*sdev
	thresh_lwr = mu[0] - 3.*sdev

	print, 'mu:' & print, mu
	print, 'thresh:' & print, thresh

	set_line_color

	plot_hist, diffn[50:200, 200:950, i], xr=[-10, 10] ; yr=[0,5000]
	plots, [ mu[0], mu[0] ], [0,3000], color=3
	plots, [ thresh, thresh ], [0,3000], color=5
	plots, [ thresh_lwr, thresh_lwr ], [0,3000], color=5

	loadct, 3
	plot_image, diffnb(*,*,i)

	contour, diffn(*,*,i), level=thresh, /over, path_info=info, $
		path_xy=xy, /path_data_coords, c_color=3, thick=2

	plots, xy(*, info[0].offset : (info[0].offset + info[0].n -1) ), $
		linestyle=0, /data

	plots, xy(*, info[1].offset : (info[1].offset + info[1].n -1) ), $
		linestyle=0, /data


	; Drawing in line from centre to the edge I determined from diffn8 and messing with recpol
	plots, [512.634,633.708], [505.293,87.651]


	ans=''
	read, 'ok?', ans

endfor





end

