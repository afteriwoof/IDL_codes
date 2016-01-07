pro test

im = fltarr( 100, 100)

im[ 10:20, 30:90 ] = 1.

im[ 60:65, 10:40 ] = 1.

im1 = fltarr( 100, 100 )

im1[ 35:45, 30:90 ] = 1.

im1[ 70:75, 10:40 ] = 1.

!p.multi = [ 0, 2, 2 ]

plot_image, im
plot_image, im1

for i = 1, 40 do begin 
       
  !p.multi = [ 2, 2, 2 ]
  
  s = fltarr( i, i )
  s[ * ] = 1. 
  imd = dilate( im1, s )
  plot_image, imd
  
  imm = imd * im
  
  if ( max( imm ) eq 1. ) then begin

	  

  endif 

  
  !p.multi = [ 1, 2, 2 ]
  plot_image, imm
  
endfor

end

