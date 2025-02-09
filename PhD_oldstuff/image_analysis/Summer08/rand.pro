pro rand


t = findgen( 200 ) / 2.
t_err = replicate(0.01, n_elements(t))
h = 1000. + 300. * t + 0.5 * 10. * t^2

h = h / 2000.
h_err = replicate(0.5, n_elements(h))

n = randomn( seed, 200 ) / 5.
pmm,n
h = h + n
pmm, h
!p.multi = [ 0, 1, 3 ]

plot, t, h, psym=-3, xr=[-10,110], /xs
oploterror, t, h, t_err, h_err, psym=3

v = deriv( t, h )
v_err = derivsig(t, h, t_err, h_err)

plot, t, v, psym=-3, xr=[-10,110], /xs, yr=[-2,2]
oploterror, t, v, t_err, v_err

a = deriv( t, v )
a_err = derivsig(t, v, t_err, v_err)

plot, t, a, psym=-3, xr=[-10,110], /xs, yr=[-5,5]
oploterror, t, a, t_err, a_err

end
