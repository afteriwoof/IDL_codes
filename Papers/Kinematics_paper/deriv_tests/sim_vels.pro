pro sim_vels

for i = 0, 40 do begin

  !p.multi = [ 0, 1, 3 ]
  !p.charsize = 3
  window, xsize = 600, ysize = 800

  h0 = 60. * 1000. ; km
  n_pts = 5
  t = findgen( n_pts ) * 60. ; seconds 
  v0 = 300. ; km/s
  a0 = 2.  ; m/s/s

  h_theory = h0 + v0 * t + 0.5 * a0 * t^2

  sig_h = h_theory * 0.1 * randomn( seed, n_pts ) 

  print, 'Percentage error on heights :'
  print, sig_h / h_theory * 100.
  
  print, ' '
  print, 'Mean percentage error in heights:', mean( abs( sig_h / h_theory ) ) * 100.
  print, ' '

  h_obs = h_theory + sig_h

  xr = [ -10, max( t ) + 10 ]

  plot, t, h_obs / 1000., psym = -2, xtit = 'Time (s)', ytit = 'Height (Mm)', yrange = [ 0, max( h_theory /1000. ) * 1.1 ], line = 2, xr = xr, /xs
  oplot, t, h_theory / 1000.
  oplot_err, t, h_obs / 1000., yerr = sig_h / 1000.

  legend, [ 'Theory', 'Simulation' ], line = [ 0, 2 ], charsize = 1.5

  v_obs = deriv( t, h_obs )
  v_theory = v0 + a0 * t

  sig_v_obs = derivsig( t, h_obs, 0, sig_h )

  plot, t, v_obs, psym = -2, xtit = 'Time (s)', ytit = 'Velocity (km/s)', yr = [ 0, max( v_theory ) * 1.2 ], line = 2, xr = xr, /xs
  oplot, t, v_theory 
  oplot_err, t, v_obs, yerr = sig_v_obs
 
  a_obs = deriv( t, v_obs )
  a_theory = replicate( a0, n_pts )

  sig_a_obs = derivsig( t, v_obs, 0, sig_v_obs )

  plot, t, a_obs, psym = -2, xtit = 'Time (s)', ytit = 'Acceleration (m/s/s)', yr = [ -20, 20 ], line = 2, xr = xr, /xs, /ys
  oplot, t, a_theory
  oplot_err, t, a_obs, yerr = sig_a_obs 

  wait, 1

endfor
 
end
