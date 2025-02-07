; Code which uses the atrous wavelet to view data according to scales.
; Then the Canny edge detector is used to obtain the modulus maxima of the derivative of the wavelet convolution.
; Contouring brings out the detected edges.

pro WTMM2

;restore, '~/PhD/Data_sav_files/da.sav' ;18apr2000
;restore, '~/PhD/Data_sav_files/in.sav'
restore, '~/PhD/Data_sav_files/da_norm_221194.sav'
restore, '~/PhD/Data_sav_files/in_221194.sav'
da_norm = da_norm[*,*,56:65]
in = in[56:65]

sz = size(da_norm, /dim)

;restore, '~/PhD/Data_sav_files/da_norm.sav'
;restore, '~/PhD/Data_sav_files/danb.sav'
restore, '~/PhD/Data_sav_files/danb_221194.sav'
danb = danb[*,*,56:65]

;decomps = fltarr(sz[0], sz[1], 10, sz[2])
;for i=0,sz[2]-1 do begin
;	atrous, da_norm[*,*,i], decomp=decomp
;	decomps[*,*,*,i] = decomp
;endfor
;save, decomps, filename='decomps_221194.sav'

restore, '~/PhD/Data_sav_files/decomps_221194.sav' ; the decompositions of the data [*,*,*,10]

;zeroths = decomps[*,*,0,*]
;firsts = decomps[*,*,1,*]
;seconds = decomps[*,*,2,*]
;thirds = decomps[*,*,3,*]
;fourths = decomps[*,*,4,*]
;fifths = decomps[*,*,5,*]
;sixths = decomps[*,*,6,*]
;sevenths = decomps[*,*,7,*]
;eights = decomps[*,*,8,*]
;ninths = decomps[*,*,9,*]
;save, zeroths, filename='zeroths.sav'
;save, firsts, filename='firsts.sav'
;save, seconds, filename='seconds.sav'
;save, thirds, filename='thirds.sav'
;save, fourths, filename='fourths.sav'
;save, fifths, filename='fifths.sav'
;save, sixths, filename='sixths.sav'
;save, sevenths, filename='sevenths.sav'
;save, eights, filename='eights.sav'
;save, ninths, filename='ninths.sav'


restore, 'fourths_221194.sav'
restore, 'fifths_221194.sav'
restore, 'sixths_221194.sav'

sz_fifths = size(fifths, /dim) ; [1024,1024,1,14]
array = fltarr(678, 656, sz_fifths[3])
restore, 'mapsnb_221194.sav'
;index2map, in, danb, mapsnb

for i=0,sz_fifths[3]-1 do begin
	plot_map, mapsnb[i]
	result = canny(fourths[*,*,*,i])
	contour, result, level=0.001, /over, path_info=info, path_xy=xy, $
		/path_data_coords, c_color=3, thick=2
	xy_org = xy
	xy(0,*) = ( xy(0,*)-in[i].crpix1 ) * in[i].cdelt1
	xy(1,*) = ( xy(1,*)-in[i].crpix2 ) * in[i].cdelt2
	plots, xy[0,*], xy[1,*], psym=3	

	entry = tvrd()
	array[*,*,i] = entry
endfor

;save, mapsnb, filename='mapsnb_221194.sav'

;for i=0,sz_fifths[3]-1 do begin

;	plot_image, fifths[*,*,*,i]
;	contour, canny(fifths[*,*,*,i], high=0.74, low=0.), level=0.001, /over
;	entry = tvrd()
;	array[*,*,i] = entry

;endfor


;wr_movie, 'map_fourths_221194', array



end
