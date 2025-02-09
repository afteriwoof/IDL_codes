; Reads in the .png files and the corresponding index and data arrays for fit ellipses.

; Last Edited: 20-07-07

pro CMEmovgraphs2, fitsfls, fls, in, da

	!p.multi=0
	angans = ''

	sz_fls = size(fls,/dim)
	temp = read_png(fls[0])
	sz_png = size(temp,/dim)
	arr = fltarr(sz_png[0],sz_png[1],sz_fls[0])

	sz_da = size(da, /dim)
	sz_in = size(in, /dim)

	window, 0, xs=900, ys=900, xpos=100, ypos=100
	mov = fltarr(900,900,sz_in[0])

	time_ar = file2time(fitsfls)
	utbasedata = time_ar[0]
	timeplot = anytim(time_ar)-anytim(time_ar[0])
	
	restore, 'height_apex.sav' ; ha
	restore, 'height_centre.sav' ; hc
	restore, 'angular_width.sav' ; aw
	restore, 'ellipse_tilt.sav' ; et
	restore, 'ratio.sav' ; ra
	restore, 'semimajor.sav' ; semimaj
	restore, 'semiminor.sav' ; semimin
	
	for i=0,sz_fls[0]-1 do arr[*,*,i]=read_png(fls[i])

	i = 0	
	j = 0
	
	while ( i lt sz_fls[0]-1) do begin
		
		fl1 = fls[i]
		
		if strlen(fl1) lt 11 then begin
			
			!p.charsize = 1
			!p.multi = [0,2,2]
			plot_image, da[*,*,j]^0.3, tit='CME Image'
			!p.multi = [2,2,2]

			ang=0	
			jump0:
			front = arr[*,*,i]
			front_ell_info, front, in[j], da[*,*,j]^0.3, height_centre, $
				height_apex, aw, ratio, ell_tilt, semimajor, semiminor, ang
			read, 'axes ok? y/n', angans
			if angans eq 'n' then begin
				ang+=1 mod 4
				goto, jump0
			endif
			
			!p.multi = [9,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], ha, utbasedata, psym=-2, tit='Height Apex', $
				yr=[min(ha[0:sz_in[0]-1])*0.9, max(ha)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(ha[0:sz_in[0]-1])*0.9, max(ha)*1.1], $
				color=255, linestyle=2
			!p.multi = [7,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], hc, utbasedata, psym=-2, tit='Height Centre Point', $
				yr=[min(hc[0:sz_in[0]-1])*0.9, max(hc)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(hc[0:sz_in[0]-1])*0.9, max(hc)*1.1], $
				color=255, linestyle=2
			!p.multi = [5,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], ra, utbasedata, psym=-2, tit='Ratio Major/Minor', $
				yr=[min(ra[0:sz_in[0]-1])*0.9, max(ra)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(ra[0:sz_in[0]-1])*0.9, max(ra)*1.1], $
			        color=255, linestyle=2
			!p.multi = [3,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], angw, utbasedata, psym=-2, tit='Angular Width', $
				yr=[min(angw[0:sz_in[0]-1])*0.9, max(angw)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(angw[0:sz_in[0]-1])*0.9, max(angw)*1.1], $
			        color=255, linestyle=2
			!p.multi = [1,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], et, utbasedata, psym=-2, tit='Ellipse Tilt Angle', $
				yr=[min(et[0:sz_in[0]-1])*0.9, max(et)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(et[0:sz_in[0]-1])*0.9, max(et)*1.1], $
			        color=255, linestyle=2
				
			pause

			tvlct, R, G, B, /get
			mov[*,*,j] = tvrd()
			
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


			!p.charsize = 1
			!p.multi = [0,2,2]
			plot_image, da[*,*,j]^0.3, tit='CME Image'
			ang=0
			;jump1:
			!p.multi = [2,2,2]
			front_full_ell, all, in[j], da[*,*,j]^0.3, height_centre, $
				height_apex, aw, ratio, ell_tilt, semimajor, semiminor, ang
			;read, 'axes ok? y/n', angans
			;if angans eq 'n' then begin
			;	ang+=1 mod 4
			;	goto, jump1
			;endif

			!p.multi = [9,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], ha, utbasedata, psym=-2, tit='Height Apex', $
				yr=[min(ha[0:sz_in[0]-1])*0.9, max(ha)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(ha[0:sz_in[0]-1])*0.9, max(ha)*1.1], $
				color=255, linestyle=2
			!p.multi = [7,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], hc, utbasedata, psym=-2, tit='Height Centre Point', $
				yr=[min(hc[0:sz_in[0]-1])*0.9, max(hc)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(hc[0:sz_in[0]-1])*0.9, max(hc)*1.1], $
				color=255, linestyle=2
			!p.multi = [5,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], ra, utbasedata, psym=-2, tit='Ratio Major/Minor', $
				yr=[min(ra[0:sz_in[0]-1])*0.9, max(ra)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(ra[0:sz_in[0]-1])*0.9, max(ra)*1.1], $
			        color=255, linestyle=2
			!p.multi = [3,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], angw, utbasedata, psym=-2, tit='Angular Width', $
				yr=[min(angw[0:sz_in[0]-1])*0.9, max(angw)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(angw[0:sz_in[0]-1])*0.9, max(angw)*1.1], $
			        color=255, linestyle=2
			!p.multi = [1,2,5]
			!p.charsize = 1.5
			utplot, timeplot[0:sz_in[0]-1], et, utbasedata, psym=-2, tit='Ellipse Tilt Angle', $
				yr=[min(et[0:sz_in[0]-1])*0.9, max(et)*1.1], /xstyle
			plots, [timeplot[j], timeplot[j]], [min(et[0:sz_in[0]-1])*0.9, max(et)*1.1], $
			        color=255, linestyle=2
				
			pause
			mov[*,*,j] = tvrd()

			
			j += 1

		endelse

	endwhile

	wr_movie, 'Graphs_plots', mov, framedelay=50, red=R, green=G, blue=B

	

end
