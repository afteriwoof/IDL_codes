; Take the background image from Stereo and perform preprocessing on data

; SECCHI_PREP calls COR_PREP which does a normalisation with regard to exposure time, flat-fielding and other pre-processing.

; Inputs:
;	date = '1-Jan-2007'
;	intsr = 'Ahead' or 'Behind'
;	bkgrd_path = paths to the background fits files for each pol. angle 0,120,240
;	pb_path = output path to folder for pb data
;	totb_path = output path to folder for totb data

; Last Edited: 13-07-07

pro stereo_prep, date, instr, bkgrd_path000, bkgrd_path120, bkgrd_path240, pb_path, totb_path

	cat = cor1_pbseries(date, instr)

	sz_cat = size(cat, /dim)
	
	pol000 = sccreadfits(bkgrd_path000, hd000)
	pol120 = sccreadfits(bkgrd_path120, hd120)
	pol240 = sccreadfits(bkgrd_path240, hd240)
	pol_bk = fltarr(1024,1024,3)
	pol_bk[*,*,0] = pol000 & delvarx, pol000
	pol_bk[*,*,1] = pol120 & delvarx, pol120
	pol_bk[*,*,2] = pol240 & delvarx, pol240
		
	
	for i=0,sz_cat[1]-1 do begin
	
		secchi_prep, cat[*,i].filename, in, da, /calimg_off, /calfac_off

		cor1_point, in[0]

		newin = in[0]

		for j=0,2 do da[*,*,j] = da[*,*,j] - pol_bk[*,*,j]

		cor1_quickpol, da, totb, pb

		print, 'Writing Image', i, '  To  ', newin.filename

		sccwritefits, 'pb_'+newin.filename, pb, newin, savepath=pb_path
		sccwritefits, 'totb_'+newin.filename, totb, newin, savepath=totb_path

	endfor
	

end
