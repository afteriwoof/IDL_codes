; Make plots for the AandA paper using toggle.

; Last Edited: 19-02-08

pro make_plots6


	!p.multi=[0,2,2]

	toggle, f='images_20040401.ps';, /color, /landscape

	k=3
	
	fls = file_search('~/phd/data_vso/20040401/c2/normalised_rm/*fts')
	mreadfits, fls[k], temp, da
	;cme = da[525:975,175:625]
	fls = file_search('~/phd/data_Vso/20040401/c2/*fts')
	mreadfits, fls[k], in

	index2map, in, da, map
	sub_map, map, smap, xrange=[-5500,-150], yrange=[-950,4400]
	
	restore, '~/PhD/data_vso/20040401/errorsc2.sav'
	restore, '~/PhD/data_vso/20040401/my_frontsc2.sav'
	
;	ell_kinematics_printout3, in, da, edges, errorsc2, 2
	
	r_sun = pb0r(map.time, /arcsec, /soho)

	pos = [0, 0.5, 0.5, 1]
	plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
	draw_circle, 0, 0, r_sun[2]

	pos = [0.5, 0.5, 1, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose6, my_frontsc2[*,*,k], errorsc2[k], in, da, 2, pos, smap
				   

	;**********

	k=16
	fls = file_search('~/phd/data_vso/20040401/c3/normalised_rm/*fts')
	mreadfits, fls[k], temp, da
	fls = file_search('~/phd/data_vso/20040401/c3/*fts')
	mreadfits, fls[k], in

	index2map, in, alog(sigrange(da)), map
	sub_map, map, smap, xr=[-24000,0], yr=[-2000,22000]
	
	restore, '~/phd/data_vso/20040401/errorsc3.sav'
	restore, '~/phd/data_vso/20040401/my_frontsc3.sav'

	r_sun = pb0r(map.time, /arcsec, /soho)
	
	pos = [0,0.15,0.5,0.65]
	plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
	draw_circle, 0, 0, r_sun[2]

	pos = [0.5,0.15,1,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose6, my_frontsc3[*,*,k], errorsc3[k], in, da, 2, pos, smap
	    
	toggle
	
	;***********



end
