pro multiut

	fls1=file_search('~/phd/data_stereo/cor1/ahead_24jan07/pb/cme/normalised/*fts')
	fls2=file_search('~/phd/data_stereo/cor1/behind_24jan07/pb/CME/normalised/*fts')
	da1=sccreadfits(fls1)
	da2=sccreadfits(fls2)
	fls1=file_search('~/phd/data_stereo/cor1/ahead_24jan07/pb/cme/*fts')
	fls2=file_search('~/phd/data_stereo/cor1/behind_24jan07/pb/CME/*fts')
	mreadfits, fls1, in1
	mreadfits, fls2, in2	
	
	sz_inA = size(in1, /dim)
	sz_inB = size(in2, /dim)
	
	time_arA = file2time(fls1)
	utbasedataA = time_arA[0]
	timeplotA = anytim(time_arA)-anytim(time_arA[0])
	time_arB = file2time(fls2)
	utbasedataB = time_arB[0]
	timeplotB = anytim(time_arB)-anytim(time_arB[0])
	heightA = findgen(11)
	heightB = findgen(11)+2

	for j=0,sz_inA[0]-1 do begin
	print, size(timeplotA,/dim)

	utplot, timeplotA[0:sz_inA[0]-1], heightA, utbasedataA, psym=-2, tit='Height', $
		yr=[min(heightA[0:sz_inA[0]-1])*0.9, max(heightA)*1.1], /xstyle
	plots, timeplotB[0:sz_inB[0]-1], heightB, utbasedataB, psym=-4
	plots, [timeplotA[j],timeplotA[j]], [min(heightA[0:sz_inA[0]-1])*0.9, max(heightA)*1.1], $
		color=255, linestyle=2
	print, timeplotA[j], timeplotB[j]
	pause
	endfor


end
