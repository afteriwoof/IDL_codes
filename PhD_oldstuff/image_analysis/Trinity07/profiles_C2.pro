pro profiles_C2, in, height

restore, '~/PhD/Data_sav_files/in.sav'
restore, 'height.sav'

  image_times = anytim( in.date_d$obs + ' ' + in.time_d$obs ) ; in secs
  diff_times = fltarr( n_elements( height ) )
  
  for i = 1, n_elements( image_times ) - 1 do begin
  
    dt = ( image_times[ i ] - image_times[ i - 1 ] ) / 2.
    diff_times[ i - 1 ] = image_times[ i - 1 ] + dt

  endfor

  !p.multi = [ 0, 1, 3 ]
  !p.charsize = 2.

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
     

save, h, filename='C2_h.sav'
save, diff_times, filename='C2_difftimes.sav'

		       
  utplot, diff_times[ 3:9 ] - diff_times[ 3 ], h[ 3:9 ], diff_times[ 3 ], psym = -2, $
	  timerange = '18-apr-2000 ' + [ '15:00', '17:30' ], /xs, yrange = [ 1, 6 ], /ys, $
	  ytitle = 'Height above limb (R!DS!N)', title = 'Height'


h_km = height * 720.

v = fltarr(sz[0])

for i=1,sz[0]-1 do begin
	v[i-1] = (h_km[i] - h_km[i-1]) / (diff_times[i] - diff_times[i-1])
endfor

print, h_km
print, v
	  
  utplot, midtim[ 3:8 ] - midtim[ 3 ], v[ 3:8 ], midtim[ 3 ], psym = -2, $
	  timerange = '18-apr-2000 ' + [ '15:00', '17:30' ], /xs, yrange = [0,700], /ys, $
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


utplot, diff_times[ 4:8 ] - diff_times[ 4 ], acc[ 3:7 ], diff_times[ 4 ], psym = -2, $
	timerange = '18-apr-2000 ' + [ '15:00', '17:30' ], /xs, yr=[-0.3, 0.5], /ys, $
	ytitle = 'Acceleration (km/sec!U2!N)', title = 'Acceleration'

  
  
  
  
  
end

