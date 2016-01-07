pro blackcircle

im = gauss_put(1024,1024, 500, 512, 200, 512, 200)

xcen = 512.
ycen = 512.

plot_image, im

pmm, im

r = 200.

;h = 2*!pi/100

;theta = fltarr(100)
;eqn = fltarr(100)

;for i = 0,99 do begin	
;	theta(i) = h*i
;	eqn(i) = r*r*cos(theta(i)) + r*r*sin(theta(i))
;endfor

sqr = r^2
print, 'sqr:' & print, sqr

h = r/100.
print, 'h:' & print, h

for i=0,100 do begin
	for j=0,100 do begin
		eqn = (i*h)^2 + (j*h)^2
		;print, 'eqn:' & print, eqn
		if eqn le sqr then begin
			im(xcen+i, ycen+j) = 0
			im(xcen+i, ycen-j) = 0
			im(xcen-i, ycen+j) = 0
			im(xcen-i, ycen-j) = 0
		endif
	endfor
endfor


plot_image, im
;shade_surf, im

end


