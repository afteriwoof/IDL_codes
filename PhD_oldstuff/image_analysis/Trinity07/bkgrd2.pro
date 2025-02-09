; Last edited: 22-05-07

; Program based on bkgrd.pro but with the centre as the centre of the image array.
; and using an image with a fake CME in order to see how it affects the pixel distribution.

; Second quadrant


pro bkgrd2

restore, '~/PhD/Data_sav_files/in.sav'
restore, '~/PhD/Data_sav_files/dan.sav'

ans = ''

window, 0
im = dan[*,*,0]

plot_image, im

plots, [512,512], [512,1024], color=3


newim = fltarr(1024,1024)

newim = rm_inner(im,in[0],dr_px,thr=2.4)
newim = rm_outer(newim,in[0],dr_px,thr=6.)

window, 1
plot, newim[*, 512]
set_line_color
oplot, newim[512, *], color=2


; Attempting to define a radial line by simply increasing the angle but
; through the idea of increasing the pixel in the y relative to its position
; in the x.

lines = fltarr(2, 512, 40)

for j=0,511 do begin
	; declaring first radial line
	lines[0,j,0] = 512 
	lines[1,j,0] = 512 + j 
endfor

window, 2
plot_image, newim 
oplot, lines[0,*,0], lines[1,*,0], color=4

; Now getting the increasing lines
;for i=1,39 do begin
;	for j=0,511 do begin
;		x = j
;		y = (0.1 * j)
;		lines[0,j,i] = lines[0,j,i-1]
;		lines[1,j,i] = lines[1,j,i-1] + y
;		oplot, lines[0,*,i], lines[1,*,i], color=(i mod 8), psym=3
;	endfor
;endfor



; That wasn't working properly, so now try using the Cosine Rule

;alpha = 0.
;radius = 512.
;
;for i=1,39 do begin
;	for j=0,511 do begin
;		x = j
;		;y = sqrt((radius^2.) + (radius-x)^2. - 2.*radius*(radius-x)*cos(alpha))
;		y = sqrt((x^2.) + (x^2.) - 2*x*x*cos(alpha))
;		lines[0,j,i] = lines[0,j,i-1]
;		lines[1,j,i] = lines[1,j,i-1] + y
;		oplot, lines[0,*,i], lines[1,*,i], color=(i mod 8), psym=3
;	endfor
;	alpha = alpha + 5.
;endfor


; Cosine rule not working out...now just trying 3 line equations in first quadrant!

;count = [0., 0.5, 1., 2., 0.]
;
;for i=1,3 do begin
;	for j=0,511 do begin
;		x = j
;		y = count[i]*x
;		lines[0,j,i] = 512 + x
;		lines[1,j,i] = 512 + y
;		oplot, lines[0,*,i], lines[1,*,i], color=(i mod 8), psym=3
;	endfor
;endfor
;
;window, 3
;plot, newim[[lines[0,*,0]],[lines[1,*,0]]]
;for i=1,3 do begin
;	oplot, newim[[lines[0,*,i]],[lines[1,*,i]]]
;endfor


; Trying the map space and polar coords with transforms between...complicated tho!

window, 4

index2map, in[0], newim, map

plot_map, map

x_first = fltarr(20)
y_first = fltarr(20)
radius = 6000.
theta = 90.
for i=0,19 do begin
	polrec, radius, theta, x, y, /degrees
	x_first[i] = x
	y_first[i] = y
	plots, [0,x], [0,y]
	theta = theta + 4.5
endfor


x_orig = fltarr(20)
y_orig = fltarr(20)
window, 5
plot_image, im
for i=0,19 do begin
	x_orig[i] = (x_first[i] / in[0].cdelt1 ) + 512
	y_orig[i] = (y_first[i] / in[0].cdelt2 ) + 512
	plots, [512, x_orig[i]], [512, y_orig[i]]
endfor
oplot, [512,512], [512,512], psym=7, color=4

window, 6
profs = fltarr(512,20)
help, profs
result = profile(newim,xx,yy,xi=512,xf=x_orig[0],yi=512,yf=y_orig[0])
sz_res = size(result, /dim)
profs[0:sz_res[0]-1,0] = result
;plot, profs[*,0]
for i=1,19 do begin
	result = profile(newim,xx,yy,xi=512,xf=x_orig[i],yi=512,yf=y_orig[i] )
	help, result
	sz_res = size(result, /dim)
	profs[0:sz_res[0]-1,i] = result
	help, profs
	;oplot, profs[*,i]
	;read, 'ok?', ans
endfor

window, 7
temp = fltarr(512, 20)
profs0 = profs[where(profs[*,0] ne 0.), 0]
sz_profs0 = size(profs0,/dim)
temp[0:sz_profs0[0]-1,0] = profs0
plot, temp[*,0], xr=[-200,400], yr=[0,200]
for i=0,19 do begin
	profs0 = profs[where(profs[*,i] ne 0.), i]
	help, profs0
	sz_profs0 = size(profs0,/dim)
	temp[0:sz_profs0[0]-1,i] = profs0
	help, temp
	oplot, temp[*,i], color=(i mod 7)
	;read, 'ok?', ans
endfor





end
