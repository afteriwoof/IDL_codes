; Code to combine the CME detection of the angle info in CME_DETECTION.pro with COMBINED_THRESHOLDS.pro and localise a CME in given data set

pro automated_detection, in, da, list

sz = size(in,/dim)

list = bytarr(sz, 5)

for k=0,sz[0]-1 do begin

	if in[k].detector eq 'C2' then nrgf_stepsc2_one_image, in[k], da[*,*,k], filt
	if in[k].detector eq 'C3' then nrgf_stepsc3_one_image, in[k], da[*,*,k], filt
	
	;pre_spatiotemp, filt, 5, modgrads, alpgrads
	canny_atrous2d, filt, modgrad, alpgrad

	print, 'IMAGE ', k
	
	if in[k].detector eq 'C2' then cme_detection_mask, in[k], filt, modgrad[*,*,2:6], alpgrad[*,*,2:6], circ_pol, list_single, cme_detect, /show
	if in[k].detector eq 'C3' then cme_detection_maskC3, in[k], filt, modgrad[*,*,2:6], alpgrad[*,*,2:6], circ_pol, list_single, cme_detect;, /show
	
	wr_movie, 'cme_detect_temp_'+in[k].detector+'_masks'+string(k), cme_detect
	
	list[k,*]=list_single
	
endfor


end
