FUNCTION Fit_Ellipse, indices, XSize=xsize, YSize=ysize, NPoints=npoints, $
	   Axes=axes, SemiAxes=semiAxes, Orientation=orientation, Center=center

         ; The following method determines the "mass density" of the ROI and fits
	       ; an ellipse to it. This is used to calculate the major and minor axes of
	             ; the ellipse, as well as its orientation. The orientation is calculated in
		           ; degrees counter-clockwise from the X axis.

			   IF N_Elements(xsize) EQ 0 THEN xsize = !D.X_Size
			   IF N_Elements(ysize) EQ 0 THEN ysize = !D.Y_Size
			   IF N_Elements(npoints) EQ 0 THEN npoints = 120

			      ; Fake indices for testing purposes.

			      IF N_Elements(indices) EQ 0 THEN BEGIN
				         xs = xsize / 4
					    xf = xsize / 4 * 2
					       ys = ysize / 4
					          yf = ysize / 4 * 2
						     array = BytArr(xsize, ysize)
						        array[xs:xf, ys:yf] = 255B
							   indices = Where(array EQ 255)
						   ENDIF

						   array = BytArr(xsize, ysize)
						   array[indices] = 255B
						   totalMass = Total(array)
						   xcm = Total( Total(array, 2) * Indgen(xsize) ) / totalMass
						   ycm = Total( Total(array, 1) * Indgen(ysize) ) / totalMass
						   center = [xcm, ycm]

						      ; Obtain the position of every pixel in the image, with the origin
						         ; at the center of mass of the ROI.

							 x = Findgen(xsize)
							 y = Findgen(ysize)
							 xx = (x # (y * 0 + 1)) - xcm
							 yy = ((x * 0 + 1) # y) - ycm
							 npts = N_Elements(indices)

							    ; Calculate the mass distribution tensor.

							    i11 = Total(yy[indices]^2) / npts
							    i22 = Total(xx[indices]^2) / npts
							    i12 = -Total(xx[indices] * yy[indices]) / npts
							    tensor = [[ i11, i12],[i12,i22]]

							       ; Find the eigenvalues and eigenvectors of the tensor.

							       evals = Eigenql(tensor, Eigenvectors=evecs)

							          ; The semi-major and semi-minor axes of the ellipse are obtained from the eigenvalues.

								  semimajor = Sqrt(evals[0]) * 2.0
								  semiminor = Sqrt(evals[1]) * 2.0

								     ; We want the actual axes lengths.

								     major = semimajor * 2.0
								     minor = semiminor * 2.0
								     semiAxes = [semimajor, semiminor]
								     axes = [major, minor]

								        ; The orientation of the ellipse is obtained from the first eigenvector.

									evec = evecs[*,0]

									   ; Degrees counter-clockwise from the X axis.

									   orientation = ATAN(evec[1], evec[0]) * 180. / !Pi - 90.0

									      ; Divide a circle into Npoints.

									      phi = 2 * !PI * (Findgen(npoints) / (npoints-1))

									         ; Position angle in radians.

										 ang = orientation / !RADEG

										    ; Sin and cos of angle.

										    cosang = Cos(ang)
										    sinang = Sin(ang)

										       ; Parameterized equation of ellipse.

										       x =  semimajor * Cos(phi)
										       y =  semiminor * Sin(phi)

										        ; Rotate to desired position angle.

											xprime = xcm + (x * cosang) - (y * sinang)
											yprime = ycm + (x * sinang) + (y * cosang)

											   ; Extract the points to return.

											   pts = FltArr(2, N_Elements(xprime))
											   pts[0,*] = xprime
											   pts[1,*] = yprime

											   RETURN, pts
											   END
