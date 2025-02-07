; Using running difference technique to specify a Mask from the intensity changes.
; Using methods outlined in SEEDS Oledo paper (see rundiff_seeds.pro)

;Last Edited: 08-08-08

pro rdiff_window, da, diffmasks

sz = size(da, /dim)

diffmasks = fltarr(sz[0], sz[1], sz[2]-1)
;diffmasks = diff

for k=0,sz[2]-2 do begin
	mean0 = (moment(da[*,*,k]))[0]
	mean1 = (moment(da[*,*,k+1]))[0]
	div = mean1 / mean0
	im = da[*,*,k] * div
	temp = da[*,*,k+1] - im
	;diff[*,*,k] = da[*,*,k+1] - im
	mu = moment(temp, sdev=sdev)
	;mu = moment(diff[*,*,k], sdev=sdev)
	ind = where(temp gt (mu[0]+0.5*sdev))
	;ind = where(diff[*,*,k] gt (mu[0]))
	mask = fltarr(sz[0], sz[1])
	mask[ind] = 1
	diffmasks[*,*,k] = mask[*,*]
endfor



end
