pro diffprob, data, diff, sigdiff

;Reading in the images, and plotting the contoured images with a level specified by the threshold of sigma.

  fls = file_search( '../18-apr-2000/*' )
  
  mreadfits, fls, index, data

   sz = size( data, /dim )

   diff = fltarr( sz[ 0 ], sz[ 1 ], sz[ 2 ] - 1 )
   sigdiff = diff
  
   for i = 1, sz[ 2 ] - 1 do begin
     
     diff[ *, *, i - 1 ]  = data[ *, *, i ] - data[ *, *, i - 1]
     sigdiff[ *, *, i - 1 ] = smooth( sigrange( data[ *, *, i ] - data[ *, *, i - 1] ), 5, /ed )

  endfor

  szd = size( diff, /dim )

  !p.multi = [ 0, 1, 2 ]

  ;for i = 3 ;do begin
i=3
          mu = moment( diff( 50 : 200, 200 : 950, i ), sdev = sdev )
	  thresh = mu[ 0 ] + 2. * sdev
	  print, 'mu:' & print, mu
	  print, 'thresh:' & print, thresh
	  
	  set_line_color
	  plot_hist, diff[ 50:200, 50:200, i ], xr = [ -100, 100 ]
	  plots, [ mu[ 0 ], mu[ 0 ] ], [ 0, 1200 ], color=3
	  plots, [ thresh, thresh ], [ 0, 1200 ], color=4 

	  loadct, 0 
	  plot_image, sigdiff[ *, *, i ]
	  
	  draw_circle, 511, 511, 150, /data
          
	  set_line_color
	  contour, sigdiff[ *, *, i ], level = thresh, /over, path_info = info, $
		   path_xy = xy, /path_data_coords, c_color = 3, thick = 2
          
	   plots, xy[ *, info[ 0 ].offset : (info[ 0 ].offset+info[ 0 ].n-1) ], $
		   linestyle = 0, /data

	   ;if ( i le 9 ) then x2jpeg, 'diff0' + arr2str( i, /trim ) + '.jpg' else $
           ;                   x2jpeg, 'diff' + arr2str( i, /trim ) + '.jpg' 
          ans = ' '
          read, 'ok? ', ans
  	  
  ;endfor

end
