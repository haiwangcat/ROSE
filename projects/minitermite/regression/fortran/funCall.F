# 1 "test.F"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "test.F"
      SUBROUTINE icsd_t1_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
      IMPLICIT NONE
      INTEGER :: POSTPROCESSMARKER1

# 1 "global.fh" 1

# 1 "gacommon.h" 1




# 1 "macommon.h" 1












# 22 "macommon.h"
                     














# 5 "gacommon.h" 2







# 22 "gacommon.h"









# 2 "global.fh" 2
      integer ga_max_dim
      parameter (ga_max_dim = 7)
!
      integer ga_nnodes, ga_nodeid, ga_read_inc
      integer ga_pgroup_nnodes, ga_pgroup_nodeid
      integer nga_pgroup_nnodes, nga_pgroup_nodeid
      integer ga_spd_invert, ga_solve, ga_llt_solve
      integer ga_inquire_memory, ga_memory_avail
      integer nga_inquire_memory, nga_memory_avail
      logical ga_create, ga_destroy, ga_locate, ga_create_irreg
      logical nga_destroy
      logical ga_locate_region
      logical ga_compare_distr, ga_duplicate, ga_uses_ma
      logical nga_compare_distr, nga_duplicate, nga_uses_ma
      logical ga_memory_limited, nga_memory_limited
      logical ga_create_mutexes
      logical nga_create_mutexes
      logical ga_destroy_mutexes
      logical nga_destroy_mutexes
      logical ga_valid_handle, nga_valid_handle
      logical ga_verify_handle, nga_verify_handle
      logical ga_update2_ghosts
      logical ga_update3_ghosts
      logical ga_update4_ghosts
      logical ga_update5_ghosts
      logical ga_update6_ghosts
      logical ga_update7_ghosts
      logical ga_set_update4_info
      logical ga_set_update5_info
      logical nga_update_ghost_dir
      logical ga_has_ghosts, nga_has_ghosts
      integer ga_create_handle
      integer nga_create_handle
      logical ga_allocate
      integer ga_pgroup_create, nga_pgroup_create
      integer ga_pgroup_split, nga_pgroup_split
      integer ga_pgroup_split_irreg, nga_pgroup_split_irreg
      double precision ga_ddot, ga_ddot_patch
      double complex   ga_zdot, ga_zdot_patch
      double complex   nga_zdot_patch
      complex   ga_cdot, ga_cdot_patch
      complex   nga_cdot_patch
      double precision nga_ddot_patch, ga_wtime
      integer ga_idot
      integer nga_idot_patch
      integer ga_pgroup_get_default, ga_pgroup_get_mirror
      integer nga_pgroup_get_default, nga_pgroup_get_mirror
      integer ga_pgroup_get_world, nga_pgroup_get_world
      integer ga_ndim, nga_ndim
      real ga_sdot, ga_sdot_patch, nga_sdot_patch
      integer ga_is_mirrored, nga_is_mirrored
      integer ga_nbtest, nga_nbtest
!
      integer nga_read_inc
      integer ga_cluster_nprocs, ga_cluster_nodeid, ga_cluster_nnodes
      integer ga_cluster_procid, ga_cluster_proc_nodeid
      integer nga_locate_num_blocks
      integer ga_total_blocks, nga_total_blocks
      logical ga_uses_proc_grid, nga_uses_proc_grid
      logical nga_create, nga_locate, nga_create_irreg
      logical nga_locate_region
      logical nga_create_ghosts_irreg,nga_create_ghosts
      logical nga_create_config, nga_create_irreg_config
      logical nga_create_ghosts_irreg_config, nga_create_ghosts_config
      logical ga_get_debug, nga_get_debug
      integer ga_get_dimension, nga_get_dimension
      integer ga_get_pgroup, nga_get_pgroup
      integer ga_get_pgroup_size, nga_get_pgroup_size
      logical ga_pgroup_destroy, nga_pgroup_destroy
      integer ga_pgroup_absolute_id, nga_pgroup_absolute_id
      integer nga_register_type, nga_deregister_type
      logical nga_check_notify
!
      external ga_create, ga_destroy, ga_ddot, ga_locate
      external nga_destroy
      external ga_locate_region
      external ga_nnodes, ga_nodeid, ga_read_inc, ga_create_irreg
      external ga_pgroup_nnodes, ga_pgroup_nodeid
      external nga_pgroup_nnodes, nga_pgroup_nodeid
      external ga_ddot_patch, ga_compare_distr, ga_duplicate
      external nga_compare_distr, nga_duplicate
      external ga_inquire_memory, ga_uses_ma, ga_memory_limited
      external nga_inquire_memory, nga_uses_ma, nga_memory_limited
      external ga_memory_avail
      external ga_zdot, ga_zdot_patch
      external ga_cdot, ga_cdot_patch
      external ga_create_mutexes
      external nga_create_mutexes
      external ga_destroy_mutexes
      external nga_destroy_mutexes
      external ga_valid_handle, nga_valid_handle
      external ga_verify_handle, nga_verify_handle
      external ga_update2_ghosts
      external ga_update3_ghosts
      external ga_update4_ghosts
      external ga_update5_ghosts
      external ga_update6_ghosts
      external ga_update7_ghosts
      external ga_set_update4_info
      external ga_set_update5_info
      external nga_update_ghost_dir
      external ga_create_handle
      external nga_create_handle
      external ga_allocate
      external ga_pgroup_create, nga_pgroup_create
      external ga_pgroup_split, nga_pgroup_split
      external ga_pgroup_split_irreg, nga_pgroup_split_irreg
      external ga_has_ghosts, nga_has_ghosts
      external ga_pgroup_get_default, ga_pgroup_get_mirror
      external nga_pgroup_get_default, nga_pgroup_get_mirror
      external ga_pgroup_get_world, nga_pgroup_get_world
      external ga_ndim, nga_ndim
      external ga_spd_invert, ga_solve, ga_llt_solve
      external nga_read_inc, nga_create, nga_locate, nga_create_irreg
      external nga_locate_region
      external nga_create_ghosts_irreg,nga_create_ghosts
      external nga_create_config, nga_create_irreg_config
      external nga_create_ghosts_irreg_config,nga_create_ghosts_config
      external nga_ddot_patch, nga_zdot_patch, nga_cdot_patch
      external nga_idot_patch, ga_idot
      external ga_sdot, ga_sdot_patch, nga_sdot_patch
      external ga_cluster_nprocs, ga_cluster_nodeid, ga_cluster_nnodes
      external ga_cluster_procid, ga_cluster_proc_nodeid
      external ga_is_mirrored
      external nga_locate_num_blocks
      external ga_total_blocks
      external ga_uses_proc_grid, nga_uses_proc_grid
      external ga_get_debug, nga_get_debug
      external ga_get_pgroup, nga_get_pgroup
      external ga_get_pgroup_size, nga_get_pgroup_size
      external ga_pgroup_destroy, nga_pgroup_destroy
      external ga_wtime
      external ga_nbtest, nga_nbtest
      external ga_pgroup_absolute_id, nga_pgroup_absolute_id
      external nga_register_type, nga_deregister_type
      external nga_get_field, nga_nbget_field
      external nga_put_field, nga_nbput_field
      external nga_check_notify
!
# 5 "test.F" 2

# 1 "mafdecls.fh" 1



!
!     $Id: mafdecls.fh,v 1.11 2002-09-14 05:40:30 d3g001 Exp $
!

!
!     Public header file for a portable dynamic memory allocator.
!
!     This file may be included by internal and external FORTRAN files.
!



!
!     The guard ends here instead of at the end of the file because we only
!     need the cpp constants (stuff above) defined once per FORTRAN file,
!     but need the declarations (stuff below) to be defined each time this
!     file is included in a FORTRAN file.
!



!
!     constants
!

!     type declarations for datatype constants
      integer    MT_BYTE      ! byte
      integer    MT_INT       ! integer
      integer    MT_LOG       ! logical
      integer    MT_REAL      ! real
      integer    MT_DBL       ! double precision
      integer    MT_SCPL      ! single precision complex
      integer    MT_DCPL      ! double precision complex

      integer    MT_F_FIRST   ! first type
      integer    MT_F_LAST    ! last type

!     parameter declarations for datatype constants
      parameter    (MT_BYTE = (1000 + 9))
      parameter    (MT_INT = (1000 + 10))
      parameter    (MT_LOG = (1000 + 11))
      parameter    (MT_REAL = (1000 + 12))
      parameter    (MT_DBL = (1000 + 13))
      parameter    (MT_SCPL = (1000 + 14))
      parameter    (MT_DCPL = (1000 + 15))

      parameter    (MT_F_FIRST = MT_BYTE)
      parameter    (MT_F_LAST = MT_DCPL)

!
!     function types
!


      logical MA_alloc_get
      logical MA_allocate_heap
      logical MA_chop_stack
      logical MA_free_heap
      logical MA_free_heap_piece
      logical MA_get_index
      logical MA_get_next_memhandle
      logical MA_get_numalign
      logical MA_init
      logical MA_initialized
      logical MA_init_memhandle_iterator
      integer MA_inquire_avail
      integer MA_inquire_heap
      integer MA_inquire_heap_check_stack
      integer MA_inquire_heap_no_partition
      integer MA_inquire_stack
      integer MA_inquire_stack_check_heap
      integer MA_inquire_stack_no_partition
      logical MA_pop_stack
!     subroutine MA_print_stats
      logical MA_push_get
      logical MA_push_stack
      logical MA_set_auto_verify
      logical MA_set_error_print
      logical MA_set_hard_fail
      logical MA_set_numalign
      integer MA_sizeof
      integer MA_sizeof_overhead
!     subroutine MA_summarize_allocated_blocks
!     subroutine MA_trace
      logical MA_verify_allocator_stuff

      external MA_alloc_get
      external MA_allocate_heap
      external MA_chop_stack
      external MA_free_heap
      external MA_free_heap_piece
      external MA_get_index
      external MA_get_next_memhandle
      external MA_get_numalign
      external MA_init
      external MA_initialized
      external MA_init_memhandle_iterator
      external MA_inquire_avail
      external MA_inquire_heap
      external MA_inquire_heap_check_stack
      external MA_inquire_heap_no_partition
      external MA_inquire_stack
      external MA_inquire_stack_check_heap
      external MA_inquire_stack_no_partition
      external MA_pop_stack
      external MA_print_stats
      external MA_push_get
      external MA_push_stack
      external MA_set_auto_verify
      external MA_set_error_print
      external MA_set_hard_fail
      external MA_set_numalign
      external MA_sizeof
      external MA_sizeof_overhead
      external MA_summarize_allocated_blocks
      external MA_trace
      external MA_verify_allocator_stuff


!
!     variables
!
      character*1       byte_mb(2)

      integer           int_mb(2)

      logical           log_mb(2)

      real              real_mb(2)

      double precision  dbl_mb(2)

      complex           scpl_mb(2)

      double complex    dcpl_mb(2)

# 6 "test.F" 2

# 1 "sym.fh" 1
      logical sym_shell, sym_shell_pair, sym_atom, sym_atom_pair
      logical sym_char_table, sym_abelian_group
C      logical sym_shell_quartet, sym_atom_quartet
C$Id: sym.fh 19708 2010-10-29 18:04:21Z d3y133 $
      logical  sym_atom_quartet
      integer sym_center_map, sym_number_ops
      external sym_shell, sym_atom
      external sym_center_map, sym_number_ops
      external sym_shell_pair, sym_atom_pair
      external  sym_atom_quartet, sym_char_table
      external sym_abelian_group
C      external sym_shell_quartet, sym_atom_quartet
# 7 "test.F" 2

# 1 "errquit.fh" 1
c UERR - Not yet assigned to a catagory
c UNKNOWN_ERR - Not yet assigned to a catagory
c MEM_ERR - Generic Memory error
c RTDB_ERR - Error in the Runtime Database
c INPUT_ERR - Error resulting from inproper user input
c CAPMIS_ERR - Features that have not been implemented yet
c BASIS_ERR - Error related to basis sets
c GEOM_ERR - Error related to geometry
c MA_ERR - local memory error
c GA_ERR - global memory error
c INT_ERR - error related to integrals
c DISK_ERR - error in reading or writing from disk
c CALC_ERR - calcutation fails to converge
c FMM_ERR - 
c STACK_ERR - error in MA stack
c HEAP_ERR - error in MA heap
      integer UERR,UNKNOWN_ERR, MEM_ERR, RTDB_ERR, INPUT_ERR, CAPMIS_ERR
      integer BASIS_ERR, GEOM_ERR, GA_ERR, MA_ERR, INT_ERR, DISK_ERR
      integer CALC_ERR, FMM_ERR, STACK_ERR, HEAP_ERR
      parameter (UERR=0,UNKNOWN_ERR=0, MEM_ERR=10, RTDB_ERR=20,
     I  INPUT_ERR=30)
      parameter (CAPMIS_ERR=40, BASIS_ERR=50, GEOM_ERR=60, GA_ERR=70)
      parameter (MA_ERR=80, INT_ERR=90, DISK_ERR=100, CALC_ERR=110)
      parameter (FMM_ERR=120, STACK_ERR=11, HEAP_ERR=12)
c $Id: errquit.fh 21176 2011-10-10 06:35:49Z d3y133 $
# 8 "test.F" 2

# 1 "tce.fh" 1
c
c $Id: tce.fh 21409 2011-11-05 06:36:24Z d3y133 $
c
c     This is the universal header file for TCE subroutines.  Only variables which
c     must be shared by ALL subroutines should be placed here.  In other words,
c     only those variables needed by the computer-generated code or related to
c     intorb should be here.  Most variables should go in tce_main.fh, although
c     there are distinct headers for other features.
c
c     Warning: if you modify this file, the entire TCE must be recompiled.
c
c     - Jeff Hammond, January 2008
c
      integer l_spin, k_spin      ! Spins of blocks
      integer l_sym, k_sym        ! Symmetry of blocks
      integer l_range, k_range    ! Length of blocks
c      integer l_offset, k_offset  ! Offset of blocks
c      integer l_alpha,k_alpha     ! Alpha-izer of beta orbitals (for restricted case)
      integer noa,nob,nva,nvb     ! Number of blocks
      integer noab,nvab           ! Number of blocks
      integer irrep_e             ! Totally symmetric
      parameter (irrep_e = 0)
      integer irrep_e2            ! Totally symmetric
      parameter (irrep_e2 = 0)
      integer irrep_f             ! Totally symmetric
      parameter (irrep_f = 0)
      integer irrep_v             ! Totally symmetric
      parameter (irrep_v = 0)
      integer irrep_t             ! Totally symmetric
      parameter (irrep_t = 0)
      integer irrep_t1            ! Totally symmetric
      parameter (irrep_t1 = 0)
      integer irrep_t2            ! Totally symmetric
      parameter (irrep_t2 = 0)
      integer irrep_t3            ! Totally symmetric
      parameter (irrep_t3 = 0)
      integer irrep_x             ! Irreducible representation of X vector (X=EOM-RIGHT)
      integer irrep_y             ! Irreducible representation of Y vector (Y=EOM-LEFT
      integer irrep_d             ! Irreducible representation of D vector (D=dipole)
      integer irrep_o             ! Irreducible representation of O vector (O=operator)
      integer irrep_a             ! Generic irrep in property codes
      integer irrep_b             ! Generic irrep in property codes
      integer irrep_c             ! Generic irrep in property codes
      integer irrep_tr            ! Irreducible representation of T(1)
      integer irrep_yr            ! Irreducible representation of L(1) (L=Lambda)
      integer irrep_oa            ! Irreducible representation of property A
      integer irrep_ob            ! Irreducible representation of property B
      integer irrep_oc            ! Irreducible representation of property C
      integer irrep_od            ! Irreducible representation of property D
c
      integer irrep_tra           ! Irreducible representation of T(1) w.r.t. A
      integer irrep_trb           ! Irreducible representation of T(1) w.r.t. B
      integer irrep_trc           ! Irreducible representation of T(1) w.r.t. C
      integer irrep_trd           ! Irreducible representation of T(1) w.r.t. D
c
      integer idiv2e            ! offset related parameter
c
c     Currently not in use but I am reserving them for future use.
c
c      integer irrep_yra           ! Irreducible representation of L(1) w.r.t. A
c      integer irrep_yrb           ! Irreducible representation of L(1) w.r.t. B
c      integer irrep_yrc           ! Irreducible representation of L(1) w.r.t. C
c      integer irrep_yrd           ! Irreducible representation of L(1) w.r.t. D
c
c      integer irrep_qrab          ! For quadratic response whenever it gets done
c      integer irrep_qrac          ! QR=T(2)
c      integer irrep_qrad          ! Each of the unique off-diagonal components of
c      integer irrep_qrbc          ! (A,B,C,D) (x) (A,B,C,D) each has a symmetry handle, which is why
c      integer irrep_qrbd          ! handle, which is why there are six of them.
c      integer irrep_qrcd          !
c
c      integer irrep_z             ! Irreducible representation of Z vector (Z=Xi) (for EOM properties)
c      integer irrep_za            ! Irreducible representation of Z(1) vector w.r.t. A 
c      integer irrep_zb            ! Irreducible representation of Z(1) vector w.r.t. B
c      integer irrep_zc            ! Irreducible representation of Z(1) vector w.r.t. C
c      integer irrep_zd            ! Irreducible representation of Z(1) vector w.r.t. D
c
      logical restricted          ! As in RHF
      logical intorb              ! When using spatial indexing of the 2-electron integrals
c
      logical read_int,write_int
      logical read_ta,write_ta
      logical read_xa,write_xa
      logical read_in3,write_in3
      integer  nproc_read_tensor,nproc_write_tensor

      common /tceinteger/
     1  noa,nob,nva,nvb,noab,nvab,!l_alpha,k_alpha,
     2  l_spin,k_spin,l_sym,k_sym,l_range,k_range,!l_offset,k_offset,
     4  irrep_x,irrep_y,irrep_d,irrep_o,irrep_tr,irrep_yr,
     5  irrep_a,irrep_b,irrep_c,
     6  irrep_oa,irrep_ob,irrep_oc,irrep_od,
     7  irrep_tra,irrep_trb,irrep_trc,irrep_trd,
     8  nproc_read_tensor,nproc_write_tensor,idiv2e
c     8  irrep_yra,irrep_yrb,irrep_yrc,irrep_yrd
c     9  irrep_qrab,irrep_qrac,irrep_qrad,
c     1  irrep_qrbc,irrep_qrbd,irrep_qrcd,
c     2  irrep_z,irrep_za,irrep_zb,irrep_zc,irrep_zd

      common /tcelogical/
     1  restricted,intorb,read_int,write_int,read_ta,write_ta,
     2  read_xa,write_xa,read_in3,write_in3
# 9 "test.F" 2
      INTEGER :: POSTPROCESSMARKER2
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: p2b_1
      INTEGER :: h1b_1
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_c
      INTEGER :: k_c
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO p2b = noab + 1, noab + nvab
      DO h1b = 1, noab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + p2b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + p2b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_f) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      CALL TCE_RESTRICTED_2(p2b,h1b,p2b_1,h1b_1)
      dim_common = 1
      dima_sort = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      IF (dima > 0) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_1',0,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + (noab + nvab) * (p2b_1 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p2b - 1),int_mb(k_range + h1b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_1',2,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + p2b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_1',4,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_1',5,MA_ERR)
      END IF
      END IF
      END IF
      END IF
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
      END IF
c ----------------
      count = count + 1
      END DO
      END DO
c old way      next = NXTASK(-nprocs, 1)
c old way      call GA_SYNC()
      RETURN
      END SUBROUTINE 

