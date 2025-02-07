; Reads in the .png files and the corresponding index and data arrays for fit ellipses.

; Last Edited: 23-07-07

pro CMEmovgraphs, fls, in, da

	angans = ''

	sz_fls = size(fls,/dim)
	temp = read_png(fls[0])
	sz_png = size(temp,/dim)
	arr = fltarr(sz_png[0],sz_png[1],sz_fls[0])

	sz_da = size(da, /dim)
	sz_in = size(in, /dim)
	hc = fltarr(sz_in[0])
	ha = hc
	angw = hc
	ra = hc
	et = hc
	semimaj = hc
	semimin = hc
	
	for i=0,sz_fls[0]-1 do arr[*,*,i]=read_png(fls[i])

	i = 0	
	j = 0
	
	while ( i lt sz_fls[0]-1) do begin
		
		fl1 = fls[i]
		
		if strlen(fl1) le 11 then begin
		
			ang = 0	
			jump0:	
			front = arr[*,*,i]
			front_ell_info, front, in[j], da[*,*,j]^0.3, height_centre, $
				height_apex, aw, ratio, ell_tilt, semimajor, semiminor, ang	
			read, 'axes ok? y/n', angans
			if angans eq 'n' then begin
				ang += 1
				ang = ang mod 4
				goto, jump0
			endif
			
			hc[j] = height_centre
			ha[j] = height_apex
			angw[j] = aw
			ra[j] = ratio
			et[j] = ell_tilt
			semimaj[j] = semimajor
			semimin[j] = semiminor
				
			i += 1
			j += 1
		
		endif else begin
			
			case3 = 0
			
			if strlen(fl1) eq 12 then begin
				front1 = arr[*,*,i]
				i += 1
				if strlen(fls[i]) eq 12 then begin
					front2 = arr[*,*,i]
					i += 1
					res = strpos(fls[i], '_c')
					if res eq 6 then begin
						front3 = arr[*,*,i]
						case3 = 1
						i += 1
					endif
				endif
			endif else if strlen(fl1) eq 13 then begin
				front1 = arr[*,*,i]
				i+=1
				if strlen(fls[i]) eq 13 then begin
					front2 = arr[*,*,i]
					i+=1
					res = strpos(fls[i], '_c')
					if res eq 7 then begin
						front3 = arr[*,*,i]
						case3 = 1
						i+=1
					endif	
				endif
			endif				

			if case3 eq 1 then lots_fronts, all, front1, front2, front3
			if case3 eq 0 then full_fronts, front1, front2, all

			ang=0
			;jump1:
			front_full_ell, all, in[j], da[*,*,j]^0.3, height_centre, $
				height_apex, aw, ratio, ell_tilt, semimajor, semiminor, ang
			;read, 'axes ok? y/n', angans
			;if angans eq 'n' then begin
			;	ang+=1 mod 4
			;	goto, jump1
			;endif	
			
                        hc[j] = height_centre
                        ha[j] = height_apex
                        angw[j] = aw
                        ra[j] = ratio
                        et[j] = ell_tilt
                        semimaj[j] = semimajor
                        semimin[j] = semiminor
			
			j += 1

		endelse

	endwhile

	save, hc, f='height_centre.sav'
	save, ha, f='height_apex.sav'
	save, angw, f='angular_width.sav'
	save, ra, f='ratio.sav'
	save, et, f='ellipse_tilt.sav'
	save, semimaj, f='semimajor.sav'
	save, semimin, f='semiminor.sav'
	
	

end
