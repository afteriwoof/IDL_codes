; Routine to test the parametric bootstrap method for analysis of the fit parameters for each
; fit to the given data points.

pro parametric_bootstrap_lin_195, date, grt_dist_195, time195, h_err, dist_arr_195, f_195_lin, $
		perror, conf_range_d, conf_range_v, bootstrap_dist, bootstrap_vel, plot_on=plot_on

	if (keyword_set(plot_on)) then begin

		window, 0, xs = 1000, ys = 1000
	
		!p.multi = [0, 1, 3]

	endif

; Fitted equation that we wish to test.

	resolve_routine, 'data_fit_195_linear'

	if (keyword_set(plot_on)) then begin

		data_fit_195_linear, grt_dist_195, time195, h_err, dist_arr_195, f_195_lin, perror, /plot_on

	endif else begin
		
		data_fit_195_linear, grt_dist_195, time195, h_err, dist_arr_195, f_195_lin, perror
		
	endelse

; Plot trend line and standard deviation margin

	if (keyword_set(plot_on)) then begin

		tim195 = time195 - time195[0]

		xf = findgen( max(tim195) )

		dist_fit_195_lin = f_195_lin[0] + f_195_lin[1]*xf

		oplot, xf, dist_fit_195_lin, linestyle = 0, thick = 2, color = 0
	
		legend, ['R0 = ' + num2str(f_195_lin[0]) + ' +/- ' + num2str(perror[0]) + ' Mm', $
				'V0 = ' + num2str(1000*f_195_lin[1]) + ' +/- ' + num2str(1000*perror[1]) + ' km/s'], $
				textcolor = [3, 3], /clear, /bottom, /right, charsize = 1.5, outline_color = 0

	endif

;************************************
; Bootstrapping - Distance Parameter
;************************************

; Number of iterations	

	num_iter = 100000
	
; Create array to store data points

	mean_dist_arr = dblarr(num_iter)

; Loop over 50,000 iterations to bootstrap

	for i = 0L, num_iter-1 do begin

; Randomly choose n data points from Gaussian distribution with same mean and standard deviation 
; of fit to original data

		dist_arr = RANDOMN( Seed1, dist_arr_195, /DOUBLE, /NORMAL )*perror[0] + f_195_lin[0]

; Find mean of new data points

		mean_dist_arr[i] = mean(dist_arr)
	
	endfor

; Plot histogram of mean distance parameter values

	dist_hist = histogram( mean_dist_arr, loc = loc_d, binsize = 1 )
	
	arr_info_dist = moment(mean_dist_arr, sdev=sd)

	if (keyword_set(plot_on)) then begin

		plot, loc_d, dist_hist, psym = 0, yr = [0, 1.25*max(dist_hist)], $
				xr = [arr_info_dist[0] - 3.*sd, arr_info_dist[0] + 3.*sd], /xs, /ys, color = 0, $
				background = 1, xtitle = 'Distance parameter values', charsize = 2, $
				ytitle = 'Probability', thick = 2, $
				title = 'Bootstrapping analysis of 195A data R!D0!N fit parameter, ' + num2str(date)

		legend, ['R0 = ' + num2str(arr_info_dist[0]) + ' +/- ' + num2str(sd) + ' Mm'], $
			textcolor = [3], /clear, /top, /right, charsize = 1.5, outline_color = 0

	endif
	
;************************************
; Bootstrapping - Velocity Parameter
;************************************

; Create array to store data points

	mean_vel_arr = dblarr(num_iter)

; Loop over 50,000 iterations to bootstrap

	for i = 0L, num_iter-1 do begin

; Randomly choose n data points from Gaussian distribution with same mean and standard deviation 
; of fit to original data

		vel_arr = RANDOMN( Seed2, dist_arr_195, /DOUBLE, /NORMAL )*perror[1] + f_195_lin[1]

; Find mean of new data points

		mean_vel_arr[i] = mean(vel_arr)
		
	endfor

; Plot histogram of mean distance parameter values

	vel_hist = histogram( mean_vel_arr, loc = loc_v, binsize = 0.001 )
	
	arr_info_vel = moment(mean_vel_arr, sdev=sv)

	if (keyword_set(plot_on)) then begin

		plot, loc_v, vel_hist, psym = 0, yr = [0, 1.25*max(vel_hist)], $
				xr = [arr_info_vel[0] - 3.*sv, arr_info_vel[0] + 3.*sv], /xs, /ys, color = 0, $
				background = 1, xtitle = 'Velocity parameter values', charsize = 2, $
				ytitle = 'Probability', thick = 2, $
				title = 'Bootstrapping analysis of 195A data V!D0!N fit parameter, ' + num2str(date)

		legend, ['V0 = ' + num2str(1000*arr_info_vel[0]) + ' +/- ' + num2str(1000*sv) + ' km/s'], $
			textcolor = [3], /clear, /top, /right, charsize = 1.5, outline_color = 0

	endif
	
; Confidence intervals

	conf_range_d = [arr_info_dist[0] - 2.0*sd, arr_info_dist[0] + 2.0*sd]

	conf_range_v = [arr_info_vel[0] - 2.0*sv, arr_info_vel[0] + 2.0*sv]
	
	bootstrap_dist = [arr_info_dist[0], sd]

	bootstrap_vel = [arr_info_vel[0], sv]

end