; Code to work out the angular width of an ellipse when it actually crosses the 0/360 line.

; Last Edited: 05-12-07

function shift_ell, in, da, x_ell, y_ell, p

true=0
sz_da = size(da,/dim)
sz = size(x_ell,/dim)

; transform back into array space (from the map space)
xe = x_ell/in.cdelt1 + in.crpix1
ye = y_ell/in.cdelt2 + in.crpix2
xec = p[2]/in.cdelt1 + in.crpix1
yec = p[3]/in.cdelt2 + in.crpix2

;to see if the ellipse needs shifting, make masks of ellipse and 0/360 line and add.
res = polyfillv( [xec, xe[0], xe[1]], [yec, ye[0], ye[1]], sz_da[0], sz_da[1] )
for i=1,sz[0]-2 do begin
	res2 = polyfillv( [xec, xe[i], xe[i+1]], [yec, ye[i], ye[i+1]], sz_da[0], sz_da[1] )
	res = [res,res2]
endfor
ell_mask=fltarr(sz_da[0], sz_da[1])
ell_mask[res] = 1
;plot_image, ell_mask

line_mask = fltarr(sz_da[0],sz_da[1])
line_mask[in.crpix1:sz_da[0]-1, in.crpix2] = 1
;plot_image, line_mask

intersect = line_mask + ell_mask
if max(intersect) eq 2 then true=1

return, true

end
