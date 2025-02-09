pro cor2_bkgrd, fls

	sz_fls = size(fls, /dim)

	da = sccreadfits(fls, in)

	bkgrd = median(da, dim=3)

	for i=0,sz_fls[0]-1 do begin
		da[*,*,i] = da[*,*,i] / bkgrd
		sccwritefits, 'prepped_'+time2file(in[i].date_obs,/sec)+'.fts', $
			da[*,*,i], in[i], comments='Background subtracted'
	endfor
		



end
