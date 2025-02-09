pro ellipse_angles, in, height

restore, 'time_C2+C3.sav'
restore, 'ellipse_angles.sav'


  !p.multi = [ 0, 1, 3 ]
  !p.charsize = 2.

utplot, timtot[0:10] - timtot[0], angles[0:10], timtot[0], psym=-2, $
	timerange= '18-Apr-2000 ' + ['15:00', '19:30'], /xs, yr=[-10,90], /ys, $
	ytitle='Orientation (degrees)', title='Ellipse Orientation'

stop

  
  r_sun = pb0r( diff_times[ 3 ], /arc )
  r_sun = r_sun[ 2 ]
 
  h = height / r_sun - 1.
 
 sz = size(diff_times, /dim)
  
 midpts = fltarr(sz[0])
 midtim = fltarr(sz[0])
 

for i=1,sz[0]-1 do begin
   
	midpts[i-1] = h[i-1] + (h[i] - h[i-1])/2.
	midtim[i-1] = diff_times[i-1] + (diff_times[i] - diff_times[i-1])/2.
endfor
    
save, h, filename='C3_h.sav'
save, diff_times, filename='C3_difftimes.sav'


  utplot, diff_times[ 0:3 ] - diff_times[ 0 ], h[ 0:3 ], diff_times[ 0 ], psym = -2, $
	  timerange = '18-apr-2000 ' + [ '17:00', '19:30' ], /xs, yr=[4, 14], /ys, $
	  ytitle = 'Height above limb (R!DS!N)', title = 'Height'


h_km = height * 720.

v = fltarr(sz[0])

for i=1,sz[0]-1 do begin
	v[i-1] = (h_km[i] - h_km[i-1]) / (diff_times[i] - diff_times[i-1])
endfor


	  
  utplot, midtim[ 0:3 ] - midtim[ 0 ], v[ 0:3 ], midtim[ 0 ], psym = -2, $
	  timerange = '18-apr-2000 ' + [ '17:00', '19:30' ], /xs, /ys, $
	  ytitle = 'Velocity (km/sec)', title = 'Velocity'



midpts2 = fltarr(sz[0])
midtim2 = fltarr(sz[0])

for i=1,sz[0]-1 do begin
	
	midpts2[i-1] = v[i-1] + (v[i] - v[i-1])/2.
	midtim2[i-1] = midtim[i-1] + (midtim[i] - midtim[i-1])/2.
endfor

acc = fltarr(sz[0])

for i=1,sz[0]-1 do begin
	acc[i-1] = (v[i] - v[i-1]) / (midtim[i] - midtim[i-1])
endfor


utplot, diff_times[ 1:2 ] - diff_times[ 0 ], acc[ 1:2 ], diff_times[ 0 ], psym = -2, $
	timerange = '18-apr-2000 ' + [ '17:00', '19:30' ], /xs, /ys, $
	ytitle = 'Acceleration (km/sec!U2!N)', title = 'Acceleration'

  
  
  
  
  
end

