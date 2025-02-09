; Code which produces normalised exposure time data array and byte-scaling of same from Alex's data 18-apr-2000.
; Also removes disk surrounding Solar disk.

; This code uses fmedian before it applies the normalisation or bytscl.
; fmedian calls fmedian_slow which takes a long time to run!!!

; Creating MAPS from the data and scaling contour values to maps coords.

; Made tangents to the CME edges and also lines at intervals of ten through CME angle.

; Obtains average point of CME front and deduces the apex.

; Derives width of CME from the maximum width close to the mid curve through ave. point.

; Sample attempt to fit an ellipse to the array of data points.

; Uses ellipse fit to average point of front to give start params for mpfitellipse.pro

; Attempt to model where the CME front will be once it goes off the image edge

; Try to assign a prediction of velocity of the front off edge from the previous velocity before going off edge.

; Last edited 23-03-07


pro CME_offedge_frontonly, final_front_x, final_front_y, x_next, y_next, req_x_front, req_y_front, front_arr_x, front_arr_y, next_front, front_vel, front_arr_r, tangents=tangents, previous=previous, lines=lines

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
x_next = fltarr(28, c, szd[2]-1)
y_next = x_next
xy = fltarr(szd[2], c)
ans = ''

;**************************************
; Code from CME_contours.pro in order to determine the contours and assign them to arrays.

contours_x = fltarr(5000, c, szd[2])
contours_y = contours_x
contours_x_org = contours_x
contours_y_org = contours_x_org
req_x_front = fltarr(100, c, szd[2])
req_y_front = req_x_front

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
		;print, sz_x_org, sz_y_org
		contours_y_org[0:sz_y_org[1]-1, k, i] = y_org[*]
		contours_x_org[0:sz_x_org[1]-1, k, i] = x_org[*]
		;plot, contours_x, contours_y, psym=3
		x = xy(0,info[k].offset:(info[k].offset+info[k].n-1))
		y = xy(1,info[k].offset:(info[k].offset+info[k].n-1))
		sz_x = size(x, /dim)
		sz_y = size(y, /dim)
		contours_x[0:sz_x[1]-1, k, i] = x[*]
		contours_y[0:sz_y[1]-1, k, i] = y[*]
		
		;read, 'ok?', ans
;	endfor
;endfor

;******temp*****
; Sticking in the piece of code to get the fronts but only with a few necessary points (from the original main body below)
		
		recpol, x_org, y_org, r_org, a_org, /degrees

		
		x_map = xy(0,info[k].offset:(info[k].offset+info[k].n-1))
		y_map = xy(1,info[k].offset:(info[k].offset+info[k].n-1))
		recpol, x_map, y_map, r, a, /degrees

		a_max1 = max(a)
		a_min1 = min(a)

		a = round(a)
		r = round(r)

		a_max = max(a)
		a_min = min(a)

		a_front = fltarr(a_max - a_min +1)
		r_front = fltarr(a_max - a_min +1)
		temp = 0.
		count = a_min
		stepsize = 1.
		while(count le a_max) do begin
			a_front(temp) = count
			if(where(a eq count) eq [-1]) then goto, jump1
			r_front(temp) = max(r(where(a eq count)))
			jump1:
			temp = temp + 1
			count = count + stepsize
		endwhile

		polrec, r_front, a_front, x_front, y_front, /degrees

		; Average point of front

		sz_x_front = size(x_front, /dim)
		sz_y_front = size(y_front, /dim)
		sumx = 0.
		sumy = 0.
		count = 0.
		while(count lt sz_x_front[0]) do begin
			sumx = sumx + x_front[count]
			sumy = sumy + y_front[count]
			count = count + 1
		endwhile

		x_front_bar = sumx / sz_x_front[0]
		y_front_bar = sumy / sz_y_front[0]

;		plots, x_front, y_front
		;plots, x_front_bar, y_front_bar, psym=7
		
		recpol, x_front_bar, y_front_bar, r_bar, a_bar, /degrees
		r_a_bar = max(r(where(a eq round(a_bar))))
		polrec, r_a_bar, a_bar, x_apex, y_apex, /degrees
		;plots, x_apex, y_apex, psym=2	
		;print, 'apex:' & print, r_a_bar	


;******temp*********
set_line_color

			; Condition that once it meets the edge of the image it won't jump into the next front.
			count_x = 0
			count_y = 0
			unwanted_x = fltarr(sz_x_front[0]+1)
			unwanted_y = unwanted_x
			for j=0,sz_x_front[0]-1 do begin
				if j eq 0 then j_0 = sz_x_front[0]-1 else j_0 = j-1
				if j eq sz_x_front[0]-1 then j_n = 0 else j_n = j+1
				if abs(x_front[j_0]) gt 5900 then begin
					if abs(x_front[j_n]) gt 5900 then begin
						unwanted_x[count_x] = x_front[j]
						unwanted_y[count_x] = y_front[j]
						count_x = count_x+1
					endif
				endif
			endfor
			for j=0,sz_x_front[0]-1 do begin
				if j eq 0 then j_0 = sz_x_front[0]-1 else j_0 = j-1
				if j eq sz_x_front[0]-1 then j_n = 0 else j_n = j+1
				if abs(y_front[j_0]) gt 5900 then begin
					if abs(y_front[j_n]) gt 5900 then begin
						unwanted_x[count_y] = x_front[j]
						unwanted_y[count_y] = y_front[j]
						count_y = count_y+1
					endif
				endif
			endfor

			nonzeros = where(unwanted_x[*] ne 0.)
			if nonzeros[0] ne -1 then begin
				unwanted_x = unwanted_x(where(unwanted_x[*] ne 0.))
				unwanted_y = unwanted_y(where(unwanted_y[*] ne 0.))			
			endif	
				
;			plot_map, mapsb[i]
;			plots, x_front, y_front
;			plots, unwanted_x, unwanted_y, psym=-7, color=7
		
			sz_unwanted_x = size(unwanted_x, /dim)
			sz_unwanted_y = size(unwanted_y, /dim)
			new_x_front = fltarr(sz_x_front[0])
			new_y_front = new_x_front
			count = 0
			true = 0
			false = 0
			; Using the unwanted bits, take a new array of the front which ignores all points between unwanted ones.
			for j=0,sz_x_front[0]-1 do begin
				for l=0,sz_unwanted_x[0]-1 do begin
					if round(x_front[j]) ne round(unwanted_x[l]) then begin
						true = 1
					endif else begin
						false = 1
					endelse
				endfor
				if false eq 0 then begin
					new_x_front[count] = x_front[j]
					new_y_front[count] = y_front[j]
					count = count+1
				endif
				false = 0
			endfor
			
			
;			plots, new_x_front, new_y_front, psym=5, color=2
				
			new_x_front = new_x_front(where(new_x_front[*] ne 0.))
			new_y_front = new_y_front(where(new_y_front[*] ne 0.))
;			plots, new_x_front, new_y_front, psym=-5, color=2
			
			sz_new_x_front = size(new_x_front, /dim)
			
		req_x_front[0:sz_new_x_front[0]-1, k, i] = new_x_front[*]
		req_y_front[0:sz_new_x_front[0]-1, k, i] = new_y_front[*]	
		
			;read, 'go?', ans
endfor
endfor
;***************************************



; On with the rest of the code now...

for i=0,szd[2]-1 do begin
;for i=7,10 do begin
	
	mu = moment( diffn(50:200, 200:950, i), sdev=sdev)
	thresh = mu[0] + 6.*sdev

	set_line_color

	loadct, 0

	contour, diffn(*,*,i), level=thresh, /over, path_info=info, $
		path_xy=xy, /path_data_coords, c_color=3, thick=2

	
	
	; Scaling the xy indices for map, lining up according to the Sun's centre.
	xy_org = xy
	
	xy(0,*) = ( xy(0,*)-in[i].crpix1 ) * in[i].cdelt1
	xy(1,*) = ( xy(1,*)-in[i].crpix2 ) * in[i].cdelt2

;	plot_map, mapsb[i]


	; plotting tangents from previous image, only if keyword tangents is also set.
	if keyword_set(previous) then begin
		if i ne 0 then begin	
			set_line_color
			plots, [0,x_apex], [0,y_apex], color=3
			plots, [0,x_edge1],[0,y_edge1], color=5
			plots, [0,x_edge2],[0,y_edge2], color=4	
		endif
	endif


	; Increase c to include more contours
	for k=0,c-1 do begin

		x_org = xy_org(0,info[k].offset:(info[k].offset+info[k].n-1))
		y_org = xy_org(1,info[k].offset:(info[k].offset+info[k].n-1))

		
		
;***************************************************
		; Calling function ellipsefit.pro to plot ellipse	
		ellipse = ellipsefit(x_org, y_org)
		aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
		bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
	
		aprime = (aprime-in[i].crpix1) * in[i].cdelt1
		bprime = (bprime-in[i].crpix2) * in[i].cdelt2 
		x_bar_org = ellipse[size(ellipse,/dim)-2]
		y_bar_org = ellipse[size(ellipse,/dim)-1]
		x_bar = (x_bar_org-in[i].crpix1) * in[i].cdelt1
		y_bar = (y_bar_org-in[i].crpix2) * in[i].cdelt2	
		set_line_color
;		plots, aprime, bprime, color=2 ;plots my ellipse
;		plots, x_bar, y_bar, psym=4	
;****************************************************


		recpol, x_org, y_org, r_org, a_org, /degrees

		
		x_map = xy(0,info[k].offset:(info[k].offset+info[k].n-1))
		y_map = xy(1,info[k].offset:(info[k].offset+info[k].n-1))
		recpol, x_map, y_map, r, a, /degrees

		a_max1 = max(a)
		a_min1 = min(a)

		a = round(a)
		r = round(r)

		a_max = max(a)
		a_min = min(a)

		a_front = fltarr(a_max - a_min +1)
		r_front = fltarr(a_max - a_min +1)
		temp = 0.
		count = a_min
		stepsize = 1.
		while(count le a_max) do begin
			a_front(temp) = count
			;if(where(a eq count) eq [-1]) then goto, jump1
			r_front(temp) = max(r(where(a eq count)))
			;jump1:
			temp = temp + 1
			count = count + stepsize
		endwhile

		polrec, r_front, a_front, x_front, y_front, /degrees

		; Average point of front

		sz_x_front = size(x_front, /dim)
		sz_y_front = size(y_front, /dim)
		sumx = 0.
		sumy = 0.
		count = 0.
		while(count lt sz_x_front[0]) do begin
			sumx = sumx + x_front[count]
			sumy = sumy + y_front[count]
			count = count + 1
		endwhile

		x_front_bar = sumx / sz_x_front[0]
		y_front_bar = sumy / sz_y_front[0]

;		plots, x_front, y_front
		;plots, x_front_bar, y_front_bar, psym=7
		
		recpol, x_front_bar, y_front_bar, r_bar, a_bar, /degrees
		r_a_bar = max(r(where(a eq round(a_bar))))
		polrec, r_a_bar, a_bar, x_apex, y_apex, /degrees
		;plots, x_apex, y_apex, psym=2	
		;print, 'apex:' & print, r_a_bar	

;*****************************************************************
		
		; Find the width of my first CME fit used in start params of mpfitellipse.pro

		n = 30
		count = 1
		sign = 0
		crossing = where(r eq round(r_bar))
		range = [crossing]
		while (size(range, /dim) lt n) do begin
			if sign mod 2 eq 0 then crossings = where(r eq round(r_bar)+count)
			if sign mod 2 eq 1 then crossings = where(r eq round(r_bar)-count)
			range = [range, [crossings]]
			count = count + 1
			sign = sign + 1
		endwhile

		a_width = max(a(range)) - min(a(range))
		polrec, r_bar, max(a(range)), x_width1, y_width1, /degrees
		polrec, r_bar, min(a(range)), x_width2, y_width2, /degrees
		
		; These plots show the initial width approximation from first ellipse fit.
		;plots, x_width1, y_width1, psym=7
		;plots, x_width2, y_width2, psym=7
		;plots, [x_width1,x_width2], [y_width1,y_width2], color=8
		
		width = fltarr(szd[2],c+1)
		;slope_width = (y_width2 - y_width1) / (x_width2 - x_width1)
		width[i,k] = sqrt((y_width2 - y_width1)^2 + (x_width2 - x_width1)^2)
		;print, 'width:' & print, width

;*****************************************************************

	;********
		; drawing circle of solar limb
		r_sun = pb0r(maps[i].time, /soho, /arcsec)
		draw_circle, 0, 0, r_sun[2]
	
	;********
	
		; drawing tangents to the CME edges
		if keyword_set(tangents) then begin
			loadct, 0
			;plotting lines to points of width
			;plots, [0,x_width1], [0,y_width1]
			;plots, [0,x_width2], [0,y_width2]
			;plotting line to apex
			;plots, [0,x_apex], [0,y_apex]
			slope1 = sqrt((y_front[0] / x_front[0])^2)
			y_edge1 = (in[i].naxis2 - in[i].crpix2) * in[i].cdelt2
			x_edge1 = y_edge1/slope1
			if y_front[0] lt 0 then begin
				y_edge1 = -y_edge1
				if x_front[0] lt 0 then begin
					x_edge1 = -x_edge1
				endif
			endif else begin
				if x_front[0] lt 0 then begin
					x_edge1 = -x_edge1
				endif
			endelse
			plots, [0,x_edge1], [0,y_edge1]		
			;plots, [0,x_new[0]], [0, y_new[0]]
		
			szx_front = size(x_front, /dim)
			szy_front = size(y_front, /dim)
		
			slope2 = sqrt((y_front[szy_front] / x_front[szx_front])^2)
       		 	y_edge2 = (in[i].naxis2 - in[i].crpix2) * in[i].cdelt2
       		 	x_edge2 = y_edge2/slope2
       		 	if y_front[szy_front] lt 0 then begin
       		        	y_edge2 = -y_edge2
       		        	if x_front[szx_front] lt 0 then begin
       		                	x_edge2 = -x_edge2
       		         	endif   
		       	endif else begin
		                if x_front[szx_front] lt 0 then begin
       		         	        x_edge2 = -x_edge2
       		         	endif   
      	 	 	endelse
        		plots, [0,x_edge2], [0,y_edge2]
			;plots, [0,x_front[szx_front]], [0,y_front[szy_front]]
		endif


		; plotting N angle lines along CME
		;if keyword_set(lines) then begin
			dist = a_max1 - a_min1
			n = 30.
			steps = dist / n
			angles = fltarr(n+1)
			r_angles = fltarr(n+1)
			r_mid = fltarr(n+1)
			r_front = fltarr(n+1)
			count = a_min1
			temp = 0
			;print, angles
			;print, temp
			;print, count
			;print, steps
			;print, a_max1	
			while(count le a_max1) do begin
				angles(temp) = count
				if(where(a eq round(count)) eq [-1]) then goto, jump2
				r_angles(temp) = max(r(where(a eq round(count)))) 
				jump2:
				r_mid(temp) = r_bar
				r_front(temp) = r_a_bar
				temp = temp + 1
				count = count + steps
			endwhile		
			r_mid = r_mid(where(r_mid ne 0))	
			polrec, r_angles, angles, x_step, y_step, /degrees
			polrec, r_mid, angles, x_mid, y_mid, /degrees
			polrec, r_front, angles, x_front2, y_front2, /degrees
			;plots, x_front2, y_front2	
	;		plots, x_mid, y_mid
			szx_step = size(x_step, /dim)
	
		; Taking the front data into front_arr
		front_arr_x[*, k, i] = x_step
		front_arr_y[*, k, i] = y_step
		front_arr_r[*, k, i] = r_angles
		
		if keyword_set(lines) then begin	
			for j=0,szx_step[0]-1 do begin
				loadct, 0
				plots, [0,x_step[j]],[0,y_step[j]]
			endfor
		endif


;*****************************************************************
;               Using the average point of the front coords (scaled to origin) 
;		to find the fit given by MPFITFUN for inclined ellipse equation.

		xbar = (x_bar_org[0]-in[i].crpix1) * in[i].cdelt1
		ybar = (y_bar_org[0]-in[i].crpix2) * in[i].cdelt2
		x0 = x_front - xbar
		y0 = y_front - ybar
		recpol, x0, y0, y, x
		radiusbar = sqrt(xbar^2+ybar^2)
		fit = 'sqrt((p(0)^2*p(1)^2)/((p(0)^2+p(1)^2)/2-((p(0)^2-p(1)^2)/2)*cos(2*x-2*p(2))))'
		parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]},3)
		parinfo(*).value = [10*width[i,k], 10*width[i,k], 1.]
		param = mpfitexpr(fit, x, y, y*0.1, parinfo=parinfo, perror=perror, yfit=yfit)

		x_fit = x_front
		y_fit = y_front

	; MPFITELLIPSE	

		start_params = [param[0], param[1], xbar, ybar, param[2]]
	       	
		p = mpfitellipse(x_fit, y_fit, start_params, /tilt, weights=wts)
		phi = dindgen(101)*2D*!dpi/100
		
		x_ellipse = p(2)+p(0)*cos(phi)
		y_ellipse = p(3)+p(1)*sin(phi)
		
		; transform by swinging about the map centre:
		x_ellipse2 = x_ellipse*cos(p(4)) + y_ellipse*sin(p(4))
		y_ellipse2 = y_ellipse*cos(p(4)) - x_ellipse*sin(p(4))

		shift_xbar = p(2)*cos(p(4)) + p(3)*sin(p(4))
		shift_ybar = p(3)*cos(p(4)) - p(2)*sin(p(4))
		
		shift_factor_x = shift_xbar - p(2)
		shift_factor_y = shift_ybar - p(3)
		
		x_ellipse_new = x_ellipse2 - shift_factor_x
		y_ellipse_new = y_ellipse2 - shift_factor_y
	
		if p(0)	lt 12000 then begin
			if p(1) lt 12000 then begin
;				plots, x_ellipse_new, y_ellipse_new
;				plots, p(2), p(3), psym=2
			endif
		endif

	;**************************
	; Computing the velocities of the front from the difference in the front_arr_r for each image.

		if i ne 0 then begin
			front_vel[*, k, i-1] = front_arr_r[*, k, i] - front_arr_r[*, k, i-1]

			;***************
			; Postulate where the next front (off the edge) would be!
			next_front[*, k, i+1] = front_arr_r[*, k, i] + front_vel[*, k, i-1]

			polrec, next_front[1:n-2,k,i+1], angles[1:n-2], x_next_temp, y_next_temp, /degrees
;			plots, x_next_temp, y_next_temp
			x_next[*,k,i-1] = [x_next_temp]
			y_next[*,k,i-1] = [y_next_temp]
	
;			plots, x_next[*,k,i-1], y_next[*,k,i-1], color=2, psym=2

	;	read, 'go?', ans
			;**************************


		


		endif
	

	endfor

	;***********************
	
	
	;for making the movie
	;entry = tvrd()
	;print, size(entry,/dim)
	;temparr(*,*,i) = entry
	
	;read, 'ok?', ans

endfor



;*****
; Try to set the condition that if the front goes off the edge then the predicted next front should be taken by the previous velocity only.
new_next_front = fltarr(31, c, szd[2]+1)
new_x_next = fltarr(28, c, szd[2]-1)
new_y_next = new_x_next
true0 = 0
for i=0,szd[2]-1 do begin
	for k=0,c-1 do begin
		if i ne 0 then begin
		if max(abs(front_arr_x[*,k,(i+1) mod 13])) gt 5900 then true0=0
		if true0 eq 1 then begin
			last_vel = front_vel[*,k,i-1]
			print, 'last_vel:' & print, last_vel
			read, 'vels ok?', ans
		endif
		endif
	endfor
endfor
true0 = 0
false0 = 0
for i=0,szd[2]-1 do begin
	plot_map, mapsb[i]
	for k=0,c-1 do begin
		plots, front_arr_x[*,k,i], front_arr_y[*,k,i]
		if i ne 0 then begin
		plots, x_next[*,k,i-1], y_next[*,k,i-1]
		if max(abs(front_arr_y[*,k,(i+1) mod 13])) gt 5990 then true0 = 1
		if true0 eq 1 then begin
			if false0 ne 1 then begin
			last_vel = front_vel[*,k,i-1]
			new_next_front[*,k,i] = front_arr_r[*,k,i]
			endif
			print, 'last_vel:' & print, last_vel
			print, k, i
			false0 = 1
			;************
			; DOESN'T WORK BECAUSE THE K CONTOURS CHANGE ONCE IT GOES OFF EDGE!!!
			;************
			new_next_front[*,k,i+1] = new_next_front[*,k,i] + last_vel
			read, 'vels ok?', ans
		endif
		polrec, new_next_front[1:n-2,k,i+1], angles[1:n-2], x_next_temp, y_next_temp, /degrees
		new_x_next[*,k,i-1] = [x_next_temp]
		new_y_next[*,k,i-1] = [y_next_temp]
		plots, new_x_next[*,k,i-1], new_y_next[*,k,i-1], psym=-2, color=2
		read, 'huh?', ans
		endif
	endfor
endfor
true0 = 0
		
		

;*****


;wr_movie, 'CME_ellipse_c0', temparr

stop

;***********************************************************************************************

; Now that I've gone through once assigning the arrays I'll work with off-edge contours.

final_front_x = fltarr(100, c, szd[2])
final_front_y = final_front_x

;****
; temp look at the next front plots
for i=0,szd[2]-2 do begin
	plot_map, mapsb[i]
	for k=0,c-1 do begin
		if i ne 0. then begin
			plots, x_next[*,k,i], y_next[*,k,i]
	;		read, 'on with it?', ans
		endif
	endfor
endfor


for i=0,szd[2]-2 do begin

	for k=0,c-1 do begin
		
		;***********************
		; Taking the contours which are close to where the predicted next_front would be.
		if i ne 0. then begin
		
			if max(abs(y_next[*,*,i-1])) gt 5900 then begin
		
				loadct, 0
			
				;relevant_x = contours_x[*,*,i+1]
				;relevant_y = contours_y[*,*,i+1]
				;plot, relevant_x, relevant_y, psym=3
				relevant_x = front_arr_x[*,k,i+1]
				relevant_y = front_arr_y[*,k,i+1]
				;*********
				; So with the relevant contours, determine which are the fronts I want.
				plot_map, mapsb[i+1]
				set_line_color
				plots, relevant_x, relevant_y, psym=2, color=2
				plots, x_next[*,*,i-1], y_next[*,*,i-1], psym=4, color=4
;				read, 'good?', ans
				;print, relevant_x, relevant_y

				sz_tempx = size(front_arr_x[*,k,i+1])
				sz_tempy = size(front_arr_y[*,k,i+1])
;				true = 0
;				for j=0,sz_tempx[1]-1 do begin
;					if abs(front_arr_x[j,k,i+1]) gt 5900. then true = 1
;				endfor
;					if true eq 1 then begin
;						offedge_x = front_arr_x[*,k,i+1]
;						offedge_y = front_arr_y[*,k,i+1]
;						print, 'x offedge'
;						print, offedge_x, offedge_y
;						plot, offedge_x, offedge_y, color=5
;						read, 'ok1?', ans
;					endif
;					
				true = 0
				for j=0,sz_tempx[1]-1 do begin
					if abs(front_arr_y[j,k,i+1]) gt 5800. then true = 1
				endfor
					if true eq 1 then begin	
;					; These are the contours which are part of the front that's now off the edge.
;						set_line_color
;						; x_next, y_next being the forward modelled front from previous velocities.
						plots, req_x_front[*,k,i+1], req_y_front[*,k,i+1], psym=-6, color=6
						;plots, req_x_front[*,*,i+1], req_y_front[*,*,i+1], psym=-5, color=5
						print, 'k i' & print, k, i
;						read, 'again?', ans
;						; These are the points of the next contours which lie within the image.
;						y_next_notoff = y_next[where(abs(y_next[*,0,i-1]) lt 5900),0,i-1]
;						x_next_notoff = x_next[where(abs(y_next[*,0,i-1]) lt 5900),0,i-1]
;;						plots, x_next_notoff, y_next_notoff, psym=-6, color=4
;						
;						; And obtain the points of the contour which lie within the image (not on edge).
;						within_edge_y = offedge_y[where(abs(offedge_y) lt 5900)]
;						within_edge_x = offedge_x[where(abs(offedge_y) lt 5900)]
;;						plots, within_edge_x, within_edge_y, psym=-4, color=3
;
;;						plots, req_x_front[*,*,i+1], req_y_front[*,*,i+1], psym=6, color=6				
						sz_x_next = size(x_next, /dim)
						sz_reqx = size(req_x_front, /dim)
						thresh=300.
						true2 = 0
						final_x = fltarr(sz_reqx[0])
						final_y = final_x
						for m=0,sz_reqx[0]-1 do begin
;							if req_x_front[m,k,i+1] ne 0. then begin
								reqx = req_x_front[m,k,i+1]
								reqy = req_y_front[m,k,i+1]
								for n=0,c-1 do begin
								for l=0,sz_x_next[0]-1 do begin
									x = x_next[l,n,i-1]
									y = y_next[l,n,i-1]
;									print, reqx, reqy, x, y
;									;***
									plots, x_next[l, n, i-1], y_next[l, n,i-1], psym=-7, color=7
									plots, req_x_front[m,k,i+1], req_y_front[m,k,i+1], psym=6;, color=6
									;***
									distance = sqrt((reqx-x)^2+(reqy-y)^2)
;									print, 'distance' & print, distance
									if distance lt thresh then true2 = 1
									print, 'true2' & print, true2
								endfor
								;read, 'roish?', ans
								endfor
;							endif
;							print, 'true2:' & print, true2
							if true2 eq 1 then begin
								final_x[m] = reqx
								final_y[m] = reqy
								true2 = 0
							endif
;
;							print, final_x, final_y
							plots, final_x, final_y, psym=-7, color=8
;						
;							print, k, i	
							final_front_x[*,k,i] = [final_x]
							final_front_y[*,k,i] = [final_y]
;							read, 'y?', ans
						endfor
;
;						read, 'ok2?', ans
					endif
;			
;					
;					
;				;endfor
;				
			endif

		endif

	endfor

endfor




; New loop just to see the stuff I've done above.

for i=0,szd[2]-2 do begin

	plot_map, mapsb[i]
	
	for k=0,c-1 do begin

		plots, final_front_x[*,k,i], final_front_y[*,k,i]
		
;		if i ne 0 then begin
		
			;plot, x_next[*, k, i-1], y_next[*, k,i-1], psym=-5, color=5
;			plot, req_x_front[*,k,i+1], req_y_front[*,k,i+1], yr=[-6000,0], xr=[-3000, 6000], psym=-2, color=2
;			plots, x_next[*, k, i-1], y_next[*, k,i-1], psym=-5, color=5
			
;		endif

		read, 'go on?', ans

	endfor

endfor

;plot, x_next[*,0,8], y_next[*,0,8], xr=[-6000,6000], yr=[-8000,0],psym=-2, color=2
;plots, req_x_front[*,*,10], req_y_front[*,*,10], psym=4, color=4

;print, final_front_x, final_front_y

end

