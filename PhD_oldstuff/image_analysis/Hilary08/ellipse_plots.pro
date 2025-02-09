; Code which outputs the kinematic curves for the ellipse information determined in ell_kinematics.pro

; the flsc2, flsc3 must be in the format where the names are the observation dates (as in normalised_rm folder)

; h_errors might be in pixels in which case transform to arcsec by multiplying by in.platescl

; Last Edited: 09-01-08

pro ellipse_plots, flsc2, flsc3, kinsc2, kinsc3, h_errors


time_arc2 = file2time(flsc2)
utbasedata = time_arc2[0]
timeplotc2 = anytim(time_arc2) - anytim(utbasedata)

time_arc3 = file2time(flsc3)
; use the utbasedata
timeplotc3 = anytim(time_arc3) - anytim(utbasedata)

t = [timeplotc2, timeplotc3]
; ERRORS
; Error in time is just coronagraph exposure time.
mreadfits, flsc2, inc2
mreadfits, flsc3, inc3
delta_tc2 = inc2.exptime
delta_tc3 = inc3.exptime
delta_t = [delta_tc2, delta_tc3]

h_arcsec = [kinsc2[*,5], kinsc3[*,5]]
v_arcsec = deriv(t,h_arcsec)
a_arcsec = deriv(t,v_arcsec)

v_errors = fltarr(n_elements(t))
a_errors = v_errors
for i=0,n_elements(t)-1 do begin
	v_errors[i] = v_arcsec[i]*( h_errors[i]/h_arcsec[i] + delta_t[i]/t[i] )
	a_errors[i] = a_arcsec[i]*( v_errors[i]/v_arcsec[i] + delta_t[i]/t[i] )
endfor
print, v_errors, a_errors
; h is in arcsec --> change to R_sun
;mreadfits, flsc2[0], in
;h = h*in.platescl/((pb0r(in,/arc,/soho))[2])
Rsun_arcsec = (pb0r(in,/arc,/soho))[2]
h_Rsun = h_arcsec/Rsun_arcsec
h_errs_Rsun = h_errors/Rsun_arcsec
; Change the errors into R_sun
;errors = errors*in.platescl/((pb0r(in,/arc,/soho))[2])
;errors = errors*11.9/((pb0r(in,/arc,/soho))[2])

; Work out the errors in Velocity and Acceleration

!p.multi=[0,1,2]

yf = 'p[0]*x^2. + p[1]*x + p[2]'
f = mpfitexpr(yf, t, h_arcsec, h_errors, [h_arcsec[0],v_arcsec[0],a_arcsec[0]])

h_model = f[0]*t^2 + f[1]*t + f[2]
v_model = f[0]*t + f[1]
a_model = f[0]

; HEIGHT
utplot, t, h_Rsun, utbasedata, psym=3, tit='!6Height Apex', ytit='R_sun', yr=[0,22],/ys
outplot, t, h_model/Rsun_arcsec, utbasedata, psym=-3
oploterror, t, h_Rsun, delta_t, h_errs_Rsun, psym=3

;VELOCITY
utplot, t, v_arcsec*710, utbasedata, psym=2, tit='Velocity Apex', ytit='km/sec'
outplot, t, v_model*710, utbasedata, psym=-3
oploterror, t, v_arcsec*710, delta_t, v_errors*710, psym=3
stop
;ACCELERATION
utplot, t, a*750000., utbasedata, psym=2, tit='Acceleration', ytit='m/sec^2'
a_model_array = replicate(a_model*750000., n_elements(t))
outplot, t, a_model_array, utbasedata, psym=-3
oploterror, t, a, delta_t


	
	


end
