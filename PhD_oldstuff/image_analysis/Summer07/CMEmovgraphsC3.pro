; Reads in the .png files and the corresponding index and data arrays for fit ellipses.

; cd to directory where sav files are required to output to and run from there!

; Last Edited: 07-08-07

pro CMEmovgraphsC3, pngfls, in, da, ang

	angans = ''

	window, 0, xs=800, ys=800
	
	sz_fls = size(pngfls,/dim)
	temp = read_png(pngfls[0])
	sz_png = size(temp,/dim)
	arr = fltarr(sz_png[0],sz_png[1],sz_fls[0])

	sz_da = size(da, /dim)
	sz_in = size(in, /dim)
	hcB = fltarr(sz_in[0])
	haB = hcB
	angwB = hcB
	raB = hcB
	etB = hcB
	semimajB = hcB
	semiminB = hcB

	mov = fltarr(800,800,sz_in[0])
	
	for i=0,sz_fls[0]-1 do arr[*,*,i]=read_png(pngfls[i])

	i = 0	
	j = 0
	
	while ( i lt sz_fls[0]-1) do begin
		
		pngfl1 = pngfls[i]
		print, 'i: ', i
		print, 'strlen(pngfl1): ', strlen(pngfl1)	
		if strlen(pngfl1) le 11 then begin
		
			ang = 0	
			front = arr[*,*,i]
			lasco_front_ell, front, in[j], da[*,*,j], height_centre, $
				height_apex, aw, ratio, ell_tilt, semimajor, semiminor, ang	
			
			hcB[j] = height_centre
			haB[j] = height_apex
			angwB[j] = aw
			raB[j] = ratio
			etB[j] = ell_tilt
			semimajB[j] = semimajor
			semiminB[j] = semiminor
			
			mov[*,*,j] = tvrd()		
			
			i += 1
			j += 1
		
		endif else begin
			
			case2 = 1
			case3 = 0
			case4 = 0
			case5 = 0
			case6 = 0
			case7 = 0
			case8 = 0
			
			if strlen(pngfl1) eq 12 then begin
				front1 = arr[*,*,i]
				if (i+1) lt sz_fls then i+=1
				if strlen(pngfls[i]) eq 12 then begin
					front2 = arr[*,*,i]
					if (i+1) lt sz_fls then i+=1
					res = strpos(pngfls[i], '_c')
					if res eq 6 then begin
						front3 = arr[*,*,i]
						case2 = 0
						case3 = 1
						if (i+1) lt sz_fls then i+=1
						res = strpos(pngfls[i], '_d')
						if res eq 6 then begin
							front4 = arr[*,*,i]
							case3 = 0
							case4 = 1
							if (i+1) lt sz_fls then i+=1
							res = strpos(pngfls[i], '_e')
							if res eq 6 then begin
								front5 = arr[*,*,i]
								case4 = 0
								case5 = 1
								if (i+1) lt sz_fls then i+=1
								res = strpos(pngfls[i], '_f')
								if res eq 6 then begin
									front6 = arr[*,*,i]
									case5 = 0
									case6 = 1
									if (i+1) lt sz_fls then i+=1
									res = strpos(pngfls[i], '_g')
									if res eq 6 then begin
										front7 = arr[*,*,i]
										case6 = 0
										case7 = 1
										if (i+1) lt sz_fls then i+=1
										res = strpos(pngfls[i], '_h')
										if res eq 6 then begin
											front8 = arr[*,*,i]
											case7 = 0
											case8 = 1
											if (i+1) lt sz_fls then i+=1
										endif
									endif
								endif
							endif
						endif
					endif
				endif
			endif else if strlen(pngfl1) eq 13 then begin
				print, pngfl1 & print, i
				front1 = arr[*,*,i]
				help, front1, arr
				if (i+1) lt sz_fls then i+=1
				if strlen(pngfls[i]) eq 13 then begin
					print, pngfls[i] & print, i
					front2 = arr[*,*,i]
					if (i+1) lt sz_fls then i+=1
					res = strpos(pngfls[i], '_c')
					print, 'res ', res
					if res eq 7 then begin
						front3 = arr[*,*,i]
						case2 = 0
						case3 = 1
						if (i+1) lt sz_fls then i+=1
						res = strpos(pngfls[i], '_d')
						print, 'res ', res
						if res eq 7 then begin
							front4 = arr[*,*,i]
							case3 = 0
							case4 = 1
							if (i+1) lt sz_fls then i+=1
							res = strpos(pngfls[i], '_e')
							print, 'res ', res
							if res eq 7 then begin
								front5 = arr[*,*,i]
								case4 = 0
								case5 = 1
								if (i+1) lt sz_fls then i+=1
								res = strpos(pngfls[i], '_f')
								print, 'res ', res
								if res eq 7 then begin
									front6 = arr[*,*,i]
									case5 = 0
									case6 = 1
									if (i+1) lt sz_fls then i+=1
									res = strpos(pngfls[i], '_g')
									if res eq 7 then begin
										front7 = arr[*,*,i]
										case6 = 0
										case7 = 1
										if (i+1) lt sz_fls then i+=1
										res = strpos(pngfls[i], '_h')
										if res eq 7 then begin
											front8 = arr[*,*,i]
											case7 = 0
											case8 = 1
											if (i+1) lt sz_fls then i+=1
										endif
									endif
								endif
							endif
						endif	
					endif	
				endif
			endif				

			if case3 eq 1 then lots_fronts, all, front1, front2, front3
			if case2 eq 1 then full_fronts, front1, front2, all
			if case4 eq 1 then four_fronts, all, front1, front2, front3, front4
			if case5 eq 1 then five_fronts, all, front1, front2, front3, front4, front5
			if case6 eq 1 then six_fronts, all, front1, front2, front3, front4, front5, front6
			if case7 eq 1 then seven_fronts, all, front1, front2, front3, front4, front5, front6, front7
			if case8 eq 1 then eight_fronts, all, front1, front2, front3, front4, front5, front6, $
				front7, front8
			
			ang=0
			lasco_full_fronts_ell, all, in[j], da[*,*,j], height_centre, $
				height_apex, aw, ratio, ell_tilt, semimajor, semiminor, ang
			
                        hcB[j] = height_centre
                        haB[j] = height_apex
                        angwB[j] = aw
                        raB[j] = ratio
                        etB[j] = ell_tilt
                        semimajB[j] = semimajor
                        semiminB[j] = semiminor

			mov[*,*,j] = tvrd()		

			j += 1

		endelse
	
	endwhile

	save, hcB, f='height_centreC3.sav'
	save, haB, f='height_apexC3.sav'
	save, angwB, f='angular_widthC3.sav'
	save, raB, f='ratioC3.sav'
	save, etB, f='ellipse_tiltC3.sav'
	save, semimajB, f='semimajorC3.sav'
	save, semiminB, f='semiminorC3.sav'
	
	wr_movie, 'C3_movie_ell', mov
	

end
