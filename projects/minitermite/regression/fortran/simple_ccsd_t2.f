      SUBROUTINE ccsd_t2(d_f1,d_i0,d_t1,d_t2,d_v2,k_f1_offset,k_i0_offse
     &t,k_t1_offset,k_t2_offset,k_v2_offset)
      IMPLICIT NONE
	
c #include "global.fh"
c #include "mafdecls.fh"
c #include "util.fh"
c #include "errquit.fh"
c #include "tce.fh"
c #include "tce_main.fh"
c when local copies of  T1/X1 tensors are used,  d_t1 refers to k_t1_local (kk)
c local copies of the most important 2-dimensional intermediates
c ccsd_t2_4(...) and ccsd_t2_5(...) (kk)
      INTEGER d_i0
      INTEGER k_i0_offset
      INTEGER d_v2
      INTEGER k_v2_offset
      INTEGER d_t1
      INTEGER k_t1_offset
      INTEGER d_i1
      INTEGER k_i1_offset
      INTEGER d_t2
      INTEGER k_t2_offset
      INTEGER l_i1_offset
      INTEGER size_i1
      INTEGER d_i2
      INTEGER k_i2_offset
      INTEGER l_i2_offset
      INTEGER size_i2
c      INTEGER size_t2
      INTEGER d_i3
      INTEGER k_i3_offset
      INTEGER l_i3_offset
      INTEGER size_i3
      INTEGER d_f1
      INTEGER k_f1_offset
c - T1/X1 LOCALIZATION -------------------
      integer l_i1_local,k_i1_local
c ---------------------------------------
      CHARACTER*255 filename
      logical nodezero         ! True if node 0
      double precision cpu     ! CPU sec counter
      double precision wall    ! WALL sec counter
      
c -dummy extern decls to make it parsable by ROSE
      integer ga_nodeid
      EXTERNAL ga_nodeid
      logical MA_pop_stack
      EXTERNAL MA_pop_stack
      logical MA_push_get
      EXTERNAL MA_push_get
      integer    MT_DBL    
      integer    MA_ERR   
      integer    dbl_mb
      double precision util_wallsec
      EXTERNAL util_wallsec
      double precision util_cpusec
      EXTERNAL util_cpusec
      double precision cpusecs(100)

c - END dummy extern decls

      nodezero=(ga_nodeid().eq.0)
      CALL ccsd_t2_1(d_v2,k_v2_offset,d_i0,k_i0_offset)
      CALL OFFSET_ccsd_t2_2_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsd_t2_2_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsd_t2_2_1(d_v2,k_v2_offset,d_i1,k_i1_offset)
      CALL OFFSET_ccsd_t2_2_2_1(l_i2_offset,k_i2_offset,size_i2)
      CALL TCE_FILENAME('ccsd_t2_2_2_1_i2',filename)
      CALL CREATEFILE(filename,d_i2,size_i2)
      CALL ccsd_t2_2_2_1(d_v2,k_v2_offset,d_i2,k_i2_offset)
      CALL OFFSET_ccsd_t2_2_2_2_1(l_i3_offset,k_i3_offset,size_i3)
      CALL TCE_FILENAME('ccsd_t2_2_2_2_1_i3',filename)
      CALL CREATEFILE(filename,d_i3,size_i3)
      CALL ccsd_t2_2_2_2_1(d_v2,k_v2_offset,d_i3,k_i3_offset)
      CALL ccsd_t2_2_2_2_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                     d_i3,k_i3_offset)
      CALL RECONCILEFILE(d_i3,size_i3)
      CALL ccsd_t2_2_2_2(d_t1,k_t1_offset,d_i3,k_i3_offset,
     1                   d_i2,k_i2_offset)
      CALL DELETEFILE(d_i3)
      IF (.not.MA_POP_STACK(l_i3_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL ccsd_t2_2_2_3(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                   d_i2,k_i2_offset)
      CALL RECONCILEFILE(d_i2,size_i2)
      CALL ccsd_t2_2_2(d_t1,k_t1_offset,d_i2,k_i2_offset,
     1                 d_i1,k_i1_offset)
      CALL DELETEFILE(d_i2)
      IF (.not.MA_POP_STACK(l_i2_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL OFFSET_ccsd_t2_2_4_1(l_i2_offset,k_i2_offset,size_i2)
      CALL TCE_FILENAME('ccsd_t2_2_4_1_i2',filename)
      CALL CREATEFILE(filename,d_i2,size_i2)
      CALL ccsd_t2_2_4_1(d_f1,k_f1_offset,d_i2,k_i2_offset)
      CALL ccsd_t2_2_4_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                   d_i2,k_i2_offset)
      CALL RECONCILEFILE(d_i2,size_i2)
      CALL ccsd_t2_2_4(d_t2,k_t2_offset,d_i2,k_i2_offset,
     1                 d_i1,k_i1_offset)
      CALL DELETEFILE(d_i2)
      IF (.not.MA_POP_STACK(l_i2_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL OFFSET_ccsd_t2_2_5_1(l_i2_offset,k_i2_offset,size_i2)
      CALL TCE_FILENAME('ccsd_t2_2_5_1_i2',filename)
      CALL CREATEFILE(filename,d_i2,size_i2)
      CALL ccsd_t2_2_5_1(d_v2,k_v2_offset,d_i2,k_i2_offset)
      CALL ccsd_t2_2_5_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                   d_i2,k_i2_offset)
      CALL RECONCILEFILE(d_i2,size_i2)
      CALL ccsd_t2_2_5(d_t2,k_t2_offset,d_i2,k_i2_offset,
     1                 d_i1,k_i1_offset)
      CALL DELETEFILE(d_i2)
      IF (.not.MA_POP_STACK(l_i2_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL c2f_t2_t12(d_t1,k_t1_offset,d_t2,k_t2_offset)
      CALL ccsd_t2_2_6(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL c2d_t2_t12(d_t1,k_t1_offset,d_t2,k_t2_offset) 
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL ccsd_t2_2(d_t1,k_t1_offset,d_i1,k_i1_offset,d_i0,k_i0_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL lccsd_t2_3x(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                 d_i0,k_i0_offset)
      CALL OFFSET_ccsd_t2_4_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsd_t2_4_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsd_t2_4_1(d_f1,k_f1_offset,d_i1,k_i1_offset)
      CALL OFFSET_ccsd_t2_4_2_1(l_i2_offset,k_i2_offset,size_i2)
      CALL TCE_FILENAME('ccsd_t2_4_2_1_i2',filename)
      CALL CREATEFILE(filename,d_i2,size_i2)
      CALL ccsd_t2_4_2_1(d_f1,k_f1_offset,d_i2,k_i2_offset)
      CALL ccsd_t2_4_2_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                   d_i2,k_i2_offset)
      CALL RECONCILEFILE(d_i2,size_i2)
      CALL ccsd_t2_4_2(d_t1,k_t1_offset,d_i2,k_i2_offset,
     1                 d_i1,k_i1_offset)
      CALL DELETEFILE(d_i2)
      IF (.not.MA_POP_STACK(l_i2_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL ccsd_t2_4_3(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL ccsd_t2_4_4(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
c - T1/X1 LOCALIZATION ----------
        if (.not.MA_PUSH_GET(mt_dbl,size_i1,'i1_local',
     1      l_i1_local,k_i1_local))
     1      call errquit('i1_local',1,MA_ERR)
        call ma_zero(dbl_mb(k_i1_local),size_i1)
c    copy d_t1 ==> l_t1_local
cc        call ga_get(d_i1,1,size_i1,1,1,dbl_mb(k_i1_local),1)
         call get_block(d_i1,dbl_mb(k_i1_local),size_i1,0)
c -------------------------------
ccx      CALL ccsd_t2_4(d_t2,k_t2_offset,d_i1,k_i1_offset,d_i0,k_i0_offset)
      CALL ccsd_t2_4(d_t2,k_t2_offset,k_i1_local,k_i1_offset,
     &              d_i0,k_i0_offset)
c - T1/X1 LOCALIZATION --
         if(.not.MA_POP_STACK(l_i1_local))
     &      call errquit('l_i1_local',2,MA_ERR)
c -----------------------
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL OFFSET_ccsd_t2_5_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsd_t2_5_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsd_t2_5_1(d_f1,k_f1_offset,d_i1,k_i1_offset)
      CALL ccsd_t2_5_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL ccsd_t2_5_3(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
c - T1/X1 LOCALIZATION ----------
        if (.not.MA_PUSH_GET(mt_dbl,size_i1,'i1_local',
     1      l_i1_local,k_i1_local))
     1      call errquit('i1_local',1,MA_ERR)
        call ma_zero(dbl_mb(k_i1_local),size_i1)
c    copy d_t1 ==> l_t1_local
cc        call ga_get(d_i1,1,size_i1,1,1,dbl_mb(k_i1_local),1)
         call get_block(d_i1,dbl_mb(k_i1_local),size_i1,0) 
c -------------------------------
ccx      CALL ccsd_t2_5(d_t2,k_t2_offset,d_i1,k_i1_offset,d_i0,k_i0_offset)
      CALL ccsd_t2_5(d_t2,k_t2_offset,k_i1_local,k_i1_offset,
     &               d_i0,k_i0_offset)
c - T1/X1 LOCALIZATION --
         if(.not.MA_POP_STACK(l_i1_local))
     &      call errquit('l_i1_local',2,MA_ERR)
c -----------------------
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL OFFSET_ccsd_t2_6_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsd_t2_6_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsd_t2_6_1(d_v2,k_v2_offset,d_i1,k_i1_offset)
      CALL OFFSET_ccsd_t2_6_2_1(l_i2_offset,k_i2_offset,size_i2)
      CALL TCE_FILENAME('ccsd_t2_6_2_1_i2',filename)
      CALL CREATEFILE(filename,d_i2,size_i2)
      CALL ccsd_t2_6_2_1(d_v2,k_v2_offset,d_i2,k_i2_offset)
      CALL ccsd_t2_6_2_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                   d_i2,k_i2_offset)
      CALL RECONCILEFILE(d_i2,size_i2)
      CALL ccsd_t2_6_2(d_t1,k_t1_offset,d_i2,k_i2_offset,
     1                 d_i1,k_i1_offset)
      CALL DELETEFILE(d_i2)
      IF (.not.MA_POP_STACK(l_i2_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL ccsd_t2_6_3(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL ccsd_t2_6(d_t2,k_t2_offset,d_i1,k_i1_offset,d_i0,k_i0_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL OFFSET_ccsd_t2_7_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsd_t2_7_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsd_t2_7_1(d_v2,k_v2_offset,d_i1,k_i1_offset)
      CALL ccsd_t2_7_2(d_t1,k_t1_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL ccsd_t2_7_3(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                 d_i1,k_i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL ccsd_t2_7(d_t2,k_t2_offset,d_i1,k_i1_offset,d_i0,k_i0_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) 
     1    CALL ERRQUIT('ccsd_t2',-1,MA_ERR)
      CALL OFFSET_vt1t1_1_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('vt1t1_1_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL vt1t1_1_2(d_t1,k_t1_offset,d_v2,k_v2_offset,d_i1,k_i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL vt1t1_1(d_t1,k_t1_offset,d_i1,k_i1_offset,d_i0,k_i0_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) 
     1    CALL ERRQUIT('vt1t1',-1,MA_ERR)
      CALL c2f_t2_t12(d_t1,k_t1_offset,d_t2,k_t2_offset)
      cpu = - util_cpusec()
      wall = - util_wallsec()
#ifdef NEW_COMM_STRUCT
      CALL ccsd_t2_8_spiral(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1                      d_i0,k_i0_offset)
#else
      CALL ccsd_t2_8(d_t2,k_t2_offset,d_v2,k_v2_offset,
     1               d_i0,k_i0_offset)
#endif
      cpu = cpu + util_cpusec()
      wall = wall + util_wallsec()
      cpusecs(37) = cpu
      cpusecs(38) = wall
      CALL c2d_t2_t12(d_t1,k_t1_offset,d_t2,k_t2_offset)
c --- PETA ----------
c 9020 format('DIAG-D',i3,1x,'Cpu & wall time / sec',2f15.4)
c 9021 format('   DIAG-D',i3,1x,i3,2x,'Cpu & wall time / sec',2f15.4)
c -------------------
      RETURN
      END




