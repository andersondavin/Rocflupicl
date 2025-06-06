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
! ******************************************************************************
!
! Purpose: Allocate memory wrapper.
!
! Description: None.
!
! Input:
!   pRegion        Region pointer
!
! Output: None.
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_AllocateMemoryWrapper.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2002-2005 by the University of Illinois
!
! ******************************************************************************

SUBROUTINE RFLU_AllocateMemoryWrapper(pRegion)

  USE ModDataTypes
  USE ModError
  USE ModGlobal, ONLY: t_global
  USE ModDataStruct, ONLY: t_region
  USE ModParameters
  USE ModMPI

#ifdef PLAG
  USE ModPartLag, ONLY: t_plag
#endif

#ifdef GENX
  USE RFLU_ModGENXAdmin, ONLY: RFLU_GENX_CreateDataInterf
#endif

  USE ModInterfaces, ONLY: RFLU_AllocateMemory

#ifdef PLAG
  USE ModInterfacesLagrangian, ONLY: PLAG_RFLU_AllocMemSol, &
                                     PLAG_RFLU_AllocMemSolTile, &
                                     PLAG_RFLU_AllocMemTStep, &
                                     PLAG_RFLU_AllocMemTStepTile, &
                                     PLAG_INRT_AllocMemTStep
#endif

#ifdef PERI
  USE ModInterfacesPeriodic, ONLY : PERI_AllocateMemory
#endif

#ifdef SPEC
  USE ModInterfacesSpecies, ONLY: SPEC_RFLU_AllocateMemory, & 
                                  SPEC_RFLU_AllocateMemoryEEv
#endif

#ifdef TURB
  USE ModInterfacesTurbulence, ONLY: TURB_AllocateMemory
#endif

  IMPLICIT NONE

! ******************************************************************************
! Definitions and declarations
! ******************************************************************************

! ==============================================================================
! Arguments
! ==============================================================================

  TYPE(t_region), POINTER :: pRegion

! ==============================================================================
! Locals
! ==============================================================================

  CHARACTER(CHRLEN) :: RCSIdentString
  TYPE(t_global), POINTER :: global
#ifdef PLAG
  TYPE(t_plag), POINTER :: pPlag
#endif

! ******************************************************************************
! Start
! ******************************************************************************

  RCSIdentString = & 
    '$RCSfile: RFLU_AllocateMemoryWrapper.F90,v $ $Revision: 1.1.1.1 $'

  global => pRegion%global

  CALL RegisterFunction(global,'RFLU_AllocateMemoryWrapper',__FILE__)

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_NONE ) THEN
    WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Allocating memory...'
  END IF ! global%verbLevel

! ******************************************************************************
! Allocate memory 
! ******************************************************************************

! ==============================================================================
! Mixture
! ==============================================================================

  CALL RFLU_AllocateMemory(pRegion)
  
#ifdef GENX
  CALL RFLU_GENX_CreateDataInterf(pRegion)  
#endif

#ifdef PLAG
! ==============================================================================
! Particles
! ==============================================================================

  IF ( global%plagUsed .EQV. .TRUE. ) THEN
    pPlag => pRegion%plag
    CALL PLAG_RFLU_AllocMemSol(pRegion,pPlag)
    CALL PLAG_RFLU_AllocMemSolTile(pRegion)
    CALL PLAG_RFLU_AllocMemTStep(pRegion,pPlag)
    CALL PLAG_RFLU_AllocMemTStepTile(pRegion)
    CALL PLAG_INRT_AllocMemTStep(pRegion,pPlag)
  END IF ! plagUsed
#endif

#ifdef RADI
! ==============================================================================
! Radiation
! ==============================================================================

  IF ( pRegion%mixtInput%radiUsed .EQV. .TRUE. ) THEN
    CALL RADI_AllocateMemory(pRegion)
  END IF ! pRegion%mixtInput%radiUsed
#endif

#ifdef SPEC
! ==============================================================================
! Species
! ==============================================================================

  IF ( global%specUsed .EQV. .TRUE. ) THEN
    CALL SPEC_RFLU_AllocateMemory(pRegion)
    CALL SPEC_RFLU_AllocateMemoryEEv(pRegion)
  END IF ! pRegion%mixtInput%specUsed
#endif

#ifdef TURB
! ==============================================================================
! Turbulence
! ==============================================================================

  print*,'TLJ Calling TURB_allocatememory'
  IF ( (pRegion%mixtInput%flowModel == FLOW_NAVST) .AND. &
       (pRegion%mixtInput%turbModel /= TURB_MODEL_NONE) ) THEN
    CALL TURB_AllocateMemory(pRegion)
  END IF ! pRegion%mixtInput%flowModel
#endif

#ifdef PERI
  print*,'TLJ Calling PERI_allocatememory'
  IF ( pRegion%periInput%flowKind /= OFF ) THEN
    CALL PERI_AllocateMemory(pRegion)
  END IF ! pRegion%periInput%flowKind
#endif

! ******************************************************************************
! End
! ******************************************************************************

  IF ( global%myProcid == MASTERPROC .AND. &
       global%verbLevel > VERBOSE_NONE ) THEN
    WRITE(STDOUT,'(A,1X,A)') SOLVER_NAME,'Allocating memory done.'
  END IF ! global%verbLevel

  CALL DeregisterFunction(global)

END SUBROUTINE RFLU_AllocateMemoryWrapper

! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_AllocateMemoryWrapper.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:38  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:47  mtcampbe
! Updated license.
!
! Revision 1.2  2008/11/19 22:16:59  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.1  2007/04/09 18:49:56  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 18:01:00  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.23  2005/11/27 01:52:08  haselbac
! Added allocate call for EEv
!
! Revision 1.22  2004/10/20 12:52:02  haselbac
! Bug fix: Erroneous reintroduction of INRT routine
!
! Revision 1.21  2004/10/19 19:29:05  haselbac
! Adapted to GENX changes, no longer create grid
!
! Revision 1.20  2004/07/28 15:29:20  jferry
! created global variable for spec use
!
! Revision 1.19  2004/07/27 21:27:15  jferry
! removed rocinteract allocation routines (moved to rocpart)
!
! Revision 1.18  2004/07/26 17:05:51  fnajjar
! moved allocation of inrtSources into Rocpart
!
! Revision 1.17  2004/07/23 22:43:16  jferry
! Integrated rocspecies into rocinteract
!
! Revision 1.16  2004/06/17 23:05:58  wasistho
! added memory allocation for rocperi
!
! Revision 1.15  2004/06/14 23:20:24  jferry
! Added checks for inrtUsed, plagUsed, and/or peulUsed
!
! Revision 1.14  2004/03/19 21:21:30  haselbac
! Cosmetics only
!
! Revision 1.13  2004/03/05 22:09:03  jferry
! created global variables for peul, plag, and inrt use
!
! Revision 1.12  2004/02/26 21:02:06  haselbac
! Added PLAG support, changed logic
!
! Revision 1.11  2004/02/02 22:51:15  haselbac
! Commented out PLAG_AllocateMemory - temporary measure
!
! Revision 1.10  2003/11/25 21:04:35  haselbac
! Added call to SPEC_RFLU_AllocateMemory
!
! Revision 1.9  2003/03/18 21:33:25  haselbac
! Added allocMode argument
!
! Revision 1.8  2003/03/15 18:24:59  haselbac
! Some changes for parallel computations
!
! Revision 1.7  2003/01/28 14:21:17  haselbac
! Cosmetic changes only
!
! Revision 1.6  2002/09/17 22:51:23  jferry
! Removed Fast Eulerian particle type
!
! Revision 1.5  2002/09/09 15:27:01  haselbac
! global and mixtInput now under regions
!
! Revision 1.4  2002/08/24 03:19:56  wasistho
! put safety within #ifdef TURB
!
! Revision 1.3  2002/07/25 14:27:13  haselbac
! Added MASTERPROC distinction for output
!
! Revision 1.2  2002/06/17 13:34:12  haselbac
! Prefixed SOLVER_NAME to all screen output
!
! Revision 1.1  2002/05/04 17:01:59  haselbac
! Initial revision
!
! ******************************************************************************

