PRO laplacian

kernelsize=[3,3]
        
kernel=FLTARR(kernelsize[0],kernelsize[1])
             
kernel[*,*]=-1

kernel[1,1]=8

print, 'kernel', kernel

filteredimage=CONVOL(FLOAT(img8), kernel, /CENTER, /EDGE_TRUNCATE)

window, /free, title='smoothed image laplacian filtered'
    
plot_image, filteredimage

END
