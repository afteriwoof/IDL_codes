; Code to plot the different kinematics generate on a noised data set compared with the model, for different numerical differencing schemes.

;Created: 29-06-2011 from plot_different_kins_cadence_fixed2_gallag.pro  but to figure out how to extend the amount of time the acceleration peak acts over.

; Last edited: 19-01-2011 to include most apropriate _fullmodel variables.

pro plot_peaked_accel, cadence, fixed, no_plot=no_plot, fit_vel=fit_vel, large_range=large_range, af, ac, al, att, a_max, no_legend=no_legend, plot_fixed_point=plot_fixed_point, tog=tog

if ~keyword_set(tog) then begin
	!p.charsize=2
	!p.thick=1
	!x.thick=1
	!y.thick=1
	!p.charthick=1
endif else begin
	!p.charsize=2
	!p.thick=3
	!x.thick=3
	!y.thick=3
	!p.charthick=3
endelse
!p.multi=[0,1,3]
;Model
;r0 = 100e6 ;m
;v0 = 400e3 ;m/s
;a0 = 50. ;m/s/s

time = 20000. ;secs
t = dindgen(time)
;cadence = 1. ;secs
noise = randomn(seed, size(t[0:*:cadence], /n_elements))
noise2 = randomn(seed, size(t[0:*:cadence], /n_elements))

; coding up the timesteps from fixed with cadence
start_limit = fixed
while (start_limit-cadence) gt 0 do start_limit-=cadence
end_limit = fixed
while (end_limit+cadence) lt time do end_limit+=cadence

tt = start_limit
count=1
while max(tt) lt end_limit do tt=[tt,tt[n_elements(tt)-1]+cadence]

tt_sig = dblarr(n_elements(tt))
tt_sig[*] = 0 ;second

; Accel model:
model_fac = 200.
h_fullmodel = sqrt(model_fac*2)*(t*atan(exp(t/(model_fac*2))/sqrt((model_fac*2))))
v_fullmodel = sqrt((model_fac*2))*atan(exp(t/(model_fac*2))/sqrt((model_fac*2))) + (exp(t/(model_fac*2))*t)/((model_fac*2)+exp(t/model_fac))
a_fullmodel = (exp(t/(model_fac*2))*((model_fac*2)*(t+(model_fac*4))-exp(t/model_fac)*(t-(model_fac*4))))/((model_fac*2)*((exp(t/model_fac)+(model_fac*2))^2.))

;h_fullmodel = sqrt(10)*(t*atan(exp(t/1000.)/10.))
;v_fullmodel = sqrt(10)*((exp(t/1000.)*t)/(10000*(exp(t/500.)/100.+1)) + atan(exp(t/1000.)/10))
;a_fullmodel = (exp(t/1000.)*(100*(t+2000)-exp(t/500.)*(t-2000)))/(10000*sqrt(10)*(exp(t/500.)+100)^2.)

;h_fullmodel = sqrt(10)*(t*atan(exp(t/100.)/(100*sqrt(10))))
;v_fullmodel = (10*exp(t/100.)*t)/(exp(t/50.)+100000) + sqrt(10)*atan(exp(t/100.)/(100*sqrt(10)))
;a_fullmodel = (exp(t/100.)*(100000*(t+200)-exp(t/50.)*(t-200)))/(10*(exp(t/50.)+100000)^2.)

;h_fullmodel = t*atan(exp(t/10.))
;v_fullmodel = (exp(t/10.)*t)/(10*(exp(t/5.)+1)) + atan(exp(t/10.))
;a_fullmodel = (exp(t/10.)*(-exp(t/5.)*(t-20)+t+20))/(100*(exp(t/5.)+1)^2.)

;h_fullmodel = (t*atan(exp(t/100.)/100.))/sqrt(10)
;v_fullmodel = ((exp(t/100.)*t)/(exp(t/50.)+10000)+atan(exp(t/100.)/100))/sqrt(10)
;a_fullmodel = (exp(t/100.)*(10000*(t+200)-exp(t/50.)*(t-200)))/(100*sqrt(10)*(exp(t/50.)+10000)^2.)

;h_fullmodel = t*atan(exp(t/(10*sqrt(10)))/(100*sqrt(10)))
;v_fullmodel = (10*exp(t/(10*sqrt(10)))*t)/(exp(t/(5*sqrt(10)))+100000) + atan(exp(t/(10*sqrt(10)))/(100*sqrt(10)))
;a_fullmodel = ((exp(t/(10*sqrt(10))))*(exp(t/(5*sqrt(10)))*(200-sqrt(10)*t)+100000*(sqrt(10)*t+200))) / (10*(exp(t/(5*sqrt(10)))+100000)^2.)

print, 'Location of acceleration peak: ', where(a_fullmodel eq max(a_fullmodel))
print, 'Location of acceleration minimum: ', where(a_fullmodel eq min(a_fullmodel))

h = sqrt((model_fac*2))*(tt*atan(exp(tt/(model_fac*2))/sqrt((model_fac*2))))
v = sqrt((model_fac*2))*atan(exp(tt/(model_fac*2))/sqrt((model_fac*2))) + (exp(tt/(model_fac*2))*tt)/((model_fac*2)+exp(tt/model_fac))
a = (exp(tt/(model_fac*2))*((model_fac*2)*(tt+(model_fac*4))-exp(tt/model_fac)*(tt-(model_fac*4))))/((model_fac*2)*((exp(tt/model_fac)+(model_fac*2))^2.))

;temp=20.
;plot, t, (exp(t/(2*temp))*((2*temp)*(t+(4*temp))-exp(t/(temp))*(t-(4*temp))))/((2*temp)*((exp(t/(temp))+(2*temp))^2.))
;stop

height_factor = 1e1
vel_factor = 1e-2
accel_factor = 1e-2

;Noisy distance eqn
noise_percent = 0
if noise_percent eq 0 then h_noisy = h; + noise_percent*height_factor*noise ;1%noise
if noise_percent ne 0 then h_noisy = h + noise_percent*height_factor*noise ;1%noise
;tt_noisy = tt+3.*noise2

; Using errorbars are the percentage error for 1-sigma error on hieght-time.
errorbars = 2 ;percent
h_noisy_sig = h_noisy*(errorbars/100.)

;Derive kinematics
v_forward = choose_deriv(tt, h_noisy, /forward)
v_centre = choose_deriv(tt, h_noisy, /centre)
;v_lagrangian = choose_deriv(tt, h_noisy, /lagrangian)
v_lagrangian = deriv(tt, h_noisy)

v_forward_sig = dblarr(n_elements(v_forward))
for k=0,n_elements(v_forward_sig)-1 do v_forward_sig[k] = sqrt( (h_noisy_sig[k+1]^2.+h_noisy_sig[k]^2.)/((tt[k+1]-tt[k])^2.) + (v_forward[k]^2.)*((tt_sig[k+1]^2.+tt_sig[k]^2.)/((tt[k+1]-tt[k])^2.)) )

v_centre_sig = dblarr(n_elements(v_centre))
for k=1,n_elements(v_centre_sig) do v_centre_sig[k-1] = sqrt( (h_noisy_sig[k+1]^2.+h_noisy_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.) + (v_centre[k-1]^2.)*((tt_sig[k+1]^2.+tt_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.)) )

v_lagrangian_sig = derivsig(tt, h_noisy, tt_sig, h_noisy_sig)
v_lagrangian_sig_man = dblarr(n_elements(v_lagrangian))
for k=1,n_elements(v_lagrangian_sig_man)-2 do v_lagrangian_sig_man[k] = sqrt( (h_noisy_sig[k+1]^2.+h_noisy_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.) + (v_lagrangian[k]^2.)*((tt_sig[k+1]^2.+tt_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.)) )

a_forward = choose_deriv(tt[0:n_elements(tt)-2], v_forward, /forward)
a_centre = choose_deriv(tt[1:n_elements(tt)-2], v_centre, /centre)
a_lagrangian = deriv(tt, v_lagrangian)

a_forward_sig = dblarr(n_elements(a_forward))
for k=0,n_elements(a_forward_sig)-1 do a_forward_sig[k] = sqrt( (v_forward_sig[k+1]^2.+v_forward_sig[k]^2.)/((tt[k+1]-tt[k])^2.) + (a_forward[k]^2.)*((tt_sig[k+1]^2.+tt_sig[k]^2.)/((tt[k+1]-tt[k])^2.)) )

a_centre_sig = dblarr(n_elements(a_centre))
for k=1,n_elements(a_centre_sig) do a_centre_sig[k-1] = sqrt( (v_centre_sig[k+1]^2.+v_centre_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.) + (a_centre[k-1]^2.)*((tt_sig[k+1]^2.+tt_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.)) )

a_lagrangian_sig = derivsig(tt, v_lagrangian, tt_sig, v_lagrangian_sig)
a_lagrangian_sig_man = dblarr(n_elements(a_lagrangian))
for k=1,n_elements(a_lagrangian_sig_man)-2 do a_lagrangian_sig_man[k] = sqrt( (v_lagrangian_sig[k+1]^2.+v_lagrangian_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.) + (a_lagrangian[k]^2.)*((tt_sig[k+1]^2.+tt_sig[k-1]^2.)/((tt[k+1]-tt[k-1])^2.)) )

if keyword_set(fit_vel) then begin
        yf = 'p[0]*x + p[1]'
        f = mpfitexpr(yf, tt, v_forward, 100,[h_noisy[0],v_forward[0],a_forward[0]], /quiet)
	h_fit_forward = (f[0]*0.5)*tt^2. + f[1]*tt + h_noisy[0]
        v_fit_forward = f[0]*tt + f[1]
        a_fit_forward = f[0]
	f = mpfitexpr(yf, tt, v_centre, 1, [h_noisy[0],v_centre[0],a_centre[0]], /quiet)
	h_fit_centre = (f[0]*0.5)*tt^2. + f[1]*tt + h_noisy[0]
	v_fit_centre = f[0]*tt + f[1]
	a_fit_centre = f[0]
endif
;print, 'Model velocity: ', deriv(tt, h)

if ~keyword_set(no_plot) then begin
	plot, tt, h/height_factor, psym=-0, linestyle=1, /ylog, yr=[0.1,100],/ys, xr=[-10,20010], /xs, xtit='Time (secs)', ytit='Height (Mm)'
	;oplot, tt, h_noisy/height_factor, psym=1, color=3
	oploterror, tt, h_noisy/height_factor, tt_sig, h_noisy_sig/height_factor, psym=3
	if keyword_set(fit_vel) then begin
		oplot, tt, h_fit_forward/height_factor, linestyle=4, color=5
		oplot, tt, h_fit_centre/height_factor, linestyle=5, color=3
	endif
	if ~keyword_set(no_legend) then legend, ['Model: r!D0!N+v!D0!Nt+0.5a!D0!Nt!U5/2!N','r!D0!N=100Mm, v!D0!N=400kms!U-1!N, a!D0!N=50ms!U-2!N',int2str(noise_percent)+'% Noise', int2str(cadence)+'s cadence', int2str(errorbars)+'% errorbars'], charsize=1, box=0
	;oplot, tt_noisy, h_noisy, psym=1, color=4
	oplot, t, h_fullmodel/height_factor, psym=-0
	if keyword_set(plot_fixed_point) then plots, fixed, h[where(tt eq fixed)]/height_factor, psym=6, color=6
endif

percent_noise = (abs(h_noisy - h)/h)*100.0d
;print, 'Mean % noise: ', mean(percent_noise)

if keyword_set(fit_vel) then begin
	chi_sq_v_forward = 0.
	for i=0,n_elements(v_forward)-1 do chi_sq_v_forward += (v_forward[i]-v_fit_forward[i])^2.
	chi_sq_v_centre = 0.
	for i=0,n_elements(v_centre)-1 do chi_sq_v_centre += (v_centre[i]-v_fit_centre[i])^2.
endif
	
if ~keyword_set(no_plot) then begin
	if ~keyword_set(large_range) then begin
		plot, tt, v/vel_factor, psym=-0, linestyle=1, yr=[0,700], xr=[-10,20010], /xs, /ys, xtit='Time (secs)', ytit='Velocity (km/s)'
	endif else begin
		plot, tt, v/vel_factor, psym=-0, linestyle=1, yr=[min(v_forward-v_forward_sig)/vel_factor,max(v_forward+v_forward_sig)/vel_factor], xr=[-10,00210], /xs, /ys, xtit='Time (secs)', ytit='Velocity (km/s)'
	endelse
	plots, tt[0:n_elements(tt)-2], v_forward/vel_factor, psym=-1, color=5
;	oplot, tt, deriv(tt, h)/vel_factor, psym=1, color=2
	plots, tt, v_lagrangian/vel_factor, psym=-1, color=4
	plots, tt[1:n_elements(tt)-2], v_centre/vel_factor, psym=-1, color=3
	oploterror, tt, v_forward/vel_factor, v_forward_sig/vel_factor, psym=3, errcolor=5
	if (cadence mod 8 ne 0) then oploterror, tt, v_lagrangian/vel_factor, v_lagrangian_sig/vel_factor, psym=3, errcolor=4
	;pause
	oploterror, tt[1:n_elements(tt)-2], v_centre/vel_factor, v_centre_sig/vel_factor, psym=3, errcolor=3
	if keyword_set(fit_vel) then begin
		oplot, tt, v_fit_forward/vel_factor, linestyle=4, color=5
		oplot, tt, v_fit_centre/vel_factor, linestyle=5, color=3
		if ~keyword_set(no_legend) then legend, ['!9c!X!U2!Dforward!N='+int2str(chi_sq_v_forward),'!9c!X!U2!Dcentre!N='+int2str(chi_sq_v_centre)], charsize=1, box=0
	endif
	oplot, t, v_fullmodel/vel_factor, psym=-0
	if keyword_set(plot_fixed_point) then plots, fixed, v[where(tt eq fixed)]/vel_factor, psym=6, color=6
endif

;plots, tt_noisy[0:n_elements(tt_noisy)-2], v_forward_n, psym=-1, color=5
;plots, tt_noisy[1:n_elements(tt_noisy)-2], v_centre_n, psym=-1, color=3
;plots, tt_noisy, v_lagrangian_n, psym=-1, color=4

;print, 'chi-squared v_forward: ', chi_squared
;print, 'chi-squared v_centre: ', chi_squared

;chi_squared = 0.
;for i=0,n_elements(v_lagrangian)-1 do chi_squared += (v_lagrangian[i]-v0)^2.
;print, 'chi-squared v_lagrangian: ', chi_squared

if keyword_set(fit_vel) then begin
	chi_sq_a_forward = 0.
	for i=0,n_elements(a_forward)-1 do chi_sq_a_forward += (a_forward[i]-a_fit_forward)^2.
	chi_sq_a_centre = 0.
	for i=0,n_elements(a_centre)-1 do chi_sq_a_centre += (a_centre[i]-a_fit_centre)^2.
endif

if ~keyword_set(no_plot) then begin
	if ~keyword_set(large_range) then begin
		plot, tt, a/accel_factor, psym=-0, linestyle=1, yr=[min(a_fullmodel/accel_factor)-10,max(a_fullmodel/accel_factor)+10], xr=[-10,20010], /xs, /ys, xtit='Time (secs)', ytit='Acceleration (m/s/s)'
	endif else begin
		plot, tt, a/accel_factor, psym=-0, linestyle=1, yr=[min(a_forward/accel_factor-a_forward_sig/accel_factor), max(a_forward/accel_factor+a_forward_sig/accel_factor)], xr=[-10,20010], /xs, /ys, xtit='Time (secs)', ytit='Acceleration (m/s/s)'
	endelse
	plots, tt[0:n_elements(tt)-3], a_forward/accel_factor, psym=-1, color=5
	;plots, tt, a_lagrangian, psym=-1, color=4
	oploterror, tt[0:n_elements(tt)-3], a_forward/accel_factor, a_forward_sig/accel_factor, psym=3, errcolor=5
	plots, tt, a_lagrangian/accel_factor, psym=-1, color=4
	if (cadence mod 8 ne 0) then oploterror, tt, a_lagrangian/accel_factor, a_lagrangian_sig/accel_factor, psym=3, errcolor=4
	plots, tt[2:n_elements(tt)-3], a_centre/accel_factor, psym=-1, color=3
	oploterror, tt[2:n_elements(tt)-3], a_centre/accel_factor, a_centre_sig/accel_factor, psym=3, errcolor=3
	
	if keyword_set(fit_vel) then begin
		oplot, tt, replicate(a_fit_forward/accel_factor,n_elements(tt)), linestyle=4, color=5
		oplot, tt, replicate(a_fit_centre/accel_factor,n_elements(tt)), linestyle=5, color=3
		if ~keyword_set(no_legend) then legend, ['!9c!X!U2!Dforward!N='+int2str(chi_sq_a_forward),'!9c!X!U2!Dcentre!N='+int2str(chi_sq_a_centre)], charsize=1, box=0
		if ~keyword_set(no_legend) then legend, ['Forward fit '+int2str(a_fit_forward),'Centre fit '+int2str(a_fit_centre)], charsize=1, box=0, /bottom,/right
	endif

	oplot, t, a_fullmodel/accel_factor, psym=-0
	
	if keyword_set(plot_fixed_point) then begin
		; Plotting the fixed point
		plots, fixed, a[where(tt eq fixed)]/accel_factor, psym=6, color=6
		;plots, fixed, a_forward[where(tt eq fixed)]/accel_factor, psym=4, color=7
		;plots, fixed, a_lagrangian[where(tt eq fixed)]/accel_factor, psym=4, color=7
		;plots, fixed, a_centre[where(tt eq fixed)-2]/accel_factor, psym=4, color=7
	endif

endif

att = a[where(tt eq fixed)]
af = a_forward[where(tt eq fixed)]
if where(tt eq fixed) ge n_elements(a_forward) then af=0.
ac = a_centre[where(tt eq fixed)-2]
if where(tt eq fixed)-2 lt 0 then ac = 0.
if where(tt eq fixed)-2 ge n_elements(a_centre) then ac = 0.
al = a_lagrangian[where(tt eq fixed)]

a_max = max(a_fullmodel)

print, 'Accelerations:'
print, 'forward: ', af/accel_factor
print, 'centre: ', ac/accel_factor
print, 'lagrangian: ', al/accel_factor
print, 'a at fixed: ', att/accel_factor
print, 'a_fullmodel: ', max(a_fullmodel)/accel_factor

end
