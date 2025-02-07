; EDITED: to work on HEEQ - Jason.

;+
; NAME:
;       op_ells
; PURPOSE:
;       Over plots 3D reconstuction on an image  
;
; EXPLANATION:
;       Converts the given Heliospheric-Earth-Eclipic (HEE) coordinates to
;		the corresponding pixel coordinates in the image and over plots them.
;        
; CALLING SEQUENCE:
;       res = op_ells(xhee, yhee, zhee, img, hdr [/plot])
;
; INPUTS:
;		xhee, yhee, zhee the coordinates in HEE in meters
;		from ellipse slices [x, 101] where x is number of slices
;               
; OUTPUTS:
;       result(x, 101, 2) array contain pixeling positions coresponding to header info
;		If /plot will plot the image and over plot the points.
;
;		Will return -1 on error.
;
;
; AUTHOR:
;		Shane Maloney 21/05/2009
;-

; Last edited: 10-12-09 to include a clause on the xes in the case where they're only a single array and not a set of arrays. -Jason.

function op_ells, xee, yee, zee, img, hdr, plot=plot

	; Converstions
	dtor = !dpi/180.0d
	rtod = 1.0d/dtor
	
	; Do some simple error checking
	if ( ( n_elements(xee) ne n_elements(yee) ) or ( n_elements(yee) ne n_elements(zee) ) ) then begin
		print, 'ERROR: x, y, z, must all be the same size'
		out = -1
		goto, error
	end
	
	if ( DATATYPE(hdr) NE 'STC' ) then begin ;hdr=SCC_FITSHDR2STRUCT(hdr)
		Print, 'ERROR: hdr is not  valid structure'
		out = -1
		goto, error		
	endif
	
	if ( TAG_NAMES(hdr, /STRUCTURE_NAME) NE 'SECCHI_HDR_STRUCT' ) then begin
		Print, 'ERROR: hdr is not a secchi header'
		out = -1
		goto, error		
	endif
	
	imgdim = size(img)
	
	if ( (imgdim[1] ne hdr.naxis1) or (imgdim[2] ne hdr.naxis2) ) then begin
		Print, 'ERROR: Image size does not match the header info (naxis1, naxis2)'
	;	out = -1
	;	goto, error
	endif
	
	
	; Size to loop over
	dimms = size(xee, /dim)
	
	; Convert from Rsun to meters
	xes = xee*6.95508e8
	yes = yee*6.95508e8
	zes = zee*6.95508e8
	
	; Get wcs ready
	wcs = fitshead2wcs(hdr)
	dsun = hdr.dsun_obs
	spc = strmid(hdr.OBSRVTRY, 7)
	
	; Out put array
	if size(dimms,/dim) ne 1 then out = dblarr(dimms[1], dimms[0], 2) else out = dblarr(dimms[0], 2)
	
	; If plot keyword set then plot base image
	if ( keyword_set(plot) ) then begin
			loadct, 0
			plot_image, img, title = hdr.obsrvtry+' '+hdr.detector+' '+hdr.date_obs
	endif
	
	;Loop through each ellipse and get pixel coords
	if size(dimms, /dim) eq 1 then i_limit = 0 else i_limit = dimms[1]-1
	for i=0, i_limit do begin
		
		; Rearrange to correct format for convert_stereo_coord
		heecoords = transpose([ [xes[*,i]], [yes[*,i]], [zes[*,i]] ])
		hgrtncoords = heecoords
		
		; Convert to HGRTN
		convert_stereo_coord, hdr.date_obs, hgrtncoords, 'HEEQ', 'HGRTN', spacecraft=spc
		
		; Rearrange to HPC
		hpccoords = [hgrtncoords[1,*], hgrtncoords[2,*], hgrtncoords[0,*]]
		
		; Convert to HPC
		d = sqrt(hpccoords[0,*]^2.0 + hpccoords[1,*]^2.0 + (dsun - hpccoords[2,*])^2.0)
		thetax = atan(hpccoords[0,*]/ (dsun - hpccoords[2,*]) )
		thetay = asin(hpccoords[1,*]/d)
		
		; Convert from radian to degree and relavent unit arcsec etc
		conv = rtod
		case wcs.cunit[0] of
			'arcmin': conv = conv * 60.d0
			'arcsec': conv = conv * 3600.d0
			'mas':    conv = conv * 3600.d3
			'rad':    conv = 1.d0
			else:     conv = conv
		endcase
		thetax = thetax * conv
		thetay = thetay * conv
		
		; Loop over each 3d coord and get corresponding pixel positions 
		for j=0, dimms[0]-1 do begin
			pixes = wcs_get_pixel(wcs, [ thetax[j], thetay[j] ])
			; If plot keyword set over plot points
			if ( keyword_set(plot) ) then begin 
					set_line_color
					plots, pixes[0], pixes[1], psym=3, color=5
			endif
			if size(dimms,/dim) ne 1 then out[i,j,*] = pixes else out[j,*] = pixes
		endfor
		
	endfor

	error:
	
	return, out

end
