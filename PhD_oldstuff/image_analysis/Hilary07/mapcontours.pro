; Code which produces normalised exposure time data array and byte-scaling of same from Alex's data 18-apr-2000.
; Also removes disk surrounding Solar disk.

; This code uses fmedian before it applies the normalisation or bytscl.
; fmedian calls fmedian_slow which takes a long time to run!!!

; Creating MAPS from the data and scaling contour values to maps coords.

; Sample attempt to fit an ellipse to the array of data points.

; Last edited 01-03-07


pro mapcontours, xy,danb, diffnb

fls = file_search('~/NASA_Internship/Data_for_Jason/C2/*.fts')
;fls = file_search('~/PhD/Data_from_Alex/18-apr-00/*.fts')
;fls = file_search('~/PhD/Data_from_James/010515/*.fts')

mreadfits, fls, in, da

; Operations to be done on James's data
;c2data = where( in.detector eq 'C2' and in.naxis1 eq 1024)
;mreadfits, fls(c2data), in, c2data
;ssw_fill_cube2, c2data, da

save, da, filename='da_221194.sav'
save, in, filename='in_221194.sav'

;restore, '~/PhD/18apr2000.sav'

;restore, '~/PhD/in.sav'

; Convert INT array to FLOAT
da = float(da)

da_norm = da

danb = da

sz = size(da, /dim)


for i=0,sz[2]-1 do begin
	
	im = da(*,*,i)

	; Remove inner disk
	rm_inner, im, in[i], dr, thr=2.1
	
	; Median operator to smooth noise pixels
	da(*,*,i) = fmedian(im, 5, 3)

	; Normalising the data with regard to exposure time
	da_norm(*,*,i) = da(*,*,i) / in[i].exptime

	; Bytscaling for image presentation only.
	danb(*,*,i) = bytscl(da_norm(*,*,i), 25, 225)

endfor

save, da_norm, filename='da_norm_221194.sav'
save, danb, filename='danb_221194.sav'

; Now computing Running Difference

diffn = fltarr(sz[0],sz[1],sz[2]-1)

diffnb = diffn

for i=0,sz[2]-2 do begin

	diffn(*,*,i) = da_norm(*,*,i+1) - da_norm(*,*,i)

	diffnb(*,*,i) = bytscl( diffn(*,*,i), -10, 18)

endfor

szd = size(diffn, /dim)

; Creating maps but note the header isn't being edited (the times will be wrong)!

newin = in(0:szd[2]-1)

index2map, newin, diffn, maps

index2map, newin, diffnb, mapsb

szmap = size(maps.data, /dim)

loadct, 3

;For making the movie: temparr=fltarr(1051,852,szmap[2])

; Contour / Thresholding

for i=0,szd[2]-1 do begin

	mu = moment( diffn(50:200, 200:950, i), sdev=sdev)
	thresh = mu[0] + 3.*sdev
	;thresh_lwr = mu[0] - 3.*sdev

	;print, 'mu:' & print, mu
	;print, 'thresh:' & print, thresh

	set_line_color

	;plot_hist, diffn[50:200, 200:950, i], xr=[-10, 10] ; yr=[0,5000]
	;plots, [ mu[0], mu[0] ], [0,3000], color=3
	;plots, [ thresh, thresh ], [0,3000], color=5
	;plots, [ thresh_lwr, thresh_lwr ], [0,3000], color=5

	loadct, 3
	;plot_image, diffnb(*,*,i)

	contour, diffn(*,*,i), level=thresh, /over, path_info=info, $
		path_xy=xy, /path_data_coords, c_color=3, thick=2

	
	; Scaling the xy indices for map, lining up according to the Sun's centre.
	
	xy(0,*) = ( xy(0,*)-in[i].crpix1 ) * in[i].cdelt1
	xy(1,*) = ( xy(1,*)-in[i].crpix2 ) * in[i].cdelt2

	plot_map, mapsb[i]

	; plotting tangents from previous image
	if i ne 0 then begin	
		set_line_color
		plots, [0,x_new[0]],[0,y_new[0]], color=5
		plots, [0,x_new[szx_new]],[0,y_new[szy_new]], color=4	
	endif

	
	; Plotting the contours
	
	;plots, xy(*, info[0].offset : (info[0].offset + info[0].n -1) ), $
	;	linestyle=0, /data

	;plots, xy(*, info[1].offset : (info[1].offset + info[1].n -1) ), $
	;	linestyle=0, /data

	;plots, xy(*, info[2].offset : (info[2].offset + info[2].n -1) ), $
	;	linestyle=0, /data


	; This was attempt at fitting ellipse!

	;x1 = xy(0, info[0].offset : (info[0].offset + info[0].n -1))
	;y1 = xy(1, info[0].offset : (info[0].offset + info[0].n -1))

	;x1 = transpose(x1)
	;y1 = transpose(y1)

	;weights = 0.75/(4.0^2 + 0.1^2)

	;p = mpfitellipse(x1,y1)

	;phi = dindgen(101) * 2D * !dpi/100

	;plots, p(2)+p(0)*cos(phi), p(3)+p(1)*sin(phi)
	
	

; Transforming to polar coords for each case using recpol, and determining the midpoint in polar coords to transform back to cartesian and plot a line from sun centre to supposed CME apex

	recpol, xy(0,info[0].offset:(info[0].offset+info[0].n-1)), $
		xy(1,info[0].offset:(info[0].offset+info[0].n-1)), r, a, /degrees

	a = round(a)
	r = round(r)
	
	a_min = min(a)
	a_max = max(a)

	r_a_min = r(where(a eq min(a)))
	r_a_max = r(where(a eq max(a)))

	count = a_min
	stepsize = 1

	a_new = fltarr(a_max - a_min +1)
	r_new = fltarr(a_max - a_min +1)
	temp = 0
	
	while(count le a_max) do begin
		
		a_new(temp) = count
		r_new(temp) = max( r(where(a eq count)) )

		temp = temp + 1

		count = count + stepsize

	endwhile

	polrec, r_new, a_new, x_new, y_new, /degrees

	; plotting the CME front	
	plots, x_new, y_new

	; drawing circle of solar limb
	r_sun = pb0r(maps[i].time, /soho, /arcsec)
	draw_circle, 0, 0, r_sun[2]
	
	; drawing tangents to the CME edges
	plots, [0,x_new[0]], [0, y_new[0]]
	szx_new = size(x_new, /dim)
	szy_new = size(y_new, /dim)
	plots, [0,x_new[szx_new]], [0,y_new[szy_new]]

	
	;r_ave = (max(r)-min(r))/2. + min(r)


	; Drawing in line from centre to the edge I determined from diffn8 and messing with recpol
	;plots, [512.634,633.708], [505.293,87.651]


	; @outeredge.bat
	
; Drawing lines from contour edge to edge

	;a_int = a
	;sz=size(a,/dim)
	;for k=0,sz[1]-1 do begin 
	;        a_int(*,k)=fix(a(*,k))
	;endfor

	;plot, r, a_int

	;for i=0,13 do begin & $

	;window, /free &  plot_image, diffn(*,*,i) & $

	;for j=min(a_int),max(a_int) do begin
	;        sz1 = size(r(where(a_int eq j)),/dim)
	;        if sz1 gt 2 then begin
;			array1 = fltarr(1,sz1)
;			array1 = r(where(a_int eq j))
			
;			polrec, array1, j, xx, yy, /degrees
;			plots, xx, yy
;		endif
;	endfor																			
	;for making the movie
	;entry = tvrd()
	;print, size(entry,/dim)
	;temparr(*,*,i) = entry
	
	ans=''
	read, 'ok?', ans

endfor

;wr_movie, 'CME_front_id', temparr



end

