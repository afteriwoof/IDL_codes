; Code to take the Matlab fronts saved by eye and plot them in IDL for ellipse fit.

; Last Edited: 27-06-07

; path is the pathname for the data array in question
; front is the .png filename and/or pathname from the Matlab savefile
; im_num is the number of the image in the data array
pro read_fronts, path, front, im_num, front2=front2

	loadct, 8

	fls = file_search(path)
	mreadfits, fls, in, da

	da = da[*,*,im_num]

	im = read_png(front)

	temp = im

	sz = size(im, /dim)

	for i=0,sz[0]-1 do temp[*, abs(sz[0]-1-i)] = im[*,i]

	im = temp
	delvarx, temp

	plot_image, da

	frontonly = where(im ne 0)
	ind = array_indices(im, frontonly)
	set_line_color
	plots, ind[0,*], ind[1,*], psym=3, color=3
	

	if keyword_set(front2) then begin
		im2 = read_png(front2)
		temp2 = im2
		sz2 = size(im2, /dim)
		for i=0,sz2[0]-1 do temp2[*, abs(sz2[0]-1-i)] = im2[*,i]
		im2 = temp2
		delvarx, temp2
		frontonly2 = where(im2 ne 0)
		ind2 = array_indices(im2, frontonly2)
		plots, ind2[0,*], ind2[1,*], psym=3, color=3
	endif

end
