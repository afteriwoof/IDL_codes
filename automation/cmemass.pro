; Created	2014-02-12	to take out the CME mass info from Huw's files.

; INPUT
;	 dets_path = '/Volumes/Bluedisk/detections/yyyy/mm/dd'
;	 mass_path = '/Volumes/Bluedisk/cme_masses'


pro cmemass, dets_path, mass_path, tog=tog

print, 'dets_path: ', dets_path
print, 'mass_path: ', mass_path
fls = file_search(dets_path+'/cme_profs/*txt')
print, 'fls: ', fls
if strlen(fls[0]) eq 0 then goto, jump_end

;for ii = 0, n_elements(fls)-1 do begin
for ii=1,1 do begin

	fl_in = fls[ii]
	datetime_label = strmid(file_basename(fl_in),0,15)

	;eg readcol, '/Volumes/Bluedisk/detections/2000/01/12/cme_kins/cme_kins_20000112_203306.txt', datetimes_in, heights_in, pos_angles_in, f='A,D,F'
	readcol, fl_in, datetimes_in, heights_in, pos_angles_in, f='A,A,D,F'
	datetimes = datetimes_in
	
	out_dir = dets_path+'/cme_masses'
	if ~dir_exist(out_dir) then spawn, 'mkdir -p '+out_dir

	dets_datetimes = strmid(datetimes[uniq(datetimes,sort(datetimes))],0,16)
	; Loop over the dets to get the relevant mass (C2 only)
	loop_flag = 0
	for i=0,n_elements(dets_datetimes)-1 do begin & $
		; Find the relevant mass_file & $
		mass_fl = file_search(mass_path+'/*'+strjoin(strsplit(strmid(dets_datetimes[i],0,10),'/',/extract))+'.dat') & $
		if strlen(mass_fl) eq 0 then goto, jump1
		restore, mass_fl & $
		mass_datetimes = strmid(mmain.date,0,10)+'T'+strmid(mmain.date,11,5) & $
		ind = where(mass_datetimes eq dets_datetimes[i], cnt) & $
		if cnt ne 1 then goto, jump1 & $
		mass_now = mmain[ind].mass & $
		if where(mass_now ne 0) eq [-1] then goto, jump1 & $
		angs_now = (where(mass_now ne 0))/2. & $
		mass_now = mass_now[where(mass_now ne 0)] & $
		datetime_now = dets_datetimes[i] & $
		if loop_flag eq 0 then begin & $
			mass_list = mass_now & $
			angs_list = angs_now & $
			datetimes_list = replicate(datetime_now, n_elements(mass_now)) & $
			loop_flag = 1 & $
		endif else begin & $
			mass_list = [mass_list, mass_now] & $
			angs_list = [angs_list, angs_now] & $
			datetimes_list = [datetimes_list, replicate(datetime_now, n_elements(mass_now))] & $
		endelse & $
		jump1: & $
	endfor
	if loop_flag eq 0 then goto, jump_loop_end

	;*****
	sav_fl = file_search(dets_path+'/cme_kins/cme_kins_savgol_'+datetime_label+'.sav')
	print, 'sav_fl ', sav_fl
	if strlen(sav_fl) eq 0  then goto, jump_loop_end
	restore, sav_fl, /ver
	posang1 = cme_kins.cme_posang1
	posang2 = cme_kins.cme_posang2
	cpa = cme_kins.cme_cpa
	print, 'posang1: ', posang1
	print, 'posang2: ', posang2
	print, 'cpa: ', cpa
	if cpa gt posang1 then inds = where(angs_list ge posang1 AND angs_list le posang2) $
		else inds = where(angs_list le posang1 AND angs_list ge posang2)
	if inds eq [-1] then goto, jump_loop_end
	angs_list = angs_list[inds]
	mass_list = mass_list[inds]
	datetimes_list = datetimes_list[inds]

	; Loop over the masses per time and find the summed max at one time
	max_mass = 0.
	max_time = '0'
	for jj=0,n_elements(dets_datetimes)-1 do begin
		ind = where(datetimes_list eq dets_datetimes[jj])
		if ind ne [-1] then begin
			max_mass = [max_mass, total(mass_list[ind])]
			max_time = [max_time, dets_datetimes[jj]]
		endif 
	endfor
	help, max_mass
	if n_elements(max_mass) gt 1 then begin
		max_mass = max_mass[1:n_elements(max_mass)-1]
		max_time = max_time[1:n_elements(max_time)-1]
		max_cme_mass = max(max_mass)
		save, max_cme_mass, filename=out_dir+'/max_cme_mass.sav'
	endif

	;*****
	; PLOT
	if keyword_set(tog) then goto, jump_tog
	
	utbase = min(anytim(datetimes_list))
	
	utplot, datetimes_list, mass_list, utbase, ytit='Mass', /nodata, yr=[min(mass_list),max(max_mass)]
	
	for i=min(angs_list),max(angs_list) do begin & $
		pos_ind = where(abs(angs_list-i) lt 0.5, cnt) & $
		if cnt gt 1 then begin & $
			outplot, datetimes_list[pos_ind], mass_list[pos_ind], color=(i-min(angs_list))*(255./(max(angs_list)-min(angs_list))), psym=1 & $
	
		endif & $
	endfor

	;ticknames = int2str(fix((((indgen(7))*((max(angs_list)-min(angs_list))/6)+min(angs_list))+180) mod 360))
	ticknames = int2str(fix(((indgen(7))*((max(angs_list)-min(angs_list))/6)+min(angs_list))))
	colorbar, ncol=255,pos=[0.4,0.93,0.7,0.945], tickinterval=6, tickname=ticknames, $
		tit='Position Angle (deg.)', charsize=1, xtit=''

	outplot, max_time, max_mass, psym=-2

	goto, jump_loop_end

	jump_tog:
	; EPS	
	set_plot, 'ps'
	loadct, 13
	device, /encapsul, bits=8, language=2, /portrai, /color, filename=out_dir+'/plot_cme_mass_'+datetime_label+'.eps', xs=20, ys=20
	!p.background=1
	!p.charsize=1
	!p.charthick=5
	!p.thick=3

	time_add = ( max(anytim(datetimes_list)) - min(anytim(datetimes_list)) ) * 0.05
        xls = anytim(min(anytim(datetimes_list)) - time_add, /ccsds)
        xrs = anytim(max(anytim(datetimes_list)) + time_add, /ccsds)
	
	utplot, datetimes_list, mass_list, utbase, ytit='Mass (g)', xr=[xls,xrs], /xs, yr=[0,max(mass_list)], /nodata, pos=[0.15,0.1,0.85,0.80], ystyle=8

	for i=min(angs_list),max(angs_list) do begin & $
	        pos_ind = where(abs(angs_list-i) lt 0.5, cnt) & $
	        if cnt gt 1 then begin & $
	                outplot, datetimes_list[pos_ind], mass_list[pos_ind], color=(i-min(angs_list))*(255./(max(angs_list)-min(angs_list))), psym=1 & $
	
	        endif & $
	endfor

	;ticknames = int2str(fix((((indgen(7))*((max(angs_list)-min(angs_list))/6)+min(angs_list))+180) mod 360)) 
	ticknames = int2str(fix(((indgen(7))*((max(angs_list)-min(angs_list))/6)+min(angs_list))))
	colorbar, ncol=255,pos=[0.35,0.85,0.65,0.87], tickinterval=6, tickname=ticknames, $
	        tit='Position Angle (deg.)', charsize=1, xtit=''
	
	set_line_color
	axis, yaxis=1, yrange=[0,max(max_mass)], /ys, ytit='Total Mass (g)', color=9, /save
	outplot, max_time, max_mass, psym=-3, color=9, thick=8
	
	device, /close_file

	jump_loop_end:

endfor

jump_end:

end
