; Last edited: 06-08-07

PRO rot_norms_stereo

fls=file_search('../*fts')
da=sccreadfits(fls)
fls=file_search('../../*fts')
temp=sccreadfits(fls, in)
delvarx, temp

sz = size(da, /dim)

; Remove inner disk and perform fmedian filter (slow!)
for i=0,sz[2]-1 do begin
	da[*,*,i] = rot(da[*,*,i], -in[i].crota, 1., in[i].crpix1, in[i].crpix2)
	da[*,*,i] = rm_outer(da[*,*,i], in[i], dr_px, thr=4.2)
	in[i].crota = 0
	sccwritefits, 'norm_rot_'+time2file(in[i].date_obs,/sec)+'.fts', $
		da[*,*,i], in[i], comments='Rotated Image'
	
endfor

END
