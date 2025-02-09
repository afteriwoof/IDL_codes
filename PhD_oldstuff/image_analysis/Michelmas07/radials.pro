; Code to take the window defined in combined_thresholds.pro and highlight max radial pixels.

; Last Edited: 08-10-07

pro radials, in, da, lines 

sz_da = size(da,/dim)

lines = fltarr(2, sz_da[0]/2, 4)

for quadrant=1,4 do begin

	case quadrant of
		1: begin
			theta = 0
			for j=0,sz_da[0]/2-1 do begin	
				lines[0,j,0] = in[0].crpix1 + j
				lines[1,j,0] = in[0].crpix2
			endfor
		end
		2: begin
			theta = 90
			for j=0,sz_da[0]/2-1 do begin
				lines[0,j,1] = in[0].crpix1
				lines[1,j,1] = in[0].crpix2 + j
			endfor
		end
		3: begin
			theta = 180
			for j=0,sz_da[0]/2-1 do begin
				lines[0,j,2] = in[0].crpix1 - j
				lines[1,j,2] = in[0].crpix2
			endfor
		end
		4: begin
			theta = 270
			for j=0,sz_da[0]/2-1 do begin
				lines[0,j,3] = in[0].crpix1
				lines[1,j,3] = in[0].crpix2 - j
			endfor
		end
	endcase
	
	x_first = fltarr(20)
	y_first = fltarr(20)
	radius = 6000
	for i=0,19 do begin
		polrec, radius, theta, x, y, /degrees
		x_first[i] = x
		y_first[i] = y
		theta += 4.5
	endfor
	x_orig = fltarr(20)
	y_orig = fltarr(20)
	for i=0,19 do begin
		x_orig[i] = (x_first[i] / in[0].cdelt1) + in[0].crpix1
		y_orig[i] = (y_first[i] / in[0].cdelt2) + in[0].crpix2
	endfor
	profs = fltarr(sz_da[0]/2,20)
	result = profile(newim,xx,yy,xi=in[0].crpix1,xf=x_orig[0],yi=in[0].crpix2,yf=y_orig[0])

	case quadrant of
		1: first = result
		2: second = result
		3: third = result
		4: fourth = result
	endcase

	sz_res = size(result,/dim)
	profs[0:sz_res[0]-1,0] = result

	for i=0,19 do begin
		result = profile(newim,xx,yy,xi=in[0].crpix1,xf=x_orig[i],$
			yi=in[0].crpix2,yf=y_orig[i])
		sz_res = size(result,/dim)
		profs[0:sz_res[0]-1,i] = result
	endfor
	
	temp = fltarr(512, 20)
	profs0 = profs[where(profs[*,0] ne 0), 0]
	sz_profs0 = size(profs0, /dim)
	temp[0:sz_profs0[0]-1,0] = profs0

	for i=0,19 do begin
		profs0 = profs[where(profs[*,i] ne 0), i]
		sz_profs0 = size(profs0, /dim)
		temp[0:sz_profs0[0]-1, i] = profs0
	endfor



endfor

end

