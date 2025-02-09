; Code which makes a window of the CME based upon running difference

; Then do teh canny_atrous decomposition and the angle & magnitude information extraction

; Last Edited: 20-03-08

pro run_diff_window, in, da

; presuming data has been normalised/ffmedian/ssw_fill_cube preprocessed etc.

sz = size(da, /dim)

diff = fltarr(sz[0], sz[1], sz[2]-1)

for k=0,sz[2]-2 do begin
	diff[*,*,k] = da[*,*,k+1] - da[*,*,k]
endfor


; Make the nrgf images
nrgf_stepsC2, in, da, filt

combined_thresholds, in, da, filt


end
