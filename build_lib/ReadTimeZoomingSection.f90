










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
! Purpose: read in user input related to timezooming.
!
! Description: none.
!
! Input: user input file.
!
! Output: global = timezooming parameters
!
! Notes: none.
!
!******************************************************************************


SUBROUTINE ReadTimeZoomingSection( global )

  USE ModDataTypes
  USE ModGlobal, ONLY     : t_global
  USE ModInterfaces, ONLY : ReadSection
  USE ModError
  USE ModParameters
  USE ModMPI

  IMPLICIT NONE

! ... parameters
  TYPE(t_global), POINTER :: global

! ... local variables
  INTEGER :: nVals
  INTEGER, PARAMETER :: NVALS_MAX = 9

  CHARACTER(10) :: keys(NVALS_MAX)

  LOGICAL :: defined(NVALS_MAX)

  REAL(RFREAL) :: vals(NVALS_MAX)

!******************************************************************************

  CALL RegisterFunction( global,'ReadTimeZoomingSection',"../libfloflu/ReadTimeZoomingSection.F90" )
! specify keywords and search for them

  nVals = NVALS_MAX

  keys(1) = 'MINPLANE'
  keys(2) = 'MAXPLANE'
  keys(3) = 'NOZINLET'
  keys(4) = 'NOZRAD'
  keys(5) = 'AXIS'
  keys(6) = 'THROATRAD'
  keys(7) = 'N'
  keys(8) = 'RHO'
  keys(9) = 'A'

  
  CALL ReadSection( global,IF_INPUT,nVals,keys,vals,defined )

  IF (defined( 1)) THEN
     global%tzMinPlane        = vals( 1)
  ELSE
     global%tzMinPlane = -9d10
  ENDIF

  IF (defined( 2)) THEN
     global%tzMaxPlane        = vals( 2)
  ELSE
     global%tzMaxPlane = 0.85_RFREAL
  ENDIF

  IF (defined( 8)) THEN
     global%tzRhos        = vals( 8)
  ELSE
     global%tzRhos = 1702.68_RFREAL
  ENDIF

  IF (defined( 9)) THEN
     global%tzA           = vals( 9)
  ELSE
     global%tzA = .000003789917_RFREAL
  ENDIF

  IF (defined( 7)) THEN
     global%tzN           = vals( 7)
  ELSE
     global%tzN = 0.461_RFREAL
  ENDIF

  IF (defined( 6)) THEN
     global%tzThroatRad   = vals( 6)
  ELSE
     global%tzThroatRad = 0.013208_RFREAL
  ENDIF

  IF (defined( 5)) THEN
     IF(vals(5) == 1.0) THEN
        global%tzCoordLong   = XCOORD
        global%tzCoordTrans1 = YCOORD
        global%tzCoordTrans2 = ZCOORD
     ELSE IF (vals(5) == 2.0) THEN
        global%tzCoordLong   = YCOORD
        global%tzCoordTrans1 = ZCOORD
        global%tzCoordTrans2 = XCOORD
     ELSE
        global%tzCoordLong   = ZCOORD
        global%tzCoordTrans1 = XCOORD
        global%tzCoordTrans2 = YCOORD
     ENDIF
  ELSE
     global%tzCoordLong   = XCOORD
     global%tzCoordTrans1 = YCOORD
     global%tzCoordTrans2 = ZCOORD
  ENDIF

  global%tzSubNoz = .false.
  IF (defined(3)) THEN
     global%tzNozInlet   = vals( 3)
     global%tzSubNoz = .true.
  ELSE
     global%tzNozInlet = global%tzMaxPlane
  ENDIF

  IF (defined(4)) THEN
     global%tzNozRad   = vals(4)
     global%tzSubNoz = .true.
  ELSE
     global%tzNozRad = global%tzThroatRad
  ENDIF

! finalize

  CALL DeregisterFunction( global )

END SUBROUTINE ReadTimeZoomingSection


