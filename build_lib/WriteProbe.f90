










!*********************************************************************
!* Illinois Open Source License                                      *
!*                                                                   *
!* University of Illinois/NCSA                                       * 
!* Open Source License                                               *
!*                                                                   *
!* Copyright@2008, University of Illinois.  All rights reserved.     *
!*                                                                   *
!*  Developed by:                                                    *
!*                                                                   *
!*     Center for Simulation of Advanced Rockets                     *
!*                                                                   *
!*     University of Illinois                                        *
!*                                                                   *
!*     www.csar.uiuc.edu                                             *
!*                                                                   *
!* Permission is hereby granted, free of charge, to any person       *
!* obtaining a copy of this software and associated documentation    *
!* files (the "Software"), to deal with the Software without         *
!* restriction, including without limitation the rights to use,      *
!* copy, modify, merge, publish, distribute, sublicense, and/or      *
!* sell copies of the Software, and to permit persons to whom the    *
!* Software is furnished to do so, subject to the following          *
!* conditions:                                                       *
!*                                                                   *
!*                                                                   *
!* @ Redistributions of source code must retain the above copyright  * 
!*   notice, this list of conditions and the following disclaimers.  *
!*                                                                   * 
!* @ Redistributions in binary form must reproduce the above         *
!*   copyright notice, this list of conditions and the following     *
!*   disclaimers in the documentation and/or other materials         *
!*   provided with the distribution.                                 *
!*                                                                   *
!* @ Neither the names of the Center for Simulation of Advanced      *
!*   Rockets, the University of Illinois, nor the names of its       *
!*   contributors may be used to endorse or promote products derived * 
!*   from this Software without specific prior written permission.   *
!*                                                                   *
!* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,   *
!* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   *
!* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          *
!* NONINFRINGEMENT.  IN NO EVENT SHALL THE CONTRIBUTORS OR           *
!* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       * 
!* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
!* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE    *
!* USE OR OTHER DEALINGS WITH THE SOFTWARE.                          *
!*********************************************************************
!* Please acknowledge The University of Illinois Center for          *
!* Simulation of Advanced Rockets in works and publications          *
!* resulting from this software or its derivatives.                  *
!*********************************************************************
!******************************************************************************
!
! Purpose: write data of a probe into a file.
!
! Description: none.
!
! Input: regions%levels%mixt = flow variables
!        iReg                = current region number
!        global%probePos     = list of probes
!
! Output: into file.
!
! Notes: none.
!
!******************************************************************************
!
! $Id: WriteProbe.F90,v 1.3 2016/01/31 04:57:09 rahul Exp $
!
! Copyright: (c) 2001 by the University of Illinois
!
!******************************************************************************

SUBROUTINE WriteProbe( regions,iReg )

  USE ModDataTypes
  USE ModDataStruct, ONLY : t_region
  USE ModGlobal, ONLY     : t_global
  USE ModError
  USE ModParameters

  USE ModInterfaces, ONLY : MixtPerf_R_CpG, MixtPerf_T_DPR
  USE RFLU_ModPlottingVars
  IMPLICIT NONE



! number of timesteps kept in history kernels
! maximum number of triangular patch boundaries

! y, y1, ydot, ydotc: 12

! rprop: 64

! map: 10






















! ... parameters
  TYPE(t_region), POINTER :: regions(:)

  INTEGER :: iReg

! ... loop variables
  INTEGER :: iprobe

! ... local variables
  CHARACTER(CHRLEN+9) :: fname !was (CHRLEN+9)

  INTEGER :: errorFlag,ipcbeg, ipcend, jpcbeg, jpcend, kpcbeg, kpcend
  INTEGER :: iLev, iCOff, ijCOff, iCell, nDv, nPeul, i, j, k
  INTEGER :: iLocTp,iLocUp,iLocYp,iLocdp3,iLocdp4,iLocndp
  INTEGER :: iLocReyp,iLocVp,iLocWp,iLocVFp
  LOGICAL :: wrtProbe, firstTime, cleanupNeeded

  REAL(RFREAL)          :: refCp, refGamma, rgas, rho, u, v, w, press, temp
  REAL(RFREAL)          :: asnd,xcg,ycg,zcg,par_u,par_v,par_w,par_dens,par_t
  REAL(RFREAL), POINTER :: cv(:,:), dv(:,:), peulCv(:,:)
!BRAD
  REAL(RFREAL) :: volFrac
  INTEGER :: indVFracE,ispc,nCells
!BRAD

   REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: phiP
   REAL(KIND=8),DIMENSION(:,:,:,:), ALLOCATABLE :: vfP,vfD,vpx,vpy,vpz,vpt
   integer :: lx,ly,lz          
   REAL(RFREAL) :: tester, total_vol,tester1,tester2
   REAL(RFREAL) :: testerx,testery,testerz,testert
   REAL(RFREAL) :: vFrac,volFrac2

        
  REAL(RFREAL), DIMENSION(:,:), POINTER :: pPv
  TYPE(t_global), POINTER :: global
  TYPE(t_region), POINTER :: pRegion

!******************************************************************************

  global => regions(iReg)%global

  CALL RegisterFunction( global,'WriteProbe',"../libfloflu/WriteProbe.F90" )

  ! TLJ - Set local values to zero
  u     = 0.0_RFREAL
  v     = 0.0_RFREAL
  w     = 0.0_RFREAL
  par_u = 0.0_RFREAL
  par_v = 0.0_RFREAL
  par_w = 0.0_RFREAL
  par_t = 0.0_RFREAL
  par_dens = 0.0_RFREAL
  tester1 = 0.0_RFREAL
  vFrac = 0.0_RFREAL
  volFrac2 = 0.0_RFREAL

  refCp = global%refCp
  refGamma = global%refGamma
  rgas = MixtPerf_R_CpG( refCp,refGamma )

! determine if Dv array is used or not

  nDv = regions(iReg)%mixtInput%nDv

! determine number of smoke/species types that exist (if any)
! TLJ - I have no clue who or why "nPeul" is the name used
  nPeul = 0
  firstTime = .true.
  cleanupNeeded = .false.
  IF (global%specUsed) THEN
     nPeul = regions(iReg)%specInput%nSpecies
  ENDIF

! loop over all specified probes ----------------------------------------------
   !1 CODE HERE
    nCells = regions(iReg)%grid%nCells    
    ALLOCATE(vfP(2,2,2,nCells),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,178,'PPICLF:xGrid')
    END IF ! global%error

    ALLOCATE(vfD(2,2,2,nCells),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,184,'PPICLF:xGrid')
    END IF ! global%error

    ALLOCATE(vpx(2,2,2,nCells),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,190,'PPICLF:xGrid')
    END IF ! global%error

    ALLOCATE(vpy(2,2,2,nCells),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,196,'PPICLF:xGrid')
    END IF ! global%error

    ALLOCATE(vpz(2,2,2,nCells),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,202,'PPICLF:xGrid')
    END IF ! global%error

    ALLOCATE(vpt(2,2,2,nCells),STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,208,'PPICLF:xGrid')
    END IF ! global%error

!write(*,*) " Atempting to write probes"
  DO iprobe=1,global%nProbes

    wrtProbe = .false.

    IF ( global%probePos(iprobe,PROBE_REGION) == &
         regions(iReg)%iRegionGlobal ) THEN

      iCell = global%probePos(iprobe,PROBE_CELL)

      cv => regions(iReg)%mixt%cv
      IF (nDv > 0 ) dv => regions(iReg)%mixt%dv
      IF (nPeul > 0) peulCv => regions(iReg)%spec%cv

      wrtProbe = .TRUE.
    END IF ! global%probePos

!Add check so particle vel are calulated once per entire probe stuff

    if ((wrtProbe) .and. (firstTime)) then
        firstTime = .false.

pRegion => regions(iReg)

    end if!wrtProbe and firstTime
! - write probe data to file

    IF (wrtProbe) THEN
      IF ( global%solverType == SOLV_IMPLICIT_HM ) THEN
        rho   = cv(CV_MIXT_DENS,iCell)*global%refDensity
        u     = cv(CV_MIXT_XVEL,iCell)*global%refVelocity
        v     = cv(CV_MIXT_YVEL,iCell)*global%refVelocity
        w     = cv(CV_MIXT_ZVEL,iCell)*global%refVelocity

        press = (cv(CV_MIXT_PRES,iCell) &
                *global%refDensity*global%refVelocity*global%refVelocity) &
                +global%refPressure
        temp = MixtPerf_T_DPR(rho,press,rgas)
      ELSE
        rho   = cv(CV_MIXT_DENS,iCell)
        u     = cv(CV_MIXT_XMOM,iCell)/rho
        v     = cv(CV_MIXT_YMOM,iCell)/rho
        w     = cv(CV_MIXT_ZMOM,iCell)/rho

        press = dv(DV_MIXT_PRES,iCell)
        temp  = dv(DV_MIXT_TEMP,iCell)
        asnd  = dv(DV_MIXT_SOUN,iCell)
        !sound speed 
        if (abs(u) .lt. 1.0E-20_RFREAL) u = 0.0_RFREAL
        if (abs(v) .lt. 1.0E-20_RFREAL) v = 0.0_RFREAL
        if (abs(w) .lt. 1.0E-20_RFREAL) w = 0.0_RFREAL

        if (nPeul .gt. 0) then
        Do ispc=1,nPeul
           if (abs(peulCv(ispc,iCell)) .lt.  1.0E-50_RFREAL) then
              peulCv(ispc,iCell) =  0.0_RFREAL
           end if       
        enddo
        end if
!BRAD
        xcg = regions(iReg)%grid%cofg(XCOORD,iCell)
        ycg = regions(iReg)%grid%cofg(YCOORD,iCell)
        zcg = regions(iReg)%grid%cofg(ZCOORD,iCell)
!BRAD

!1 CODE HERE

   IF (global%piclUsed .EQV. .TRUE. ) THEN
!Per cell grab desired value
       tester1 = 0 
       tester2 = 0 
       testerx = 0
       testery = 0 
       testerz = 0 
       testert = 0 
       do lz=1,2
       do ly=1,2
       do lx=1,2

! TLJ: This needs to be checked
!particle volume
       call ppiclf_solve_GetProFldIJKEF(lx, ly, lz, iCell, 1,&
                        vfP(lx,ly,lz,iCell))
!density
       call ppiclf_solve_GetProFldIJKEF(lx, ly, lz, iCell, 6,&
                        vfD(lx,ly,lz,iCell))
!x-vel
       call ppiclf_solve_GetProFldIJKEF(lx, ly, lz, iCell, 7,&
                        vpx(lx,ly,lz,iCell))
!y-vel
       call ppiclf_solve_GetProFldIJKEF(lx, ly, lz, iCell, 8,&
                        vpy(lx,ly,lz,iCell))
!z-vel
       call ppiclf_solve_GetProFldIJKEF(lx, ly, lz, iCell, 9,&
                        vpz(lx,ly,lz,iCell))
!T-temperature
       call ppiclf_solve_GetProFldIJKEF(lx, ly, lz, iCell, 10,&
                        vpt(lx,ly,lz,iCell))

       ! TLJ - modified 12/21/2024
       tester1 = tester1 +(0.125*vfP(lx,ly,lz,iCell))!*pRegion%grid%vol(iCell)
       tester2 = tester2 +(0.125*vfD(lx,ly,lz,iCell))!*pRegion%grid%vol(iCell)
       testerx = testerx +(0.125*vpx(lx,ly,lz,iCell))!*pRegion%grid%vol(iCell)
       testery = testery +(0.125*vpy(lx,ly,lz,iCell))!*pRegion%grid%vol(iCell)
       testerz = testerz +(0.125*vpz(lx,ly,lz,iCell))!*pRegion%grid%vol(iCell)
       testert = testert +(0.125*vpt(lx,ly,lz,iCell))!*pRegion%grid%vol(iCell)

       end do
       end do
       end do
    !number of picl particles
      ! TLJ - Commented out 12/21/2024
      !tester1 = tester1 / pRegion%grid%vol(iCell)
      !volFrac = pRegion%mixt%piclVF(iCell)

      vFrac = 1.0d0 - pRegion%mixt%piclVF(iCell)
      volFrac = regions(iReg)%mixt%piclVF(iCell)

      ! TLJ - modified 12/21/2024
      par_dens = tester2 / tester1!/(global%pi/6.0*(115.0E-6)**3)
      par_u = testerx / tester1 !/ par_dens
      par_v = testery / tester1 !/ par_dens
      par_w = testerz / tester1 !/ par_dens
      par_t = testert / tester1 !/ par_dens

      if (abs(vFrac) .lt. 1.0E-20_RFREAL) vFrac = 0.0_RFREAL
      if (abs(volFrac) .lt. 1.0E-20_RFREAL) volFrac = 0.0_RFREAL
      if (abs(par_dens) .lt. 1.0E-20_RFREAL) par_dens = 0.0_RFREAL
      if (abs(par_u) .lt. 1.0E-20_RFREAL) par_u = 0.0_RFREAL
      if (abs(par_v) .lt. 1.0E-20_RFREAL) par_v = 0.0_RFREAL
      if (abs(par_w) .lt. 1.0E-20_RFREAL) par_w = 0.0_RFREAL
      IF (IsNan(par_dens) .EQV. .TRUE.) par_dens = 0
      IF (IsNan(par_u) .EQV. .TRUE.) par_u = 0
      IF (IsNan(par_v) .EQV. .TRUE.) par_v = 0
      IF (IsNan(par_w) .EQV. .TRUE.) par_w = 0
      IF (IsNan(par_t) .EQV. .TRUE.) par_t = 0

   ENDIF

      END IF!wrt_probe


      IF (nPeul == 0) THEN
        IF (global%flowType == FLOW_STEADY) THEN
          WRITE(IF_PROBE+iprobe-1,1000,IOSTAT=errorFlag) global%currentIter,  &
                                                         rho,u,v,w,press,temp, &
                                                         asnd,volFrac
        ELSE
          WRITE(IF_PROBE+iprobe-1,1005,IOSTAT=errorFlag) global%currentTime,xcg,&
                                                         ycg,zcg,rho,u,v,w,press,temp, &
                                                         asnd,volFrac,par_dens, &
                                                         par_u,par_v,par_w,par_t, &
                                                         vFrac
        ENDIF
      ELSE
        IF (global%flowType == FLOW_STEADY) THEN
          WRITE(IF_PROBE+iprobe-1,1000,IOSTAT=errorFlag) global%currentIter,  &
                                                         rho,u,v,w,press,temp,&
                                                         peulCv(1:nPeul,iCell), &
                                                         asnd,volFrac,par_dens,&
                                                         par_u,par_v,par_w
        ELSE


          WRITE(IF_PROBE+iprobe-1,1005,IOSTAT=errorFlag) global%currentTime,xcg,&
                                                         ycg,zcg,rho,u,v,w,press,temp,&
                                                         peulCv(1:nPeul,iCell)/rho,&
                                                         asnd,volFrac,&
                                                         par_dens,par_u,par_v,par_w,par_t,&
                                                         Vfrac

        ENDIF
      ENDIF

      global%error = errorFlag
      IF (global%error /= 0) THEN
        CALL ErrorStop( global,ERR_FILE_WRITE,433,'Probe file' )
      ENDIF

! --- close and open probe file (instead of fflush)

      IF (global%probeOpenClose) THEN
        WRITE(fname,'(A,I4.4)') &
!              TRIM(global%outDir)//TRIM(global%casename)//'.prb_',iprobe
! BBR - begin - Dump probes data file in appropriate folder
              './Probes/'//TRIM(global%casename)//'.prb_',iprobe
! BBR - end
        CLOSE(IF_PROBE+iprobe-1)
        OPEN(IF_PROBE+iprobe-1,FILE=fname,FORM='FORMATTED',STATUS='OLD', &
             POSITION='APPEND')
      ENDIF
    ENDIF   ! wrtProbe

  ENDDO     ! iprobe

DEALLOCATE(vfP,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,461,'PPICLF:xGrid')
    END IF ! global%error

DEALLOCATE(vfD,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,467,'PPICLF:xGrid')
    END IF ! global%error

DEALLOCATE(vpx,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,473,'PPICLF:xGrid')
    END IF ! global%error

DEALLOCATE(vpy,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,479,'PPICLF:xGrid')
    END IF ! global%error

DEALLOCATE(vpz,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,485,'PPICLF:xGrid')
    END IF ! global%error

DEALLOCATE(vpt,STAT=errorFlag)
    global%error = errorFlag
    IF ( global%error /= ERR_NONE ) THEN
      CALL ErrorStop(global,ERR_ALLOCATE,491,'PPICLF:xGrid')
    END IF ! global%error



! finalize --------------------------------------------------------------------

  CALL DeregisterFunction( global )

1000 FORMAT(I6,1P,99E24.16)
1005 FORMAT(1PE24.16,99E24.16)

END SUBROUTINE WriteProbe

!******************************************************************************
!
! RCS Revision history:
!
! $Log: WriteProbe.F90,v $
! Revision 1.3  2016/01/31 04:57:09  rahul
! Added the compile flag 1.
!
! Revision 1.2  2015/07/23 23:11:18  brollin
! 1) The pressure coefficient of the  collision model has been changed back to its original form
! 2) New options in the format of the grid and solutions have been added. Now the user can choose the endianness, and convert from one to the over in rfluconv.
! 3) The solutions are now stored in folders named by timestamp or iteration number.
! 4) The address enty in the hashtable has been changed to an integer(8) for cases when the grid becomes very large.
! 5) RFLU_WritePM can now compute PM2 on the fly for the Macroscale problem
!
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.5  2008/12/06 08:43:33  mtcampbe
! Updated license.
!
! Revision 1.4  2008/11/19 22:16:48  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.3  2008/05/29 01:35:15  mparmar
! Increased significant digits of data written to probe file
!
! Revision 1.2  2007/11/28 23:17:49  mparmar
! Writing probe data for SOLV_IMPLICIT_HM
!
! Revision 1.1  2007/04/09 18:48:33  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 17:59:26  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.2  2006/02/13 21:01:05  wasistho
! added ifdef PEUL
!
! Revision 1.1  2004/12/01 16:52:25  haselbac
! Initial revision after changing case
!
! Revision 1.21  2004/07/28 15:29:18  jferry
! created global variable for spec use
!
! Revision 1.20  2004/07/23 22:43:15  jferry
! Integrated rocspecies into rocinteract
!
! Revision 1.19  2004/03/05 22:09:00  jferry
! created global variables for peul, plag, and inrt use
!
! Revision 1.18  2003/11/20 16:40:36  mdbrandy
! Backing out RocfluidMP changes from 11-17-03
!
! Revision 1.15  2003/05/15 16:40:57  jblazek
! Changed index function call to fit into single line.
!
! Revision 1.14  2003/05/15 02:57:02  jblazek
! Inlined index function.
!
! Revision 1.13  2003/04/07 18:25:09  jferry
! added smoke concentrations to output
!
! Revision 1.12  2003/04/07 14:19:33  haselbac
! Removed ifdefs - now also used for 1
!
! Revision 1.11  2003/01/23 17:48:53  jblazek
! Changed algorithm to dump convergence, solution and probe data.
!
! Revision 1.10  2003/01/10 17:58:43  jblazek
! Added missing explicit interfaces.
!
! Revision 1.9  2002/10/07 19:24:28  haselbac
! Change use of IOSTAT, cures problem on SGIs
!
! Revision 1.8  2002/10/05 18:42:09  haselbac
! Added 1 functionality
!
! Revision 1.7  2002/09/05 17:40:20  jblazek
! Variable global moved into regions().
!
! Revision 1.6  2002/02/21 23:25:05  jblazek
! Blocks renamed as regions.
!
! Revision 1.5  2002/02/16 07:16:00  jblazek
! Added implicit residual smoothing.
!
! Revision 1.4  2002/02/09 01:47:01  jblazek
! Added multi-probe option, residual smoothing, physical time step.
!
! Revision 1.3  2002/02/01 00:00:24  jblazek
! Edge and corner cells defined for each level.
!
! Revision 1.2  2002/01/31 20:56:30  jblazek
! Added basic boundary conditions.
!
! Revision 1.1  2002/01/31 00:39:23  jblazek
! Probe output moved to common library.
!
!******************************************************************************

