; Batch file to accompany the writing of mapcontours.pro

; Last Edited: 20-02-07


;fls = file_search('~/PhD/Data_from_Alex/18-apr-00/*.fts')

;mreadfits, fls, in, da 
restore, 'da.sav'
restore, 'in.sav'

da = float(da)

da_norm = da
danb = da
sz = size(da, /dim)

;for i=0,sz[2]-1 do begin & $

;	im = da(*,*,i) & $

;	rm_inner, im, in[i], dr, thr=2.1 & $

;	da(*,*,i) = fmedian(im,5,3) & $

;	da_norm(*,*,i) = da(*,*,i) / in[i].exptime & $
	
;	danb(*,*,i) = bytscl(da_norm(*,*,i), 25, 225) & $

;endfor

restore, 'da_norm.sav'
restore, 'danb.sav'

diffn = fltarr(sz[0],sz[1],sz[2]-1)
diffnb = diffn

for i=0,sz[2]-2 do begin & $

	diffn(*,*,i) = da_norm(*,*,i+1) - da_norm(*,*,i) & $

	diffnb(*,*,i) = bytscl(diffn(*,*,i), -10, 18) & $

endfor

newin = in(0:13)

index2map, newin, diffn, maps

index2map, newin, diffnb, mapsb

szd = size(diffn, /dim)

;loadct, 3

;for i=0,szd[2]-1 do begin & $
for i=8,8 do begin & $

	mu = moment( diffn(50:200, 200:950, i), sdev=sdev ) & $
	thresh = mu[0] + 3.*sdev & $

	contour, diffn(*,*,i),level=thresh,/over,path_info=info,path_xy=xy,/path_data_coords,c_color=3,thick=2 & $

	xy_org = xy & $
	
	xy(0,*) = ( xy(0,*)-in[i].crpix1 ) * in[i].cdelt1 & $
	xy(1,*) = ( xy(1,*)-in[i].crpix2 ) * in[i].cdelt2 & $

	plot_map, mapsb[i] & $

	;plots, xy(*,info[0].offset:(info[0].offset+info[0].n -1)),linestyle=0,/data & $
	;plots, xy(*,info[1].offset:(info[1].offset+info[1].n -1)),linestyle=0,/data & $

		k = 0 & $
                ; Plot the centre average point of the front
                x = xy_org(0,info[k].offset:(info[k].offset+info[k].n-1)) & $
                y = xy_org(1,info[k].offset:(info[k].offset+info[k].n-1)) & $

                sz_x = size(x,/dim) & $
                sz_y = size(y,/dim) & $
                sumx = 0. & $
                sumy = 0. & $
                count = 0. & $
                while(count lt sz_x[1]) do begin & $
                        sumx = sumx + x[count] & $
                        sumy = sumy + y[count] & $
                        count = count + 1 & $
                endwhile & $
                x_bar = sumx / sz_x[1] & $
                y_bar = sumy / sz_y[1] & $
                
		x_bar = (x_bar-in[i].crpix1 ) * in[i].cdelt1 & $
                y_bar = (y_bar-in[i].crpix2 ) * in[i].cdelt2 & $
       

                ; Obtain slope and perpendicular to find width
                slope = y_bar/x_bar
                slope_perp = -1./slope
                c = y_bar - slope_perp*x_bar
                ;plots, [0,x_bar], [c,y_bar]
	
         
		; Plotting the average point
                plots, x_bar, y_bar, psym=2 & $

                ; Find the angle of the average point and deduce the apex at this angle.
                recpol, x_bar, y_bar, r_bar, a_bar, /degrees & $
                print, 'r_apex:' & print, r_bar & $


	recpol, xy(0,info[0].offset:(info[0].offset+info[0].n-1)), xy(1,info[0].offset:(info[0].offset+info[0].n-1)), r, a, /degrees & $

	a_max1 = max(a)
	a_min1 = min(a)

	a = round(a)
	r = round(r)

 tol = 2
        lwr = round(r_bar) - tol
        upr = round(r_bar) + tol
        r_range = r
        a_range = a
        r_range(where(r_range lt lwr)) = 0
        r_range(where(r_range gt upr)) = 0
        a_range = a(where(r eq r_range))
 
	a_bar_max = max(a(where(r_range ne 0)))	
	a_bar_min = min(a(where(r_range ne 0)))
	
	a_min = min(a) & $
	a_max = max(a) & $

	r_a_min = r(where(a eq min(a))) & $
	r_a_max = r(where(a eq max(a))) & $
	r_a_bar = max(r(where(a eq round(a_bar)))) & $
	
	count = a_min & $
	stepsize = 1 & $

	a_new = fltarr(a_max-a_min+1) & $
	r_new = fltarr(a_max-a_min+1) & $
	temp = 0 & $

	while(count le a_max) do begin & $
	
		a_new(temp) = count & $
        	r_new(temp) = max(r(where(a eq count))) & $

        	temp = temp + 1 & $

        	count = count + stepsize & $

	endwhile & $

	polrec, r_new, a_new, x_new, y_new, /degrees & $
	plots, x_new, y_new & $

	polrec, r_a_bar, a_bar, x_apex, y_apex, /degrees & $
	plots, x_apex, y_apex, psym=4 & $
	print, 'apex(x,y):' & print, x_apex, y_apex & $

	r_sun = pb0r(maps[i].time, /soho, /arcsec) & $
	draw_circle, 0, 0, r_sun[2] & $

	plots, [0,x_new[0]], [0,y_new[0]] & $
	szx_new = size(x_new, /dim) & $
	szy_new = size(y_new, /dim) & $
	plots, [0,x_new[szx_new]],[0,y_new[szy_new]] & $

	; Equation of a line
	slope1 = y_new[0] / x_new[0]
	y_edge = in[i].naxis2 * in[i].cdelt2
	


	dist = a_max1 - a_min1 & $
	n = 30.
	steps = (dist / n) & $
	angles = fltarr(n+1) & $
	r_angles = fltarr(n+1) & $
	r_mid = fltarr(n+1) & $
	count = a_min1 & $
	temp = 0 & $
	while(count le a_max1) do begin & $
		angles(temp) = count & $
		r_angles(temp) = max(r(where(a eq round(count)))) & $
		r_mid(temp) = r_bar & $
		temp = temp + 1 & $
		count = count + steps & $
	endwhile & $

	polrec, r_angles, angles, x_step, y_step, /degrees & $
	polrec, r_mid, angles, x_mid, y_mid, /degrees & $
	plots, x_mid, y_mid & $

	szx_step = size(x_step, /dim) & $
	for j=0,szx_step[0]-1 do begin & $
		plots, [0,x_step[j]],[0,y_step[j]] & $
	endfor & $

	
; Try to find where the mid curve hits the CME contour front

	tol = 200. & $
	upr = r_bar + tol & $
	lwr = r_bar - tol & $
	allow = upr - lwr & $
	temp = 0.
	sz_r_new = size(r_new, /dim) & $
	cross = fltarr(sz_r_new) & $
	for j=0,sz_r_new[0]-2 do begin & $
		diff = abs(r_new[j] - r_bar) & $
		if diff le allow then begin & $
			if j ne 0 then begin & $
			if diff le temp then begin & $
				cross[j] = r_new[j] & $
			endif & $
			endif else cross[j] = r_new[j] & $
			temp = diff & $
		endif & $
	endfor & $
	
	a_cross = a_new(where(cross ne 0)) & $
	sz_a_cross = size(a_cross, /dim) & $
	diff_cross = fltarr(sz_a_cross[0]-1) & $
	for j=0,sz_a_cross[0]-2 do begin & $
		diff_cross[j] = a_cross[j+1] - a_cross[j] & $
	endfor & $
	max_pos = where(diff_cross eq max(diff_cross)) & $
	a_min_cross = a_cross[max_pos] & $
	a_max_cross = a_cross[max_pos+1] & $	
	r_min_cross = r_new(where(a_new eq a_min_cross[0])) & $	
	r_max_cross = r_new(where(a_new eq a_max_cross[0])) & $
	polrec, r_min_cross, a_min_cross, x1_cross, y1_cross, /degrees & $
	polrec, r_max_cross, a_max_cross, x2_cross, y2_cross, /degrees & $
	
	count = 0 & $
	for j=0,sz_r_new[0]-2 do begin & $
		if count eq 0 then begin & $
			if r_bar gt r_new[j] then begin & $
				if r_bar lt r_new[j+1] then begin & $
					left1 = r_new[j] & $
					right1 = r_new[j+1] & $
					count = 1 & $
				endif & $
			endif & $ 
		endif else begin & $
			if r_bar gt r_new[j] then begin & $
				if r_bar lt r_new[j+1] then begin & $
					left2 = r_new[j] & $
					right2 = r_new[j+1] & $
				endif & $
			endif & $
		endelse & $
	endfor & $
end	

	







