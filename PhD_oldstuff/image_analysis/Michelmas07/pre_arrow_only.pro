; Code to take the arrows alone but thicker and more visible for paper

; Call pre_spatiotemp.pro to get the mods, alps, rows and cols for a scale.

; Last Edited: 28-11-07

pro pre_arrow_only, da, in, mods, alps, rows, cols, mov

sz = size(da, /dim)

mov = fltarr(sz[0], sz[1], sz[2])

for k=0,sz[2]-1 do begin

	modnorm = mods[*,*,k] / max(mods[*,*,k])
	modl = modnorm * 50 

	win_xs = sz[0]
	win_ys = sz[1]
	
	mask = fltarr(sz[0], sz[1]) +1
	mask = rm_inner(mask, in[k], dr_px, thr=2.5)
	mask = rm_outer(mask, in[k], dr_px, thr=7.8)
	mask = rm_edges(mask, in[k], dr_px, edge=10)

	r = rows[*,*,k]*mask
	c = cols[*,*,k]*mask
	dmod = modl*mask
	dang = alps[*,*,k]*mask

	window, xs=win_xs, ys=win_ys

	for i=0,win_xs-1,15 do begin
		for j=0,win_ys-1,15 do begin
			if dmod[i,j] ne 0 then begin
				arrow2,i,j,dang[i,j],dmod[i,j],/angle,$
					/device,hsize=3,thick=2,hthick=5
			endif
		endfor
	endfor

	mov[*,*,k] = tvrd()

endfor
end
