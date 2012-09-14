# 1 "/home/ajay/Desktop/report/dim-telyrb.F90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/home/ajay/Desktop/report/dim-telyrb.F90"
      SUBROUTINE icsd_t1_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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

      SUBROUTINE icsd_t1_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: h7b
      INTEGER :: p2b_1
      INTEGER :: h7b_1
      INTEGER :: h7b_2
      INTEGER :: h1b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
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
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_t,irrep_f)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO h7b = 1, noab
      IF (int_mb(k_spin + p2b - 1) .EQ. int_mb(k_spin + h7b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h7b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p2b,h7b,p2b_1,h7b_1)
      CALL TCE_RESTRICTED_2(h7b,h1b,h7b_2,h1b_2)
      dim_common = int_mb(k_range + h7b - 1)
      dima_sort = int_mb(k_range + p2b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h1b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h7b_1 - 1 + noab * (p2b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p2b - 1),int_mb(k_range + h7b - 1),1,2,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_2',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_2',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(h1b_2 - 1 + noab * (h7b_2 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h7b - 1),int_mb(k_range + h1b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_2',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_2',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + p2b - 1),2,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_2',11,MA_ERR)
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

      SUBROUTINE icsd_t1_2_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h7b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: h7b_1
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
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h7b = 1, noab
      DO h1b = 1, noab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_f) THEN
      dimc = int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      CALL TCE_RESTRICTED_2(h7b,h1b,h7b_1,h1b_1)
      dim_common = 1
      dima_sort = int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      IF (dima > 0) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2_1',0,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + (noab + nvab) * (h7b_1 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + h7b - 1),int_mb(k_range + h1b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2_1',2,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + h7b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (h7b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2_1',4,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2_1',5,MA_ERR)
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

      SUBROUTINE OFFSET_icsd_t1_2_1(l_a_offset,k_a_offset,size)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: l_a_offset
      INTEGER :: k_a_offset
      INTEGER :: size
      INTEGER :: length
      INTEGER :: addr
      INTEGER :: h7b
      INTEGER :: h1b
      length = 0
      DO h7b = 1, noab
      DO h1b = 1, noab
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      length = length + 1
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_INT,2 * length + 1,'noname',l_a_offset,k_a_offset)) CALL ERRQUIT('icsd_t1_2_1',0,MA_ERR)
      int_mb(k_a_offset) = length
      addr = 0
      size = 0
      DO h7b = 1, noab
      DO h1b = 1, noab
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      addr = addr + 1
      int_mb(k_a_offset + addr) = h1b - 1 + noab * (h7b - 1)
      int_mb(k_a_offset + length + addr) = size
      size = size + int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      END IF
      END IF
      END IF
      END DO
      END DO
      RETURN
      END SUBROUTINE 

      SUBROUTINE icsd_t1_2_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h7b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p3b
      INTEGER :: p3b_1
      INTEGER :: h1b_1
      INTEGER :: h7b_2
      INTEGER :: p3b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h7b = 1, noab
      DO h1b = 1, noab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_f,irrep_t)) THEN
      dimc = int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_2_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + p3b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + p3b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p3b,h1b,p3b_1,h1b_1)
      CALL TCE_RESTRICTED_2(h7b,p3b,h7b_2,p3b_2)
      dim_common = int_mb(k_range + p3b - 1)
      dima_sort = int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h7b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2_2',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2_2',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (p3b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + h1b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2_2',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_2_2',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_2_2',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - noab - 1 + nvab * (h7b_2 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h7b - 1),int_mb(k_range + p3b - 1),1,2,1.0d0)
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_2_2',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_2_2',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2_2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h7b - 1),int_mb(k_range + h1b - 1),1,2,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (h7b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2_2',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_2_2',11,MA_ERR)
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

      SUBROUTINE icsd_t1_2_2_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h7b
      INTEGER :: p3b
      INTEGER :: dimc
      INTEGER :: h7b_1
      INTEGER :: p3b_1
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h7b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + p3b - 1)) .EQ. irrep_f) THEN
      dimc = int_mb(k_range + h7b - 1) * int_mb(k_range + p3b - 1)
      CALL TCE_RESTRICTED_2(h7b,p3b,h7b_1,p3b_1)
      dim_common = 1
      dima_sort = int_mb(k_range + h7b - 1) * int_mb(k_range + p3b - 1)
      dima = dim_common * dima_sort
      IF (dima > 0) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2_2_1',0,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2_2_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p3b_1 - 1 + (noab + nvab) * (h7b_1 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + h7b - 1),int_mb(k_range + p3b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2_2_1',2,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2_2_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range + p3b - 1),int_mb(k_range + h7b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p3b - noab - 1 + nvab * (h7b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2_2_1',4,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2_2_1',5,MA_ERR)
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

      SUBROUTINE OFFSET_icsd_t1_2_2_1(l_a_offset,k_a_offset,size)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: l_a_offset
      INTEGER :: k_a_offset
      INTEGER :: size
      INTEGER :: length
      INTEGER :: addr
      INTEGER :: h7b
      INTEGER :: p3b
      length = 0
      DO h7b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + p3b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      length = length + 1
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_INT,2 * length + 1,'noname',l_a_offset,k_a_offset)) CALL ERRQUIT('icsd_t1_2_2_1',0,MA_ERR)
      int_mb(k_a_offset) = length
      addr = 0
      size = 0
      DO h7b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + p3b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      addr = addr + 1
      int_mb(k_a_offset + addr) = p3b - noab - 1 + nvab * (h7b - 1)
      int_mb(k_a_offset + length + addr) = size
      size = size + int_mb(k_range + h7b - 1) * int_mb(k_range + p3b - 1)
      END IF
      END IF
      END IF
      END DO
      END DO
      RETURN
      END SUBROUTINE 

      SUBROUTINE icsd_t1_2_2_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h7b
      INTEGER :: p3b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p5b
      INTEGER :: h6b
      INTEGER :: p5b_1
      INTEGER :: h6b_1
      INTEGER :: h7b_2
      INTEGER :: h6b_2
      INTEGER :: p3b_2
      INTEGER :: p5b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h7b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + p3b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + h7b - 1) * int_mb(k_range + p3b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_2_2_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p5b = noab + 1, noab + nvab
      DO h6b = 1, noab
      IF (int_mb(k_spin + p5b - 1) .EQ. int_mb(k_spin + h6b - 1)) THEN
      IF (ieor(int_mb(k_sym + p5b - 1),int_mb(k_sym + h6b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p5b,h6b,p5b_1,h6b_1)
      CALL TCE_RESTRICTED_4(h7b,h6b,p3b,p5b,h7b_2,h6b_2,p3b_2,p5b_2)
      dim_common = int_mb(k_range + p5b - 1) * int_mb(k_range + h6b - 1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h7b - 1) * int_mb(k_range + p3b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2_2_2',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2_2_2',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h6b_1 - 1 + noab * (p5b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p5b - 1),int_mb(k_range + h6b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2_2_2',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_2_2_2',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_2_2_2',5,MA_ERR)
      IF ((h6b <= h7b) .AND. (p5b < p3b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))),p3b_2,p5b_2,h7b_2,h6b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h6b - 1),int_mb(k_range + h7b - 1),int_mb(k_range + p5b - 1),int_mb(k_range + p3b - 1),4,2,1,3,-1.0d0)
      END IF
      IF ((h6b <= h7b) .AND. (p3b <= p5b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))),p5b_2,p3b_2,h7b_2,h6b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h6b - 1),int_mb(k_range + h7b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p5b - 1),3,2,1,4,1.0d0)
      END IF
      IF ((h7b < h6b) .AND. (p5b < p3b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))),p3b_2,p5b_2,h6b_2,h7b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h7b - 1),int_mb(k_range + h6b - 1),int_mb(k_range + p5b - 1),int_mb(k_range + p3b - 1),4,1,2,3,1.0d0)
      END IF
      IF ((h7b < h6b) .AND. (p3b <= p5b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))),p5b_2,p3b_2,h6b_2,h7b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h7b - 1),int_mb(k_range + h6b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p5b - 1),3,1,2,4,-1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_2_2_2',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_2_2_2',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2_2_2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2_2_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + p3b - 1),int_mb(k_range + h7b - 1),2,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p3b - noab - 1 + nvab * (h7b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2_2_2',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_2_2_2',11,MA_ERR)
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

      SUBROUTINE icsd_t1_2_3(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h7b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p4b
      INTEGER :: h5b
      INTEGER :: p4b_1
      INTEGER :: h5b_1
      INTEGER :: h7b_2
      INTEGER :: h5b_2
      INTEGER :: h1b_2
      INTEGER :: p4b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h7b = 1, noab
      DO h1b = 1, noab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_2_3',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p4b = noab + 1, noab + nvab
      DO h5b = 1, noab
      IF (int_mb(k_spin + p4b - 1) .EQ. int_mb(k_spin + h5b - 1)) THEN
      IF (ieor(int_mb(k_sym + p4b - 1),int_mb(k_sym + h5b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p4b,h5b,p4b_1,h5b_1)
      CALL TCE_RESTRICTED_4(h7b,h5b,h1b,p4b,h7b_2,h5b_2,h1b_2,p4b_2)
      dim_common = int_mb(k_range + p4b - 1) * int_mb(k_range + h5b - 1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2_3',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2_3',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1 - 1 + noab * (p4b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p4b - 1),int_mb(k_range + h5b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2_3',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_2_3',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_2_3',5,MA_ERR)
      IF ((h5b <= h7b) .AND. (h1b <= p4b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (h1b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (h1b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))),p4b_2,h1b_2,h7b_2,h5b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h5b - 1),int_mb(k_range + h7b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + p4b - 1),3,2,1,4,1.0d0)
      END IF
      IF ((h7b < h5b) .AND. (h1b <= p4b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (h1b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (h1b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))),p4b_2,h1b_2,h5b_2,h7b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h7b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + p4b - 1),3,1,2,4,-1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_2_3',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_2_3',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2_3',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2_3',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + h7b - 1),2,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (h7b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2_3',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_2_3',11,MA_ERR)
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

      SUBROUTINE icsd_t1_2_4(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h7b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p3b
      INTEGER :: p4b
      INTEGER :: h5b
      INTEGER :: p3b_1
      INTEGER :: p4b_1
      INTEGER :: h1b_1
      INTEGER :: h5b_1
      INTEGER :: h7b_2
      INTEGER :: h5b_2
      INTEGER :: p3b_2
      INTEGER :: p4b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER, DIMENSION(2) :: nsuperp
      INTEGER :: isuperp
      INTEGER :: l_c
      INTEGER :: k_c
      DOUBLE PRECISION :: FACTORIAL
c old way      EXTERNAL NXTASK
      external :: FACTORIAL
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h7b = 1, noab
      DO h1b = 1, noab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h7b - 1) + int_mb(k_spin + h1b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h7b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + h7b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + h7b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_2_4',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab + 1, noab + nvab
      DO p4b = p3b, noab + nvab
      DO h5b = 1, noab
      IF (int_mb(k_spin + p3b - 1) + int_mb(k_spin + p4b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + h5b - 1)) THEN
      IF (ieor(int_mb(k_sym + p3b - 1),ieor(int_mb(k_sym + p4b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + h5b - 1)))) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_4(p3b,p4b,h1b,h5b,p3b_1,p4b_1,h1b_1,h5b_1)
      CALL TCE_RESTRICTED_4(h7b,h5b,p3b,p4b,h7b_2,h5b_2,p3b_2,p4b_2)
      dim_common = int_mb(k_range + p3b - 1) * int_mb(k_range + p4b - 1) * int_mb(k_range + h5b - 1)
      dima_sort = int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h7b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_2_4',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_2_4',2,MA_ERR)
      IF ((h5b < h1b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (h5b_1 - 1 + noab * (p4b_1 - noab - 1 + nvab * (p3b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h1b - 1),4,3,2,1,-1.0d0)
      END IF
      IF ((h1b <= h5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1 - 1 + noab * (h1b_1 - 1 + noab * (p4b_1 - noab - 1 + nvab * (p3b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + h5b - 1),3,4,2,1,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_2_4',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_2_4',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_2_4',5,MA_ERR)
      IF ((h5b <= h7b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h7b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))),p4b_2,p3b_2,h7b_2,h5b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h5b - 1),int_mb(k_range + h7b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),2,1,4,3,1.0d0)
      END IF
      IF ((h7b < h5b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h7b_2 - 1)))),p4b_2,p3b_2,h5b_2,h7b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h7b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),1,2,4,3,-1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_2_4',6,MA_ERR)
      nsuperp(1) = 1
      nsuperp(2) = 1
      isuperp = 1
      IF (p3b .EQ. p4b) THEN
      nsuperp(isuperp) = nsuperp(isuperp) + 1
      ELSE
      isuperp = isuperp + 1
      END IF
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,2.0d0 / FACTORIAL(nsuperp(1)) / FACTORIAL(nsuperp(2)),dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_2_4',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_2_4',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_2_4',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h7b - 1),int_mb(k_range + h1b - 1),1,2,-1.0d0 / 2.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (h7b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_2_4',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_2_4',11,MA_ERR)
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

      SUBROUTINE icsd_t1_3(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p3b
      INTEGER :: p3b_1
      INTEGER :: h1b_1
      INTEGER :: p2b_2
      INTEGER :: p3b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
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
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_t,irrep_f)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_3',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + p3b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + p3b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p3b,h1b,p3b_1,h1b_1)
      CALL TCE_RESTRICTED_2(p2b,p3b,p2b_2,p3b_2)
      dim_common = int_mb(k_range + p3b - 1)
      dima_sort = int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + p2b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_3',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_3',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (p3b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + h1b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_3',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_3',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_3',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - noab - 1 + nvab * (p2b_2 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + p2b - 1),int_mb(k_range + p3b - 1),1,2,1.0d0)
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_3',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_3',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_3',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_3',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + p2b - 1),int_mb(k_range + h1b - 1),1,2,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_3',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_3',11,MA_ERR)
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

      SUBROUTINE icsd_t1_3_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: p3b
      INTEGER :: dimc
      INTEGER :: p2b_1
      INTEGER :: p3b_1
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO p2b = noab + 1, noab + nvab
      DO p3b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + p2b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + p2b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + p3b - 1)) .EQ. irrep_f) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + p3b - 1)
      CALL TCE_RESTRICTED_2(p2b,p3b,p2b_1,p3b_1)
      dim_common = 1
      dima_sort = int_mb(k_range + p2b - 1) * int_mb(k_range + p3b - 1)
      dima = dim_common * dima_sort
      IF (dima > 0) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_3_1',0,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_3_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p3b_1 - 1 + (noab + nvab) * (p2b_1 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p2b - 1),int_mb(k_range + p3b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_3_1',2,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_3_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range + p3b - 1),int_mb(k_range + p2b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p3b - noab - 1 + nvab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_3_1',4,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_3_1',5,MA_ERR)
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

      SUBROUTINE OFFSET_icsd_t1_3_1(l_a_offset,k_a_offset,size)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: l_a_offset
      INTEGER :: k_a_offset
      INTEGER :: size
      INTEGER :: length
      INTEGER :: addr
      INTEGER :: p2b
      INTEGER :: p3b
      length = 0
      DO p2b = noab + 1, noab + nvab
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + p2b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + p3b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + p2b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      length = length + 1
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_INT,2 * length + 1,'noname',l_a_offset,k_a_offset)) CALL ERRQUIT('icsd_t1_3_1',0,MA_ERR)
      int_mb(k_a_offset) = length
      addr = 0
      size = 0
      DO p2b = noab + 1, noab + nvab
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + p2b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + p3b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + p2b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      addr = addr + 1
      int_mb(k_a_offset + addr) = p3b - noab - 1 + nvab * (p2b - noab - 1)
      int_mb(k_a_offset + length + addr) = size
      size = size + int_mb(k_range + p2b - 1) * int_mb(k_range + p3b - 1)
      END IF
      END IF
      END IF
      END DO
      END DO
      RETURN
      END SUBROUTINE 

      SUBROUTINE icsd_t1_3_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: p3b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p4b
      INTEGER :: h5b
      INTEGER :: p4b_1
      INTEGER :: h5b_1
      INTEGER :: p2b_2
      INTEGER :: h5b_2
      INTEGER :: p3b_2
      INTEGER :: p4b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO p2b = noab + 1, noab + nvab
      DO p3b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + p2b - 1) + int_mb(k_spin + p3b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + p2b - 1) .EQ. int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + p3b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + p3b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_3_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p4b = noab + 1, noab + nvab
      DO h5b = 1, noab
      IF (int_mb(k_spin + p4b - 1) .EQ. int_mb(k_spin + h5b - 1)) THEN
      IF (ieor(int_mb(k_sym + p4b - 1),int_mb(k_sym + h5b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p4b,h5b,p4b_1,h5b_1)
      CALL TCE_RESTRICTED_4(p2b,h5b,p3b,p4b,p2b_2,h5b_2,p3b_2,p4b_2)
      dim_common = int_mb(k_range + p4b - 1) * int_mb(k_range + h5b - 1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + p2b - 1) * int_mb(k_range + p3b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_3_2',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_3_2',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1 - 1 + noab * (p4b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p4b - 1),int_mb(k_range + h5b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_3_2',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_3_2',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_3_2',5,MA_ERR)
      IF ((h5b <= p2b) .AND. (p4b < p3b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p4b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p4b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))),p3b_2,p4b_2,p2b_2,h5b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h5b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + p4b - 1),int_mb(k_range + p3b - 1),4,2,1,3,-1.0d0)
      END IF
      IF ((h5b <= p2b) .AND. (p3b <= p4b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))),p4b_2,p3b_2,p2b_2,h5b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h5b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),3,2,1,4,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_3_2',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_3_2',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_3_2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_3_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + p3b - 1),int_mb(k_range + p2b - 1),2,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p3b - noab - 1 + nvab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_3_2',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_3_2',11,MA_ERR)
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

      SUBROUTINE icsd_t1_4(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p3b
      INTEGER :: h4b
      INTEGER :: p3b_1
      INTEGER :: h4b_1
      INTEGER :: p2b_2
      INTEGER :: h4b_2
      INTEGER :: h1b_2
      INTEGER :: p3b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
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
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_4',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab + 1, noab + nvab
      DO h4b = 1, noab
      IF (int_mb(k_spin + p3b - 1) .EQ. int_mb(k_spin + h4b - 1)) THEN
      IF (ieor(int_mb(k_sym + p3b - 1),int_mb(k_sym + h4b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p3b,h4b,p3b_1,h4b_1)
      CALL TCE_RESTRICTED_4(p2b,h4b,h1b,p3b,p2b_2,h4b_2,h1b_2,p3b_2)
      dim_common = int_mb(k_range + p3b - 1) * int_mb(k_range + h4b - 1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_4',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_4',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h4b_1 - 1 + noab * (p3b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + h4b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_4',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_4',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_4',5,MA_ERR)
      IF ((h4b <= p2b) .AND. (h1b <= p3b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (h1b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h4b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (h1b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h4b_2 - 1)))),p3b_2,h1b_2,p2b_2,h4b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h4b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + p3b - 1),3,2,1,4,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_4',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_4',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_4',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_4',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + p2b - 1),2,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_4',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_4',11,MA_ERR)
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

      SUBROUTINE icsd_t1_5(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p7b
      INTEGER :: h8b
      INTEGER :: p2b_1
      INTEGER :: p7b_1
      INTEGER :: h1b_1
      INTEGER :: h8b_1
      INTEGER :: h8b_2
      INTEGER :: p7b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
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
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_t,irrep_f)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_5',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p7b = noab + 1, noab + nvab
      DO h8b = 1, noab
      IF (int_mb(k_spin + p2b - 1) + int_mb(k_spin + p7b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + h8b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),ieor(int_mb(k_sym + p7b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + h8b - 1)))) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_4(p2b,p7b,h1b,h8b,p2b_1,p7b_1,h1b_1,h8b_1)
      CALL TCE_RESTRICTED_2(h8b,p7b,h8b_2,p7b_2)
      dim_common = int_mb(k_range + p7b - 1) * int_mb(k_range + h8b - 1)
      dima_sort = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      dimb_sort = 1
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_5',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_5',2,MA_ERR)
      IF ((p7b < p2b) .AND. (h8b < h1b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (h8b_1 - 1 + noab * (p2b_1 - noab - 1 + nvab * (p7b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p7b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + h8b - 1),int_mb(k_range + h1b - 1),4,2,3,1,1.0d0)
      END IF
      IF ((p7b < p2b) .AND. (h1b <= h8b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h8b_1 - 1 + noab * (h1b_1 - 1 + noab * (p2b_1 - noab - 1 + nvab * (p7b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p7b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + h8b - 1),3,2,4,1,-1.0d0)
      END IF
      IF ((p2b <= p7b) .AND. (h8b < h1b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (h8b_1 - 1 + noab * (p7b_1 - noab - 1 + nvab * (p2b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p2b - 1),int_mb(k_range + p7b - 1),int_mb(k_range + h8b - 1),int_mb(k_range + h1b - 1),4,1,3,2,-1.0d0)
      END IF
      IF ((p2b <= p7b) .AND. (h1b <= h8b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h8b_1 - 1 + noab * (h1b_1 - 1 + noab * (p7b_1 - noab - 1 + nvab * (p2b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p2b - 1),int_mb(k_range + p7b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + h8b - 1),3,1,4,2,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_5',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_5',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_5',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p7b_2 - noab - 1 + nvab * (h8b_2 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h8b - 1),int_mb(k_range + p7b - 1),1,2,1.0d0)
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_5',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_5',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_5',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_5',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + p2b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_5',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_5',11,MA_ERR)
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

      SUBROUTINE icsd_t1_5_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h8b
      INTEGER :: p7b
      INTEGER :: dimc
      INTEGER :: h8b_1
      INTEGER :: p7b_1
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way       next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h8b = 1, noab
      DO p7b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h8b - 1) + int_mb(k_spin + p7b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h8b - 1) .EQ. int_mb(k_spin + p7b - 1)) THEN
      IF (ieor(int_mb(k_sym + h8b - 1),int_mb(k_sym + p7b - 1)) .EQ. irrep_f) THEN
      dimc = int_mb(k_range + h8b - 1) * int_mb(k_range + p7b - 1)
      CALL TCE_RESTRICTED_2(h8b,p7b,h8b_1,p7b_1)
      dim_common = 1
      dima_sort = int_mb(k_range + h8b - 1) * int_mb(k_range + p7b - 1)
      dima = dim_common * dima_sort
      IF (dima > 0) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_5_1',0,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_5_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p7b_1 - 1 + (noab + nvab) * (h8b_1 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + h8b - 1),int_mb(k_range + p7b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_5_1',2,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_5_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range + p7b - 1),int_mb(k_range + h8b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p7b - noab - 1 + nvab * (h8b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_5_1',4,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_5_1',5,MA_ERR)
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

      SUBROUTINE OFFSET_icsd_t1_5_1(l_a_offset,k_a_offset,size)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: l_a_offset
      INTEGER :: k_a_offset
      INTEGER :: size
      INTEGER :: length
      INTEGER :: addr
      INTEGER :: h8b
      INTEGER :: p7b
      length = 0
      DO h8b = 1, noab
      DO p7b = noab + 1, noab + nvab
      IF (int_mb(k_spin + h8b - 1) .EQ. int_mb(k_spin + p7b - 1)) THEN
      IF (ieor(int_mb(k_sym + h8b - 1),int_mb(k_sym + p7b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h8b - 1) + int_mb(k_spin + p7b - 1) .NE. 4)) THEN
      length = length + 1
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_INT,2 * length + 1,'noname',l_a_offset,k_a_offset)) CALL ERRQUIT('icsd_t1_5_1',0,MA_ERR)
      int_mb(k_a_offset) = length
      addr = 0
      size = 0
      DO h8b = 1, noab
      DO p7b = noab + 1, noab + nvab
      IF (int_mb(k_spin + h8b - 1) .EQ. int_mb(k_spin + p7b - 1)) THEN
      IF (ieor(int_mb(k_sym + h8b - 1),int_mb(k_sym + p7b - 1)) .EQ. irrep_f) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h8b - 1) + int_mb(k_spin + p7b - 1) .NE. 4)) THEN
      addr = addr + 1
      int_mb(k_a_offset + addr) = p7b - noab - 1 + nvab * (h8b - 1)
      int_mb(k_a_offset + length + addr) = size
      size = size + int_mb(k_range + h8b - 1) * int_mb(k_range + p7b - 1)
      END IF
      END IF
      END IF
      END DO
      END DO
      RETURN
      END SUBROUTINE 

      SUBROUTINE icsd_t1_5_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h8b
      INTEGER :: p7b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p5b
      INTEGER :: h6b
      INTEGER :: p5b_1
      INTEGER :: h6b_1
      INTEGER :: h8b_2
      INTEGER :: h6b_2
      INTEGER :: p7b_2
      INTEGER :: p5b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h8b = 1, noab
      DO p7b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h8b - 1) + int_mb(k_spin + p7b - 1) .NE. 4)) THEN
      IF (int_mb(k_spin + h8b - 1) .EQ. int_mb(k_spin + p7b - 1)) THEN
      IF (ieor(int_mb(k_sym + h8b - 1),int_mb(k_sym + p7b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + h8b - 1) * int_mb(k_range + p7b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_5_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p5b = noab + 1, noab + nvab
      DO h6b = 1, noab
      IF (int_mb(k_spin + p5b - 1) .EQ. int_mb(k_spin + h6b - 1)) THEN
      IF (ieor(int_mb(k_sym + p5b - 1),int_mb(k_sym + h6b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p5b,h6b,p5b_1,h6b_1)
      CALL TCE_RESTRICTED_4(h8b,h6b,p7b,p5b,h8b_2,h6b_2,p7b_2,p5b_2)
      dim_common = int_mb(k_range + p5b - 1) * int_mb(k_range + h6b - 1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h8b - 1) * int_mb(k_range + p7b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_5_2',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_5_2',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h6b_1 - 1 + noab * (p5b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p5b - 1),int_mb(k_range + h6b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_5_2',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_5_2',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_5_2',5,MA_ERR)
      IF ((h6b <= h8b) .AND. (p5b <= p7b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p7b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h8b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p7b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h8b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))),p7b_2,p5b_2,h8b_2,h6b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h6b - 1),int_mb(k_range + h8b - 1),int_mb(k_range + p5b - 1),int_mb(k_range + p7b - 1),4,2,1,3,1.0d0)
      END IF
      IF ((h6b <= h8b) .AND. (p7b < p5b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p7b_2 - 1 + (noab + nvab) * (h8b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p7b_2 - 1 + (noab + nvab) * (h8b_2 - 1 + (noab + nvab) * (h6b_2 - 1)))),p5b_2,p7b_2,h8b_2,h6b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h6b - 1),int_mb(k_range + h8b - 1),int_mb(k_range + p7b - 1),int_mb(k_range + p5b - 1),3,2,1,4,-1.0d0)
      END IF
      IF ((h8b < h6b) .AND. (p5b <= p7b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p7b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h8b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p7b_2 - 1 + (noab + nvab) * (p5b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h8b_2 - 1)))),p7b_2,p5b_2,h6b_2,h8b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h8b - 1),int_mb(k_range + h6b - 1),int_mb(k_range + p5b - 1),int_mb(k_range + p7b - 1),4,1,2,3,-1.0d0)
      END IF
      IF ((h8b < h6b) .AND. (p7b < p5b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p7b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h8b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2 - 1 + (noab + nvab) * (p7b_2 - 1 + (noab + nvab) * (h6b_2 - 1 + (noab + nvab) * (h8b_2 - 1)))),p5b_2,p7b_2,h6b_2,h8b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h8b - 1),int_mb(k_range + h6b - 1),int_mb(k_range + p7b - 1),int_mb(k_range + p5b - 1),3,1,2,4,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_5_2',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_5_2',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_5_2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_5_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + p7b - 1),int_mb(k_range + h8b - 1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p7b - noab - 1 + nvab * (h8b - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_5_2',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_5_2',11,MA_ERR)
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

      SUBROUTINE icsd_t1_6(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p3b
      INTEGER :: h4b
      INTEGER :: h5b
      INTEGER :: p2b_1
      INTEGER :: p3b_1
      INTEGER :: h4b_1
      INTEGER :: h5b_1
      INTEGER :: h4b_2
      INTEGER :: h5b_2
      INTEGER :: h1b_2
      INTEGER :: p3b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER, DIMENSION(2) :: nsubh
      INTEGER :: isubh
      INTEGER :: l_c
      INTEGER :: k_c
      DOUBLE PRECISION :: FACTORIAL
c old way      EXTERNAL NXTASK
      external :: FACTORIAL
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
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_6',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab + 1, noab + nvab
      DO h4b = 1, noab
      DO h5b = h4b, noab
      IF (int_mb(k_spin + p2b - 1) + int_mb(k_spin + p3b - 1) .EQ. int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1)) THEN
      IF (ieor(int_mb(k_sym + p2b - 1),ieor(int_mb(k_sym + p3b - 1),ieor(int_mb(k_sym + h4b - 1),int_mb(k_sym + h5b - 1)))) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_4(p2b,p3b,h4b,h5b,p2b_1,p3b_1,h4b_1,h5b_1)
      CALL TCE_RESTRICTED_4(h4b,h5b,h1b,p3b,h4b_2,h5b_2,h1b_2,p3b_2)
      dim_common = int_mb(k_range + p3b - 1) * int_mb(k_range + h4b - 1) * int_mb(k_range + h5b - 1)
      dima_sort = int_mb(k_range + p2b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h1b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_6',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_6',2,MA_ERR)
      IF ((p3b < p2b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1 - 1 + noab * (h4b_1 - 1 + noab * (p2b_1 - noab - 1 + nvab * (p3b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + h4b - 1),int_mb(k_range + h5b - 1),2,4,3,1,-1.0d0)
      END IF
      IF ((p2b <= p3b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1 - 1 + noab * (h4b_1 - 1 + noab * (p3b_1 - noab - 1 + nvab * (p2b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p2b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + h4b - 1),int_mb(k_range + h5b - 1),1,4,3,2,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_6',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_6',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_6',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - noab - 1 + nvab * (h1b_2 - 1 + noab * (h5b_2 - 1 + noab * (h4b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h4b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + p3b - 1),3,2,1,4,1.0d0)
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_6',6,MA_ERR)
      nsubh(1) = 1
      nsubh(2) = 1
      isubh = 1
      IF (h4b .EQ. h5b) THEN
      nsubh(isubh) = nsubh(isubh) + 1
      ELSE
      isubh = isubh + 1
      END IF
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,2.0d0 / FACTORIAL(nsubh(1)) / FACTORIAL(nsubh(2)),dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_6',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_6',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_6',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + h1b - 1),int_mb(k_range + p2b - 1),2,1,-1.0d0 / 2.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_6',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_6',11,MA_ERR)
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

      SUBROUTINE icsd_t1_6_1(d_a,k_a_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h4b
      INTEGER :: h5b
      INTEGER :: h1b
      INTEGER :: p3b
      INTEGER :: dimc
      INTEGER :: h4b_1
      INTEGER :: h5b_1
      INTEGER :: h1b_1
      INTEGER :: p3b_1
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h4b = 1, noab
      DO h5b = h4b, noab
      DO h1b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) + int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1) .NE. 8)) THEN
      IF (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h4b - 1),ieor(int_mb(k_sym + h5b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + p3b - 1)))) .EQ. irrep_v) THEN
      dimc = int_mb(k_range + h4b - 1) * int_mb(k_range + h5b - 1) * int_mb(k_range + h1b - 1) * int_mb(k_range + p3b - 1)
      CALL TCE_RESTRICTED_4(h4b,h5b,h1b,p3b,h4b_1,h5b_1,h1b_1,p3b_1)
      dim_common = 1
      dima_sort = int_mb(k_range + h4b - 1) * int_mb(k_range + h5b - 1) * int_mb(k_range + h1b - 1) * int_mb(k_range + p3b - 1)
      dima = dim_common * dima_sort
      IF (dima > 0) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_6_1',0,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_6_1',1,MA_ERR)
      IF ((h1b <= p3b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p3b_1 - 1 + (noab + nvab) * (h1b_1 - 1 + (noab + nvab) * (h5b_1 - 1 + (noab + nvab) * (h4b_1 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p3b_1 - 1 + (noab + nvab) * (h1b_1 - 1 + (noab + nvab) * (h5b_1 - 1 + (noab + nvab) * (h4b_1 - 1)))),p3b_1,h1b_1,h5b_1,h4b_1)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + h4b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + p3b - 1),4,3,2,1,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_6_1',2,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_6_1',3,MA_ERR)
      CALL TCE_SORT_4(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range + p3b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h4b - 1),4,3,2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p3b - noab - 1 + nvab * (h1b - 1 + noab * (h5b - 1 + noab * (h4b - 1)))))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_6_1',4,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_6_1',5,MA_ERR)
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
      END DO
      END DO
c old way      next = NXTASK(-nprocs, 1)
c old way      call GA_SYNC()
      RETURN
      END SUBROUTINE 

      SUBROUTINE OFFSET_icsd_t1_6_1(l_a_offset,k_a_offset,size)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: l_a_offset
      INTEGER :: k_a_offset
      INTEGER :: size
      INTEGER :: length
      INTEGER :: addr
      INTEGER :: h4b
      INTEGER :: h5b
      INTEGER :: h1b
      INTEGER :: p3b
      length = 0
      DO h4b = 1, noab
      DO h5b = h4b, noab
      DO h1b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h4b - 1),ieor(int_mb(k_sym + h5b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + p3b - 1)))) .EQ. irrep_v) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) + int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1) .NE. 8)) THEN
      length = length + 1
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_INT,2 * length + 1,'noname',l_a_offset,k_a_offset)) CALL ERRQUIT('icsd_t1_6_1',0,MA_ERR)
      int_mb(k_a_offset) = length
      addr = 0
      size = 0
      DO h4b = 1, noab
      DO h5b = h4b, noab
      DO h1b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h4b - 1),ieor(int_mb(k_sym + h5b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + p3b - 1)))) .EQ. irrep_v) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) + int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1) .NE. 8)) THEN
      addr = addr + 1
      int_mb(k_a_offset + addr) = p3b - noab - 1 + nvab * (h1b - 1 + noab * (h5b - 1 + noab * (h4b - 1)))
      int_mb(k_a_offset + length + addr) = size
      size = size + int_mb(k_range + h4b - 1) * int_mb(k_range + h5b - 1) * int_mb(k_range + h1b - 1) * int_mb(k_range + p3b - 1)
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      END DO
      RETURN
      END SUBROUTINE 

      SUBROUTINE icsd_t1_6_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: h4b
      INTEGER :: h5b
      INTEGER :: h1b
      INTEGER :: p3b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p6b
      INTEGER :: p6b_1
      INTEGER :: h1b_1
      INTEGER :: h4b_2
      INTEGER :: h5b_2
      INTEGER :: p3b_2
      INTEGER :: p6b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER :: l_c
      INTEGER :: k_c
c old way      EXTERNAL NXTASK
      nprocs = ga_nnodes()
      count = 0
c old way      next = NXTASK(nprocs, 1)
c --- new way ----
      CALL nxt_ctx_next(ctx,icounter,next)
c ----------------
      DO h4b = 1, noab
      DO h5b = h4b, noab
      DO h1b = 1, noab
      DO p3b = noab + 1, noab + nvab
      IF (next .EQ. count) THEN
      IF ((.NOT.restricted) .OR. (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) + int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1) .NE. 8)) THEN
      IF (int_mb(k_spin + h4b - 1) + int_mb(k_spin + h5b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + p3b - 1)) THEN
      IF (ieor(int_mb(k_sym + h4b - 1),ieor(int_mb(k_sym + h5b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + p3b - 1)))) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + h4b - 1) * int_mb(k_range + h5b - 1) * int_mb(k_range + h1b - 1) * int_mb(k_range + p3b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_6_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p6b = noab + 1, noab + nvab
      IF (int_mb(k_spin + p6b - 1) .EQ. int_mb(k_spin + h1b - 1)) THEN
      IF (ieor(int_mb(k_sym + p6b - 1),int_mb(k_sym + h1b - 1)) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_2(p6b,h1b,p6b_1,h1b_1)
      CALL TCE_RESTRICTED_4(h4b,h5b,p3b,p6b,h4b_2,h5b_2,p3b_2,p6b_2)
      dim_common = int_mb(k_range + p6b - 1)
      dima_sort = int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + h4b - 1) * int_mb(k_range + h5b - 1) * int_mb(k_range + p3b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_6_2',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_6_2',2,MA_ERR)
      CALL GET_HASH_BLOCK_MA(dbl_mb(d_a),dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (p6b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p6b - 1),int_mb(k_range + h1b - 1),2,1,1.0d0)
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_6_2',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_6_2',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_6_2',5,MA_ERR)
      IF ((p6b < p3b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p6b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h4b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2 - 1 + (noab + nvab) * (p6b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h4b_2 - 1)))),p3b_2,p6b_2,h5b_2,h4b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h4b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + p6b - 1),int_mb(k_range + p3b - 1),4,2,1,3,-1.0d0)
      END IF
      IF ((p3b <= p6b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p6b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h4b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p6b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (h5b_2 - 1 + (noab + nvab) * (h4b_2 - 1)))),p6b_2,p3b_2,h5b_2,h4b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h4b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p6b - 1),3,2,1,4,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_6_2',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_6_2',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_6_2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_6_2',9,MA_ERR)
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + p3b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h4b - 1),int_mb(k_range + h1b - 1),3,2,4,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p3b - noab - 1 + nvab * (h1b - 1 + noab * (h5b - 1 + noab * (h4b - 1)))))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_6_2',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_6_2',11,MA_ERR)
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
      END DO
      END DO
c old way      next = NXTASK(-nprocs, 1)
c old way      call GA_SYNC()
      RETURN
      END SUBROUTINE 

      SUBROUTINE icsd_t1_7(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offset,ctx,icounter)
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
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: d_a
      INTEGER :: k_a_offset
      INTEGER :: d_b
      INTEGER :: k_b_offset
      INTEGER :: d_c
      INTEGER :: k_c_offset
      INTEGER :: ctx, icounter
      external :: nxt_ctx_create, nxt_ctx_destroy, nxt_ctx_next
c -------------------------
      INTEGER :: next
      INTEGER :: nprocs
      INTEGER :: count
      INTEGER :: p2b
      INTEGER :: h1b
      INTEGER :: dimc
      INTEGER :: l_c_sort
      INTEGER :: k_c_sort
      INTEGER :: p3b
      INTEGER :: p4b
      INTEGER :: h5b
      INTEGER :: p3b_1
      INTEGER :: p4b_1
      INTEGER :: h1b_1
      INTEGER :: h5b_1
      INTEGER :: p2b_2
      INTEGER :: h5b_2
      INTEGER :: p3b_2
      INTEGER :: p4b_2
      INTEGER :: dim_common
      INTEGER :: dima_sort
      INTEGER :: dima
      INTEGER :: dimb_sort
      INTEGER :: dimb
      INTEGER :: l_a_sort
      INTEGER :: k_a_sort
      INTEGER :: l_a
      INTEGER :: k_a
      INTEGER :: l_b_sort
      INTEGER :: k_b_sort
      INTEGER :: l_b
      INTEGER :: k_b
      INTEGER, DIMENSION(2) :: nsuperp
      INTEGER :: isuperp
      INTEGER :: l_c
      INTEGER :: k_c
      DOUBLE PRECISION :: FACTORIAL
c old way      EXTERNAL NXTASK
      external :: FACTORIAL
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
      IF (ieor(int_mb(k_sym + p2b - 1),int_mb(k_sym + h1b - 1)) .EQ. ieor(irrep_v,irrep_t)) THEN
      dimc = int_mb(k_range + p2b - 1) * int_mb(k_range + h1b - 1)
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c_sort,k_c_sort)) CALL ERRQUIT('icsd_t1_7',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab + 1, noab + nvab
      DO p4b = p3b, noab + nvab
      DO h5b = 1, noab
      IF (int_mb(k_spin + p3b - 1) + int_mb(k_spin + p4b - 1) .EQ. int_mb(k_spin + h1b - 1) + int_mb(k_spin + h5b - 1)) THEN
      IF (ieor(int_mb(k_sym + p3b - 1),ieor(int_mb(k_sym + p4b - 1),ieor(int_mb(k_sym + h1b - 1),int_mb(k_sym + h5b - 1)))) .EQ. irrep_t) THEN
      CALL TCE_RESTRICTED_4(p3b,p4b,h1b,h5b,p3b_1,p4b_1,h1b_1,h5b_1)
      CALL TCE_RESTRICTED_4(p2b,h5b,p3b,p4b,p2b_2,h5b_2,p3b_2,p4b_2)
      dim_common = int_mb(k_range + p3b - 1) * int_mb(k_range + p4b - 1) * int_mb(k_range + h5b - 1)
      dima_sort = int_mb(k_range + h1b - 1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range + p2b - 1)
      dimb = dim_common * dimb_sort
      IF ((dima > 0) .AND. (dimb > 0)) THEN
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a_sort,k_a_sort)) CALL ERRQUIT('icsd_t1_7',1,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dima,'noname',l_a,k_a)) CALL ERRQUIT('icsd_t1_7',2,MA_ERR)
      IF ((h5b < h1b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1 - 1 + noab * (h5b_1 - 1 + noab * (p4b_1 - noab - 1 + nvab * (p3b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),int_mb(k_range + h5b - 1),int_mb(k_range + h1b - 1),4,3,2,1,-1.0d0)
      END IF
      IF ((h1b <= h5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1 - 1 + noab * (h1b_1 - 1 + noab * (p4b_1 - noab - 1 + nvab * (p3b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),int_mb(k_range + h1b - 1),int_mb(k_range + h5b - 1),3,4,2,1,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_a)) CALL ERRQUIT('icsd_t1_7',3,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b_sort,k_b_sort)) CALL ERRQUIT('icsd_t1_7',4,MA_ERR)
      IF (.NOT.MA_push_get(MT_DBL,dimb,'noname',l_b,k_b)) CALL ERRQUIT('icsd_t1_7',5,MA_ERR)
      IF ((h5b <= p2b)) THEN
      IF (.NOT.intorb) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))))
      ELSE
      CALL GET_HASH_BLOCK_I(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p4b_2 - 1 + (noab + nvab) * (p3b_2 - 1 + (noab + nvab) * (p2b_2 - 1 + (noab + nvab) * (h5b_2 - 1)))),p4b_2,p3b_2,p2b_2,h5b_2)
      END IF
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range + h5b - 1),int_mb(k_range + p2b - 1),int_mb(k_range + p3b - 1),int_mb(k_range + p4b - 1),2,1,4,3,1.0d0)
      END IF
      IF (.NOT.MA_pop_stack(l_b)) CALL ERRQUIT('icsd_t1_7',6,MA_ERR)
      nsuperp(1) = 1
      nsuperp(2) = 1
      isuperp = 1
      IF (p3b .EQ. p4b) THEN
      nsuperp(isuperp) = nsuperp(isuperp) + 1
      ELSE
      isuperp = isuperp + 1
      END IF
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,2.0d0 / FACTORIAL(nsuperp(1)) / FACTORIAL(nsuperp(2)),dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.NOT.MA_pop_stack(l_b_sort)) CALL ERRQUIT('icsd_t1_7',7,MA_ERR)
      IF (.NOT.MA_pop_stack(l_a_sort)) CALL ERRQUIT('icsd_t1_7',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      IF (.NOT.MA_push_get(MT_DBL,dimc,'noname',l_c,k_c)) CALL ERRQUIT('icsd_t1_7',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range + p2b - 1),int_mb(k_range + h1b - 1),1,2,-1.0d0 / 2.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b - 1 + noab * (p2b - noab - 1)))
      IF (.NOT.MA_pop_stack(l_c)) CALL ERRQUIT('icsd_t1_7',10,MA_ERR)
      IF (.NOT.MA_pop_stack(l_c_sort)) CALL ERRQUIT('icsd_t1_7',11,MA_ERR)
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

c
c
c
c
c
c
c
      SUBROUTINE nxt_ctx_create(num,ctx)
      IMPLICIT NONE
      INTEGER :: POSTPROCESSMARKER1
      INTEGER :: MT_BYTE
      INTEGER :: MT_INT
      INTEGER :: MT_LOG
      INTEGER :: MT_REAL
      INTEGER :: MT_DBL
      INTEGER :: MT_SCPL
      INTEGER :: MT_DCPL
      INTEGER :: MT_F_FIRST
      INTEGER :: MT_F_LAST
      parameter(MT_BYTE = (1000 + 9)) 
      parameter(MT_INT = (1000 + 10)) 
      parameter(MT_LOG = (1000 + 11)) 
      parameter(MT_REAL = (1000 + 12)) 
      parameter(MT_DBL = (1000 + 13)) 
      parameter(MT_SCPL = (1000 + 14)) 
      parameter(MT_DCPL = (1000 + 15)) 
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
      INTEGER :: POSTPROCESSMARKER2
      INTEGER :: num, ctx
      INTEGER, DIMENSION(num) :: init_vals
      INTEGER :: me, i
      LOGICAL :: status
      status = ga_create(MT_INT,num,1,'counter',0,0,ctx)
      me = ga_nodeid()
      IF (me .EQ. 0) THEN
      DO i = 1, num
      init_vals(i) = 0
      END DO
      CALL ga_put(ctx,1,num,1,1,init_vals,1)
      END IF
      CALL ga_sync()
      END SUBROUTINE 

      SUBROUTINE nxt_ctx_destroy(ctx)
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
      INTEGER :: POSTPROCESSMARKER2
      INTEGER :: ctx
      LOGICAL :: status
      status = ga_destroy(ctx)
      END SUBROUTINE 

      SUBROUTINE nxt_ctx_next(ctx,id,nval)
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
      INTEGER :: POSTPROCESSMARKER2
      INTEGER :: ctx, id, nval
      nval = ga_read_inc(ctx,id,1,1)
      END SUBROUTINE 

