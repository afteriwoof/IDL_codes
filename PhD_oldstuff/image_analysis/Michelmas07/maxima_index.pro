; Find the maxima of a plot and index them to arrange by size

; Last Edited: 15-10-07

function maxima_index, y, ind

sz = size(y,/dim)
flag = 0

for i=1,sz[0]-2 do begin
	pix = y[i]
	if (pix gt y[i-1] AND pix gt y[i+1]) then begin
		if flag eq 0 then begin
			ind = i
			flag = 1
		endif else begin
			ind = [ind, i]
		endelse
	endif
endfor

return, ind

end
