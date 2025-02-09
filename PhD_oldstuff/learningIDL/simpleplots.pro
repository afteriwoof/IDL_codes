pro simpleplots

x = findgen(100)/100.*2*!pi
plot, x, sin(x)
plot, x, 10000+sin(x), /xs, /ys

pause

npts=256
nsig=4.

x= -nsig + findgen(npts)/float(npts)*2*nsig

gs= fltarr(npts,npts)

for j=0,npts-1 do begin
	for i=0,npts-1 do begin
		gs[i,j]=exp(-(x[i]^2+x[j]^2)/2.)
	endfor
endfor
loadct, 27
shade_surf, gs
contour, gs, x,x,nlev=255,/iso,/fill
pause
;Histogram
iseed=-1234
ndatapoints=100
nbins=20
data=randomu(iseed, ndatapoints)
xmin=min(data)
xmax=max(data)
bins=xmin+findgen(nbins)/float(nbins-1)*(xmax-xmin)

plot, bins, histogram(data,min=xmin,max=xmax,nbins=nbins), $
	psym=10, xrange=[-3.5,3.5]





end
