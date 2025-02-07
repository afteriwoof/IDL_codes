; comparing run diff thresholds with multiscale edge

pro compare, in, im, imd, imfront, mov

window, 0, xs=800, ys=800

mov = fltarr(800,800,5)

sz = size(imfront, /dim)
imf = fltarr(sz[0], sz[1])
for i=0,sz[0]-1 do imf[*,abs(sz[0]-1-i)]=imfront[*,i]

mu = moment(imd, sdev=sdev)

thr1 = mu[0] + sdev
thr2 = mu[0] + 2*sdev
thr3 = mu[0] + 3*sdev

ind = where(imf gt 0)
arr = array_indices(im, ind)


contour, imd, lev=thr1, path_xy=xy1, path_info=info1, /path_data_coords
contour, imd, lev=thr2, path_xy=xy2, path_info=info2, /path_data_coords
contour, imd, lev=thr3, path_xy=xy3, path_info=info3, /path_data_coords

x1 = xy1[0,info1[0].offset:(info1[0].offset+info1[0].n-1)]        
y1 = xy1[1,info1[0].offset:(info1[0].offset+info1[0].n-1)]

x2 = xy2[0,info2[0].offset:(info2[0].offset+info2[0].n-1)]        
y2 = xy2[1,info2[0].offset:(info2[0].offset+info2[0].n-1)]

x3 = xy3[0,info3[0].offset:(info3[0].offset+info3[0].n-1)]        
y3 = xy3[1,info3[0].offset:(info3[0].offset+info3[0].n-1)]

x4 = arr[0,*]
y4 = arr[1,*]

index2map, in, sigrange(im), map
x_map1 = (x1-in.crpix1)*in.cdelt1
y_map1 = (y1-in.crpix2)*in.cdelt2
x_map2 = (x2-in.crpix1)*in.cdelt1
y_map2 = (y2-in.crpix2)*in.cdelt2
x_map3 = (x3-in.crpix1)*in.cdelt1
y_map3 = (y3-in.crpix2)*in.cdelt2
x_map4 = (x4-in.crpix1)*in.cdelt1
y_map4 = (y4-in.crpix2)*in.cdelt2

sub_map, map, smap, /plot, xrange=[-5300,-1300], yrange=[100,4100]
plot_map, smap, /limb

;plots, x_map1, y_map1, psym=-3, color=2
;plots, x_map2, y_map2, psym=-3, color=3
;plots, x_map3, y_map3, psym=-3, color=4

arr1 = frontonly(x_map1,y_map1)
arr2 = frontonly(x_map2,y_map2)
arr3 = frontonly(x_map3,y_map3)
arr4 = frontonly(x_map4,y_map4)

x1 = arr1[0:(n_elements(arr1)/2)-1]
y1 = arr1[(n_elements(arr1)/2):n_elements(arr1)-1]

x2 = arr2[0:(n_elements(arr2)/2)-1]
y2 = arr2[(n_elements(arr2)/2):n_elements(arr2)-1]

x3 = arr3[0:(n_elements(arr3)/2)-1]
y3 = arr3[(n_elements(arr3)/2):n_elements(arr3)-1]

x4 = arr4[0:(n_elements(arr4)/2)-1]
y4 = arr4[(n_elements(arr4)/2):n_elements(arr4)-1]


mov[*,*,0]=tvrd()
set_line_color
legend, ['1 sigma'], box=0
plots, x1, y1, psym=-3, color=2, thick=2
mov[*,*,1]=tvrd()
pause
legend, ['1 sigma', '2 sigma'], box=0
plots, x2, y2, psym=-3, color=3, thick=2
mov[*,*,2]=tvrd()
pause
legend, ['1 sigma', '2 sigma', '3 sigma'], box=0
plots, x3, y3, psym=-3, color=4, thick=2
mov[*,*,3]=tvrd()
pause
legend, ['1 sigma', '2 sigma', '3 sigma', 'Multiscale'], box=0
plots, x4, y4, psym=-3, color=5, thick=2
mov[*,*,4]=tvrd()



end


function frontonly, x_map, y_map

;x_map = in[0:(n_elements(in)/2)-1]
;y_map = in[(n_elements(in)/2):n_elements(in)-1]

; Take only a number of points across the front
recpol, x_map, y_map, r, a, /degrees

a_max1 = max(a)
a_min1 = min(a)

a = round(a)
r = round(r)

a_max = max(a)
a_min = min(a)

a_front = fltarr(a_max - a_min +1)
r_front = fltarr(a_max - a_min +1)
temp = 0.
count = a_min
stepsize = 1.
while (count le a_max) do begin
        a_front[temp] = count
        if (where(a eq count) eq [-1]) then goto, jump1
        r_front[temp] = max(r[where(a eq count)])
        jump1:
        temp = temp + 1
        count = count + stepsize
endwhile


polrec, r_front, a_front, x_front, y_front, /degrees

;non_zero_front, x_front, y_front, xnf, ynf

;x_front=xnf

;y_front=ynf

;plots, x_front, y_front, psym=1;, color=2;yellow

out = [x_front, y_front]	

return, out

end


