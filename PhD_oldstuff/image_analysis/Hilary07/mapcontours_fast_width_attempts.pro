; Code which produces normalised exposure time data array and byte-scaling of same from Alex's data 18-apr-2000.
; Also removes disk surrounding Solar disk.

; This code uses fmedian before it applies the normalisation or bytscl.
; fmedian calls fmedian_slow which takes a long time to run!!!

; Creating MAPS from the data and scaling contour values to maps coords.

; Made tangents to the CME edges and also lines at intervals of ten through CME angle.

; Obtains average point of CME front and deduces the apex.

; Sample attempt to fit an ellipse to the array of data points.

; Last edited 23-02-07


pro mapcontours_fast_width_attempts, tangents=tangents, previous=previous, lines=lines

;fls = file_search('~/PhD/Data_from_Alex/18-apr-00/*.fts')
;fls = file_search('~/PhD/Data_from_James/010515/*.fts')

;mreadfits, fls, in, da
;save, da, filename='da.sav'
;save, in, filename='in.sav'
restore, 'da.sav'
restore, 'in.sav'

; Operations to be done on James's data
;c2data = where( in.detector eq 'C2' and in.naxis1 eq 1024)
;mreadfits, fls(c2data), in, c2data
;ssw_fill_cube2, c2data, da

;restore, '~/PhD/18apr2000.sav'

;restore, '~/PhD/in.sav'

; Convert INT array to FLOAT
da = float(da)

da_norm = da

danb = da

sz = size(da, /dim)


;for i=0,sz[2]-1 do begin
	
;	im = da(*,*,i)

	; Remove inner disk
;	rm_inner, im, in[i], dr, thr=2.1
	
	; Median operator to smooth noise pixels
;	da(*,*,i) = fmedian(im, 5, 3)

	; Normalising the data with regard to exposure time
;	da_norm(*,*,i) = da(*,*,i) / in[i].exptime

	; Bytscaling for image presentation only.
;	danb(*,*,i) = bytscl(da_norm(*,*,i), 25, 225)

;endfor

;save, da_norm, filename='da_norm.sav'
;save, danb, filename='danb.sav'
restore, 'da_norm.sav'
restore, 'danb.sav'

; Now computing Running Difference

diffn = fltarr(sz[0],sz[1],sz[2]-1)

diffnb = diffn

for i=0,sz[2]-2 do begin

	diffn(*,*,i) = da_norm(*,*,i+1) - da_norm(*,*,i)

	diffnb(*,*,i) = bytscl( diffn(*,*,i), -10, 18)

endfor

szd = size(diffn, /dim)

; Creating maps but note the header isn't being edited (the times will be wrong)!

newin = in[0:szd[2]-1]

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
	xy_org = xy
	
	xy(0,*) = ( xy(0,*)-in[i].crpix1 ) * in[i].cdelt1
	xy(1,*) = ( xy(1,*)-in[i].crpix2 ) * in[i].cdelt2

	plot_map, mapsb[i]


	; plotting tangents from previous image
	if keyword_set(previous) then begin
		if i ne 0 then begin	
			set_line_color
			plots, [0,x_edge1],[0,y_edge1], color=5
			plots, [0,x_edge2],[0,y_edge2], color=4	
		endif
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
	
	


	; Increase k to include more contours
	for k=0,1 do begin


		; Plot the centre average point of the front
		x = xy_org(0,info[k].offset:(info[k].offset+info[k].n-1))
		y = xy_org(1,info[k].offset:(info[k].offset+info[k].n-1))
	
		sz_x = size(x,/dim)
		sz_y = size(y,/dim)
		sumx = 0.
		sumy = 0.
		count = 0.
		while(count lt sz_x[1]) do begin
			sumx = sumx + x[count]
			sumy = sumy + y[count]
			count = count + 1	
		endwhile
		x_bar = sumx / sz_x[1]
		y_bar = sumy / sz_y[1]
		
		x_bar = (x_bar-in[i].crpix1 ) * in[i].cdelt1
		y_bar = (y_bar-in[i].crpix2 ) * in[i].cdelt2

		; Obtain slope and perpendicular to find width
		slope = y_bar/x_bar
		slope_perp = -1./slope
		print, slope, slope_perp
		c = y_bar - slope_perp*x_bar
		print, c
		;plots, [0,x_bar], [c,y_bar]
		
		; Plotting the average point
		plots, x_bar, y_bar, psym=2
		
		; Find the angle of the average point and deduce the apex at this angle.
		recpol, x_bar, y_bar, r_bar, a_bar, /degrees
		print, 'r_apex:' & print, r_bar
		

		; Obtaining the CME front in polar coords
		recpol, xy(0,info[k].offset:(info[k].offset+info[k].n-1)), $
			xy(1,info[k].offset:(info[k].offset+info[k].n-1)), r, a, /degrees
	
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

		a_min = min(a)
		a_max = max(a)
	
		r_a_min = r(where(a eq min(a)))
		r_a_max = r(where(a eq max(a)))
	
		r_a_bar = max(r(where(a eq round(a_bar))))
		
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

		polrec, r_a_bar, a_bar, x_apex, y_apex, /degrees
		plots, x_apex, y_apex, psym=4
		print, 'apex(x,y):' & print, x_apex, y_apex
	
		; drawing circle of solar limb
		r_sun = pb0r(maps[i].time, /soho, /arcsec)
		draw_circle, 0, 0, r_sun[2]
	
	
		; Fitting ellipse as determined in contour8.bat
		tempx = fltarr(100)
		tempy = fltarr(100)
		steps = sz_x[1] / 100.
		for t=0,99 do begin
		        tempx[t] = x[t*steps]
		        tempy[t] = y[t*steps]
		endfor
		x = tempx
		y = tempy
		sz_x = size(tempx, /dim)
		sz_y = size(tempy, /dim)

		sumx = 0.
		sumy = 0.
		sumxx = 0.
		sumyy = 0.
		sumxy = 0.
		t=0.
		npts = sz_x[0]

		while(t lt npts) do begin
		        sumx = sumx + x(t) 
		        sumy = sumy + y(t) 
		        sumxx = sumxx + x(t)*x(t) 
		        sumyy = sumyy + y(t)*y(t) 
		        sumxy = sumxy + x(t)*y(t) 
		        t=t+1 
		endwhile
	
		x_bar = sumx / npts
		y_bar = sumy / npts

		varx = sumxx / npts
		vary = sumyy / npts
		covarxy = sumxy / npts

		t=0.
		z=fltarr(npts,2)
		temp1=fltarr(2)
		temp2=fltarr(2,2)
		total = fltarr(2,2)

		while(t lt npts) do begin 

		        ; Take the vector (x-xbar, y-ybar)
		        z[t,0] = ( x[t] - x_bar ) 
		        z[t,1] = ( y[t] - y_bar ) 

		        ; Multiply each by its transpose
		        temp1[0] = z[t,0] 
		        temp1[1] = z[t,1] 

		        temp2 = transpose(temp1)##temp1 

		        total = total + temp2 

		        t=t+1 

		endwhile

		dx = z[*,0]
		dy = z[*,1]
		sumdxdx=0.
		sumdydy=0.
		sumdxdy=0.
		t = 0.
		while(t lt npts) do begin 
		        sumdxdx = sumdxdx + dx[t]*dx[t] 
		        sumdydy = sumdydy + dy[t]*dy[t] 
		        sumdxdy = sumdxdy + dx[t]*dy[t] 
		        t=t+1 
		endwhile
				
		;u = c*dx - s*dy
		;v = s*dx + c*dy
		;sumuu = 0.
		;sumvv = 0.
		;t = 0.
		;while(t lt npts) do begin
		;        sumuu = sumuu + u[t]*u[t] 
		;        sumvv = sumvv + v[t]*v[t] 
		;        t=t+1 
		;endwhile

		;varu = sumuu / npts
		;varv = sumvv / npts

		tensor = [[sumdxdx, sumdxdy], [sumdxdy, sumdydy]]
		evals = eigenql(tensor, eigenvectors=evecs)
		semimajor = sqrt(evals[0])/6.
		semiminor = sqrt(evals[1])/6.
		major = semimajor*2.
		minor = semiminor*2.
		semiaxes = [semimajor, semiminor]
		axes = [major, minor]
		evec = evecs[*,1]
		orient = atan(evec[1],evec[0])*180./!pi-90.
		npoints = 120.
		phi = 2*!pi*(findgen(npoints)/(npoints-1))
		ang = orient/!radeg
		cosang=cos(ang)
		sinang=sin(ang)
		a=semimajor*cos(phi)
		b=semiminor*sin(phi)
		aprime=x_bar+(a*cosang)-(b*sinang)
		bprime=y_bar+(a*sinang)+(b*cosang)

		plots, aprime, bprime
		; End of ellipse fitting!
		
	stop	
		; drawing tangents to the CME edges
		if keyword_set(tangents) then begin
			slope1 = sqrt((y_new[0] / x_new[0])^2)
			y_edge1 = (in[i].naxis2 - in[i].crpix2) * in[i].cdelt2
			x_edge1 = y_edge1/slope1
			if y_new[0] lt 0 then begin
				y_edge1 = -y_edge1
				if x_new[0] lt 0 then begin
					x_edge1 = -x_edge1
				endif
			endif else begin
				if x_new[0] lt 0 then begin
					x_edge1 = -x_edge1
				endif
			endelse
			plots, [0,x_edge1], [0,y_edge1]		
			;plots, [0,x_new[0]], [0, y_new[0]]
		
			szx_new = size(x_new, /dim)
			szy_new = size(y_new, /dim)
		
			slope2 = sqrt((y_new[szy_new] / x_new[szx_new])^2)
       		 	y_edge2 = (in[i].naxis2 - in[i].crpix2) * in[i].cdelt2
       		 	x_edge2 = y_edge2/slope2
       		 	if y_new[szy_new] lt 0 then begin
       		        	y_edge2 = -y_edge2
       		        	if x_new[szx_new] lt 0 then begin
       		                	x_edge2 = -x_edge2
       		         	endif   
		       	endif else begin
		                if x_new[szx_new] lt 0 then begin
       		         	        x_edge2 = -x_edge2
       		         	endif   
      	 	 	endelse
        		plots, [0,x_edge2], [0,y_edge2]
			;plots, [0,x_new[szx_new]], [0,y_new[szy_new]]
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
				r_angles(temp) = max(r(where(a eq round(count)))) 
				r_mid(temp) = r_bar
				r_front(temp) = r_a_bar
				temp = temp + 1
				count = count + steps
			endwhile		
	
			r_mid = r_mid(where(r_mid ne 0))	
			polrec, r_angles, angles, x_step, y_step, /degrees
			polrec, r_mid, angles, x_mid, y_mid, /degrees
			polrec, r_front, angles, x_front, y_front, /degrees
			;plots, x_front, y_front	
			plots, x_mid, y_mid
			szx_step = size(x_step, /dim)
		
		if keyword_set(lines) then begin	
			for j=0,szx_step[0]-1 do begin
				plots, [0,x_step[j]],[0,y_step[j]]
			endfor
		endif
	endfor
	;r_ave = (max(r)-min(r))/2. + min(r)

	; Find where the mid curve hits the CME contour front
	;tol = 200. 
	;upr = r_bar + tol
	;lwr = r_bar - tol
	;allow = upr - lwr
	;temp = 0.
	sz_r_new = size(r_new, /dim)
	;cross = fltarr(sz_r_new)
	;for j=0,sz_r_new[0]-2 do begin
;		diff = abs(r_new[j] - r_bar)
;		if diff le allow then begin
;			if j ne 0 then begin
;				if diff le temp then begin
;					cross[j] = r_new[j]
;				endif
;			endif else cross[j] = r_new[j]
;			temp = diff
;		endif
;	endfor
;
;	a_cross = a_new(where(cross ne 0))
;	sz_a_cross = size(a_cross, /dim)
;	diff_cross = fltarr(sz_a_cross[0]-1)
;	for j=0,sz_a_cross[0]-2 do begin
;		diff_cross[j] = a_cross[j+1] - a_cross[j]
;	endfor
;	max_pos = where(diff_cross eq max(diff_cross))
;	a_min_cross = a_cross[max_pos]
;	a_max_cross = a_cross[max_pos+1]
;	r_min_cross = r_new(where(a_new eq a_min_cross[0]))
;	r_max_cross = r_new(where(a_new eq a_max_cross[0]))
;	polrec, r_min_cross, a_min_cross, x1_cross, y1_cross, /degrees
;	polrec, r_max_cross, a_max_cross, x2_cross, y2_cross, /degrees
;	plots, x1_cross, y1_cross, psym=2
;	plots, x2_cross, y2_cross, psym=2

	print, 'r_bar' & print, r_bar
	print, 'r_new' & print, r_new
	count = 0
	for j=0,sz_r_new[0]-2 do begin
		print, 'j' & print, j
		print, count
		print, r_new[j]
		if count eq 0 then begin
			if r_bar gt r_new[j] then begin
				if r_bar lt r_new[j+1] then begin
					left1 = r_new[j]
					right1 = r_new[j+1]
					count = 1
					print, left1, right1
				endif
			endif
		endif else begin
			if r_bar gt r_new[j] then begin
				if r_bar lt r_new[j+1] then begin
					left2 = r_new[j]
					right2 = r_new[j+1]
					print, left2, right2
				endif
			endif
		endelse
	endfor

	; Drawing lines from contour edge to edge

	;a_int = a
	;sz=size(a,/dim)
	;for k=0,sz[1]-1 do begin 
	;	a_int(*,k)=fix(a(*,k))
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

