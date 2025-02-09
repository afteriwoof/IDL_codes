; Make plots for the AandA paper using toggle.

; Last Edited: 07-07-08

pro make_plots7

	!p.thick=2
	!p.charthick=2
	!p.charsize=2

	!p.multi=[0,2,2]

	;**********	


	toggle, f='images_20040401.ps'
	
	k=3
	fls = file_search('~/phd/data_vso/20040401/c2/normalised_rm/*fts')
        mreadfits, fls[k], temp, da
        fls = file_search('~/phd/data_Vso/20040401/c2/*fts')
        mreadfits, fls[k], in
	
	da = rm_inner(da, in, dr_px, thr=2.1)
	index2map, in, sigrange(da), map
	sub_map, map, smap, xr=[-5000,100], yr=[-1100,4400]
	
        restore, '~/PhD/data_vso/20040401/errorsc2.sav'
        restore, '~/PhD/data_vso/20040401/c2/normalised_rm/edg_images/my_fronts.sav'

       	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0, 0.5, 0.5, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic

        draw_circle, 0, 0, r_sun[2]
	
	pos = [0.5, 0.5, 1, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic	
	front = flip(my_fronts[*,*,k])
        front_ell_kinematics_printout_chose7, front, errorsc2[k], in, da, 2, pos, smap
        draw_circle, 0, 0, r_sun[2]

        ;**********

	k=16
	fls = file_search('~/phd/data_vso/20040401/c3/normalised_rm/*fts')
        mreadfits, fls[k], temp, da
        fls = file_search('~/phd/data_vso/20040401/c3/*fts')
        mreadfits, fls[k], in

	da = rm_inner(da, in, dr_px, thr=4.)
	index2map, in, alog(sigrange(da,frac=0.97)), map
	sub_map, map, smap, xr=[-23000,100],yr=[-1600,21500]
	
        restore, '~/phd/data_vso/20040401/errorsc3.sav'
        restore, '~/phd/data_vso/20040401/c3/normalised_rm/edg_images/frontsc3.sav'

;        ell_kinematics_printout3, in, da, edges[*,*,*], errorsc3, 2

	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0,0.15,0.5,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic        
	draw_circle, 0, 0, r_sun[2]	
	

        pos = [0.5,0.15,1,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
	front = flip(frontsc3[*,*,k])
        front_ell_kinematics_printout_chose7, front, errorsc3[k], in, da, 2, pos, smap        
	draw_circle, 0, 0, r_sun[2]

	toggle

         

	;**********
	toggle, f='images_20020421.ps'
	
	k=0
	fls = file_search('~/phd/data_vso/20020421/c2/normalised/*fts')
        mreadfits, fls[k+1], temp, da
        fls = file_search('~/phd/data_Vso/20020421/c2/*fts')
        mreadfits, fls[k+1], in
	
	da = rm_inner(da, in, dr_px, thr=2.1)
	index2map, in, sigrange(da), map
	sub_map, map, smap, xr=[-200,4600], yr=[-2300,2300]
	
        restore, '~/PhD/data_vso/20020421/errorsc2.sav'
        restore, '~/PhD/data_vso/20020421/c2/normalised/edg_images/fronts.sav'

       	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0.5, 0.5, 1, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose7, fronts[*,*,k], errorsc2[k], in, da, 2, pos, smap

        pos = [0, 0.5, 0.5, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]

        ;**********

	k=2
	fls = file_search('~/phd/data_vso/20020421/c3/normalised/*fts')
        mreadfits, fls[k+1], temp, da
        fls = file_search('~/phd/data_vso/20020421/c3/*fts')
        mreadfits, fls[k+1], in

	da = rm_inner(da, in, dr_px, thr=4.)
	index2map, in, alog(sigrange(da,frac=0.98)), map
	sub_map, map, smap, xr=[-100,19500],yr=[-10000,10000]
	
        restore, '~/phd/data_vso/20020421/errorsc3.sav'
        restore, '~/phd/data_vso/20020421/c3/normalised/edg_images/frontsc3.sav'

;        ell_kinematics_printout3, in, da, edges[*,*,*], errorsc3, 2

	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0.5,0.15,1,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose7_all, frontsc3[*,*,k], errorsc3[k], in, da, 2, pos, smap

        pos = [0,0.15,0.5,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]

	toggle

         

	;**********


	toggle, f='images_20000211.ps'
	
	k=4
	fls = file_search('~/phd/data_vso/20000211/c2/normalised_rm/*fts')
        mreadfits, fls[k+1], temp, da
        fls = file_search('~/phd/data_Vso/20000211/c2/*fts')
        mreadfits, fls[k+1], in

	index2map, in, sigrange(da), map
	sub_map, map, smap, xr=[-100,5900], yr=[-1200,5300]
	
        restore, '~/PhD/data_vso/20000211/errorsc2.sav'
        restore, '~/PhD/data_vso/20000211/c2/normalised_rm/edg_images/fronts.sav'

       	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0.5, 0.5, 1, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose7, fronts[*,*,k], errorsc2[k], in, da, 2, pos, smap

        pos = [0, 0.5, 0.5, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]

        ;**********

	k=10
	fls = file_search('~/phd/data_vso/20000211/c3/normalised_rm/*fts')
        mreadfits, fls[k], temp, da
        fls = file_search('~/phd/data_vso/20000211/c3/*fts')
        mreadfits, fls[k], in

	index2map, in, alog(sigrange(da)), map
	sub_map, map, smap, xr=[-4000,20000],yr=[-4000,20000]
	
        restore, '~/phd/data_vso/20000211/errorsc3.sav'
        restore, '~/phd/data_vso/20000211/c3/normalised_rm/edg_images/my_frontsc3.sav'

;        ell_kinematics_printout3, in, da, edges[*,*,*], errorsc3, 2

	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0.5,0.15,1,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose7_all, my_frontsc3[*,*,k], errorsc3[k], in, da, 2, pos, smap

        pos = [0,0.15,0.5,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]

	toggle
         

	;**********

	toggle, f='images_20000423.ps'
	
	k=1
	fls = file_search('~/phd/data_vso/20000423/c2/normalised/*fts')
        mreadfits, fls[k], temp, da
        fls = file_search('~/phd/data_Vso/20000423/c2/*fts')
        mreadfits, fls[k], in

	da = rm_inner(da, in, dr_px, thr=2.2)
	index2map, in, sigrange(da), map
	sub_map, map, smap, xr=[-100,5900], yr=[-2900,2900]
	
        restore, '~/PhD/data_vso/20000423/errorsc2.sav'
        restore, '~/PhD/data_vso/20000423/c2/normalised/edg_images/frontc2.sav'

       	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0.5, 0.5, 1, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose7, frontc2, errorsc2, in, da, 2, pos, smap

        pos = [0, 0.5, 0.5, 1]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]

        ;**********

	k=4
	fls = file_search('~/phd/data_vso/20000423/c3/normalised/*fts')
        mreadfits, fls[k+2], temp, da
        fls = file_search('~/phd/data_vso/20000423/c3/*fts')
        mreadfits, fls[k+2], in

	da = rm_inner(da, in, dr_px, thr=4.)
	index2map, in, alog(sigrange(da,frac=0.96)), map
	sub_map, map, smap, xr=[-3000,22000],yr=[-12000,13000]
	
        restore, '~/phd/data_vso/20000423/errorsc3.sav'
        restore, '~/phd/data_vso/20000423/c3/normalised/edg_images/frontsc3.sav'

;        ell_kinematics_printout3, in, da, edges[*,*,*], errorsc3, 2

	r_sun = pb0r(map.time, /arcsec, /soho)
        pos = [0.5,0.15,1,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]
        front_ell_kinematics_printout_chose7, frontsc3[*,*,k], errorsc3[k], in, da, 2, pos, smap

        pos = [0,0.15,0.5,0.65]
        plot_map, smap, /limb, /log, /notit, /nolabel, /noaxes, pos=pos, /isotropic
        draw_circle, 0, 0, r_sun[2]

	toggle
         

	;**********


end
