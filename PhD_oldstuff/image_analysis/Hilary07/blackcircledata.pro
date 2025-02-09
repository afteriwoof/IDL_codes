pro blackcircledata

files = file_search('../18-apr-2000/*')
mreadfits, files, index, data

im = data(*,*,0)

xcen = 512.
ycen = 512.

plot_image, im

pmm, im

r = 175.

;h = 2*!pi/100

;theta = fltarr(100)
;eqn = fltarr(100)

;for i = 0,99 do begin	
;	theta(i) = h*i
;	eqn(i) = r*r*cos(theta(i)) + r*r*sin(theta(i))
;endfor

sqr = r^2
print, 'sqr:' & print, sqr

h = r/500.
print, 'h:' & print, h

for i=0,500 do begin
	for j=0,500 do begin
		eqn = (i*h)^2 + (j*h)^2
		;print, 'eqn:' & print, eqn
		if eqn le sqr then begin
			im(xcen+i*h, ycen+j*h) = 0
			im(xcen+i*h, ycen-j*h) = 0
			im(xcen-i*h, ycen+j*h) = 0
			im(xcen-i*h, ycen-j*h) = 0
		endif
	endfor
endfor

window, /free
plot_image, im
;shade_surf, im

end


