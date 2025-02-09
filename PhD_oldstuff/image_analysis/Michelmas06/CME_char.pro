PRO CME_char

files=findfile('18-apr-2000/*.fits')

mreadfits, files, index, data

a=make_array(1024,1024,14)
sa=make_array(1024,1024,14)

loadct, 3

for i=0,13 do begin

	a(*,*,i)=sigrange(data(*,*,i+1)-data(*,*,i))
	sa(*,*,i)=smooth(a(*,*,i), 5, /ed)

	window, /free
	plot_image, sa(*,*,i)
	
	contour, sa(*,*,i), level=1, /over	

endfor

END
