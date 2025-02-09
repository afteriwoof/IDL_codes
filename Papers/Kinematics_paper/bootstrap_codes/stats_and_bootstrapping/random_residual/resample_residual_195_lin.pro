; Routine for the resampling residual bootstrapping method. 195A linear fit.

pro resample_residual_195_lin, date, grt_dist_195, time195, h_err, dist_arr_195, $
					f_195_lin, perror, p1, s1, p2, s2, conf_range_r, conf_range_v

	tim195 = time195 - time195[0]
	
	set_line_color

; Zero a fit to data

	x = findgen( max(tim195) )

	h_error = replicate(h_err, dist_arr_195)

	lin_fit_195 = 'p[0] + p[1] * x'

	pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},2)
	pi(0).limited(0) = 1
	pi(0).limits(0) = 0.
	pi(1).limited(0) = 1
	pi(1).limits(0) = 0.01
	pi(1).limited(1) = 1
	pi(1).limits(1) = 0.6

    f_195_lin = mpfitexpr(lin_fit_195, tim195, grt_dist_195, h_error, [grt_dist_195[0], 0.2], $
    		perror=perror, parinfo = pi, bestnorm = bestnorm_195_lin, /quiet)

	x = tim195

	x_arr = findgen(max(tim195))
	
	y_line = f_195_lin[1]*x_arr + f_195_lin[0]

; result array

	arr_size = 100000.
	
	print, arr_size

	res = dblarr(2, arr_size)
	
; original fit to data

	yfit = f_195_lin[1]*tim195 + f_195_lin[0]

; Loop over n! iterations to bootstrap

	for i =0L, arr_size-1 do begin

; Calculate residuals

		e = grt_dist_195 - yfit
		
; Generate number of data points random numbers between 0 and 100 from uniform distribution 

		ran = floor(RANDOMU( seed , dist_arr_195, /DOUBLE, /uniform)*(dist_arr_195-1.))
		
; Create array of 1 and -1 to multiply ran array by to fill gaps in resulting array

		unit_array = randomn(seed, dist_arr_195, /double, /normal)
		
		unit_arr = unit_array/abs(unit_array)

; Randomly reassign the residuals

		er = e[ran]	* unit_arr
		
; Make new data with random residuals

		yr = grt_dist_195 + er
		
; New fit and store the results

		res[*,i] = poly_fit(x, yr, 1)
		
	endfor
	
; Calculate the moments of the results arrays for m and c

	p1 = moment(res[0,*], sdev=s1)
	p2 = moment((res[1,*]*1e3), sdev=s2)
	
	window, 0, xs = 1000, ys = 1000
	!p.multi = [0, 1, 3]
	set_line_color

; Plot original data with fitted line

	plot, tim195, grt_dist_195, Title ='Original and noisy data - 195 Linear', xtit='X', ytit='Y', charsize=2.0, $
		background = 1, color = 0, xr = [-50, max(tim195) + 50], /xs, yr = [0, max(grt_dist_195) + 50], /ys, $
		psym = 2
	oplot, x_arr, y_line, color=3
	legend,['Data', 'Fit: r = '+ num2str(f_195_lin[0]) + ' + ' + num2str(f_195_lin[1]) + '*x'], $
		colors=[0, 3], chars=1.2, /right, /bottom, /clear, textcolor = [0, 3]

; Plot histogram of intercept parameter bootstrapping data

	plot_hist2, res[0,*], xr, hr, bin = 3, color = 0, charsize = 2, title = 'R0', xtit = 'R0 - Mm', $
			xr = [p1[0] - 3*s1, p1[0] + 3*s1], /xs, yr = [0, 1.1*max(histogram(res[0,*], binsize = 3))], /ys
	
	h_0 = histogram(res[0, *], binsize = 3)
	
	x_0 = findgen(10000)/10
	
	y_0 = max(h_0)*exp(-(x_0-p1[0])^2/(2.*s1^2))

;	oplot, x_0, y_0, color = 3, thick = 2

	legend, ['Mean R0 = ' + num2str(p1[0]), 'Std Dev = ' + num2str(s1)], textcolors = [3, 3], $
		/top, /right, chars = 1.2

; Plot histogram of slope parameter bootstrapping data

	plot_hist2, (res[1,*]*1e3), xv, hv, bin = 3, color = 0, charsize = 2, title = 'V0', $
			xr = [p2[0] - 3*s2, p2[0] + 3*s2], /xs, yr = [0, 1.1*max(histogram((res[1,*]*1e3), $
			binsize = 3))], /ys, xtit = 'V0 - km/s'
			
	h_1 = histogram((res[1,*]*1e3), binsize = 3)
	
	x_1 = findgen(10000)/10
	
	y_1 = max(h_1)*exp(-(x_1-p2[0])^2/(2.0D*s2^2))
	
;	oplot, x_1, y_1, color = 3, thick = 2

	legend, ['Mean V0 = ' + num2str(p2[0]), 'Std Dev = ' + num2str(s2)], textcolors = [3, 3], $
		/top, /right, chars = 1.2

;calculate the confidence interval without trying to make the distribution gaussian
	
	average_r = [average(res[0,*]),median(res[0,*]),xr[where(hr EQ max(hr))] ]
	alpha_r = 0.05
	q1_r = arr_size * alpha_r / 2.
	q2_r = arr_size - q1_r +1
	sort_r = (res[0,*])[SORT(res[0,*])]
	conf_range_r = [sort_r[q1_r],sort_r[q2_r]]
	
	
	average_v = [average(res[1,*]),median(res[1,*]),xv[where(hv EQ max(hv))] ]
	alpha_v = 0.05
	q1_v = arr_size * alpha_v / 2.
	q2_v = arr_size - q1_v +1
	sort_v = (res[1,*])[SORT(res[1,*])]
	conf_range_v = [sort_v[q1_v],sort_v[q2_v]]

end