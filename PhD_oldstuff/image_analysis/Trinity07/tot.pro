pro tot, t, h

restore, 'time_C2+C3.sav'
t = timtot
restore, 'height_C2+C3.sav'
h = htot


  !p.multi = [ 0, 1, 3 ]
  !p.charsize = 2.

  r_sun = pb0r( t[ 3 ], /arc )
  r_sun = r_sun[ 2 ]
 
 
 sz = size(t, /dim)
  
 midpts = fltarr(sz[0])
 midtim = fltarr(sz[0])
 

for i=1,sz[0]-1 do begin
   
	midpts[i-1] = h[i-1] + (h[i] - h[i-1])/2.
	midtim[i-1] = t[i-1] + (t[i] - t[i-1])/2.
endfor


;utplot, midtim[0:9] - midtim[0], midpts[0:9], midtim[0], psym=-2, $
;	timerange='18-Apr-2000 ' + ['15:00', '19:30'], /xs, yr=[0,14],/ys




  utplot, t[ 0:10 ] - t[ 0 ], h[ 0:10 ], t[ 0 ], psym = 2, $
	  timerange = '18-apr-2000 ' + [ '15:00', '19:30' ], /xs,yr=[0,14], /ys, $
	  ytitle = 'Height above limb (R!DS!N)', title = 'Height'

  
restore,'fit.sav'

outplot, t - t[ 0 ], yf, thick = 2

;h = yf
h_km = h * 720. * 1000.


;plot, h_km, psym=-2


v = fltarr(sz[0])

for i=1,sz[0]-1 do begin
	v[i-1] = (h_km[i] - h_km[i-1]) / (t[i] - t[i-1])
endfor

	  
  utplot, midtim[ 0:10 ] - midtim[ 0 ], v[ 0:9 ], midtim[ 0 ], psym = 2, $
	  timerange = '18-apr-2000 ' + [ '15:00', '19:30' ], /xs, yr=[0,1200], /ys, $
	  ytitle = 'Velocity (km/sec)', title = 'Velocity'
  vf = deriv( t, yf * 720. * 1000. )
  outplot, t - t[ 0 ], vf, thick = 2



acc = fltarr(sz[0])

for i=1,sz[0]-1 do begin
	acc[i-1] = (v[i] - v[i-1]) / (midtim[i] - midtim[i-1])
endfor


utplot, t[ 1:9 ] - t[ 0 ], acc[ 0:8 ] * 1000., t[ 0 ], psym = 2, $
	timerange = '18-apr-2000 ' + [ '15:00', '19:30' ], /xs, yr=[-300, 300], /ys, $
	ytitle = 'Acceleration (m/sec!U2!N)', title = 'Acceleration'

outplot, t - t[ 0 ], deriv( t, vf ) * 1000., thick = 2


 print, anytim(t,/vms)
print, h
 print, v
print, acc
  
  
  
  
end

