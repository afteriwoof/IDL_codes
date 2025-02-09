pro normalise, data, diff, sigdiff, diffnorm, sigdiffnorm

;Reading in the images, and plotting the contoured images with a level specified by the threshold of sigma.

loadct, 0
  
fls = file_search( '../18-apr-2000/*' )
  
  mreadfits, fls, index, data

   sz = size( data, /dim )

   diff = fltarr( sz[ 0 ], sz[ 1 ], sz[ 2 ] - 1 )
   sigdiff = diff
   diffnorm = diff
   sigdiffnorm = diff

   
   for i = 1, sz[ 2 ] - 1 do begin
     
     diff[ *, *, i - 1 ]  = data[ *, *, i ] - data[ *, *, i - 1]
     sigdiff[ *, *, i - 1 ] = smooth( sigrange( data[ *, *, i ] - data[ *, *, i - 1] ), 5, /ed )

  endfor

  szd = size( diff, /dim )

  !p.multi = [ 0, 1, 2 ]

  for i = 0, szd[ 2 ] - 1 do begin

	  loadct, 0

          mu = moment( diff( 50 : 200, 200 : 950, i ), sdev = sdev )
	  
	  ;Adjusting the mu values to normalise across all images
	  mu2 = mu - mu[0]
	  sdev = sqrt(mu2[1])
	  
	  diffnorm(*,*,i) = diff(*,*,i) - mu[0]
	  sigdiffnorm(*,*,i) = smooth(sigrange(diffnorm(*,*,i)), 5, /ed)
	  
	  thresh = mu2[ 0 ] + 1. * sdev
	  print, 'mu:' & print, mu
	  print, 'mu2:' & print, mu2
	  print, 'threshold:' & print, thresh
	  
	  plot_hist, diff[ 50:200, 200:950, i ] - mu[0], xr = [ -100, 200 ]
	  plots, [ mu2[ 0 ], mu2[ 0 ] ], [ 0, 2000 ]
	  plots, [ thresh, thresh ], [ 0, 2000 ] 
 
	  plot_image, sigdiffnorm[ *, *, i ]
	  
	  draw_circle, 511, 511, 150, /data
          
	  set_line_color
	  contour, sigdiffnorm[ *, *, i ], level = thresh, /over, path_info = info, $
		   path_xy = xy, /path_data_coords, c_color = 3, thick = 2

	   ;print, 'info:' & print, info

	   plots, xy[ *, info[ 0 ].offset : (info[ 0 ].offset+info[ 0 ].n-1) ], $
		   linestyle = 0, /data

	   ;if ( i le 9 ) then x2jpeg, 'diff0' + arr2str( i, /trim ) + '.jpg' else $
           ;                   x2jpeg, 'diff' + arr2str( i, /trim ) + '.jpg' 
          ans = ' '
          read, 'ok? ', ans
  	  
  endfor

end
