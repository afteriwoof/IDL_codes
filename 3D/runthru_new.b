restore,'~/idl_codes/slices.sav',/ver

readcol, 'vertices.txt', cross1, cross2, cross3, f='D,D,D'

sz = size(cross1,/dim)

lim = sz/4

for k=0,lim[0]-1 do begin & $
;for k=0,0 do begin & $
	cd, slices[k] & $
	i = [0,1,2,3]+4*k & $
	print, slices[k], i & $
	theta = 90.d0 - cross2[i[0]:i[3]] & $
	phi = cross1[i[0]:i[3]] * !dpi/180.d0 & $
	theta = theta * !dpi/180.d0 & $
	c1 = cross3[i[0]:i[3]] * sin(theta) * cos(phi) & $
	c2 = cross3[i[0]:i[3]] * sin(theta) * sin(phi) & $
	c3 = cross3[i[0]:i[3]] * cos(theta) & $
	sort3 = (sort(c3)) & $
	;temp = sort3[1] & $
	;sort3[1] = sort3[2] & $
	;sort3[2] = temp & $
	openw, lun, /get_lun, 'measure.txt', error=err & $
	free_lun, lun & $
	openu, lun, 'measure.txt', /append & $
	for j=0,3 do printf, lun, cross1[i[sort3[j]]], cross2[i[sort3[j]]], cross3[i[sort3[j]]], f='(D,D,D)' & $
	free_lun, lun & $
	flatten_plane_new, 'measure.txt',x,y,z,p1,p2,p3,p4,a,b,c,s,t,angle1,angle2,angle3,angle4,p1_init & $
	ellipse_equations, a,b,c,s,t,semimajor,semiminor,hx,hy & $
	x_ell = [0,0,a,s] & $
	y_ell = [0,c,b,t] & $
	ell_quadrilateral, x_ell,y_ell,semimajor,semiminor,hx,hy,ell & $
	plots,ell,/t3d & $
	ans = '' & $
	read, 'flip ellipse?', ans & $
	if ans eq 'y' then begin & $
		ell_quadrilateral, x_ell,y_ell,semimajor,semiminor,hx,hy,ell,/flip & $
		plots,ell & $
		print, 'regret flippin?!? Tough!' & $
		pause & $
	endif & $		
	unflatten_plane_new,ell,angle1,angle2,angle3,angle4,p1_init,xe,ye,ze & $
	;plot_spacecraft_views,ina,inb,x,y,z,xe,ye,ze,/zoom & $
	print, slices[k] & $
	pause & $
	;mov[*,*,k] = tvrd() & $	
	cd,'..' & $
endfor


