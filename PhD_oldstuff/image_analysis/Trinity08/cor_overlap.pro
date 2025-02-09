; Testing the overlaps of the Cor1 and Cor2 fov

; Last Edited: 17-04-08

pro cor_overlap, in1, da1, in2, da2

xpoint = 3000.
ypoint = 3000.

;take a point that is 3 solar radii


index2map, in1, sigrange(da1), map1
index2map, in2, sigrange(da2), map2

x_pixoffset1 = in1.xcen / in1.cdelt1
y_pixoffset1 = in1.ycen / in1.cdelt2
x_suncenter1 = (in1.naxis1-1)/2. - x_pixoffset1
y_suncenter1 = (in1.naxis2-1)/2. - y_pixoffset1
print, 'Cor1 Sun Center: ', x_suncenter1, y_suncenter1
xpoint1 = xpoint / in1.cdelt1
ypoint1 = ypoint / in1.cdelt1


x_pixoffset2 = in2.xcen / in2.cdelt1
y_pixoffset2 = in2.ycen / in2.cdelt2
x_suncenter2 = (in2.naxis1-1)/2. - x_pixoffset2
y_suncenter2 = (in2.naxis2-1)/2. - y_pixoffset2
print, 'Cor2 Sun Center: ', x_suncenter2, y_suncenter2
xpoint2 = xpoint / in2.cdelt1
ypoint2 = ypoint / in2.cdelt2

plot_image, sigrange(da2)
plots, x_suncenter1, y_suncenter1, psym=1
pause
plots, x_suncenter2, y_suncenter2, psym=5
pause
draw_circle, x_suncenter1, y_suncenter1, 100
pause
draw_circle, x_suncenter2, y_suncenter2, 100
pause

window, 0, xs=600, ys=600
plot_map, map1, /log, /limb
plots, xpoint, ypoint, psym=1
pause
window, 1, xs=600, ys=600
plot_map, map2, /log, /limb
plots, xpoint, ypoint, psym=1

recpol, xpoint1, ypoint1, r1, a1, /degrees
recpol, xpoint2, ypoint2, r2, a2, /degrees
print, xpoint1, ypoint1, r1, a1
print, xpoint2, ypoint2, r2, a2
print, r1*in1.cdelt1
print, r2*in2.cdelt1

recpol, xpoint, ypoint, r, a, /degrees
print, r, a


end
