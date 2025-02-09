pro deriv_test, n, smooth=smooth

t = dindgen(n)
a = reverse(dindgen(n/2.))
a = [a,replicate(0,n/2.)]
;a[((n/2.))] = -1
;a[((n/2.)+1)] = -2
;a[((n/2.)+2)] = -1
;a[((n/2.)+3)] = 0
v = dblarr(n)
h = dblarr(n)

v[0] = 5
h[0] = 0
;for k=0,n-2 do v[k+1] = v[k] + a[k+1]*(t[k+1]-t[k])
;for k=0,n-2 do h[k+1] = v[k]*(t[k+1]-t[k]) - 0.5*a[k+1]*((t[k+1]-t[k])^2.)

FOR k=0, n-2 DO BEGIN
       v[k+1] = v[k] + a[k]*(t[k+1]-t[k])
       h[k+1] = h[k] + v[k]*(t[k+1]-t[k]) + 0.5*a[k]*((t[k+1]-t[k])^2.)
ENDFOR

deriv_v = deriv(t,h)
deriv_a = deriv(t,deriv_v)

!p.multi=[0,1,3]

plot, t, h, psym=-1

if keyword_set(smooth) then begin
	h_sm = smooth(h,3,/edge)
	oplot, t, h_sm, linestyle=4, psym=-1
	v_sm = deriv(t, h_sm)
	a_sm = deriv(t, v_sm)
	v_sm2 = smooth(v_sm, 3, /edg)
	a_sm2 = deriv(t,v_sm2)
endif

if keyword_set(smooth) then begin
	plot, t, v, yr=[min([v,deriv_v,v_sm]),max([v,deriv_v,v_sm])], psym=-1 &
endif else begin
	plot, t, v, yr=[min([v,deriv_v]),max([v,deriv_v])], psym=-1
endelse
	oplot, t, deriv_v, linestyle=2, psym=-1
if keyword_set(smooth) then begin
	oplot, t, v_sm, linestyle=4, psym=-1
	oplot, t, v_sm2, linestyle=5, psym=-1
endif

if keyword_set(smooth) then begin
	plot, t, a, yr=[min([a,deriv_a,a_sm,a_sm2]),max([a,deriv_a,a_sm,a_sm2])], psym=-1
endif else begin
	plot, t, a, yr=[min([a,deriv_a]),max([a,deriv_a])], psym=-1
endelse
	oplot, t, deriv_a, linestyle=2, psym=-1
if keyword_set(smooth) then begin
	oplot, t, a_sm, linestyle=4, psym=-1
	oplot, t, a_sm2, linestyle=5, psym=-1
endif



end
