; Make plots for the AandA paper using toggle.

; Last Edited: 30-01-08

pro make_plots2


	!p.multi=[0,2,4]
	
	toggle, /color
	
	fls = file_search('~/phd/data_vso/20000102/c2/normalised_rm/*fts')
	mreadfits, fls, temp, da
	fls = file_search('~/phd/data_Vso/20000102/c2/*fts')
	mreadfits, fls, in

	restore, '~/PhD/data_vso/20000102/errorsc2.sav'

	restore, '~/PhD/data_vso/20000102/c2/normalised_rm/edg_images/edges.sav'

	ell_kinematics_printout2, in, da, edges, errorsc2, 2

	k=2
	print, 'You chose image ', k

	pos = [0, 0.8, 0.2, 1]
	front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc2[k], in[k], da[*,*,k], 2, pos
	;**********

	fls = file_search('~/phd/data_vso/20000102/c3/normalised_rm/*fts')
	mreadfits, fls, temp, da
	fls = file_search('~/phd/data_vso/20000102/c3/*fts')
	mreadfits, fls, in

	restore, '~/phd/data_vso/20000102/errorsc3.sav'
	restore, '~/phd/data_vso/20000102/c3/normalised_rm/edg_images/edges.sav'

	ell_kinematics_printout2, in, da, edges[*,*,2:*], errorsc3, 2

	k=8
	print, 'You chose image ', k

	pos = [0.2, 0.8, 0.4, 1]
	front_ell_kinematics_printout_chose2, edges[*,*,k+2], errorsc3[k], in[k], da[*,*,k], 2, pos
	;***********

	fls = file_search('~/phd/data_vso/20000118/c2/normalised_rm/*fts')
        mreadfits, fls, temp, da
        fls = file_search('~/phd/data_Vso/20000118/c2/*fts')
        mreadfits, fls, in

        restore, '~/PhD/data_vso/20000118/errorsc2.sav'

        restore, '~/PhD/data_vso/20000118/c2/normalised_rm/edg_images/edges.sav'
					        
        ell_kinematics_printout2, in, da, edges, errorsc2, 2

        k=2
        print, 'You chose image ', k

        pos = [0, 0.6, 0.2, 0.8]
        front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc2[k], in[k], da[*,*,k], 2, pos
	;*****
        fls = file_search('~/phd/data_vso/20000118/c3/normalised_rm/*fts')
        mreadfits, fls, temp, da
        fls = file_search('~/phd/data_vso/20000118/c3/*fts')
        mreadfits, fls, in

        restore, '~/phd/data_vso/20000118/errorsc3.sav'
        restore, '~/phd/data_vso/20000118/c3/normalised_rm/edg_images/edges.sav'

        ell_kinematics_printout2, in, da, edges[*,*,*], errorsc3, 2

        k=14
        print, 'You chose image ', k

        pos = [0.2, 0.6, 0.4, 0.8]
        front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc3[k], in[k], da[*,*,k], 2, pos

	;**********


	fls = file_search('~/phd/data_vso/20000418/c2/normalised_rm/*fts')
        mreadfits, fls, temp, da
        fls = file_search('~/phd/data_Vso/20000418/c2/*fts')
        mreadfits, fls, in

        restore, '~/PhD/data_vso/20000418/errorsc2.sav'

        restore, '~/PhD/data_vso/20000418/c2/normalised_rm/edg_images/edges.sav'
					        
        ell_kinematics_printout2, in, da, edges, errorsc2, 2

        k=5
        print, 'You chose image ', k

        pos = [0, 0.4, 0.2, 0.6]
        front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc2[k], in[k], da[*,*,k], 2, pos
        ;**********
	fls = file_search('~/phd/data_vso/20000418/c3/normalised_rm/*fts')
        mreadfits, fls, temp, da
        fls = file_search('~/phd/data_vso/20000418/c3/*fts')
        mreadfits, fls, in 

        restore, '~/phd/data_vso/20000418/errorsc3.sav'
        restore, '~/phd/data_vso/20000418/c3/normalised_rm/edg_images/edges.sav'

        ell_kinematics_printout2, in, da, edges[*,*,*], errorsc3, 2

        k=6   
        print, 'You chose image ', k

        pos = [0.2, 0.4, 0.4, 0.6] 
        front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc3[k], in[k], da[*,*,k], 2, pos

	;**********

	fls = file_search('~/phd/data_vso/20010423/c2/cme1/normalised_rm/*fts')
        mreadfits, fls, temp, da
        fls = file_search('~/phd/data_Vso/20010423/c2/cme1/*fts')
        mreadfits, fls, in

        restore, '~/PhD/data_vso/20010423/errorsc2.sav'

        restore, '~/PhD/data_vso/20010423/c2/cme1/normalised_rm/edg_images/edges.sav'

        ell_kinematics_printout2, in, da, edges, errorsc2, 2

        k=2
        print, 'You chose image ', k

        pos = [0, 0.2, 0.2, 0.4]
        front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc2[k], in[k], da[*,*,k], 2, pos
        ;**********
	
	fls = file_search('~/phd/data_vso/20010423/c3/cme1/normalised_rm/*fts')
        mreadfits, fls, temp, da
        fls = file_search('~/phd/data_vso/20010423/c3/cme1/*fts')
        mreadfits, fls, in

        restore, '~/phd/data_vso/20010423/errorsc3.sav'
        restore, '~/phd/data_vso/20010423/c3/cme1/normalised_rm/edg_images/edges.sav'

        ell_kinematics_printout2, in, da, edges[*,*,*], errorsc3, 2

        k=6
        print, 'You chose image ', k

        pos = [0.2, 0.2, 0.4, 0.4]
        front_ell_kinematics_printout_chose2, edges[*,*,k], errorsc3[k], in[k], da[*,*,k], 2, pos

         ;**********

	toggle	 

	
end
