pro mycopypg, data, diff, sigdiff

;Reading in the images and plotting the contoured images with a level specified by the threshold of sigma.

files = file_search('../18-apr-2000/*')

mreadfits, files, index, data

sz = size(data, /dim) ;size and number of image arrays

;Create the arrays for the difference images with appropriate dimensions.
diff = fltarr(sz[0],sz[1],sz[2]-1)
sigdiff = diff

for i = 1, sz[2]-1 do begin

	diff[*,*,i-1] = data[*,*,i] - data[*,*,i-1]

	sigdiff[*,*,i-1] = smooth(sigrange(data[*,*,i] - data[*,*,i-1]), 5, /ed)

endfor


szd = size(diff, /dim) ;size and number of diff images







end
