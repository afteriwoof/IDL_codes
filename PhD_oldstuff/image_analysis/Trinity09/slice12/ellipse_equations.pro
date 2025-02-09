; Created: 15-09-08

; Last Edited: 17-09-08

; for Affine trans. a=1, b=0, c=1

pro ellipse_equations, a, b, c, s, t, semimajor, semiminor, h, h_y

;h1 = ( -(s+2-t) + sqrt( (s+2-t)^2. - 4*(2*t-2)*(-s) ) ) / ( 2*(2*t-2) )
;h2 = ( -(s+2-t) - sqrt( (s+2-t)^2. - 4*(2*t-2)*(-s) ) ) / ( 2*(2*t-2) )
;print, h1, h2

h = (s/2.+a/2.)/2.
h_y = ((t-b-c)/(s-a))*h + (t/2.)-((t-b-c)/(s-a))*(s/2.)
print, 'h: ', h & print, 'h_y: ', h_y

r1 = 4*((s-a)^2.-(t-b-c)^2.)*(h-a/2.)^2.+$
	4*(s-a)*(a*(s-a)+b*(b-t)+c*(c-t))*(h-a/2.)+$
	(s-a)^2.*(a^2.-(c-b)^2.)

r2 = 8*(t-b-c)*(s-a)*(h-a/2.)^2.+$
	4*(s-a)*(a*t+s*c+b*s-2*a*b)*(h-a/2.)+$
	2*a*(s-a)^2.*(b-c)

u = r1^2. + r2^2.

big_r = sqrt( (1/(16*(s-a)^4.))*u )

big_s = (2*(b*s-a*(t-c))*h - s*a*c)*(2*h-a)*(2*h-s)

big_w = (1/4.)*(c/((s-a)^2.))*big_s

semimajor = sqrt( (1/2.)*(big_r + sqrt( big_r^2.+4*big_w )))

semiminor = sqrt( (1/2.)*(-big_r + sqrt( big_r^2.+4*big_w )))

print, 'semimajor: ', semimajor & print, 'semiminor: ', semiminor

end
