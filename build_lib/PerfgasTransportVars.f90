










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
! Purpose: compute transport variables for a thermally and calorically
!          perfect gas using various mdoels.
!
! Description: none.
!
! Input: inBeg    = first value to update
!        inEnd    = last value to update
!        indCp    = indicates if cp varies over cells (=1) or is constant (=0)
!        indMol   = indicates if the mol mass varies over cells (=1) or is
!                     constant (=0)
!        viscModel= viscosity Model
!        prLam    = laminar Prandtl number
!        refVisc  = reference viscosity
!        refTemp  = reference temperature
!        suthCoef = reference SutherLand coefficient
!        cv       = conservative variables
!        dv       = dependent variables
!        gv       = gas variables (cp, Mol)
!
! Output: tv = transport variables (viscosity, heat conductivity)
!
! Notes: values are calculated for laminar flow only.
!
!******************************************************************************
!
! $Id: PerfgasTransportVars.F90,v 1.1.1.1 2015/01/23 22:57:50 tbanerjee Exp $
!
! Copyright: (c) 2001 by the University of Illinois
!
!******************************************************************************

SUBROUTINE PerfgasTransportVars( inBeg,inEnd,indCp,indMol,viscModel,prLam, &
                                 refVisc,refTemp,suthCoef,cv,dv,gv,tv )

  USE ModDataTypes
  USE ModParameters
  IMPLICIT NONE

! ... parameters
  INTEGER :: inBeg, inEnd, indCp, indMol, viscModel

  REAL(RFREAL)          :: prLam, refTemp, refVisc, suthCoef
  REAL(RFREAL), POINTER :: cv(:,:), dv(:,:), gv(:,:), tv(:,:)

! ... loop variables
  INTEGER :: ic

! ... local variables
  REAL(RFREAL) :: absTemp, s1, s2, s12, s3, s4, prrl, rat

!******************************************************************************

  prrl = 1._RFREAL/prLam

  SELECT CASE (viscModel)

! - Sutherland formula --------------------------------------------------------

    CASE (VISC_SUTHR)
      s1  = refTemp
      s2  = suthCoef
      s12 = 1._RFREAL + s1/s2

      DO ic=inBeg,inEnd
        rat = SQRT(dv(DV_MIXT_TEMP,ic)/s2) &
            * s12/(1._RFREAL+s1/dv(DV_MIXT_TEMP,ic))

        tv(TV_MIXT_MUEL,ic) = refVisc*rat
        tv(TV_MIXT_TCOL,ic) = gv(GV_MIXT_CP,ic*indCp)*tv(TV_MIXT_MUEL,ic)*prrl
      ENDDO ! ic

! - constant viscosity --------------------------------------------------------

    CASE (VISC_FIXED)
      DO ic=inBeg,inEnd
        tv(TV_MIXT_MUEL,ic) = refVisc
        tv(TV_MIXT_TCOL,ic) = gv(GV_MIXT_CP,ic*indCp)*tv(TV_MIXT_MUEL,ic)*prrl
      ENDDO ! ic     

! - Antibes formula -----------------------------------------------------------

    CASE (VISC_ANTIB) 
      s1 = 110.0_RFREAL
      s2 = 120.0_RFREAL
      s3 = 230.0_RFREAL
      s4 = 1._RFREAL/refTemp * SQRT(s2/refTemp) *(refTemp+s1)/s3
            
      IF ( refTemp <= s2 ) THEN
        DO ic=inBeg,inEnd
          absTemp = ABS( dv(DV_MIXT_TEMP,ic) )
        
          IF ( absTemp < s2 ) THEN
            rat = absTemp/refTemp
          ELSE
            rat = SQRT(absTemp/s2) *(absTemp/refTemp) *( s3/(absTemp+s1) )
          ENDIF ! absTemp
        
          tv(TV_MIXT_MUEL,ic) = refVisc*rat
          tv(TV_MIXT_TCOL,ic) = gv(GV_MIXT_CP,ic*indCp)*tv(TV_MIXT_MUEL,ic)*prrl
        ENDDO ! ic
      
      ELSE 
        DO ic=inBeg,inEnd
          absTemp = ABS( dv(DV_MIXT_TEMP,ic) )
        
          IF ( absTemp < s2 ) THEN
            rat = s4
          ELSE
            rat = SQRT(absTemp/refTemp) *( absTemp/refTemp ) &
                * ( refTemp+s1 )/( absTemp+s1 )
          ENDIF ! absTemp
        
          tv(TV_MIXT_MUEL,ic) = refVisc*rat
          tv(TV_MIXT_TCOL,ic) = gv(GV_MIXT_CP,ic*indCp)*tv(TV_MIXT_MUEL,ic)*prrl
        ENDDO ! ic      
      ENDIF ! refTemp 
      
  END SELECT ! viscModel
  
END SUBROUTINE PerfgasTransportVars

!******************************************************************************
!
! RCS Revision history:
!
! $Log: PerfgasTransportVars.F90,v $
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:37  brollin
! New Stable version
!
! Revision 1.3  2008/12/06 08:43:32  mtcampbe
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
! Revision 1.1  2004/12/01 16:50:06  haselbac
! Initial revision after changing case
!
! Revision 1.6  2003/05/06 20:05:39  jblazek
! Corrected bug in grid motion (corner "averaging").
!
! Revision 1.5  2003/04/10 23:27:29  fnajjar
! Added 2 new viscosity models and aligned calling sequence
!
! Revision 1.4  2002/09/05 17:40:20  jblazek
! Variable global moved into regions().
!
! Revision 1.3  2002/02/09 01:47:01  jblazek
! Added multi-probe option, residual smoothing, physical time step.
!
! Revision 1.2  2002/01/23 03:51:24  jblazek
! Added low-level time-stepping routines.
!
! Revision 1.1  2002/01/10 00:02:06  jblazek
! Added calculation of mixture properties.
!
!******************************************************************************

