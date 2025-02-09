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

; Last Edited: 26-03-08

; Best to read in NRGF data

pro polar_regions, in, da, alpgrads, modgrads, circ_pol 

sz = size(da, /dim)

no_contours = 6
circ_pol = fltarr(360, no_contours, sz[2])
circ_pol_norm = circ_pol

for s=2,sz[2]-1 do begin
	
	im = da[*,*,s]
	
	
	;mag_chain, modgrads, magchains
	;xstepper, magchains, xs=700
	
	
	im_pol = polar(im, in[s].crpix1, in[s].crpix2)
	;tvscl, im_pol
	
	alp_pol = rm_inner(alpgrads[*,*,s], in[s], dr_px, thr=2.5)
	alp_pol = rm_outer(alp_pol, in[s], dr_px, thr=6.0)
	mod_pol = rm_inner(modgrads[*,*,s], in[s], dr_px, thr=2.5)
	mod_pol = rm_outer(mod_pol, in[s], dr_px, thr=6.0)
	alp_pol = polar(alp_pol, in[s].crpix1, in[s].crpix2)
	mod_pol = polar(mod_pol, in[s].crpix1, in[s].crpix2)
	

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
	;contour, mod_pol, lev=thresh, path_xy=xy, path_info=info, /path_data_coords
	for c=0,no_contours-1 do begin
		;x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)]
		;y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)]	
		;ind = polyfillv(x, y, mod_sz[0], mod_sz[1])
		;thresh_mask_show = fltarr(mod_sz[0], mod_sz[1]) + 0.2
		;thresh_mask = fltarr(mod_sz[0], mod_sz[1])
		;thresh_mask_show[ind] = 1
		;thresh_mask[ind] = 1
		;alp_pol_thr = alp_pol*thresh_mask
		;mod_pol_thr = mod_pol*thresh_mask
		alp_pol_thr = alp_pol
		mod_pol_thr = mod_pol
		;loadct, 0
		;plot_image, sigrange(mod_pol*thresh_mask_show)
		;pause
		
		;tvscl, alp_pol
	
		; Making the movie of the rows now to see how the angle changes across image.
		mov_row2_plot = fltarr(400,600,mod_sz[1]/2)
		total_mu = 0.
		indiv_mu = fltarr(mod_sz[1])
		for j=0,mod_sz[1]-1,2 do begin
			alp_row = alp_pol_thr[*,j]
			mod_row = mod_pol_thr[*,j]
		 	indiv_mu[j] = mean(alp_row)
		        total_mu += indiv_mu[j]
			window, xs=400, ys=600
			plot_image, sigrange(mod_pol);, xtit = indiv_mu[j]
			plots,[0,mod_sz[0]-1], [j,j]
			;plot, alp_pol[*,j], xtickname=[" "," "," "," "," "]
			for i=0,mod_sz[0]-1 do begin
				if mod_pol_thr[i,j] ne 0 then begin
					circ_pol[alp_pol_thr[i,j], c, s] += 1
					arrow2, i, 30, alp_pol_thr[i,j], mod_pol_thr[i,j]*400, /angle, hsize=3, thick=1
					arrow2, 350, 30, alp_pol_thr[i,j], mod_pol_thr[i,j]*400, /angle, hsize=3, thick=1
				endif
			endfor
			mov_row2_plot[*,*,j/2] = tvrd()
		endfor
		;set_line_color
		circ_pol[*,c,s] = circ_pol[*,c,s] / max(circ_pol[*,c,s])
		;plot, circ_pol[*,c,s], color=c+1
		range = where(circ_pol[*,c,s] gt 0.3 and circ_pol[*,c,s] lt 0.4)
		range = max(range)-min(range)
		if range gt 150 then begin
			legend, '*** CME DETECTED ***', charsize=3
			print, '***** CME DETECTED *****' & print, 'contour: ', c, ' in image: ', s
			pause
		endif
		;if c eq 0 then plot, abs(deriv(circ_pol[*,c,s])) else oplot, abs(deriv(circ_pol[*,c,s])), color=c+1
		wr_movie, 'mov_row2_plot', mov_row2_plot

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

end
