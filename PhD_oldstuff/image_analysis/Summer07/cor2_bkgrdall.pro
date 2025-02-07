; Last Edited: 10-08-07

pro cor2_bkgrdall, fls

;	ans = ''
;	sz_fls = size(fls, /dim)
;	sz_pol = sz_fls/3
	
;	for i=0,sz_fls[0]-1 do begin

;		da = sccreadfits(fls[i], in)

;		if in.polar eq 0 then begin
;			print, 'Region 150:155 ', da[150:155,150:155]
;			read, 'Divide by 2? y/n ', ans
;			if ans eq 'y' then da=da/2
;			da=(da-in.biasmean)/in.exptime
;			da=rot(da, -in.crota, 1, in.crpix1, in.crpix2, /pivot)
;			sccwritefits, 'pol0_norm_'+time2file(in.date_obs,/sec)+'.fts', $
;				da, in, comments='Rotated Normalised Image'
;		endif
;
;		if in.polar eq 120 then begin
;			print, 'Region 150:155 ', da[150:155,150:155]
;			read, 'Divide by 2? y/n ', ans
;			if ans eq 'y' then da=da/2
;			da=(da-in.biasmean)/in.exptime
;			da=rot(da, -in.crota, 1, in.crpix1, in.crpix2, /pivot)
;			sccwritefits, 'pol120_norm_'+time2file(in.date_obs,/sec)+'.fts', $
;				da, in, comments='Rotated Normalised Image'
;		endif
;
;		if in.polar eq 240 then begin
;			print, 'Region 150:155 ', da[150:155,150:155]
;			read, 'Divide by 2? y/n ', ans
;			if ans eq 'y' then da=da/2
;			da=(da-in.biasmean)/in.exptime
;			da=rot(da, -in.crota, 1, in.crpix1, in.crpix2, /pivot)
;			sccwritefits, 'pol240_norm_'+time2file(in.date_obs,/sec)+'.fts', $
;			        da, in, comments='Rotated Normalised Image'	
;		endif
;
;	endfor

	fls0 = file_search('pol0_norm*fts')
	fls120 = file_Search('pol120_norm*fts')
	fls240 = file_search('pol240_norm*fts')

	sz_pol = size(fls0, /dim)
	
	for i=0,sz_pol[0]-1 do begin
		da0 = sccreadfits(fls0[i], in0)
		da120 = sccreadfits(fls120[i], in120)
		da240 = sccreadfits(fls240[i], in240)
		da_tot = (da0 + da120 + da240) / 3
		sccwritefits, 'tot_pol_nonbkgrd_'+time2file(in0.date_obs,/sec)+'.fts', $
			da_tot, in0, comments='Combined polarisations'
	endfor

	fls = file_Search('tot_pol_nonbkgrd*')
	da = sccreadfits(fls, in)
	bkgrd = median(da, dim=3)

	for i=0,sz_pol[0]-1 do begin
		da_tot = da[*,*,i] / bkgrd
		sccwritefits, 'bkgrdall_'+time2file(in[i].date_obs, /sec)+'.fts', $
			da_tot, in[i], comments='Background divided for all polarisations together'
	endfor

	fls = file_search('bkgrdall*')
	for i=0,sz_pol[0]-1 do begin
		da = sccreadfits(fls[i], in)
		da = fmedian(da, 5, 3)
		sccwritefits, 'bkgrdall_fnorm_'+time2file(in.date_obs, /sec)+'.fts', $
			da, in, comments='Fmedian of background all image'
	endfor	
	
end
