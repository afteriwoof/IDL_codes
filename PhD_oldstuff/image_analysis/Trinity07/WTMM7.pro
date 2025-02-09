; Trying to automate the detection of the front and eliminate streamers.

pro WTMM7

loadct, 3

ans = ''

restore, 'fifths.sav' ;Fifth scale of 18apr00
;[1024,1024,1,14]

restore, 'alpgrads.sav' ;Direction array for each image at fifth scale 
;[1024,1024,14]

restore, 'modgrads.sav' ;Magnitude array of the Canny detection
;[1024,1024,14]

sz_fifths = size(fifths, /dim)

array = fltarr(684, 686, sz_fifths[3])


for i=0,sz_fifths[3]-1 do begin

;	print, 'Image:' & print, i
	
	im = modgrads[*,*,i]^0.25
;	plot_image, im
;	read, ans
	
	result = canny(fifths[*,*,*,i], high=0.74, low=0., sigma=10)
;	plot_image, result
;	read, ans

	contour, result, lev=0.001, /over, path_info=info, $
		path_xy=xy, /path_data_coords

;	plots, xy[0,*], xy[1,*], psym=3
;	read, ans

;	plot_image, alpgrads[*,*,i]
;	plots, xy[0,*], xy[1,*], psym=3
;	read, ans

	sz_contour = size(info, /dim)
	points = fltarr(1024,1024)
	
	points[xy[0,*], xy[1,*]] = alpgrads[xy[0,*], xy[1,*]]
;	plot_image, points
;	read, ans
	
	newpoints = fltarr(1024,1024)
	
	
	for k=0,sz_contour[0]-1 do begin
		
		temp = fltarr(1024,1024)
		x = xy[0,info[k].offset:(info[k].offset+info[k].n-1)]
		y = xy[1,info[k].offset:(info[k].offset+info[k].n-1)]
		temp[x,y] = points[x,y]
		mx = max(temp[where(temp ne 0)])
		mn = min(temp[where(temp ne 0)])
		diff = mx - mn

		if diff gt 80 then begin
			;newpoints[x,y] = points[x,y]
			newpoints[x,y] = 1
		endif
	endfor

	loadct, 0
	plot_image, newpoints
;	read, ans

	entry = tvrd()
	array[*,*,i] = entry
	
endfor

wr_movie, 'WTMM7_binary_h0-74_l0', array

end


