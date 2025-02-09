num = 47
af_array = dblarr(num+1)
ac_array = af_array
al_array = af_array
att_array = af_array
a_max_array = af_array
fixed = 9
for cadence=1,num do begin & $
plot_different_kins_cadence_fixed2_gallag,cadence,fixed,af,ac,al,att,a_max,/no_legend & $
af_array[cadence] = af & $
ac_array[cadence] = ac & $
al_array[cadence] = al & $
att_array[cadence] = att & $
a_max_array[cadence] = a_max & $
print, cadence & $
x2png, 'frames/frame'+int2str(cadence,2) & $
;wait, 0.5 & $
endfor
toggle, /color, /portrait, f='peak_a_change_cadence.ps'
!p.multi=[0,1,3]
!p.thick=3
!p.charthick=3
!p.charsize=2
!x.thick=3
!y.thick=3
plot, indgen(num)+1, att_array[1:*]/1e-2, psym=-3, yr=[-10,10], /ys, xtit='Cadence', ytit='Accel. (m/s/s)'
oplot, indgen(num)+1, a_max_array[1:*]/1e-2, psym=-3, linestyle=1
oplot, indgen(num)+1, af_array[1:*]/1e-2, psym=-1, color=5
oplot, indgen(num)+1, al_array[1:*]/1e-2, psym=-1, color=4
oplot, indgen(num)+1, ac_array[1:16]/1e-2, psym=-1, color=3
toggle
$ps2pdf peak_a_change_cadence.ps
$open peak_a_change_cadence.pdf
