; Code which produces normalised exposure time data array and byte-scaling of same from Alex's data 18-apr-2000.
; Also removes disk surrounding Solar disk.

; Multiscale analysis using canny atrous.

; Creating MAPS from the data and scaling contour values to maps coords.

; Made tangents to the CME edges and also lines at intervals of ten through CME angle.

; Obtains average point of CME front and deduces the apex.

; Derives width of CME from the maximum width close to the mid curve through ave. point.

; Sample attempt to fit an ellipse to the array of data points.

; Uses ellipse fit to average point of front to give start params for mpfitellipse.pro

; Last edited 15-05-07


pro CME_multiscale, tangents=tangents, previous=previous, lines=lines

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

dan = da

sz = size(da, /dim)

ans = ''

;for i=0,sz[2]-1 do begin

	; Remove inner disk
;	da[*,*,i] = rm_inner(da[*,*,i], in[i], dr_px, thr=2.2, plot=plot, fill=fill)

;	dan[*,*,i] = da[*,*,i] / in[i].exptime

;endfor

;save, dan, filename='dan.sav'

restore, '~/PhD/Data_sav_files/dan.sav'

;restore, '~/PhD/Data_sav_files/da_norm_221194.sav'


; Creating maps but note the header isn't being edited (the times will be wrong)!

index2map, in, dan, maps

szmap = size(maps.data, /dim)

;For making the movie: 
;temparr = fltarr(740, 705, sz[2])

; Contour / Thresholding

for i=0,sz[2]-1 do begin
;for i=4,5 do begin

	canny_atrous2d, dan[*,*,i], modgrad, alpgrad

	loadct, 0

	im = rm_inner((modgrad[*,*,3]+modgrad[*,*,4]+modgrad[*,*,5])/modgrad[*,*,0], in[i], dr_px, thr=2.6 )

	im = rm_outer(im, in[i], dr_px, thr=7.)

	im = rm_edges(im, in[i], dr_px, edge=25.)

;	im = modgrad[*,*,4] / modgrad[*,*,0]	

	plot_image, im^0.4

	read, 'ok?', ans

;	plot_image, bytscl(im, 0.5, 0.8)


	contour, im, lev=0.004, /over, path_info=info, $
		path_xy=xy, /path_data_coords, c_color=3, thick=2


	temp = fltarr(sz[0], sz[1])
	
	c = 10
	
	for k=0,c do begin
		
		x = xy[0,info[k].offset:(info[k].offset+info[k].n-1)]
		y = xy[1,info[k].offset:(info[k].offset+info[k].n-1)]

		plots, x, y	
	
		temp[x,y] = 1.
		
	endfor


	plot_image, temp
	
	;for making the movie
	;entry = tvrd()
	;print, size(entry,/dim)
	;temparr(*,*,i) = entry 
	
endfor

;wr_movie, 'multiscale_0_part', temparr





for i=0,sz[2]-1 do begin

;	mu = moment( dan[50:200, 200:950, i], sdev=sdev)
;	thresh = mu[0] + 6.*sdev

	set_line_color

	loadct, 0

	contour, dan[*,*,i], level=thresh, /over, path_info=info, $
		path_xy=xy, /path_data_coords, c_color=3, thick=2

	
	
	; Scaling the xy indices for map, lining up according to the Sun's centre.
	xy_org = xy
	
	xy[0,*] = ( xy[0,*]-in[i].crpix1 ) * in[i].cdelt1
	xy[1,*] = ( xy[1,*]-in[i].crpix2 ) * in[i].cdelt2

	plot_map, maps[i]


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
	c = 0 
	for k=0,c do begin

		x_org = xy_org[0,info[k].offset:(info[k].offset+info[k].n-1)]
		y_org = xy_org[1,info[k].offset:(info[k].offset+info[k].n-1)]
	
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

		plots, x_front, y_front
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
		
		width = fltarr(sz[2],c+1)
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
		fit = 'sqrt((p[0]^2*p[1]^2)/((p[0]^2+p[1]^2)/2-((p[0]^2-p[1]^2)/2)*cos(2*x-2*p[2])))'
		parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]},3)
		parinfo(*).value = [10*width[i,k], 10*width[i,k], 1.]
		param = mpfitexpr(fit, x, y, y*0.1, parinfo=parinfo, perror=perror, yfit=yfit)

		x_fit = x_front
		y_fit = y_front

	; MPFITELLIPSE	

		start_params = [param[0], param[1], xbar, ybar, param[2]]
	       	
		p = mpfitellipse(x_fit, y_fit, start_params, /tilt, weights=wts)
		phi = dindgen(101)*2D*!dpi/100
		
		x_ellipse = p[2]+p[0]*cos(phi)
		y_ellipse = p[3]+p[1]*sin(phi)
		
		; transform by swinging about the map centre:
		x_ellipse2 = x_ellipse*cos(p[4]) + y_ellipse*sin(p[4])
		y_ellipse2 = y_ellipse*cos(p[4]) - x_ellipse*sin(p[4])

		shift_xbar = p[2]*cos(p[4]) + p[3]*sin(p[4])
		shift_ybar = p[3]*cos(p[4]) - p[2]*sin(p[4])
		
		shift_factor_x = shift_xbar - p[2]
		shift_factor_y = shift_ybar - p[3]
		
		x_ellipse_new = x_ellipse2 - shift_factor_x
		y_ellipse_new = y_ellipse2 - shift_factor_y
	
		if p[0]	lt 12000 then begin
			if p[1] lt 12000 then begin
				plots, x_ellipse_new, y_ellipse_new
				plots, p[2], p[3], psym=2
			endif
		endif


	endfor

	
	;for making the movie
	;entry = tvrd()
	;print, size(entry,/dim)
	;temparr(*,*,i) = entry
	
	ans=''
	read, 'ok?', ans

endfor

;wr_movie, 'CME_ellipse_c0', temparr



end

