openw, lun, /get_lun, 'kins_cadence.txt'
printf, lun, '# cadence a_forward a_centre a_lagrangian'
free_lun, lun
t = dindgen(400)+1
mov = dblarr(800,600,190)
count=0
for j=10,1910,10 do begin & $
print, j & $
for k=1,399 do begin & $
cadence=k & $
plot_different_kins_cadence_fixed, cadence, j, af, ac, al, at, /no_plot & $
if k ne 1 then begin & $
aft=[aft,af] & $
act=[act,ac] & $
alt=[alt,al] & $
endif else begin & $
aft=af & $
act=ac & $
alt=al & $
endelse & $
openu, lun, 'kins_cadence.txt', /append & $
printf, lun, cadence, af, ac, al & $
free_lun, lun & $
;pause & $
endfor & $
!p.multi=0 & $
plot,t,aft,psym=4,/xlog,yr=[0,4300],/ys,color=1,xtit='Cadence',ytit='Acceleration (m/s/s/)' & $
;plot,t,aft,psym=4,/xlog,yr=[min([min(aft[where(aft ne 0)]),min(act[where(act ne 0)]),min(alt[where(alt ne 0)])]),max([max(aft),max(act),max(alt)])],color=1,xtit='Cadence',ytit='Acceleration (m/s/s/)' & $
oplot,t[where(act ne 0)],act[where(act ne 0)],psym=2,color=3 & $
oplot,t[where(alt ne 0)], alt[where(alt ne 0)],psym=1,color=4 & $
oplot,t[where(aft ne 0)],aft[where(aft ne 0)],psym=4,color=5 & $
plots,[1,1000],[at,at],psym=-3,linestyle=1 & $
legend,['Forward','Centre','Lagrangian','Model'],psym=[4,2,1,3],color=[5,3,4,0] & $
mov[*,*,count]=tvrd() & $
count+=1 & $
endfor
