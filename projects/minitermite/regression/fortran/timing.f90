      SUBROUTINE icsd_t1_1(d_a,ctx,icounter,k_a_offset,d_c,k_c_offset)
      IMPLICIT NONE
      INTEGER :: POSTPROCESSMARKER1
      INTEGER :: ga_max_dim
      parameter(ga_max_dim = 7) 
      INTEGER :: ga_nnodes, ga_nodeid, ga_read_inc
      INTEGER :: ga_pgroup_nnodes, ga_pgroup_nodeid
      INTEGER :: nga_pgroup_nnodes, nga_pgroup_nodeid
      INTEGER :: ga_spd_invert, ga_solve, ga_llt_solve
      INTEGER :: ga_inquire_memory, ga_memory_avail
      INTEGER :: nga_inquire_memory, nga_memory_avail
      LOGICAL :: ga_create, ga_destroy, ga_locate, ga_create_irreg
      LOGICAL :: nga_destroy
      LOGICAL :: ga_locate_region
      LOGICAL :: ga_compare_distr, ga_duplicate, ga_uses_ma
      LOGICAL :: nga_compare_distr, nga_duplicate, nga_uses_ma
      LOGICAL :: ga_memory_limited, nga_memory_limited
      LOGICAL :: ga_create_mutexes
      LOGICAL :: nga_create_mutexes
      LOGICAL :: ga_destroy_mutexes
      LOGICAL :: nga_destroy_mutexes
      LOGICAL :: ga_valid_handle, nga_valid_handle
      LOGICAL :: ga_verify_handle, nga_verify_handle
      LOGICAL :: ga_update2_ghosts
      LOGICAL :: ga_update3_ghosts
      LOGICAL :: ga_update4_ghosts
      LOGICAL :: ga_update5_ghosts
      LOGICAL :: ga_update6_ghosts
      LOGICAL :: ga_update7_ghosts
      LOGICAL :: ga_set_update4_info
      LOGICAL :: ga_set_update5_info
      LOGICAL :: nga_update_ghost_dir
      LOGICAL :: ga_has_ghosts, nga_has_ghosts
      INTEGER :: ga_create_handle
      INTEGER :: nga_create_handle
      LOGICAL :: ga_allocate
      INTEGER :: ga_pgroup_create, nga_pgroup_create
      INTEGER :: ga_pgroup_split, nga_pgroup_split
      INTEGER :: ga_pgroup_split_irreg, nga_pgroup_split_irreg
      DOUBLE PRECISION :: ga_ddot, ga_ddot_patch
      COMPLEX :: ga_zdot, ga_zdot_patch
      COMPLEX :: nga_zdot_patch
      COMPLEX :: ga_cdot, ga_cdot_patch
      COMPLEX :: nga_cdot_patch
      DOUBLE PRECISION :: nga_ddot_patch, ga_wtime
      INTEGER :: ga_idot
      INTEGER :: nga_idot_patch
      INTEGER :: ga_pgroup_get_default, ga_pgroup_get_mirror
      INTEGER :: nga_pgroup_get_default, nga_pgroup_get_mirror
      INTEGER :: ga_pgroup_get_world, nga_pgroup_get_world
      INTEGER :: ga_ndim, nga_ndim
      REAL :: ga_sdot, ga_sdot_patch, nga_sdot_patch
      INTEGER :: ga_is_mirrored, nga_is_mirrored
      INTEGER :: ga_nbtest, nga_nbtest
      INTEGER :: nga_read_inc
      INTEGER :: ga_cluster_nprocs, ga_cluster_nodeid, ga_cluster_nnodes
      INTEGER :: ga_cluster_procid, ga_cluster_proc_nodeid
      INTEGER :: nga_locate_num_blocks
      INTEGER :: ga_total_blocks, nga_total_blocks
      LOGICAL :: ga_uses_proc_grid, nga_uses_proc_grid
      LOGICAL :: nga_create, nga_locate, nga_create_irreg
      LOGICAL :: nga_locate_region
      LOGICAL :: nga_create_ghosts_irreg, nga_create_ghosts
      LOGICAL :: nga_create_config, nga_create_irreg_config
      LOGICAL :: nga_create_ghosts_irreg_config, nga_create_ghosts_config
      LOGICAL :: ga_get_debug, nga_get_debug
      INTEGER :: ga_get_dimension, nga_get_dimension
      INTEGER :: ga_get_pgroup, nga_get_pgroup
      INTEGER :: ga_get_pgroup_size, nga_get_pgroup_size
      LOGICAL :: ga_pgroup_destroy, nga_pgroup_destroy
      INTEGER :: ga_pgroup_absolute_id, nga_pgroup_absolute_id
      INTEGER :: nga_register_type, nga_deregister_type
      LOGICAL :: nga_check_notify
      external :: ga_create, ga_destroy, ga_ddot, ga_locate
      external :: nga_destroy
      external :: ga_locate_region
      external :: ga_nnodes, ga_nodeid, ga_read_inc, ga_create_irreg
      external :: ga_pgroup_nnodes, ga_pgroup_nodeid
      external :: nga_pgroup_nnodes, nga_pgroup_nodeid
      external :: ga_ddot_patch, ga_compare_distr, ga_duplicate
      external :: nga_compare_distr, nga_duplicate
      external :: ga_inquire_memory, ga_uses_ma, ga_memory_limited
      external :: nga_inquire_memory, nga_uses_ma, nga_memory_limited
      external :: ga_memory_avail
      external :: ga_zdot, ga_zdot_patch
      external :: ga_cdot, ga_cdot_patch
      external :: ga_create_mutexes
      external :: nga_create_mutexes
      external :: ga_destroy_mutexes
      external :: nga_destroy_mutexes
      external :: ga_valid_handle, nga_valid_handle
      external :: ga_verify_handle, nga_verify_handle
      external :: ga_update2_ghosts
      external :: ga_update3_ghosts
      external :: ga_update4_ghosts
      external :: ga_update5_ghosts
      external :: ga_update6_ghosts
      external :: ga_update7_ghosts
      external :: ga_set_update4_info
      external :: ga_set_update5_info
      external :: nga_update_ghost_dir
      external :: ga_create_handle
      external :: nga_create_handle
      external :: ga_allocate
      external :: ga_pgroup_create, nga_pgroup_create
      external :: ga_pgroup_split, nga_pgroup_split
      external :: ga_pgroup_split_irreg, nga_pgroup_split_irreg
      external :: ga_has_ghosts, nga_has_ghosts
      external :: ga_pgroup_get_default, ga_pgroup_get_mirror
      external :: nga_pgroup_get_default, nga_pgroup_get_mirror
      external :: ga_pgroup_get_world, nga_pgroup_get_world
      external :: ga_ndim, nga_ndim
      external :: ga_spd_invert, ga_solve, ga_llt_solve
      external :: nga_read_inc, nga_create, nga_locate, nga_create_irreg
      external :: nga_locate_region
      external :: nga_create_ghosts_irreg, nga_create_ghosts
      external :: nga_create_config, nga_create_irreg_config
      external :: nga_create_ghosts_irreg_config, nga_create_ghosts_config
      external :: nga_ddot_patch, nga_zdot_patch, nga_cdot_patch
      external :: nga_idot_patch, ga_idot
      external :: ga_sdot, ga_sdot_patch, nga_sdot_patch
      external :: ga_cluster_nprocs, ga_cluster_nodeid, ga_cluster_nnodes
      external :: ga_cluster_procid, ga_cluster_proc_nodeid
      external :: ga_is_mirrored
      external :: nga_locate_num_blocks
      external :: ga_total_blocks
      external :: ga_uses_proc_grid, nga_uses_proc_grid
      external :: ga_get_debug, nga_get_debug
      external :: ga_get_pgroup, nga_get_pgroup
      external :: ga_get_pgroup_size, nga_get_pgroup_size
      external :: ga_pgroup_destroy, nga_pgroup_destroy
      external :: ga_wtime
      external :: ga_nbtest, nga_nbtest
      external :: ga_pgroup_absolute_id, nga_pgroup_absolute_id
      external :: nga_register_type, nga_deregister_type
      external :: nga_get_field, nga_nbget_field
      external :: nga_put_field, nga_nbput_field
      external :: nga_check_notify
      INTEGER :: MT_BYTE
      INTEGER :: MT_INT
      INTEGER :: MT_LOG
      INTEGER :: MT_REAL
      INTEGER :: MT_DBL
      INTEGER :: MT_SCPL
      INTEGER :: MT_DCPL
      INTEGER :: MT_F_FIRST
      INTEGER :: MT_F_LAST
      parameter(MT_BYTE = 1000 + 9) 
      parameter(MT_INT = 1000 + 10) 
      parameter(MT_LOG = 1000 + 11) 
      parameter(MT_REAL = 1000 + 12) 
      parameter(MT_DBL = 1000 + 13) 
      parameter(MT_SCPL = 1000 + 14) 
      parameter(MT_DCPL = 1000 + 15) 
      parameter(MT_F_FIRST = MT_BYTE) 
      parameter(MT_F_LAST = MT_DCPL) 
      LOGICAL :: MA_alloc_get
      LOGICAL :: MA_allocate_heap
      LOGICAL :: MA_chop_stack
      LOGICAL :: MA_free_heap
      LOGICAL :: MA_free_heap_piece
      LOGICAL :: MA_get_index
      LOGICAL :: MA_get_next_memhandle
      LOGICAL :: MA_get_numalign
      LOGICAL :: MA_init
      LOGICAL :: MA_initialized
      LOGICAL :: MA_init_memhandle_iterator
      INTEGER :: MA_inquire_avail
      INTEGER :: MA_inquire_heap
      INTEGER :: MA_inquire_heap_check_stack
      INTEGER :: MA_inquire_heap_no_partition
      INTEGER :: MA_inquire_stack
      INTEGER :: MA_inquire_stack_check_heap
      INTEGER :: MA_inquire_stack_no_partition
      LOGICAL :: MA_pop_stack
      LOGICAL :: MA_push_get
      LOGICAL :: MA_push_stack
      LOGICAL :: MA_set_auto_verify
      LOGICAL :: MA_set_error_print
      LOGICAL :: MA_set_hard_fail
      LOGICAL :: MA_set_numalign
      INTEGER :: MA_sizeof
      INTEGER :: MA_sizeof_overhead
      LOGICAL :: MA_verify_allocator_stuff
      external :: MA_alloc_get
      external :: MA_allocate_heap
      external :: MA_chop_stack
      external :: MA_free_heap
      external :: MA_free_heap_piece
      external :: MA_get_index
      external :: MA_get_next_memhandle
      external :: MA_get_numalign
      external :: MA_init
      external :: MA_initialized
      external :: MA_init_memhandle_iterator
      external :: MA_inquire_avail
      external :: MA_inquire_heap
      external :: MA_inquire_heap_check_stack
      external :: MA_inquire_heap_no_partition
      external :: MA_inquire_stack
      external :: MA_inquire_stack_check_heap
      external :: MA_inquire_stack_no_partition
      external :: MA_pop_stack
      external :: MA_print_stats
      external :: MA_push_get
      external :: MA_push_stack
      external :: MA_set_auto_verify
      external :: MA_set_error_print
      external :: MA_set_hard_fail
      external :: MA_set_numalign
      external :: MA_sizeof
      external :: MA_sizeof_overhead
      external :: MA_summarize_allocated_blocks
      external :: MA_trace
      external :: MA_verify_allocator_stuff
      CHARACTER(len=1), DIMENSION(2) :: byte_mb
      INTEGER, DIMENSION(2) :: int_mb
      LOGICAL, DIMENSION(2) :: log_mb
      REAL, DIMENSION(2) :: real_mb
      DOUBLE PRECISION, DIMENSION(2) :: dbl_mb
      COMPLEX, DIMENSION(2) :: scpl_mb
      COMPLEX, DIMENSION(2) :: dcpl_mb
      LOGICAL :: sym_shell, sym_shell_pair, sym_atom, sym_atom_pair
      LOGICAL :: sym_char_table, sym_abelian_group
      LOGICAL :: sym_atom_quartet
      INTEGER :: sym_center_map, sym_number_ops
      external :: sym_shell, sym_atom
      external :: sym_center_map, sym_number_ops
      external :: sym_shell_pair, sym_atom_pair
      external :: sym_atom_quartet, sym_char_table
      external :: sym_abelian_group
      INTEGER :: UERR, UNKNOWN_ERR, MEM_ERR, RTDB_ERR, INPUT_ERR, CAPMIS_ERR
      INTEGER :: BASIS_ERR, GEOM_ERR, GA_ERR, MA_ERR, INT_ERR, DISK_ERR
      INTEGER :: CALC_ERR, FMM_ERR, STACK_ERR, HEAP_ERR
      parameter(UERR = 0,UNKNOWN_ERR = 0,MEM_ERR = 10,RTDB_ERR = 20,INPUT_ERR = 30) 
      parameter(CAPMIS_ERR = 40,BASIS_ERR = 50,GEOM_ERR = 60,GA_ERR = 70) 
      parameter(MA_ERR = 80,INT_ERR = 90,DISK_ERR = 100,CALC_ERR = 110) 
      parameter(FMM_ERR = 120,STACK_ERR = 11,HEAP_ERR = 12) 
      INTEGER :: l_spin, k_spin
      INTEGER :: l_sym, k_sym
      INTEGER :: l_range, k_range
      INTEGER :: noa, nob, nva, nvb
      INTEGER :: noab, nvab
      INTEGER :: irrep_e
      parameter(irrep_e = 0) 
      INTEGER :: irrep_e2
      parameter(irrep_e2 = 0) 
      INTEGER :: irrep_f
      parameter(irrep_f = 0) 
      INTEGER :: irrep_v
      parameter(irrep_v = 0) 
      INTEGER :: irrep_t
      parameter(irrep_t = 0) 
      INTEGER :: irrep_t1
      parameter(irrep_t1 = 0) 
      INTEGER :: irrep_t2
      parameter(irrep_t2 = 0) 
      INTEGER :: irrep_t3
      parameter(irrep_t3 = 0) 
      INTEGER :: irrep_x
      INTEGER :: irrep_y
      INTEGER :: irrep_d
      INTEGER :: irrep_o
      INTEGER :: irrep_a
      INTEGER :: irrep_b
      INTEGER :: irrep_c
      INTEGER :: irrep_tr
      INTEGER :: irrep_yr
      INTEGER :: irrep_oa
      INTEGER :: irrep_ob
      INTEGER :: irrep_oc
      INTEGER :: irrep_od
      INTEGER :: irrep_tra
      INTEGER :: irrep_trb
      INTEGER :: irrep_trc
      INTEGER :: irrep_trd
      INTEGER :: idiv2e
      LOGICAL :: restricted
      LOGICAL :: intorb
      LOGICAL :: read_int, write_int
      LOGICAL :: read_ta, write_ta
      LOGICAL :: read_xa, write_xa
      LOGICAL :: read_in3, write_in3
      INTEGER :: nproc_read_tensor, nproc_write_tensor
      COMMON / tceinteger / noa,nob,nva,nvb,noab,nvab,l_spin,k_spin,l_sym,k_sym,l_range,k_range,irrep_x,irrep_y,irrep_d,irrep_o,irrep_tr,irrep_yr,irrep_a,irrep_b,irrep_c,irrep_oa,irrep_ob,irrep_oc,irrep_od,irrep_tra,irrep_trb,irrep_trc,irrep_trd,nproc_read_tensor,nproc_write_tensor,idiv2e
      COMMON / tcelogical / restricted,intorb,read_int,write_int,read_ta,write_ta,read_xa,write_xa,read_in3,write_in3
      INTEGER :: POSTPROCESSMARKER2
      INTEGER :: d_a, d_c
      INTEGER :: k_a_offset, k_c_offset
      INTEGER :: NXTASK, next, nprocs, count,ctx,icounter
      INTEGER :: p2b, h1b, p2b_1, h1b_1
      INTEGER :: dim_common, dima_sort, dima, dimc
      INTEGER :: k_a, l_a
      external :: NXTASK
      nprocs = ga_nnodes()
      count = 0
      next = NXTASK(nprocs,1)
      DO p2b = noab + 1, noab + nvab
      DO h1b = 1, noab
! %CCSD version=timing
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
      IF (.NOT.MA_push_get(MT_DBL,dima,'a',l_a,k_a)) CALL ERRQUIT('icsd_t1_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + (noab + nvab) * (p2b_1 - 1)))
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_a),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_1',5,MA_ERR)
      END IF
      END IF
      END IF
      END IF
      next = NXTASK(nprocs,1)
      END IF
      count = count + 1
      END DO
      END DO
      next = NXTASK(-nprocs,1)
      CALL GA_SYNC()
      RETURN
      END SUBROUTINE 


