pro lots_fronts, all, first, second, third

	temp = first
	sz1 = size(first, /dim)
	for i=0,sz1[0]-1 do temp[*,abs(sz1[0]-1-i)]=first[*,i]
	im1 = temp
	delvarx, temp

	temp = second
	sz2 = size(second, /dim)
	for i=0,sz2[0]-1 do temp[*,abs(sz2[0]-1-i)]=second[*,i]
	im2 = temp
	delvarx, temp

	temp = third
	sz3 = size(third, /dim)
	for i=0,sz3[0]-1 do temp[*,abs(sz3[0]-1-i)]=third[*,i]
	im3 = temp
	delvarx, temp
	
	front1 = where(im1 ne 0)
	front2 = where(im2 ne 0)
	front3 = where(im3 ne 0)
	
	ind1 = array_indices(im1, front1)
	ind2 = array_indices(im2, front2)
	ind3 = array_indices(im3, front3)
	
	all = [[ind1],[ind2],[ind3]]

end
