pro non_const

t = findgen(2000)

l = 1.

r0 = 100e6
v0 = 400e3
va0 = 1000e3

h = l + v0*t + (4*va0)/(5*sqrt(3*!dpi))*((v0/l)^(3/2.))*t^(5/2.)

v = v0 + (2*va0)/(sqrt(3*!dpi))*((v0/l)^(3/2.))*t^(3/2.)

a = (3*va0)/(sqrt(3*!dpi))*((v0/l)^(3/2.))*t^(1/2.)

plot, t, h
plot, t, deriv(t,h), color=2
pause
oplot, t, v, color=3
plot, t, deriv(t,v), color=2
pause
oplot, t, a, color=3

end
