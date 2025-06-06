










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
! Purpose: Collect relations for static and total internal energy per unit
!   mass.
!
! Description: None.
!
! Notes: None.
!
!******************************************************************************
!
! $Id: MixtPerf_E.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2002-2004 by the University of Illinois
!
!******************************************************************************

FUNCTION MixtPerf_Eo_DGPUVW(D,G,P,U,V,W)

  USE ModDataTypes

  IMPLICIT NONE
  
  REAL(RFREAL), INTENT(IN) :: D,G,P,U,V,W
  REAL(RFREAL) :: MixtPerf_Eo_DGPUVW
   
  MixtPerf_Eo_DGPUVW = P/(D*(G - 1.0_RFREAL)) + 0.5_RFREAL*(U*U + V*V + W*W)

END FUNCTION MixtPerf_Eo_DGPUVW

! -----------------------------------------------------------------------------

FUNCTION MixtPerf_Eo_DGPVm(D,G,P,Vm)

  USE ModDataTypes

  IMPLICIT NONE
  
  REAL(RFREAL), INTENT(IN) :: D,G,P,Vm
  REAL(RFREAL) :: MixtPerf_Eo_DGPVm
   
  MixtPerf_Eo_DGPVm = P/(D*(G - 1.0_RFREAL)) + 0.5_RFREAL*Vm*Vm

END FUNCTION MixtPerf_Eo_DGPVm

! -----------------------------------------------------------------------------

FUNCTION MixtPerf_Eo_GRTUVW(G,R,T,U,V,W)

  USE ModDataTypes

  IMPLICIT NONE
  
  REAL(RFREAL), INTENT(IN) :: G,R,T,U,V,W
  REAL(RFREAL) :: MixtPerf_Eo_GRTUVW
   
  MixtPerf_Eo_GRTUVW = R*T/(G - 1.0_RFREAL) + 0.5_RFREAL*(U*U + V*V + W*W)

END FUNCTION MixtPerf_Eo_GRTUVW

!******************************************************************************
!
! RCS Revision history:
!
! $Log: MixtPerf_E.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:31  mtcampbe
! Updated license.
!
! Revision 1.2  2008/11/19 22:16:47  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.1  2007/04/09 18:48:32  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 17:59:25  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2004/12/01 16:48:54  haselbac
! Initial revision after changing case
!
! Revision 1.2  2004/04/01 21:26:20  haselbac
! Added MixtPerf_E_GRTUVW
!
! Revision 1.1  2002/05/04 16:16:52  haselbac
! Initial revision
!
!******************************************************************************

