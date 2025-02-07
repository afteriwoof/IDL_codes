; Code which runs first part of CME_ellipse and takes the contours.

; Last Edited: 21-03-07

pro CME_contours, contours_x, contours_y


;fls = file_search('~/PhD/Data_from_Alex/18-apr-00/*.fts')
;fls = file_search('~/PhD/Data_from_James/010515/*.fts')

;mreadfits, fls, in, da
;save, da, filename='da.sav'
;save, in, filename='in.sav'
restore, '~/PhD/Data_sav_files/da.sav'
restore, '~/PhD/Data_sav_files/in.sav'

;restore, '~/PhD/Data_sav_files/da_221194.sav'
;restore, '~/PhD/Data_sav_files/in_221194.sav'


; Operations to be done on James's data
;c2data = where( in.detector eq 'C2' and in.naxis1 eq 1024)
;mreadfits, fls(c2data), in, c2data
;ssw_fill_cube2, c2data, da

;restore, '~/PhD/Data_sav_files/18apr2000.sav'

;restore, '~/PhD/Data_sav_files/in.sav'

; Convert INT array to FLOAT
da = float(da)

da_norm = da

danb = da

sz = size(da, /dim)


;for i=0,sz[2]-1 do begin
	
;	im = da(*,*,i)

	; Remove inner disk
;	rm_inner, im, in[i], dr, thr=2.2
	
	; Median operator to smooth noise pixels
;	da(*,*,i) = fmedian(im, 5, 3)

	; Normalising the data with regard to exposure time
;	da_norm(*,*,i) = da(*,*,i) / in[i].exptime

	; Bytscaling for image presentation only.
;	danb(*,*,i) = bytscl(da_norm(*,*,i), 25, 225)

;endfor

;save, da_norm, filename='da_norm.sav'
;save, danb, filename='danb.sav'

restore, '~/PhD/Data_sav_files/da_norm.sav'
restore, '~/PhD/Data_sav_files/danb.sav'

;restore, '~/PhD/Data_sav_files/da_norm_221194.sav'
;restore, '~/PhD/Data_sav_files/danb_221194.sav'


; Now computing Running Difference

diffn = fltarr(sz[0],sz[1],sz[2]-1)

diffnb = diffn

for i=0,sz[2]-2 do begin
	diffn[*,*,i] = da_norm[*,*,i+1] - da_norm[*,*,i]
endfor
pmm, diffn, mm=mm
for i=0,sz[2]-2 do begin
	diffnb[*,*,i] = bytscl( diffn[*,*,i], -10, 18)
endfor

szd = size(diffn, /dim)

; Creating maps but note the header isn't being edited (the times will be wrong)!

newin = in[0:szd[2]-1]

index2map, newin, diffn, maps

index2map, newin, diffnb, mapsb

szmap = size(maps.data, /dim)


;For making the movie: 
;temparr = fltarr(850, 800, szd[2])

; Contour / Thresholding

delvarx, da, da_norm, danb

; Number of contours
c = 3 

; Array to take coords of 30 points along CME front for each image.
front_arr_x = fltarr(31, c, szd[2])
front_arr_y = fltarr(31, c, szd[2])
front_arr_r = fltarr(31, c, szd[2])
front_vel = fltarr(31, c, szd[2]-1)
next_front = fltarr(31, c, szd[2]+1)

contours_x = fltarr(5000, c, szd[2])
contours_y = contours_x

for i=0,szd[2]-1 do begin
;for i=10,10 do begin
	
	mu = moment( diffn(50:200, 200:950, i), sdev=sdev)
	thresh = mu[0] + 6.*sdev

	set_line_color

	loadct, 0

	contour, diffn(*,*,i), level=thresh, /over, path_info=info, $
		path_xy=xy, /path_data_coords, c_color=3, thick=2

	xy_org = xy
	
	xy(0,*) = ( xy(0,*)-in[i].crpix1 ) * in[i].cdelt1
	xy(1,*) = ( xy(1,*)-in[i].crpix2 ) * in[i].cdelt2

	
	for k=0,c-1 do begin

		x_org = xy_org(0,info[k].offset:(info[k].offset+info[k].n-1))
		y_org = xy_org(1,info[k].offset:(info[k].offset+info[k].n-1))
		sz_x_org = size(x_org, /dim)
		sz_y_org = size(y_org, /dim)
		print, sz_x_org, sz_y_org
		contours_y[0:sz_y_org[1]-1, k, i] = y_org[*]
		contours_x[0:sz_x_org[1]-1, k, i] = x_org[*]
		help, contours_x, contours_y
		plot, contours_x, contours_y, psym=3
		ans=''
		;read, 'ok?', ans
	endfor
endfor

;**********
; So the contours are now assigned to the arrays contours_x and contours_y

bottom = contours_x[where(contours_y eq 0.), *, *]



end	
