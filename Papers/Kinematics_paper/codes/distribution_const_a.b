c1 = fltarr(10000)
c2=c1
for i=0,n_elements(c1)-1 do begin & $
plot_different_kins_const_a,/fit_vel,/no_plot,chi_sq_v_forward, chi_sq_v_centre, chi_sq_a_forward, chi_sq_a_centre, a_fit_forward, a_fit_centre & $
c1[i]=a_fit_forward & $
c2[i]=a_fit_centre & $
endfor
print, ave(c1), ave(c2)

