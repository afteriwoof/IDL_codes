; Created:      2012-10-16      from fit_kinscasestudy.pro for the CME data.


pro fit_kinscme, restore_fl, lagrangian=lagrangian, quadratic=quadratic, cubic=cubic, powerlaw=powerlaw, exponential=exponential, sav_gol=sav_gol, residuals=residuals, fuzzy_error=fuzzy_error, bootstrap=bootstrap, tog=tog, occulters=occulters, smooth=smooth

if keyword_set(lagrangian) && keyword_set(bootstrap) && ~keyword_set(smooth) then print, 'Cannot bootstrap an unsmoothed dataset with lagrangian!'

if ~exist(restore_fl) then restore_fl = '20000102/kins_20000102.sav' ;'sample_kinscasestudy.sav'

restore, restore_fl

h_noisy = h_mm
h_noisy_sig = h_mm_err
utbase = t[0]
tt = anytim(t)-anytim(t[0])
height_factor = 1
vel_factor = 1e-3
accel_factor = 1e-6

xls = 1000
xrs = 2000

;h_noisy = h_noisy[0:5]
;tt = tt[0:5]

yr_h = [0,16000]
yr_v = [0,850]
yr_a = [-180,180]

if keyword_set(linear) then plot_name='linear'
if keyword_set(quadratic) then plot_name='quadratic'
if keyword_set(sav_gol) then plot_name='sav_gol'

if keyword_set(tog) then begin
	!p.charsize=2
	!p.charthick=4
	!p.thick=4
	!x.thick=4
	!y.thick=4
	set_plot, 'ps'
	device, /encapsul, bits=8, language=2, /portrait, /color, filename='fit_kinscme_1_'+anytim(t[0],/truncate,/ccsds)+'_'+plot_name+'.eps', $
		xs=15, ys=20
	print, 'set_plot, ps'
	print, 'Saving fit_kinscme_1_'+anytim(t[0],/truncate,/ccsds)+'_'+plot_name+'.eps'
endif else begin
	!p.charsize=2
	!p.charthick=1
	!p.thick=1
	!x.thick=1
	!y.thick=1
	set_plot, 'x'
	window, 0, xs=700, ys=850
endelse

set_line_color
!p.multi = [0,1,3]

pos_h = [0.15,0.66,0.95,0.91]
pos_v = [0.15,0.4,0.95,0.65]
pos_a = [0.15,0.14,0.95,0.39]

; Temporary lines to make output of just the model kinematics
;if keyword_set(tog) then begin
;	plot, t, h_fullmodel/height_factor, psym=-3, pos=pos_h, xtickname=[' ',' ',' ',' '], yr=yr_h, /ys, $
;		ytit='Height (Mm)'
;	plot, t, v_fullmodel/vel_factor, psym=-3, pos=pos_v, xtickname=[' ',' ',' ',' '], yr=yr_v, /ys, $
;		ytit='Velocity (km s!U-1!N)'
;	plot, t, a_fullmodel/accel_factor, psym=-3, pos=pos_a, yr=yr_a, /ys, $
;		ytit='Acceleration (m s!U-2!N)', xtit='Time (s)'
;endif
; end temporary.

; LAGRANGIAN INTERPOLATION (deriv.pro)
if keyword_set(lagrangian) then begin
	if keyword_set(smooth) then h_fit = smooth(h_noisy,3,/edge_truncate) else h_fit = h_noisy
	utplot, tt, h_noisy/height_factor, utbase, psym=1, thick=3, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_h, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	oploterror, tt, h_noisy/height_factor, h_noisy_sig/height_factor, psym=3
	plots, tt, h_fit/height_factor, line=0, color=5
	if keyword_set(occulters) then begin
		horline, 2.2*695.5, line=1
		xyouts, 2000, 1800, 'C2', charsize=1
        	horline, 6*695.5, line=1
		xyouts, 5000, 4400, 'C3', charsize=1
        	;horline, 19.5*695.5, line=1
	endif
        ; velocity
	v_fit = deriv(tt, h_fit)
	utplot, tt, v_fit/vel_factor, utbase, psym=-7, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_v, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	; acceleration
	a_fit = deriv(tt, v_fit)
	utplot, tt, a_fit/accel_factor, utbase, psym=-7, pos=pos_a, yr=yr_a, /ys, xr=[tt[0]-xls,tt[*]+xrs],/xs
	horline, 0, line=0, thick=1
endif

; QUADRATIC FIT
if keyword_set(quadratic) then begin
	fit = '0.5*p[0]*x^2. + p[1]*x + p[2]'
	fun = mpfitexpr(fit, tt, h_noisy, h_noisy_sig, bestnorm=h_chi_sq,/quiet)
	print, 'h_chi_sq ', h_chi_sq
	; height
	h_fit = 0.5*fun[0]*tt^2. + fun[1]*tt + fun[2]
	utplot, tt, h_noisy/height_factor, utbase, psym=1, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_h, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	oploterror, tt, h_noisy/height_factor, h_noisy_sig/height_factor, psym=3
	oplot, tt, h_fit/height_factor, line=0, color=5
	if keyword_set(occulters) then begin
                horline, 2.2*695.5, line=1
                horline, 6*695.5, line=1
                horline, 19.5*695.5, line=1
        endif
	; velocity
	v_fit = fun[0]*tt + fun[1]
	utplot, tt, v_fit/vel_factor, utbase, psym=-7, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_v, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	; acceleration
	a_fit = fun[0]
	utplot, tt, replicate(a_fit,n_elements(tt))/accel_factor, utbase, psym=-7, pos=pos_a, yr=yr_a, /ys, xr=[tt[0]-xls,tt[*]+xrs],/xs
        horline, 0, line=0, thick=1
endif

; CUBIC FIT
if keyword_set(cubic) then begin
	fit='p[0]*x^3. + p[1]*x^2. + p[2]*x + p[3]'
	fun = mpfitexpr(fit, tt, h_noisy, h_noisy_sig, bestnorm=h_chi_sq,/quiet)
	print, 'h_chi_sq ', h_chi_sq
        ; height
        h_fit = fun[0]*tt^3. + fun[1]*tt^2. + fun[2]*tt + fun[3]
        utplot, tt, h_noisy/height_factor, utbase, psym=1, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_h, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	oploterror, tt, h_noisy/height_factor, h_noisy_sig/height_factor, psym=3
        oplot, tt, h_fit/height_factor, line=0, color=5
        if keyword_set(occulters) then begin
                horline, 2.2*695.5, line=1
                horline, 6*695.5, line=1
                horline, 19.5*695.5, line=1
        endif
        ; velocity
        v_fit = 3*fun[0]*tt^2. + 2*fun[1]*tt + fun[2]
	utplot, tt, v_fit/vel_factor, utbase, psym=-7, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_v, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs], /xs
        ; acceleration
        a_fit = 6*fun[0]*tt + 2*fun[1]
        utplot, tt, a_fit/accel_factor, utbase, psym=-7, pos=pos_a, yr=yr_a, /ys, xr=[tt[0]-xls,tt[*]+xrs],/xs
	horline, 0, line=0, thick=1
endif

; POWER LAW FIT
if keyword_set(powerlaw) then begin
        fit='p[0]*x^p[1] + p[2]*x + p[3]'
        fun = mpfitexpr(fit, tt, h_noisy, h_noisy_sig, bestnorm=h_chi_sq,/quiet)
        print, 'h_chi_sq ', h_chi_sq
        ; height
        h_fit = fun[0]*tt^fun[1] + fun[2]*tt + fun[3]
        utplot, tt, h_noisy/height_factor, utbase, psym=1, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_h, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	oploterror, tt, h_noisy/height_factor, h_noisy_sig/height_factor, psym=3
        oplot, tt, h_fit/height_factor, line=0, color=5
        if keyword_set(occulters) then begin
                horline, 2.2*695.5, line=1
                horline, 6*695.5, line=1
                horline, 19.5*695.5, line=1
        endif
        ; velocity
        v_fit = fun[1]*fun[0]*tt^(fun[1]-1) + fun[2]
        utplot, tt, v_fit/vel_factor, utbase, psym=-7, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_v, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	; acceleration
        a_fit = (fun[1]-1)*fun[1]*fun[0]*tt^(fun[1]-2)
        utplot, tt, a_fit/accel_factor, utbase, psym=-7, pos=pos_a, yr=yr_a, /ys, xr=[tt[0]-xls,tt[*]+xrs],/xs
	horline, 0, line=0, thick=1
endif
	
; EXPONENTIAL FIT
if keyword_set(exponential) then begin
        fit='p[0]*exp(p[1]*x) + p[2]'
        fun = mpfitexpr(fit, tt, h_noisy, h_noisy_sig, bestnorm=h_chi_sq,/quiet)
        print, 'h_chi_sq ', h_chi_sq
        ; height
        h_fit = fun[0]*exp(fun[1]*tt) + fun[2]
        utplot, tt, h_noisy/height_factor, utbase, psym=1, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_h, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	oploterror, tt, h_noisy/height_factor, h_noisy_sig/height_factor, psym=3
        oplot, tt, h_fit/height_factor, line=0, color=5
        if keyword_set(occulters) then begin
                horline, 2.2*695.5, line=1
                horline, 6*695.5, line=1
                horline, 19.5*695.5, line=1
        endif
        ; velocity
        v_fit = fun[0]*fun[1]*exp(fun[1]*tt)
        utplot, tt, v_fit/vel_factor, utbase, psym=-7, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_v, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	; acceleration
        a_fit = fun[0]*fun[1]*fun[1]*exp(fun[1]*tt)
        utplot, tt, a_fit/accel_factor, utbase, psym=-7, pos=pos_a, yr=yr_a, /ys, xr=[tt[0]-xls,tt[*]+xrs],/xs
	horline, 0, line=0, thick=1
endif

flag = 0
; SAVITZKY-GOLAY FIT
if keyword_set(sav_gol) then begin
	nleft = 3
	nright = 3
	degree = 2
	utplot, tt, h_noisy/height_factor, utbase, psym=1, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_h, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
	oploterror, tt, h_noisy/height_factor, h_noisy_sig/height_factor, psym=3
	h_fit = convol(h_noisy,savgol(nleft,nright,0,degree,/double),/edge_truncate,/nan)
	oplot, tt, h_fit/height_factor, line=0, color=5
	if keyword_set(occulters) then begin
                horline, 2.2*695.5, line=1
		xyouts, 2000, 1800, 'C2', charsize=1
        	horline, 6*695.5, line=1
		xyouts, 5000, 4400, 'C3', charsize=1
        	;horline, 19.5*695.5, line=1
        endif
	;velocity
	stepsize = dblarr(n_elements(tt)-1)
	for i=1,n_elements(tt)-1 do stepsize[i-1] = tt[i] - tt[i-1]
	v_fit = 1/(ave(stepsize))*convol(h_noisy,savgol(nleft,nright,1,degree,/double),/edge_truncate,/nan)
	utplot, tt, v_fit/vel_factor, utbase, psym=-7, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' '], yr=yr_v, /ys, xtit=' ', xr=[tt[0]-xls,tt[*]+xrs], /xs
	; acceleration
	a_fit = 2/((ave(stepsize))^2.)*convol(h_noisy,savgol(nleft,nright,2,degree,/double),/edge_truncate,/nan)
	utplot, tt, a_fit/accel_factor, utbase, psym=-7, pos=pos_a, yr=yr_a, /ys, xr=[tt[0]-xls,tt[*]+xrs], /xs
	horline, 0, line=0, thick=1
endif


; RESIDUALS
if keyword_set(residuals) OR keyword_set(bootstrap) then begin
	res = h_fit - h_noisy
	if keyword_set(tog) then begin
		!p.charsize=1
	        device, /encapsul, bits=8, language=2, /portrait, /color, filename='fit_kinscme_2_'+anytim(t[0],/truncate,/ccsds)+'_'+plot_name+'.eps', $
			xs=15, ys=8
        	print, 'Saving fit_kinscme_2_'+anytim(t[0],/truncate,/ccsds)+'_'+plot_name+'.eps'
	endif else begin
	        window, 1, xs=600, ys=300
	endelse
	!p.multi=0
	yr_res = [min(res/height_factor)+0.1*min(res/height_factor),max(res/height_factor)+0.1*max(res/height_factor)]
	plot, h_fit/height_factor, res/height_factor, psym=7, yr=yr_res, $
		xtit='Fitted height (Mm)', ytit='Residuals (Mm)'
	;oploterror, h_fit/height_factor, res/height_factor, h_noisy_sig/height_factor, psym=3
	horline, 0, line=0, thick=1
endif


; FUZZY_ERROR // BOOTSTRAP
if keyword_set(fuzzy_error) OR keyword_set(bootstrap) then begin
	if keyword_set(tog) then begin
		!p.charsize=2
	        device, /encapsul, bits=8, language=2, /portrait, /color, filename='fit_kinscme_3_'+anytim(t[0],/truncate,/ccsds)+'_'+plot_name+'.eps', $
			xs=15, ys=20
	        print, 'Saving fit_kinscme_3_'+anytim(t[0],/truncate,/ccsds)+'_'+plot_name+'.eps'
	endif else begin
	        window, 2, xs=700, ys=850
	endelse
	iters = 10000
	h_noisy_orig = h_noisy
	stepsize = dblarr(n_elements(tt)-1)
        for i=1,n_elements(tt)-1 do stepsize[i-1] = tt[i] - tt[i-1]
	h_noisy = dblarr(iters,n_elements(h_noisy_orig))
	h_fit = dblarr(iters,n_elements(h_noisy_orig))
	v_fit = dblarr(iters,n_elements(h_noisy_orig))
	a_fit = dblarr(iters,n_elements(h_noisy_orig))
	; 5 entries corresponding to the lowerfence, lower (first) quartile, median (second quartile), upper (third) quartile, and upperfence.
	h_iqr = dblarr(5,n_elements(h_noisy_orig)) 
	v_iqr = dblarr(5,n_elements(h_noisy_orig))
	a_iqr = dblarr(5,n_elements(h_noisy_orig))
	!p.multi=[0,1,3]
	for j=0,iters-1 do begin
		if keyword_set(fuzzy_error) then h_noisy[j,*] = h_noisy_orig + randomn(seed,n_elements(h_noisy_sig))*(h_noisy_sig/2.)
		if keyword_set(bootstrap) then begin
			ran = rand_ind(n_elements(h_noisy_orig))
			unit_array = randomn(seed,n_elements(h_noisy_orig),/normal)
			unit_array /= abs(unit_array)
			res2 = res[ran]*unit_array
			h_noisy[j,*] = h_noisy_orig + res2
		;temp
			;if j eq 0 then plot, res2, psym=1, yr=[-500,500] else oplot, res2, psym=1, color=(j mod 9)+1 & wait, 0.001
		endif
		if keyword_set(lagrangian) then begin
			title = 'Lagrangian Interpolation'
			if keyword_set(smooth) then h_fit[j,*] = smooth(h_noisy[j,*], 3, /edge_truncate) else h_fit[j,*] = h_noisy[j,*]
			v_fit[j,*] = deriv(tt, h_fit[j,*])
			a_fit[j,*] = deriv(tt, v_fit[j,*])
		endif
		if keyword_set(quadratic) then begin
			title = 'Quadratic Polynomial'
			fit = '0.5*p[0]*x^2. + p[1]*x + p[2]'
        		fun = mpfitexpr(fit, tt, h_noisy[j,*], h_noisy_sig, bestnorm=h_chi_sq,/quiet)
        		h_fit[j,*] = 0.5*fun[0]*tt^2. + fun[1]*tt + fun[2]
			v_fit[j,*] = fun[0]*tt + fun[1]
			a_fit[j,*] = fun[0]
		endif
		if keyword_set(sav_gol) then begin
			title = 'Savitzky-Golay Filter'
			h_fit[j,*] = convol(transpose(h_noisy[j,*]),savgol(nleft,nright,0,degree,/double),/edge_truncate,/nan)
			v_fit[j,*] = 1/(ave(stepsize))*convol(transpose(h_noisy[j,*]),savgol(nleft,nright,1,degree,/double),/edge_truncate,/nan)
			a_fit[j,*] = 2/((ave(stepsize))^2.)*convol(transpose(h_noisy[j,*]),savgol(nleft,nright,2,degree,/double),/edge_truncate,/nan)
		endif
	endfor
;pause
	;interquartile range
	for i=0,n_elements(h_noisy_orig)-1 do begin
		h_iqr[2,i] = median(h_fit[*,i])
		h_iqr[1,i] = median(h_fit[where(h_fit[*,i] lt h_iqr[2,i]),i])
		h_iqr[3,i] = median(h_fit[where(h_fit[*,i] gt h_iqr[2,i]),i])
		h_iqr[0,i] = h_iqr[1,i] - 1.5*(h_iqr[3,i]-h_iqr[1,i])
		h_iqr[4,i] = h_iqr[3,i] + 1.5*(h_iqr[3,i]-h_iqr[1,i])
		v_iqr[2,i] = median(v_fit[*,i])
                v_iqr[1,i] = median(v_fit[where(v_fit[*,i] lt v_iqr[2,i]),i])
                v_iqr[3,i] = median(v_fit[where(v_fit[*,i] gt v_iqr[2,i]),i])
                v_iqr[0,i] = v_iqr[1,i] - 1.5*(v_iqr[3,i]-v_iqr[1,i])
                v_iqr[4,i] = v_iqr[3,i] + 1.5*(v_iqr[3,i]-v_iqr[1,i])
		a_iqr[2,i] = median(a_fit[*,i])
                a_iqr[1,i] = median(a_fit[where(a_fit[*,i] lt a_iqr[2,i]),i])
                a_iqr[3,i] = median(a_fit[where(a_fit[*,i] gt a_iqr[2,i]),i])
                a_iqr[0,i] = a_iqr[1,i] - 1.5*(a_iqr[3,i]-a_iqr[1,i])
                a_iqr[4,i] = a_iqr[3,i] + 1.5*(a_iqr[3,i]-a_iqr[1,i])
	endfor
	; heights plot
	for j=0,iters-1 do begin
		if j eq 0 then begin
			utplot, tt, h_noisy[j,*]/height_factor, utbase, psym=3, color=3, pos=pos_h, xtickname=[' ',' ',' ',' ',' ',' ',' ',' '], $
				yr=yr_h, /ys, ytit='Height (Mm)', xtit=' ', tit='Bootstrap : '+title, xr=[tt[0]-xls,tt[*]+xrs],/xs;, /ylog
		endif else begin
			;plots, tt, h_noisy[j,*]/height_factor, psym=1
			oplot, tt, h_fit[j,*]/height_factor, psym=3, color=3
		endelse
	endfor
	for j=0,4 do plots, tt, h_iqr[j,*]/height_factor, psym=-3, color=5, line=2
	oplot, tt, h_iqr[2,*]/height_factor, psym=-3, color=5, line=0
	oplot, tt, h_noisy_orig/height_factor, psym=1
	if keyword_set(occulters) then begin
                horline, 2.2*695.5, line=2
		xyouts, 22500, 1800, 'C2', charsize=0.8
        	horline, 6*695.5, line=2
		xyouts, 22500, 4400, 'C3', charsize=0.8
        	;horline, 19.5*695.5, line=2
        endif
	legend, 'CME: SOHO/LASCO', box=0, charsize=1, charthick=4   

	; velocity plot
	for j=0,iters-1 do begin
                if j eq 0 then begin
			utplot, tt, v_fit[j,*]/vel_factor, utbase, psym=3, color=3, pos=pos_v, xtickname=[' ',' ',' ',' ',' ',' ',' ',' '], $
				yr=yr_v, /ys, ytit='Velocity (km s!U-1!N)', xtit=' ', xr=[tt[0]-xls,tt[*]+xrs],/xs
		endif else begin
			oplot, tt, v_fit[j,*]/vel_factor, psym=3, color=3
		endelse
        endfor
	for j=0,4 do oplot, tt, v_iqr[j,*]/vel_factor, psym=-3, color=5, line=2
	oplot, tt, v_iqr[2,*]/vel_factor, psym=-3, color=5, line=0
	; accel plot
	for j=0,iters-1 do begin
		if j eq 0 then begin
			utplot, tt, a_fit[j,*]/accel_factor, utbase, psym=3, color=3, pos=pos_a, yr=yr_a, /ys, $
				ytit='Acceleration (m s!U-2!N)', xr=[tt[0]-xls,tt[*]+xrs],/xs
		endif else begin
			oplot, tt, a_fit[j,*]/accel_factor, psym=3, color=3
		endelse
	endfor
	for j=0,4 do oplot, tt, a_iqr[j,*]/accel_factor, psym=-3, color=5, line=2
	oplot, tt, a_iqr[2,*]/accel_factor, psym=-3, color=5, line=0
	horline, 0, line=0, thick=1
endif


if keyword_set(tog) then device, /close

end

