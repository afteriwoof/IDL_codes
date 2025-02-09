; Code to take the contouring of diffn8 and fit ellipse to the CME front.
; Mathematically sound according to http://ask.metafilter.com/mefi/36213

; Last Edited 15-02-07


pro contour8, a, b, theta

restore, 'diffn.sav'
diffn8=diffn[*,*,8]

plot_image, diffn8

mu = moment(diffn8(50:200,200:950),sdev=sdev)
thresh = mu[0] + 3.*sdev

contour, diffn8, level=thresh, /over, path_info=info, $
	path_xy=xy, /path_data_coords, c_color=3, thick=2

plots, xy(*,info[0].offset : (info[0].offset + info[0].n -1) ), $
	linestyle=0, /data

x = xy[0,info[0].offset : (info[0].offset + info[0].n -1)]
y = xy[1,info[0].offset : (info[0].offset + info[0].n -1)]

sz_x = size(x, /dim)
sz_y = size(y, /dim)
print, sz_x

sumx = 0.
sumy = 0.
sumxx = 0.
sumyy = 0.
sumxy = 0.
i=0.

while(i lt sz_x[1]) do begin
        sumx = sumx + x(i) 
        sumy = sumy + y(i)

        sumxx = sumxx + x(i)*x(i)
        sumyy = sumyy + y(i)*y(i)
        sumxy = sumxy + x(i)*y(i)

        i=i+1
endwhile

x_bar = sumx / sz_x[1]
y_bar = sumy / sz_y[1]
varx = sumxx / sz_x[1]
vary = sumyy / sz_y[1]
covarxy = sumxy / sz_x[1]
						
i=0.
z=fltarr(sz_x[1],2)
temp1=fltarr(2)
temp2=fltarr(2,2)
total = fltarr(2,2)

while(i lt sz_x[1]) do begin 

        ; Take the vector (x-xbar, y-ybar)
        z[i,0] = ( x[i] - x_bar )
	z[i,1] = ( y[i] - y_bar ) 

        ; Multiply each by its transpose
        temp1[0] = z[i,0]
        temp1[1] = z[i,1]

        temp2 = transpose(temp1)##temp1

        total = total + temp2 

        i=i+1 

endwhile

dx = z[*,0]
dy = z[*,1]
sumdxdx=0.
sumdydy=0.
sumdxdy=0.
i = 0.
while(i lt sz_x[1]) do begin 		       
	sumdxdx = sumdxdx + dx[i]*dx[i]
        sumdydy = sumdydy + dy[i]*dy[i]
        sumdxdy = sumdxdy + dx[i]*dy[i]
        i=i+1 
endwhile

eps = 1.e-10
theta = 0.5*atan(2*sumdxdy / (eps + (sumdydy-sumdxdx)))

c = cos(theta)
s = sin(theta)

u = c*dx - s*dy
v = s*dx + c*dy
sumuu = 0.
sumvv = 0.
i = 0.
while(i lt sz_x[1]) do begin
        sumuu = sumuu + u[i]*u[i]
        sumvv = sumvv + v[i]*v[i]
        i=i+1 
endwhile

varu = sumuu / sz_x[1]
varv = sumvv / sz_x[1]

a = sqrt(varu) ; semi-minor
b = sqrt(varv) ; semi-major

print, a, b

end
