; Code to read the different images for print out arrow overlays for the paper.

; Last Edited: 20-02-08

pro arrow_cme

cd,'~/phd/data_vso/20000102/'
@read.b
k=2
cd, '~/phd/idlstuff/image_analysis/michelmas07/nrgf'
nrgf_stepsc2, inc2, dac2, filtc2
cd,'..'
pre_spatiotemp, filtc2, 5, modsc2, alpsc2, rowsc2, colsc2
x = [550,1000]
y = [150,600]
mask = fltarr(1024,1024)+1
mask = rm_inner(mask, inc2[k], dr_px, thr=2.5)
mask = rm_outer(mask, inc2[k], dr_px, thr=6.85)
mask = rm_edges(mask, inc2[k], dr_px, edge=10)
r = rowsc2[*,*,k]*mask
c = colsc2[*,*,k]*mask
modnorm = modsc2[*,*,k]/max(modsc2)
modl = modnorm*70
dmod = modl*mask
dang = alpsc2[*,*,k]*mask
filtered = filtc2[*,*,k]*mask
im = fltarr(1024,1024)
cme = im[x[0]:x[1],y[0]:y[1]]
dmod = dmod[x[0]:x[1],y[0]:y[1]]
dang = dang[x[0]:x[1],y[0]:y[1]]
cmefilt = filtered[x[0]:x[1],y[0]:y[1]]
;toggle, f='20000102_arrow.ps'
for i=0,449,15 do begin
	for j=0,449,15 do begin
		if dmod[i,j] ne 0 then begin
			arrow2, i, j, dang[i,j], dmod[i,j], /angle, /data, $
				hsize=160, thick=8, hthick=8, color=255
		endif
	endfor
endfor
;toggle




end
