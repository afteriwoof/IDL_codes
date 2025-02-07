;Created: 03-09-08
; Last Edited: 

; Want to have three projections of two circles (one in x-plane, one in y-plane so both are lines in the other plane and in the z-plane.

pro two_circles, A, B

im = fltarr(100,100)
plot_image, im
A = circle(40,40,30)
plots, A[0,*], A[1,*]

; from http://www.dfanning.com/tips/threedaxes.html

surface, dist(5), /nodata, /save, xrange=[0,99], yrange=[0,99], zrange=[0,99], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2;, ax=0, az=0

set_line_color

plots, a[0,*], a[1,*], 40, color=2, /t3d

plots, 40, a[1,*], a[0,*], color=3, /t3d






end

function CIRCLE, xc, yc, r
points = (2*!pi/99.)*findgen(100)
x = xc + r*cos(points)
y = yc + r*sin(points)
return, transpose([[x],[y]])
end

