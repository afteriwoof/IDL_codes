; Routine that re-calculates the forward differencing technique. This is intended to replace 
; f_num_diff_lin.pro

pro forward_diff, cadence, r0, v0, time, n, noise, i, mean_percent_noise, f_lin_dist, f_error_vel_noisy, $
	f_error_acc_noisy, scatter_v, scatter_a, tog=tog, images=images

	error = 10.0d

	if (keyword_set(tog)) then begin

		toggle, /portrait, filename = 'f_diff_lin.eps', xsize = 6, ysize = 6, /inches, /color, $
			bits_per_pixel = 8
		!p.multi = [0, 1, 2]
		set_line_color

	endif
	
	if (keyword_set(images)) then begin

		window, 0, xs = 800, ys = 1000
		!p.multi = [0, 1, 3]
		set_line_color

	endif

; Define time array
	
	t = dindgen(time)
	
; Define ideal distance equation
	
	dist = r0 + v0*t[0:*:cadence]

; Define noisy distance equation

;	test_time = ['15:00:00', '15:01:40', '15:03:20', '15:05:00', '15:06:40', '15:08:20', '15:10:00', $
;		'15:11:40', '15:13:20', '15:15:00', '15:16:40', '15:18:20', '15:20:00', '15:21:40', '15:23:40', $
;		'15:25:00', '15:26:40', '15:28:20', '15:30:00', '15:31:40']
;
;	time_tester = anytim('2009/08/17' + ' ' + test_time)
;
;	h_error = replicate(1e6*(30.0d), n)

	dist_noisy = r0 + v0*t[0:*:cadence] + noise[0:*:cadence]

;	save, filename = 'sim_data_test.sav', time_tester, dist, h_error
;stop
; Calculate % noise

	percent_noise = (abs(dist_noisy - dist)/dist)*100.0d
	
	mean_percent_noise = mean(percent_noise)
	
; Fit equation to noisy data
	
	x = dindgen(time)

	h_error = replicate(error, n)

	dist_fit_195 = 'p[0] + p[1] * x'

	pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},2)
	pi(0).limited(0) = 1
	pi(0).limits(0) = 0.
	pi(1).limited(0) = 1
	pi(1).limits(0) = 0.01
	pi(1).limited(1) = 1
	pi(1).limits(1) = 0.6

    f_lin_dist = mpfitexpr(dist_fit_195, t[0:*:cadence], dist_noisy, h_error, [r0, v0], perror=perror, $
    		parinfo = pi, bestnorm = bestnorm, /quiet)

	lin_fit_dist = f_lin_dist[0] + f_lin_dist[1]*t

	ideal_line = r0 + v0*t

; Plot distance-time data from plain equation

	if (keyword_set(tog)) then begin
	
		plot, t[0:*:cadence], dist, xr = [-50, max(t) + 50], yr = [0, 1.1*max(dist_noisy)], $
			title = 'Forward difference plots, Cadence = ' + num2str(cadence) + 's', $
			ytit = 'Distance (Mm)', psym = 2, charsize = 1, /xs, /ys, color = 0, background = 1, $
			thick = 2, xtitle = ' ', xtickname = [' ',' ',' ',' ',' ',' '], pos = [0.15, 0.68, 0.95, 0.94]

		oplot, t[0:*:cadence], dist_noisy, psym = 2, color = 3, thick = 2
		oplot, t, lin_fit_dist, psym = 3, color = 3, thick = 2
		oplot, t, ideal_line, psym = 3, color = 0, thick = 2
		oploterr, t[0:*:cadence], dist, replicate(error, n), /nohat, /noconnect, errthick = 2, errcolor= 0
		oploterr, t[0:*:cadence], dist_noisy, replicate(error, n), /nohat, /noconnect, errthick = 2, errcolor= 3

	endif
	
	if (keyword_set(images)) then begin

		plot, t[0:*:cadence], dist, xr = [-50, max(t) + 50], yr = [0, 1.1*max(dist_noisy)], $
			title = 'Forward difference plots, Std. Dev. = ' + num2str(i) + ', Cadence = ' + $
			num2str(cadence) + 's', ytit = 'Distance (Mm)', psym = 2, charsize = 2, /xs, /ys, $
			color = 0, background = 1, thick = 2
	
		oplot, t[0:*:cadence], dist_noisy, psym = 2, color = 3, thick = 2
		oplot, t, lin_fit_dist, psym = 3, color = 3, thick = 2
		oplot, t, ideal_line, psym = 3, color = 0, thick = 2
		oploterr, t[0:*:cadence], dist, replicate(error, n), /nohat, /noconnect, errthick = 2, errcolor= 0
		oploterr, t[0:*:cadence], dist_noisy, replicate(error, n), /nohat, /noconnect, errthick = 2, errcolor= 3

	endif

	if (keyword_set(tog)) then begin

		legend, ['Min % noise = ' + num2str(min(percent_noise)), 'Mean % noise = ' + num2str(mean(percent_noise)), $
			'Max % noise = ' + num2str(max(percent_noise))], textcolors = [0, 0, 0], charsize = 0.8, /top, $
			/left, /clear, outline_color = 0
	
		legend, ['Ideal: r!D0!N = ' + num2str(r0) + ' Mm, v!D0!N = ' + num2str(1000*v0) + ' km/s', $
			'Fit: r!D0!N = ' + num2str(f_lin_dist[0]) + ' Mm, v!D0!N = ' + num2str(1000*f_lin_dist[1]) + ' km/s'], $
			textcolors = [0, 3], charsize = 0.8, /bottom, /right, /clear, outline_color = 0

	endif

	if (keyword_set(images)) then begin

		legend, ['Min % noise = ' + num2str(min(percent_noise)), 'Mean % noise = ' + num2str(mean(percent_noise)), $
			'Max % noise = ' + num2str(max(percent_noise))], textcolors = [0, 0, 0], charsize = 1.5, /top, $
			/left, /clear, outline_color = 0

		legend, ['Ideal: r!D0!N = ' + num2str(r0) + ' Mm, v!D0!N = ' + num2str(1000*v0) + ' km/s', $
			'Fit: r!D0!N = ' + num2str(f_lin_dist[0]) + ' Mm, v!D0!N = ' + num2str(1000*f_lin_dist[1]) + ' km/s'], $
			textcolors = [0, 3], charsize = 1.5, /bottom, /right, /clear, outline_color = 0

	endif

;***********************
; Velocity Calculations
;***********************

; Define normalised time array for Taylor series analysis.

	t_norm = dindgen(time);/time

	t_cad = t_norm[0:*:cadence]

; Define ideal distance equation using normalised time array
	
	d = r0 + v0*t_cad

; Calculate numerically differentiated data for ideal noiseless data

	f_v_upper = d[1:max(n)-1] - d[0:max(n)-2]					; Upper line (y-difference)
	
	f_v_lower = t_cad[1:max(n)-1] - t_cad[0:max(n)-2]			; Lower line (x-difference)

	f_velocity = (f_v_upper)/(f_v_lower)						; Combine upper and lower lines

; Define noisy distance equation using normalised time arrays

	d_noisy = r0 + v0*t_cad + noise[0:*:cadence]

; Calculate numerically differentiated data for noisy data

	f_v_upper_noisy = d_noisy[1:max(n)-1] - d_noisy[0:max(n)-2]		; Upper line (y-difference)

	f_v_lower_noisy = t_cad[1:max(n)-1] - t_cad[0:max(n)-2]			; Lower line (x-difference)

	f_velocity_noisy = (f_v_upper_noisy)/(f_v_lower_noisy)			; Combine upper and lower lines

;*************************
; Velocity Error Analysis
;*************************

; Calculate errors for ideal noiseless data

	f_err_upper = d[2:max(n)-1] - 2.0d*d[1:max(n)-2] + d[0:max(n)-3]

	f_err_lower = factorial(2)*(t_cad[1:max(n)-1] - t_cad[0:max(n)-2])
	
	f_error_vel_clean = mean(abs((f_err_upper)/(f_err_lower)))
	
; Calculate errors for noisy data

	f_err_upper = d_noisy[2:max(n)-1] - 2.0d*d_noisy[1:max(n)-2] + d_noisy[0:max(n)-3]

	f_err_lower = factorial(2)*(t_cad[1:max(n)-1] - t_cad[0:max(n)-2])
	
	f_error_vel_noisy = mean(abs(f_err_upper/f_err_lower))

; Fit equation to noisy data
	
	x = findgen(time)

	h_error = replicate(1000.0d*f_error_vel_noisy, size(f_velocity_noisy, /n_elements))

	vel_fit = 'p[0]'

	pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},1)
	pi(0).limited(0) = 1
	pi(0).limits(0) = 10
	pi(0).limited(1) = 1
	pi(0).limits(1) = 500

    f_lin_vel = mpfitexpr(vel_fit, t_norm[0:*:cadence], 1000.0d*f_velocity_noisy, h_error, [1000*v0], $
    		perror=perror, parinfo = pi, bestnorm = bestnorm, /quiet)

	t_size = size(x, /n_elements)

	lin_fit_vel = replicate(f_lin_vel[0], t_size)

;****************
; Velocity Plots
;****************

	vel_diff_lower = mean(1000.0d*f_velocity_noisy) - min(1000.0d*f_velocity_noisy)
	vel_diff_upper = max(1000.0d*f_velocity_noisy) - mean(1000.0d*f_velocity_noisy)

	scatter_v = abs(vel_diff_upper) + abs(vel_diff_lower)

	t_plot = t_cad

	if (keyword_set(tog)) then begin
	
		plot, t_plot[0:max(n)-2], 1000.0d*f_velocity, xr = [-50, max(t) + 50], /xs, color = 0, $
			yr = [1.1*min(1000.0d*f_velocity_noisy), 1.1*max(1000.0d*f_velocity_noisy)], /ys, $
			ytit = 'Velocity (km/s)', psym = 2, charsize = 1, background = 1, thick = 2, $
			xtitle = ' ', xtickname = [' ',' ',' ',' ',' ',' '], pos = [0.15, 0.39, 0.95, 0.66]

		oplot, t_plot[0:max(n)-2], 1000.0d*f_velocity_noisy, psym = 2, color = 3, thick = 2
		oplot, x, lin_fit_vel, psym = 3, color = 3, thick = 2
		oploterr, t_plot[0:max(n)-2], 1000.0d*f_velocity, replicate(1000.0d*f_error_vel_clean, $
			size(f_velocity, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 0
		oploterr, t_plot[0:max(n)-2], 1000.0d*f_velocity_noisy, replicate(1000.0d*f_error_vel_noisy, $
			size(f_velocity_noisy, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 3

	endif

	if (keyword_set(images)) then begin
	
		if (i EQ 0) then begin
		
			plot, t_plot[0:max(n)-2], 1000.0d*f_velocity, xr = [-50, max(t) + 50], /xs, color = 0, $
				yr = [mean(1000.0d*f_velocity_noisy) - 50., mean(1000.0d*f_velocity_noisy) + 50.], /ys, $
				ytit = 'Velocity (km/s)', psym = 2, charsize = 2, background = 1, thick = 2

			oplot, t_plot[0:max(n)-2], 1000.0d*f_velocity_noisy, psym = 2, color = 3, thick = 2
			oplot, x, lin_fit_vel, psym = 3, color = 3, thick = 2
			oploterr, t_plot[0:max(n)-2], 1000.0d*f_velocity, replicate(1000.0d*f_error_vel_clean, $
				size(f_velocity, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 0
			oploterr, t_plot[0:max(n)-2], 1000.0d*f_velocity_noisy, replicate(1000.0d*f_error_vel_noisy, $
				size(f_velocity_noisy, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 3

		endif else begin
		
			plot, t_plot[0:max(n)-2], 1000.0d*f_velocity, xr = [-50, max(t) + 50], /xs, color = 0, $
				yr = [mean(1000.0d*f_velocity_noisy) - 1.1*vel_diff_lower, $
				mean(1000.0d*f_velocity_noisy) + 1.1*vel_diff_upper], /ys, ytit = 'Velocity (km/s)', $
				psym = 2, charsize = 2, background = 1, thick = 2

			oplot, t_plot[0:max(n)-2], 1000.0d*f_velocity_noisy, psym = 2, color = 3, thick = 2
			oplot, x, lin_fit_vel, psym = 3, color = 3, thick = 2
			oploterr, t_plot[0:max(n)-2], 1000.0d*f_velocity, replicate(1000.0d*f_error_vel_clean, $
				size(f_velocity, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 0
			oploterr, t_plot[0:max(n)-2], 1000.0d*f_velocity_noisy, replicate(1000.0d*f_error_vel_noisy, $
				size(f_velocity_noisy, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 3
		
		endelse

	endif

	if (keyword_set(tog)) then begin

		legend, ['No noise: v!D0!N = ' + num2str(1000.0d*mean(f_velocity)) + ' km/s', $
			'Fit: v!D0!N = ' + num2str(f_lin_vel[0]) + ' km/s', $
			'Mean error = ' + num2str(1000.0d*f_error_vel_noisy) + ' km/s'], $
			textcolors = [0, 3, 3], charsize = 0.8, /bottom, /right, /clear, outline_color = 0

	endif
	
	if (keyword_set(images)) then begin

		legend, ['No noise: v!D0!N = ' + num2str(1000.0d*mean(f_velocity)) + ' km/s', $
			'Fit: v!D0!N = ' + num2str(f_lin_vel[0]) + ' km/s', $
			'Mean error = ' + num2str(1000.0d*f_error_vel_noisy) + ' km/s'], $
			textcolors = [0, 3, 3], charsize = 1.5, /bottom, /right, /clear, outline_color = 0

	endif

;***************************
; Acceleration Calculations
;***************************

; Calculate numerically differentiated data for ideal noiseless data

	t_cadence = t_cad[0:max(n)-2]

	m = size(t_cadence, /n_elements)

	f_a_upper = f_velocity[1:max(m)-1] - f_velocity[0:max(m)-2]

	f_a_lower = t_cadence[1:max(m)-1] - t_cadence[0:max(m)-2]

	f_accel = (f_a_upper)/(f_a_lower)

; Calculate numerically differentiated data for noisy data

	f_a_upper_noisy = f_velocity_noisy[1:max(m)-1] - f_velocity_noisy[0:max(m)-2]

	f_a_lower_noisy = t_cadence[1:max(m)-1] - t_cadence[0:max(m)-2]

	f_accel_noisy = (f_a_upper_noisy)/(f_a_lower_noisy)

;*****************************
; Acceleration Error Analysis
;*****************************

; Calculate errors for ideal noiseless data

	a_err_upper = f_velocity[2:max(m)-1] - 2.0d*f_velocity[1:max(m)-2] + f_velocity[0:max(m)-3]

	a_err_lower = factorial(2)*(t_cadence[1:max(m)-1] - t_cadence[0:max(m)-2])
	
	f_error_acc_clean = mean(abs(a_err_upper/a_err_lower))
	
; Calculate errors for noisy data

	a_err_upper = f_velocity_noisy[2:max(m)-1] - 2.0d*f_velocity_noisy[1:max(m)-2] + f_velocity_noisy[0:max(m)-3]

	a_err_lower = factorial(2)*(t_cadence[1:max(m)-1] - t_cadence[0:max(m)-2])
	
	f_error_acc_noisy = mean(abs(a_err_upper/a_err_lower))

; Fit equation to noisy data
	
	x = findgen(time)

	h_error = replicate(1e6*f_error_acc_noisy, size(f_accel_noisy, /n_elements))

	acc_fit = 'p[0]'

	pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},1)
	pi(0).limited(0) = 1
	pi(0).limits(0) = -100
	pi(0).limited(1) = 1
	pi(0).limits(1) = 100

    f_lin_acc = mpfitexpr(acc_fit, t_cadence[0:max(m)-2], 1e6*f_accel_noisy, h_error, [0], $
    		perror=perror, parinfo = pi, bestnorm = bestnorm, /quiet)

	t_size = size(x, /n_elements)

	lin_fit_acc = replicate(f_lin_acc[0], t_size)

;********************
; Acceleration Plots
;********************

	t_plotting = t_cadence

	scatter_a = abs(min(1e6*f_accel_noisy)) + abs(max(1e6*f_accel_noisy))

	if (keyword_set(tog)) then begin

		plot, t_plotting[0:max(m)-2], 1e6*f_accel, xr = [-50, max(t) + 50], xtit = 'Time (s)', $
			yr = [1.1*min(1e6*f_accel_noisy), 1.1*max(1e6*f_accel_noisy)], /xs, /ys, thick = 2, $
			ytit = 'Acceleration (m/s/s)', background = 1, color = 0, psym = 2, charsize = 1, $
			pos = [0.15, 0.1, 0.95, 0.37]

			oplot, t_plotting[0:max(m)-2], 1e6*f_accel_noisy, psym = 2, color = 3, thick = 2
			oplot, x, lin_fit_acc, psym = 3, color = 3, thick = 2
			oploterr, t_plotting[0:max(m)-2], 1e6*f_accel, replicate(1e6*f_error_acc_clean, $
				size(f_accel, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 0
			oploterr, t_plotting[0:max(m)-2], 1e6*f_accel_noisy, replicate(1e6*f_error_acc_noisy, $
				size(f_accel_noisy, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 3

	endif
	
	if (keyword_set(images)) then begin
	
		if (i EQ 0) then begin
		
			plot, t_plotting[0:max(m)-2], 1e6*f_accel, xr = [-50, max(t) + 50], xtit = 'Time (s)', $
				yr = [-50, 50], /xs, /ys, thick = 2, $
				ytit = 'Acceleration (m/s/s)', background = 1, color = 0, psym = 2, charsize = 2

			oplot, t_plotting[0:max(m)-2], 1e6*f_accel_noisy, psym = 2, color = 3, thick = 2
			oplot, x, lin_fit_acc, psym = 3, color = 3, thick = 2
			oploterr, t_plotting[0:max(m)-2], 1e6*f_accel, replicate(1e6*f_error_acc_clean, $
				size(f_accel, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 0
			oploterr, t_plotting[0:max(m)-2], 1e6*f_accel_noisy, replicate(1e6*f_error_acc_noisy, $
				size(f_accel_noisy, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 3

		endif else begin
		
			plot, t_plotting[0:max(m)-2], 1e6*f_accel, xr = [-50, max(t) + 50], xtit = 'Time (s)', $
				yr = [1.1*min(1e6*f_accel_noisy), 1.1*max(1e6*f_accel_noisy)], /xs, /ys, thick = 2, $
				ytit = 'Acceleration (m/s/s)', background = 1, color = 0, psym = 2, charsize = 2

			oplot, t_plotting[0:max(m)-2], 1e6*f_accel_noisy, psym = 2, color = 3, thick = 2
			oplot, x, lin_fit_acc, psym = 3, color = 3, thick = 2
			oploterr, t_plotting[0:max(m)-2], 1e6*f_accel, replicate(1e6*f_error_acc_clean, $
				size(f_accel, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 0
			oploterr, t_plotting[0:max(m)-2], 1e6*f_accel_noisy, replicate(1e6*f_error_acc_noisy, $
				size(f_accel_noisy, /n_elements)), /nohat, /noconnect, errthick = 2, errcolor= 3

		endelse

	endif

	if (keyword_set(tog)) then begin

		legend, ['No noise: a!D0!N = ' + num2str(mean(1e6*f_accel)) + ' m/s/s', $
			'Fit: a!D0!N = ' + num2str(f_lin_acc[0]) + ' m/s/s', $
			'Mean error = ' + num2str(1e6*f_error_acc_noisy) + ' m/s/s'], $
			textcolors = [0, 3, 3], charsize = 0.8, /bottom, /right, /clear, outline_color = 0

		toggle

	endif

	if (keyword_set(images)) then begin

		legend, ['No noise: a!D0!N = ' + num2str(mean(1e6*f_accel)) + ' m/s/s', $
			'Fit: a!D0!N = ' + num2str(f_lin_acc[0]) + ' m/s/s', $
			'Mean error = ' + num2str(1e6*f_error_acc_noisy) + ' m/s/s'], $
			textcolors = [0, 3, 3], charsize = 1.5, /bottom, /right, /clear, outline_color = 0

	endif


end
