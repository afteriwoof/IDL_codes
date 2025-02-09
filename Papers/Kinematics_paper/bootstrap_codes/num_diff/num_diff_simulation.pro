; Routine that defines variables and calls different numerical differencing routines - forward_diff.pro,
; reverse_diff.pro and centre_diff.pro

pro num_diff_simulation, tog=tog, noise_on=noise_on, cadence_on=cadence_on, images=images, $
			no_images=no_images

; Define routine parameters

	r0 = 150.0d		; Mm

	v0 = 0.4d		; 400 km/s
	
	time = 1800.0d	; s

; Either cadence or i may be varied to examine their effects
	
	cadence = 200	; s

	cad_array = 300	; Maximum value of cadence being examined (s)

	max_noise = 300	; Max width of standard deviation being examined (Mm)
	
	j = 100			; Max width of standard deviation
	
	jump = 10.		; Steps of standard deviation/cadence

; Define time array

	t = findgen(time)

; Calculate noise to add to equations

;	n = size(t, /n_elements)
;
;	array = randomn(seed, n)
;
;	save, filename = 'noise_array.sav', array

	restore, 'noise_array.sav'

; Compile routines to ensure smooth operation in case of changes

	resolve_routine, 'forward_diff'
	resolve_routine, 'reverse_diff'
	resolve_routine, 'centre_diff'
	resolve_routine, 'lagrange_diff'

; Create array structures to store mean noise levels (both velocity and acceleration)

	percent_noise = dblarr(cad_array+1)
	f_distance = dblarr(cad_array+1)
	f_velocity = dblarr(cad_array+1)

	f_error_vel = dblarr(cad_array+1)
	f_error_acc = dblarr(cad_array+1)
	r_error_vel = dblarr(cad_array+1)
	r_error_acc = dblarr(cad_array+1)
	c_error_vel = dblarr(cad_array+1)
	c_error_acc = dblarr(cad_array+1)
	l_error_vel = dblarr(cad_array+1)
	l_error_acc = dblarr(cad_array+1)

	if (keyword_set(noise_on)) then begin

		resolve_routine, 'sub_simulation_noise'
	
		sub_simulation_noise, max_noise, jump, t, array, r0, v0, time, cadence, tog=tog, images=images, $
			no_images=no_images

	endif

	if (keyword_set(cadence_on)) then begin

		resolve_routine, 'sub_simulation_cadence'
	
		sub_simulation_cadence, cad_array, jump, t, array, r0, v0, time, cadence, tog=tog, images=images, $
			no_images=no_images

	endif

stop

end
