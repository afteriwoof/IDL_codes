; This is edited for doing the CME analysis of the point&click events from Dave's waves.

; Code to read in the CME front and fit an ellipss, taking out the kinematics.

; This is the Best code I have for the most correct ellipse information.

; This code is called by ell_kinematics.pro which allows an array to be read in together.

; Created: 14-01-09 from front_ell_kinematics.pro
; Last Edited: 19-01-09
; Last Edited: 16-03-09 to include the arcsec keyword when x and y are in arcseconds already.

pro front_ell_kins, x, y, errs, in, da, ang, ell_info, r_err, x_ellipse, y_ellipse, perror, max_h_front, apex_a, noplot, noflank=noflank, arcsec=arcsec

	noplot=0

	ans = ''
	angans=''
	
	;im = image
	
	;front = where(im ne 0)
	;ind = array_indices(im, front)
	;x = ind[0,*]
	;y = ind[1,*]


	
	if in.instrume eq 'SECCHI' then begin
		map = mk_secchi_map(in,sigrange(da))
		; calculating the centre of the Sun in the pixel space coords
		x_pixel_offset = in.xcen / in.cdelt1
		y_pixel_offset = in.ycen / in.cdelt2
		x_sun_center = ( in.naxis1 ) / 2. - x_pixel_offset
		y_sun_center = ( in.naxis2 ) / 2. - y_pixel_offset
		x_map = (x-x_sun_center)*in.cdelt1
		y_map = (y-y_sun_center)*in.cdelt2
		;x_map = (x-in.crpix1)*in.cdelt1
		;y_map = (y-in.crpix2)*in.cdelt2
	endif else begin
		index2map, in, sigrange(da), map
		x_map = (x-in.crpix1)*in.cdelt1
		y_map = (y-in.crpix2)*in.cdelt2
	endelse
	
	if keyword_set(arcsec) then begin
		x_map = x
		y_map = y
	endif
	plot_map, map, /limb
	plots, x_map, y_map, psym=1

	;******
	; Take only a number of points across the front
	; though it's commented out below because I now take all front points for more accuracy.
	recpol, x_map, y_map, r, a, /degrees

	if keyword_set(noflank) then begin
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
		while (count le a_max) do begin
			a_front[temp] = count
			if (where(a eq count) eq [-1]) then goto, jump1
			r_front[temp] = max(r[where(a eq count)])
			jump1:
			temp = temp + 1
			count = count + stepsize
		endwhile
		plot_map, map, /limb
		polrec, r_front, a_front, x_front, y_front, /degrees
	endif else begin
		x_front = fltarr(n_elements(x_map))
		y_front = x_front
		if n_elements(size(x_map,/dim)) gt 1 then x_front[0:*] = x_map[0,0:*] else x_front=x_map
		if n_elements(size(x_map,/dim)) gt 1 then y_front[0:*] = y_map[0,0:*] else y_front=y_map
		plot_map, map, /limb

	endelse
	
	non_zero_front, x_front, y_front, xnf, ynf
	x_front=xnf
	y_front=ynf
	plots, x_front, y_front, psym=1;, color=2;yellow

	; drawing circle of solar limb <-- unnecessary if I use plot_map, /limb
       	;if ~keyword_set(secchi) then do begin
	;	r_sun = pb0r(map.time, /arcsec)
        ;	draw_circle, 0, 0, r_sun[2]
	;endif
	; messin with solar grid
	;plot_helio, in.date_d$obs, roll=in.crota, /over
	
	
	; Take only the points that I deem part of the front
	sz_xf = size(x_front, /dim)
	sz_yf = size(y_front, /dim)
	my_xfront = fltarr(sz_xf[0])
	my_yfront = fltarr(sz_yf[0])
	count = 0
	read, 'Specify front? y/n ', ans
	;ans = 'n'
	if ans eq 'n' then begin
		for i=0,sz_xf[0]-1 do begin
			my_xfront[count] = x_front[i]
			my_yfront[count] = y_front[i]
			count += 1
		endfor
	endif else begin	
	for i=0,sz_xf[0]-1 do begin
		plots, x_front[i], y_front[i], psym=2, color=3
		read, 'Front? y/n', ans
		if ans ne 'n' then begin
			my_xfront[count] = x_front[i]
			my_yfront[count] = y_front[i]
			count = count + 1
		endif
	endfor
	endelse
	my_xfront = my_xfront[0:count-1]
	my_yfront = my_yfront[0:count-1]
	if noplot ne 1 then begin
		case in.detector of
		'COR1': plot_map, map, xr=[-3800,3800], yr=[-3800,3800], /limb
		'COR2': plot_map, map, xr=[-15000,15000], yr=[-15000,15000], /limb
		'C2': plot_map, map, xr=[-6000,6000], yr=[-6000,6000], /limb
		'C3': plot_map, map, xr=[-28000,28000], yr=[-28000,28000], /limb
		'CMOS 1Kx1K': plot_map, map, xr=[-1400,1800], yr=[-1590,1600], /limb
		endcase
		plots, my_xfront, my_yfront, psym=1;, color=6
	endif
	x_front = my_xfront
	y_front = my_yfront
	delvarx, count, my_xfront, my_yfront, sz_xf, sz_yf
	;******

	; Want to take the height of the maximum point on the front
	recpol, x_front, y_front, r_front, a_front, /degrees
	temp = where(r_front eq max(r_front))
	print, '*********************'
	print, 'The maximum height of the front is: ', r_front[temp]
	print, '*********************'
	max_h_front = r_front[temp]

	
	;********
	; Calling function to plot ellipse (written by Jason)
	; Coords need to be in original array format (not map)
	if in.instrume eq 'SECCHI' then begin
		x_org = ( x_front / in.cdelt1 ) + x_sun_center
		y_org = ( y_front / in.cdelt2 ) + y_sun_center
		ellipse = ellipsefit(x_org, y_org)
		aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
		bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
		aprime = (aprime-x_sun_center) * in.cdelt1
		bprime = (bprime-y_sun_center) * in.cdelt2
		x_bar_org = ellipse[size(ellipse,/dim)-2]
		y_bar_org = ellipse[size(ellipse,/dim)-1]
		x_bar = (x_bar_org-x_sun_center) * in.cdelt1
		y_bar = (y_bar_org-y_sun_center) * in.cdelt2
	endif else begin ; for LASCO	
		x_org = ( x_front / in.cdelt1 ) + in.crpix1
		y_org = ( y_front / in.cdelt2 ) + in.crpix2
		ellipse = ellipsefit(x_org, y_org)
		aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
		bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
		aprime = (aprime-in.crpix1) * in.cdelt1
		bprime = (bprime-in.crpix2) * in.cdelt2
		x_bar_org = ellipse[size(ellipse,/dim)-2]
		y_bar_org = ellipse[size(ellipse,/dim)-1]
		x_bar = (x_bar_org-in.crpix1) * in.cdelt1
		y_bar = (y_bar_org-in.crpix2) * in.cdelt2
	;	plots, aprime, bprime, color=3;red
	;	plots, x_bar, y_bar, psym=4;diamond
	endelse
	recpol, x_bar, y_bar, r_bar, a_bar, /degrees
	;********

	;******
	; Find width of CME ellipsefit for use in start params of mpfitellipse.pro
	min_ap = min(aprime)
	max_ap = max(aprime)
	min_bp = bprime[where(aprime eq min_ap)]
	max_bp = bprime[where(aprime eq max_ap)]
	;plots, [min_ap,max_ap], [min_bp,max_bp], color=5;blue	
	width = sqrt( (max_bp-min_bp)^2. + (max_ap-min_ap)^2. )
	;******

	;********
	; Use mpfitfun for perform mpfitellipse using my guestimate.
	x0 = x_front - x_bar
	y0 = y_front - y_bar
	recpol, x0, y0, r0, a0, /degrees
	radiusbar = sqrt( x_bar^2. + y_bar^2. )
	fit = 'sqrt( (p[0]^2.*p[1]^2.) / ((p[0]^2.+p[1]^2.)/2. - ((p[0]^2.-p[1]^2.)/2.) * cos(2.*x - 2.*p[2]) ) )'
	parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
	parinfo[*].value = [10.*width, 10.*width, 1.]
	param = mpfitexpr( fit, a0, r0, r0*0.1, parinfo=parinfo, $
		perror=perror, yfit=yfit)
	x_fit = x_front
	y_fit = y_front
	;MPFITELLIPSE
	start_params = [param[0]*0.1, param[1]*0.1, x_bar, y_bar, param[2]*0.1]
	print, 'errs: ', errs
	wts = 0.75/(errs^2+errs^2)
	print, 'weights: ', wts
	p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weights=wts, quiet=1, perror=perror )
	print, 'p: ', p
	print, 'perror: ', perror
	phi = dindgen(101) * 2D * !dpi/100.
	x_ell = p[2] + p[0]*cos(phi)
	y_ell = p[3] + p[1]*sin(phi)

	r_centre = sqrt(p[2]^2.+p[3]^2.)
	; Error analysis of ellipse fit (by picking one point since they'll all have the same error)
	x_ell_err = perror[2]; + perror[0]
	y_ell_err = perror[3]; + perror[1]
	print, 'x_ell_err: ', x_ell_err & print, 'y_ell_err: ', y_ell_err
	;r_err = sqrt( (x_ell_err)^2. + (y_ell_err)^2. )
	;r_err = r_centre * 0.5 * (2 * (x_ell_err/p[2]) + 2 * (y_ell_err/p[3]) )
	r_err = sqrt( (p[2] * x_ell_err / r_centre)^2. + (p[3] * y_ell_err / r_centre)^2. )
	print, 'r_err: ', r_err
	
	;transform by swinging about map centre
	x_ell2 = x_ell*cos(p[4]) + y_ell*sin(p[4])
	y_ell2 = y_ell*cos(p[4]) - x_ell*sin(p[4])
	shift_x_bar = p[2]*cos(p[4]) + p[3]*sin(p[4])
	shift_y_bar = p[3]*cos(p[4]) - p[2]*sin(p[4])
	shift_x = shift_x_bar - p[2]
	shift_y = shift_y_bar - p[3]
	x_ellipse = x_ell2 - shift_x
	y_ellipse = y_ell2 - shift_y
	if noplot ne 1 then plots, x_ellipse, y_ellipse
	;plots, p[2], p[3], psym=6;, color=6

	;plots, [0,p[2]], [0,p[3]]

	; the transforming of the major and minor axes

	jump2:

	if ang eq 0 then begin
		xc = p[2]*cos(p[4]) + p[3]*sin(p[4])
        	yc = p[3]*cos(p[4]) - p[2]*sin(p[4])
		mn1x = xc+p[0]*cos(p[4]+!pi/2) - shift_x
		mn1y = yc+p[0]*sin(p[4]+!pi/2) - shift_y
		mn2x = xc-p[0]*cos(p[4]+!pi/2) - shift_x
		mn2y = yc-p[0]*sin(p[4]+!pi/2) - shift_y
		mj1x = xc+p[1]*cos(p[4]) - shift_x
		mj1y = yc+p[1]*sin(p[4]) - shift_y
		mj2x = xc-p[1]*cos(p[4]) - shift_x
		mj2y = yc-p[1]*sin(p[4]) - shift_y
	endif
	if ang eq 1 then begin
		xc = p[2]*cos(p[4]) + p[3]*sin(p[4])
		yc = p[3]*cos(p[4]) - p[2]*sin(p[4])
		mn1x = xc+p[0]*cos(-p[4]+!pi/2) - shift_x
		mn1y = yc+p[0]*sin(-p[4]+!pi/2) - shift_y
		mn2x = xc-p[0]*cos(-p[4]+!pi/2) - shift_x
		mn2y = yc-p[0]*sin(-p[4]+!pi/2) - shift_y
		mj1x = xc+p[1]*cos(-p[4]) - shift_x
		mj1y = yc+p[1]*sin(-p[4]) - shift_y
		mj2x = xc-p[1]*cos(-p[4]) - shift_x
		mj2y = yc-p[1]*sin(-p[4]) - shift_y
	endif	
	if ang eq 2 then begin
		xc = p[2]*cos(p[4]) + p[3]*sin(p[4])
		yc = p[3]*cos(p[4]) - p[2]*sin(p[4])
		mn1x = xc+p[0]*cos(-p[4]) - shift_x
		mn1y = yc+p[0]*sin(-p[4]) - shift_y
		mn2x = xc-p[0]*cos(-p[4]) - shift_x
		mn2y = yc-p[0]*sin(-p[4]) - shift_y
		mj1x = xc+p[1]*cos(-p[4]+!pi/2) - shift_x
		mj1y = yc+p[1]*sin(-p[4]+!pi/2) - shift_y
		mj2x = xc-p[1]*cos(-p[4]+!pi/2) - shift_x
		mj2y = yc-p[1]*sin(-p[4]+!pi/2) - shift_y
	endif 
	if ang eq 3 then begin
		xc = p[2]*cos(p[4]) + p[3]*sin(p[4])
		yc = p[3]*cos(p[4]) - p[2]*sin(p[4])
		mn1x = xc+p[0]*cos(p[4]) - shift_x
		mn1y = yc+p[0]*sin(p[4]) - shift_y
		mn2x = xc-p[0]*cos(p[4]) - shift_x
		mn2y = yc-p[0]*sin(p[4]) - shift_y
		mj1x = xc+p[1]*cos(p[4]+!pi/2) - shift_x
		mj1y = yc+p[1]*sin(p[4]+!pi/2) - shift_y
		mj2x = xc-p[1]*cos(p[4]+!pi/2) - shift_x
		mj2y = yc-p[1]*sin(p[4]+!pi/2) - shift_y
	endif		
	length_mj = sqrt( (mj1x-mj2x)^2 + (mj1y-mj2y)^2 )
	length_mn = sqrt( (mn1x-mn2x)^2 + (mn1y-mn2y)^2 )
	if length_mj lt length_mn then begin
		temp_mn1x = mn1x
		temp_mn1y = mn1y
		temp_mn2x = mn2x
		temp_mn2y = mn2y
		mn1x = mj1x
		mn1y = mj1y
		mn2x = mj2x
		mn2y = mj2y
		mj1x = temp_mn1x
		mj1y = temp_mn1y
		mj2x = temp_mn2x
		mj2y = temp_mn2y
		delvarx, temp_mn1x, temp_mn1y, temp_mn2x, temp_mn2y
	endif
	length_mj = sqrt( (mj1x-mj2x)^2 + (mj1y-mj2y)^2 )
	length_mn = sqrt( (mn1x-mn2x)^2 + (mn1y-mn2y)^2 )
	print, 'length_mj ', length_mj
	print, 'length_mn ', length_mn
	if noplot eq 0 then begin
		plots, [mj1x, mj2x], [mj1y, mj2y], color=5
		plots, [mn1x, mn2x], [mn1y, mn2y], color=5
		plots, [0, mj1x], [0, mj1y], line=5, color=5
		plots, [0, mj2x], [0, mj2y], line=5, color=5
		plots, [0, mn1x], [0, mn1y], line=5, color=5
		plots, [0, mn2x], [0, mn2y], line=5, color=5
	endif
	; Commenting this out since ang = 2 all the time!
	;read, 'axes ok? y/n', angans
        ;if angans eq 'n' then begin
	;        plot_map, map
	;	draw_circle, 0, 0, r_sun[2]
	;	plot_helio, in.date_obs, roll=in.crota1, /over
	;	plots, x_front, y_front, psym=3;, color=2;yellow
	;	plots, x_ellipse, y_ellipse
	;	plots, p[2], p[3], psym=2, color=5
	;	ang+=1 mod 4
	;	goto, jump2
	;endif	

	
	;*******
	; Including a bit of analysis on the parameters given by the ellipse.


	print, '' & print, '****** Ellipse Information ******' & print, ''

	semimajor = length_mj/2.
	semiminor = length_mn/2.
	x_ell_centre = p[2]
	y_ell_centre = p[3]

	; Ellipse Tilt
	print, p[4]
	ell_tilt = p[4]*180./!pi mod 360.
	print, 'ell_tilt init ', ell_tilt
        print, 'ang is ', ang
	if ell_tilt lt 0 then ell_tilt = -360-ell_tilt
	if ell_tilt gt 0 then ell_tilt = 360-ell_tilt
	if abs(ell_tilt) gt 90 then begin
		if ell_tilt lt 0 then begin 
			ell_tilt = 180+ell_tilt
		endif else begin
			ell_tilt = 180-ell_tilt
		endelse
	endif
	print, 'ell_tilt corrected: ', ell_tilt

	; My own calculation of the ellipse tilt from the slope of the semimajor axis
	; need to transform the axis to image coords (non-map space)
	if in.instrume eq 'SECCHI' then begin
		mj1x_im = mj1x / in.cdelt1 + x_sun_center
		mj1y_im = mj1y / in.cdelt2 + y_sun_center
		mj2x_im = mj2x / in.cdelt1 + x_sun_center
		mj2y_im = mj2y / in.cdelt2 + y_sun_center
	endif else begin ; for LASCO	
		mj1x_im = mj1x / in.cdelt1 + in.crpix1
	       	mj1y_im = mj1y / in.cdelt2 + in.crpix2
		mj2x_im = mj2x / in.cdelt1 + in.crpix1
		mj2y_im = mj2y / in.cdelt2 + in.crpix2
	endelse
	slope_mj = (mj2y_im-mj1y_im)/(mj2x_im-mj1x_im)
       	angle_mj = (atan(slope_mj))*180/!pi
	print, 'angle_mj ', angle_mj
	if angle_mj lt 0 then angle_mj += 180
	print, 'angle_mj inclined ', angle_mj

	print, 'semimajor(arcsec): ', semimajor & print, 'semiminor(arcsec): ', semiminor
	; 1 arcsec = 725 km
	; 1 R_sun = 960 arcsec
	print, 'semimajor(km): ', semimajor*725 & print, 'semiminor(km): ', semiminor*725
	ratio = semimajor / semiminor
	print, 'ratio: ', ratio

	print, 'tilt angle(degrees): ', ell_tilt

	; Take the furthest point on the ellipse from Sun centre
	recpol, x_ellipse, y_ellipse, r_ellipse, a_ellipse, /degrees
	apex_r = max(r_ellipse)
	apex_a = (a_ellipse[where(r_ellipse eq apex_r)])[0]
	polrec, apex_r, apex_a, x_apex, y_apex, /degrees
	if noplot eq 0 then plots, x_apex, y_apex, psym=1, color=3
	print, '******'
	print, 'apex_a: ', apex_a
	print, '******'
	
	height_apex = sqrt( (x_apex)^2. + (y_apex)^2. )
	print, 'height_apex(arcsec): ', height_apex
	print, 'height_apex(km): ', height_apex*725
	if noplot eq 0 then plots, [0,x_apex], [0,y_apex], color=3
	
	height_centre = sqrt( (p[2])^2. + (p[3])^2. )
	print, 'height_centre(arcsec): ', height_centre
	print, 'height_centre(km): ', height_centre*725
	if noplot eq 0 then plots, [0,p[2]], [0,p[3]], line=1, color=5

	; Does the ellipse cut the 0/360 line which means it needs shifting to obtain the angular width.
	true = shift_ell(in, da, x_ellipse, y_ellipse, p)
	print, 'true: ', true
	if true eq 0 then begin	
		; Cone of Ellipse
		min_cone_a = min(a_ellipse)
		max_cone_a = max(a_ellipse)
		min_cone_r = r_ellipse[where(a_ellipse eq min_cone_a)]
		max_cone_r = r_ellipse[where(a_ellipse eq max_cone_a)]
		polrec, min_cone_r, min_cone_a, min_cone_x, min_cone_y, /degrees
		polrec, max_cone_r, max_cone_a, max_cone_x, max_cone_y, /degrees
		if noplot eq 0 then begin
			plots, [0,min_cone_x], [0,min_cone_y]
			plots, [0,max_cone_x], [0,max_cone_y]
		endif
		aw = max_cone_a - min_cone_a
		print, 'angular width(degrees): ', aw
	endif else begin
		; do the shift now...
		aes = (a_ellipse+180) mod 360
		aes_min = min(aes)
		aes_max = max(aes)
		aw = aes_max - aes_min
		re_cone1 = r_ellipse[where(aes eq aes_min)]
		re_cone2 = r_ellipse[where(aes eq aes_max)]
		polrec, r_ellipse, aes, xes, yes, /degrees
		ae_min = (aes_min+180) mod 360
		ae_max = (aes_max+180) mod 360
		polrec, re_cone1, ae_min, min_cone_x, min_cone_y, /degrees
		polrec, re_cone2, ae_max, max_cone_x, max_cone_y, /degrees
		if noplot eq 0 then begin
			plots, [0,min_cone_x], [0,min_cone_y]
			plots, [0,max_cone_x], [0,max_cone_y]
		endif
		print, 'angular width (degrees): ', aw
	endelse


	; Clause for when the ellipse runs away and the height is not within the CME cone
	;if true eq 0 then begin
		if apex_a lt min(a_front) or apex_a gt max(a_front) then begin
			temp_a_ellipse = a_ellipse[where(a_ellipse lt max(a_front) and a_ellipse gt min(a_front))]
			temp_r_ellipse = r_ellipse[where(a_ellipse lt max(a_front) and a_ellipse gt min(a_front))]
			temp_apex_r = max(temp_r_ellipse)
			temp_apex_a = (temp_a_ellipse[where(temp_r_ellipse eq temp_apex_r)])[0]
			polrec, temp_apex_r, temp_apex_a, temp_x_apex, temp_y_apex, /degrees
			if noplot eq 0 then plots, temp_x_apex, temp_y_apex, psym=1, color=3
			print, 'temp_apex_a: ', temp_apex_a
			temp_height_apex = sqrt( (temp_x_apex)^2. + (temp_y_apex)^2. )
			print, 'temp_height_apex(arcsec): ', temp_height_apex
			if noplot eq 0 then plots, [0,temp_x_apex], [0,temp_y_apex], color=4
		endif
	;endif else begin
	; needs case for true eq 1 when shift is involved!
	;endif	

	
	; Take the ellipse info together and write out an array.
	ell_info=fltarr(6)
	ell_info[0] = semimajor
	ell_info[1] = semiminor
	ell_info[2] = angle_mj
	ell_info[3] = aw
	ell_info[4] = height_centre
	ell_info[5] = height_apex[0]

	;pause	
	;wait, 1

	print, '****************************'
	print, 'semimajor semiminor tilt ang_width height_centre height_apex instr date time max_h_front apex_a'
	print, semimajor, semiminor, angle_mj, aw, height_centre, height_apex[0], $
		in.detector, in.date_obs, max_h_front, apex_a

end


; Code to work out the angular width of an ellipse when it actually crosses the 0/360 line.

; Last Edited: 05-12-07

function shift_ell, in, da, x_ell, y_ell, p

true=0
sz_da = size(da,/dim)
sz = size(x_ell,/dim)

if in.instrume eq 'SECCHI' then begin
	x_pixel_offset = in.xcen / in.cdelt1
	y_pixel_offset = in.ycen / in.cdelt2
	x_sun_center = (in.naxis1) / 2. - x_pixel_offset
	y_sun_center = (in.naxis2) / 2. - y_pixel_offset
	; transform back into array space (from the map space)
	xe = x_ell/in.cdelt1 + x_sun_center
	ye = y_ell/in.cdelt2 + y_sun_center
	xec = p[2]/in.cdelt1 + x_sun_center
	yec = p[3]/in.cdelt2 + y_sun_center	
endif else begin
	; transform back into array space (from the map space)
	xe = x_ell/in.cdelt1 + in.crpix1
	ye = y_ell/in.cdelt2 + in.crpix2
	xec = p[2]/in.cdelt1 + in.crpix1
	yec = p[3]/in.cdelt2 + in.crpix2
endelse
	
;to see if the ellipse needs shifting, make masks of ellipse and 0/360 line and add.
res = polyfillv( [xec, xe[0], xe[1]], [yec, ye[0], ye[1]], sz_da[0], sz_da[1] )
for i=1,sz[0]-2 do begin
	res2 = polyfillv( [xec, xe[i], xe[i+1]], [yec, ye[i], ye[i+1]], sz_da[0], sz_da[1] )
	res = [res,res2]
endfor
ell_mask=fltarr(sz_da[0], sz_da[1])
ell_mask[res] = 1
;plot_image, ell_mask

line_mask = fltarr(sz_da[0],sz_da[1])
line_mask[in.crpix1:sz_da[0]-1, in.crpix2] = 1
;plot_image, line_mask

intersect = line_mask + ell_mask
if max(intersect) eq 2 then true=1

return, true

end
