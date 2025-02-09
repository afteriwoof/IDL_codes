function polar, image, xcen, ycen
	sz = size(image)
        xmax = max([abs(sz(1)-xcen-1),xcen])
        ymax = max([abs(sz(2)-ycen-1),ycen])
        rmax = sqrt(xmax^2 + ymax^2)
        nr = round(rmax)+1
        r = findgen(nr) # replicate(1,360)
        theta = replicate(!dtor,nr) # findgen(360)
        i = fix(r*cos(theta) + xcen)
        j = fix(r*sin(theta) + ycen)
        w = where((i lt 0) or (i ge sz(1)) or (j lt 0) or (j ge sz(2)))
        if sz(0) eq 3 then nz=sz(3) else nz=1
        result = fltarr(nr,360,nz)

        for k=0,nz-1 do begin
		temp = image(*,*,k)
		temp = temp(i,j)
		temp(w) = 0
		result(0,0,k) = temp
	endfor

        return, result
end	





; Want to take out polar regions of arrows of the image

; Taken from attempts written in polar_rings.pro

; Finalised as polar_regions.pro and renamed to cme_detection.pro

; Last Edited: 14-05-08

; Best to read in NRGF data

; One image detection 

pro cme_detection_contours2_one_image, in, da, modgrads, alpgrads, circ_pol, list, show=show

sz = size(da, /dim)
sz_mod = size(modgrads, /dim)
!p.multi=[0,2,1]
no_contours = 4
circ_pol = fltarr(180, no_contours,sz_mod[2])
circ_pol_norm = circ_pol
cme_detect = fltarr(800,600,no_contours*sz_mod[2])
count = -1
list = bytarr(sz_mod[2]) ;where list entry is 1 the corresponding image contains a CME

for s=0,sz_mod[2]-1 do begin
; for each scale in the decomp.	
	
	;mag_chain, modgrads, magchains
	;xstepper, magchains, xs=700
	
	
	im_pol = polar(da, in.crpix1, in.crpix2)
	;tvscl, im_pol
	
	alp_pol = rm_inner(alpgrads[*,*,s], in, dr_px, thr=2.5)
	alp_pol = rm_outer(alp_pol, in, dr_px, thr=6.0)
	mod_pol = rm_inner(modgrads[*,*,s], in, dr_px, thr=2.5)
	mod_pol = rm_outer(mod_pol, in, dr_px, thr=6.0)
	mod_rm = mod_pol
	mu = moment(mod_rm, sdev=sdev)
	thresh = mu[0] + 1*sdev
	plot_image, sigrange(mod_rm)
	contour, mod_rm, lev=thresh, /over
	pause
	contour, mod_rm, lev=thresh, path_xy=xy, path_info=info, /path_data_coords
	mask = bytarr(sz[0], sz[1])
	for c=0,no_contours-1 do begin
		x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)]
		y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)]
		ind = polyfillv(x,y,sz[0],sz[1])
		mask[ind] = 1
	endfor
	mask_pol = polar(mask, in.crpix1, in.crpix2)
	sz_mask_pol = size(mask_pol, /dim)
	cont_break = 0
	line_mask_count = 0
	while cont_break eq 0 do begin
		line_mask = bytarr(sz_mask_pol[0], sz_mask_pol[1])
		line_mask[*,line_mask_count] = 1
		temp = line_mask + mask_pol
		cross = where(temp eq 2)
		if cross eq [-1] then cont_break=1
		line_mask_count += 1
		if line_mask_count ge (sz_mask_pol[1]-1) then cont_break=1
	endwhile
	
	alp_pol = polar(alp_pol, in.crpix1, in.crpix2)
	mod_pol = polar(mod_pol, in.crpix1, in.crpix2)
        mod_sz = size(mod_pol, /dim)
	; Making the unwrapped image not cut across a contour so it doesn't split up the CME if possible.
	alp_pol_seg = alp_pol[*,0:line_mask_count-1]
	temp = fltarr(mod_sz[0], mod_sz[1])
	temp[*,0:(mod_sz[1]-1-line_mask_count)] = alp_pol[*,line_mask_count:*]
	temp[*,(mod_sz[1]-line_mask_count):*] = alp_pol_seg
	alp_pol = temp
	mod_pol_seg = mod_pol[*,0:line_mask_count-1]
	temp = fltarr(mod_sz[0], mod_sz[1])
	temp[*,0:(mod_sz[1]-1-line_mask_count)] = mod_pol[*,line_mask_count:*]
	temp[*,(mod_sz[1]-line_mask_count):*] = mod_pol_seg
	mod_pol = temp
	
	
	mod_pol = mod_pol[200:500,*]
        alp_pol = alp_pol[200:500,*]
	
        mod_sz = size(mod_pol, /dim)
	;print, mu, sdev
	;print, thresh

	mu = moment(mod_pol, sdev=sdev)
	thresh = mu[0] + 1*sdev
	;plot_image, mod_pol
	;contour, mod_pol, lev=thresh, /over
	;pause
	contour, mod_pol, lev=thresh, path_xy=xy, path_info=info, /path_data_coords
	if keyword_set(show) then window, xs=800, ys=600
	;while size(info, /dim) lt no_contours do no_contours-=1
	for c=0,no_contours-1 do begin
		x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)]
		y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)]	
		ind = polyfillv(x, y, mod_sz[0], mod_sz[1])
		thresh_mask_show = fltarr(mod_sz[0], mod_sz[1]) + 0.2
		thresh_mask = fltarr(mod_sz[0], mod_sz[1])
		thresh_mask_show[ind] = 1
		thresh_mask[ind] = 1
		alp_pol_thr = alp_pol*thresh_mask
		mod_pol_thr = mod_pol*thresh_mask
		;loadct, 0
		if keyword_set(show) then plot_image, sigrange(mod_pol*thresh_mask_show), tit='Scale'+string(s)+'    Contour'+string(c)
			
		; Making the movie of the rows now to see how the angle changes across image.
		total_mu = 0.
		indiv_mu = fltarr(mod_sz[1])
		for j=0,mod_sz[1]-1 do begin
			alp_row = alp_pol_thr[*,j]
			mod_row = mod_pol_thr[*,j]
		 	indiv_mu[j] = mean(alp_row)
		        total_mu += indiv_mu[j]
			;window, xs=600, ys=800
			;plot_image, mod_pol, xtit = indiv_mu[j]
			;plots,[0,mod_sz[0]-1], [j,j]
			;plot, alp_pol[*,j], xtickname=[" "," "," "," "," "]
			for i=0,mod_sz[0]-1 do begin
				if mod_pol_thr[i,j] ne 0 then begin
					circ_pol[(alp_pol_thr[i,j] mod 180), c, s] += 1
					if keyword_set(show) then begin
						arrow2, i+50, 30, alp_pol_thr[i,j], mod_pol_thr[i,j]*400, /angle, hsize=3, thick=1
						arrow2, 400, 30, alp_pol_thr[i,j], mod_pol_thr[i,j]*400, /angle, hsize=3, thick=1
					endif
				endif
			endfor
		endfor
		circ_pol[*,c,s] = circ_pol[*,c,s] / max(circ_pol[*,c,s])
		;plot, circ_pol[*,c,s], color=c+1
		; centre circ_pol on its maximum at coord 90
		circ_pol1 = circ_pol[*,c,s]
		temp=fltarr(180)
		tip = (where(circ_pol[*,c,s] eq 1))[0]
		if tip eq 90 then temp=circ_pol1
		if tip gt 90 then begin
			temp[0:90]=circ_pol1[(tip-90):tip]
			for i=91,179 do temp[i]=circ_pol1[((tip+(i-90)) mod 180)]
		endif
		if tip lt 90 then begin
			for i=0,90 do temp[i]=circ_pol1[(90+tip+i) mod 180]
			temp[91:179]=circ_pol1[(tip+1):(tip+90)-1]
		endif
		med_temp = median(temp)
		if keyword_set(show) then begin
			plot, temp, xr=[0,180], /xs, ytit=med_temp;, color=c+1
			plots, [0,180], [med_temp, med_temp], line=1
		endif
		circ_pol[*,c,s]=temp
		; old threshold plots, [0,200], [0.4,0.4], line=2
		; old threshold plots, [0,200], [0.35,0.35], line=2
		;pause

		;***
		; old threshold range = where(circ_pol[*,c,s] gt 0.35 and circ_pol[*,c,s] lt 0.4)
		; old threshold range = max(range)-min(range)
		; old threshold if range gt 70 then begin
		; old threshold 	list[s] = 1
		; old threshold 	legend, '*** CME DETECTED ***', charsize=3;, /bottom
		; old threshold 	print, '***** CME DETECTED *****' & print, 'contour: ', c, ' in image: ', s
		; old threshold 	wait, 2
		; old threshold endif
		
		if med_temp gt 0.05 then begin
			list[s] = 1
			if keyword_set(show) then legend, '*** CME DETECTED ***', charsize=2 & wait, 2;, /bottom
			print, '***** CME DETECTED *****' & print, 'contour: ', c, ' at scale: ', s
		endif
		count += 1
	;	cme_detect[*,*,count] = tvrd()
		;if c eq 0 then plot, abs(deriv(circ_pol[*,c,s])) else oplot, abs(deriv(circ_pol[*,c,s])), color=c+1
		;wr_movie, 'mov_row1_plot', mov_row1_plot

		;circ_pol_mu = moment(circ_pol[*,c,s], sdev=sdev)
		;print, 'for contour ', c
		;print, circ_pol_mu, sdev
		;fwhm = 2 * sqrt ( 2*alog(2)) * sdev
		;print, 'fwhm:', fwhm
		;print, circ_pol[*,c]
		;y=indgen(360)
		;x = fltarr(no_contours)
		;x[c] = integral(circ_pol[*,c,s], y)
		;print, 'integral: ', x[c]
		
	endfor


endfor

	;wr_movie, 'cme_detect', cme_detect	

end
