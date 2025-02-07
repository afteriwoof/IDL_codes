; Code which uses the atrous wavelet to view data according to scales.
; Then the Canny edge detector is used to obtain the modulus maxima of the derivative of the wavelet convolution.
; Contouring brings out the detected edges.

pro WTMM3

;restore, '~/PhD/Data_sav_files/da.sav' ;18apr2000
;restore, '~/PhD/Data_sav_files/in.sav'
;restore, '~/PhD/Data_sav_files/da_norm_221194.sav'
;restore, '~/PhD/Data_sav_files/in_221194.sav'

restore, '~/PhD/Data_sav_files/pb.sav'

da = pb[*,*,15:24]^0.3

sz = size(da, /dim)

;decomps = fltarr(sz[0], sz[1], 10, sz[2])
;for i=0,sz[2]-1 do begin
;	atrous, da[*,*,i], decomp=decomp
;	decomps[*,*,*,i] = decomp
;endfor
;save, decomps, filename='decomps_pb.sav'
;restore, '~/PhD/Data_sav_files/decomps_pb.sav' ; the decompositions of the data [*,*,*,10]

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
;save, zeroths, filename='zeroths_pb.sav'
;save, firsts, filename='firsts_pb.sav'
;save, seconds, filename='seconds_pb.sav'
;save, thirds, filename='thirds_pb.sav'
;save, fourths, filename='fourths_pb.sav'
;save, fifths, filename='fifths_pb.sav'
;save, sixths, filename='sixths_pb.sav'
;save, sevenths, filename='sevenths_pb.sav'
;save, eights, filename='eights_pb.sav'
;save, ninths, filename='ninths_pb.sav'


restore, 'fourths_pb.sav'
restore, 'fifths_pb.sav'
restore, 'sixths_pb.sav'

sz_fifths = size(fifths, /dim) ; [1024,1024,1,14]
array = fltarr(678, 656, sz_fifths[3])
;restore, 'mapsnb_221194.sav'
restore, '~/PhD/Data_sav_files/hdrs.sav'
in = hdrs[15:24]
index2map, in, da^0.3, maps

for i=0,sz_fifths[3]-1 do begin
	plot_map, maps[i]
	result = canny(sixths[*,*,*,i], high=0.905, low=0., sigma=0.1)
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


wr_movie, 'map_sixths2_pb', array



end
