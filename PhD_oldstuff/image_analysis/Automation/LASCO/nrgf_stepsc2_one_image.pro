; Code for radial filtereing steps from Huw Morgan for Lasco

; Last Edited: 02-10-07

PRO nrgf_stepsC2_one_image, in, da, filt

sz = size(da, /dim)

filt = fltarr(sz[0], sz[1])

pre_make_pos, in, da, x, y

r = make_pos(x,y)

index = where( r gt 2.2 and r lt 7.9, comp=nindex )

im2 = nrgf(da, r, index)

im2[nindex] = avg(im2[index])

filt[*,*] = im2

END
