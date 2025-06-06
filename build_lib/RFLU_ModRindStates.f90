










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
! Purpose: Collection of routines for setting rind states.
!
! Description: None
!
! Notes: None.
!
! ******************************************************************************
!
! $Id: RFLU_ModRindStates.F90,v 1.2 2016/02/04 19:58:58 fred Exp $
!
! Copyright: (c) 2004 by the University of Illinois
!
! ******************************************************************************

MODULE RFLU_ModRindStates

  USE ModDataTypes
  USE ModParameters
  USE ModGlobal, ONLY: t_global

  USE ModInterfaces, ONLY: MixtPerf_C_DGP, &
                           MixtPerf_C_GRT, &  
                           MixtPerf_D_PRT, & 
                           MixtPerf_Eo_DGPUVW, &
                           MixtPerf_Eo_DGPVm, &  
                           MixtPerf_Ho_CpTUVW, & 
                           MixtPerf_G_CpR, &                           
                           MixtPerf_P_DEoGVm2, &
                           MixtPerf_R_M 

  USE RFLU_ModConvertCv,   ONLY: RFLU_ScalarConvertCvCons2Prim, &
                                 RFLU_ScalarConvertCvPrim2Cons
  USE RFLU_ModJWL

  IMPLICIT NONE
    
! ******************************************************************************
! Declarations and definitions
! ******************************************************************************  

! ==============================================================================  
! Procedures
! ==============================================================================  

  PUBLIC :: RFLU_SetRindStateFarfieldPerf, & 
            RFLU_SetRindStateSlipWallPerf, & 
            RFLU_SetRindStateSlipWallPerf1, & 
            RFLU_SetRindStateInjectPerf

  PRIVATE :: EvaluateDFunction, & 
             EvaluateFunction

! ==============================================================================  
! Data
! ==============================================================================  

  CHARACTER(CHRLEN), PRIVATE :: & 
    RCSIdentString = '$RCSfile: RFLU_ModRindStates.F90,v $ $Revision: 1.2 $'        
       
! ******************************************************************************
! Procedures
! ******************************************************************************
                
  CONTAINS
  






! ******************************************************************************
!
! Purpose: Compute function value
!
! Description: None.
!
! Input:
!   A           Coefficient of first term
!   B           Coefficient of second term
!   gGas        gamma
!   rho_w       density at wall
!
! Output: 
!   EvaluateFunction    value of expression
!
! Notes: 
!
! ******************************************************************************

  FUNCTION EvaluateFunction(A,B,gGas,rho_w)
  
    USE ModDataTypes
  
    IMPLICIT NONE
  
    REAL(RFREAL), INTENT(IN) :: A,B,gGas,rho_w
    REAL(RFREAL) :: EvaluateFunction
  
    EvaluateFunction = rho_w**gGas + A*rho_w - B   

  END FUNCTION EvaluateFunction









! ******************************************************************************
!
! Purpose: Compute derivative of function
!
! Description: None.
!
! Input:
!   A           Coefficient of first term
!   B           Coefficient of second term
!   gGas        gamma
!   rho_w       density at wall
!
! Output: 
!   EvaluateDFunction    value of derivative of expression
!
! Notes: 
!
! ******************************************************************************

  FUNCTION EvaluateDFunction(A,B,gGas,rho_w)
  
    USE ModDataTypes
  
    IMPLICIT NONE
  
    REAL(RFREAL), INTENT(IN) :: A,B,gGas,rho_w
    REAL(RFREAL) :: EvaluateDFunction
  
    EvaluateDFunction = gGas*rho_w**(gGas-1) + A  
  
  END FUNCTION EvaluateDFunction









! ******************************************************************************
!
! Purpose: Set rind state for farfield boundaries and perfect gas.
!
! Description: None.
!
! Input:
!   global      Pointer to global data
!   cpGas       Specific heat at constant pressure
!   mmGas       Molecular mass
!   nx,ny,nz    Components of unit normal vector
!   machInf     Mach number at infinity
!   pInf        Pressure at infinity
!   tInf        Temperature at infinity
!   alphaInf    Angle of attack
!   betaInf     Sideslip angle
!   corrFlag    Flag for vortex-correction
!   liftCoef    Lift coefficient
!   xc          x-coordinate 
!   yc          y-coordinate
!   zc          z-coordinate
!   rl          Density at boundary
!   rul         x-momentum component at boundary
!   rvl         y-momentum component at boundary
!   rwl         z-momentum component at boundary
!   rel         Total internal energy at boundary
!
! Output: 
!   rr          Density 
!   rur         x-momentum component 
!   rvr         y-momentum component 
!   rwr         z-momentum component 
!   rer         Total internal energy 
!   pr          Pressure 
!
! Notes: 
!   1. Valid only for thermally and calorically perfect gas.
!   2. Valid only for two-dimensional flows.
!
! ******************************************************************************

  SUBROUTINE RFLU_SetRindStateFarfieldPerf(global,cpGas,mmGas,nx,ny,nz, &
                                           machInf,pInf,tInf,alphaInf, &
                                           betaInf,corrFlag,liftCoef,xc,yc, &
                                           zc,rl,rul,rvl,rwl,rel,rr,rur,rvr, &
                                           rwr,rer,pr)
 
    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================  
!   Arguments 
! ==============================================================================  

    LOGICAL, INTENT(IN) :: corrFlag
    REAL(RFREAL), INTENT(IN) :: alphaInf,betaInf,cpGas,liftCoef,machInf, &
                                mmGas,nx,ny,nz,pInf,rl,rel,rul,rvl,rwl, & 
                                tInf,xc,yc,zc
    REAL(RFREAL), INTENT(OUT) :: pr,rer,rr,rur,rvr,rwr 
    TYPE(t_global), POINTER :: global

! ==============================================================================  
!   Locals 
! ==============================================================================  

    REAL(RFREAL) :: al,corr,corrTerm,denom,dist,dq2,dx,dy,el,gGas,gm1og, & 
                    gogm1,gGasTerm3,numer,pb,pi,pl,qi,ql,rb,rGas,ri,sl2, &
                    term,theta,ub,ui,ul,vb,vi,vl,wb,wi,wl    

! ******************************************************************************
!   Compute gas properties
! ******************************************************************************

    rGas = MixtPerf_R_M(mmGas)
    gGas = MixtPerf_G_CpR(cpGas,rGas)
          
    gm1og = (gGas-1.0_RFREAL)/gGas
    gogm1 = 1.0_RFREAL/gm1og  
          
    corrTerm = global%forceRefLength/(4.0_RFREAL*global%pi)
          
! ******************************************************************************
!   Interior state at boundary
! ******************************************************************************
        
    ul = rul/rl
    vl = rvl/rl
    wl = rwl/rl
    ql = ul*nx + vl*ny + wl*nz
 
    el  = rel/rl   
    sl2 = ul*ul + vl*vl + wl*wl
    pl  = MixtPerf_P_DEoGVm2(rl,el,gGas,sl2)
          
! ******************************************************************************
!   Compute state at infinity without vortex correction
! ******************************************************************************
 
    ri = MixtPerf_D_PRT(pInf,rGas,tInf)
    pi = pInf    
    
    qi = machInf*MixtPerf_C_GRT(gGas,rGas,tInf)
    ui = qi*COS(alphaInf)*COS(betaInf)
    vi = qi*SIN(alphaInf)*COS(betaInf)
    wi = qi*              SIN(betaInf)    

! ******************************************************************************
!   Compute state at infinity with vortex correction. NOTE the correction is 
!   assumed to be two-dimensional and the aerofoil center of pressure is assumed
!   to be located at (x,y) = (0.25,0.0).
! ******************************************************************************
 
    IF ( corrFlag .EQV. .TRUE. ) THEN 
      dx = xc - 0.25_RFREAL
      dy = yc
      
      dist  = SQRT(dx**2 + dy**2)
      theta = ATAN2(dy,dx)
      
      numer = liftCoef*qi*SQRT(1.0_RFREAL-machInf**2)
      denom = dist*(1.0_RFREAL - (machInf*SIN(theta-alphaInf))**2)
      corr  = corrTerm*numer/denom
      
      ui = ui + corr*SIN(theta)
      vi = vi - corr*COS(theta)
            
      dq2 = qi*qi - (ui*ui + vi*vi)            
      pi  = (pi**gm1og + 0.5_RFREAL*gm1og*ri/pi**(1.0_RFREAL/gGas)*dq2)**gogm1         
      ri  = ri*(pi/pInf)**gGas
    END IF ! corrFlag

! ******************************************************************************
!   Compute right state at boundary
! ******************************************************************************

! ==============================================================================  
!   Subsonic flow
! ==============================================================================  
   
    IF ( machInf < 1.0_RFREAL ) THEN
      al = MixtPerf_C_DGP(rl,gGas,pl)

! ------------------------------------------------------------------------------
!     Subsonic inflow
! ------------------------------------------------------------------------------

      IF ( ql < 0.0_RFREAL ) THEN
        pb = 0.5_RFREAL*(pi+pl-rl*al*((ui-ul)*nx+(vi-vl)*ny+(wi-wl)*nz))

        rb = ri -    (pi - pb)/(al*al)        
        ub = ui - nx*(pi - pb)/(rl*al)
        vb = vi - ny*(pi - pb)/(rl*al)
        wb = wi - nz*(pi - pb)/(rl*al)

! ------------------------------------------------------------------------------
!     Subsonic outflow
! ------------------------------------------------------------------------------

      ELSE
        pb = pi
      
        rb = rl -    (pl-pi)/(al*al)
        ub = ul + nx*(pl-pi)/(rl*al)
        vb = vl + ny*(pl-pi)/(rl*al)
        wb = wl + nz*(pl-pi)/(rl*al)
      END IF ! ql

      rr  = rb
      rur = rb*ub
      rvr = rb*vb
      rwr = rb*wb
      rer = rb*MixtPerf_Eo_DGPUVW(rb,gGas,pb,ub,vb,wb)
      pr  = pb

! ==============================================================================  
!   Supersonic flow
! ==============================================================================  

    ELSE

! ------------------------------------------------------------------------------
!     Supersonic inflow
! ------------------------------------------------------------------------------

      IF ( ql < 0.0_RFREAL ) THEN
        rr  = ri
        rur = ri*ui
        rvr = ri*vi
        rwr = ri*wi
        rer = ri*MixtPerf_Eo_DGPVm(ri,gGas,pi,qi)
        pr  = pi

! ------------------------------------------------------------------------------
!     Supersonic outflow
! ------------------------------------------------------------------------------

      ELSE
        rr  = rl
        rur = rul
        rvr = rvl
        rwr = rwl
        rer = rel
        pr  = pl
      END IF ! ql
    END IF ! machInf
 
! ******************************************************************************
!   End
! ******************************************************************************

  END SUBROUTINE RFLU_SetRindStateFarfieldPerf











! ******************************************************************************
!
! Purpose: Set rind state for injection boundaries and perfect gas.
!
! Description: None.
!
! Input:
!   cpGas       Specific heat at constant pressure
!   mmGas       Molecular mass
!   nx,ny,nz    Components of unit normal vector
!   mInj        Injection mass flux
!   tInj        Injection temperature
!   pl          Pressure
!   fs          Grid speed
!
! Output: 
!   rl          Density
!   ul          x-velocity component
!   vl          y-velocity component
!   wl          z-velocity component
!   Hl          Stagnation enthalpy per unit mass
!
! Notes: 
!   1. Valid only for thermally and calorically perfect gas.
!
! ******************************************************************************

  SUBROUTINE RFLU_SetRindStateInjectPerf(cpGas,mmGas,nx,ny,nz,mInj,tInj,pl, &
                                         fs,rl,ul,vl,wl,Hl)
 
    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================  
!   Arguments 
! ==============================================================================  

    REAL(RFREAL), INTENT(IN) :: cpGas,fs,mInj,mmGas,nx,ny,nz,pl,tInj
    REAL(RFREAL), INTENT(OUT) :: Hl,rl,ul,vl,wl 

! ==============================================================================  
!   Locals 
! ==============================================================================  

    REAL(RFREAL) :: gGas,ql,rGas    
          
! ******************************************************************************
!   Compute wall pressure
! ******************************************************************************

    rGas = MixtPerf_R_M(mmGas)
    gGas = MixtPerf_G_CpR(cpGas,rGas)
 
    rl = MixtPerf_D_PRT(pl,rGas,tInj)
 
    ql = -mInj/rl + fs
    ul = ql*nx
    vl = ql*ny
    wl = ql*nz
     
    Hl = MixtPerf_Ho_CpTUVW(cpGas,tInj,ul,vl,wl)
 
! ******************************************************************************
!   End
! ******************************************************************************

  END SUBROUTINE RFLU_SetRindStateInjectPerf








! ******************************************************************************
!
! Purpose: Set rind state for slip-wall boundaries and perfect gas.
!
! Description: None.
!
! Input:
!   cpGas       Specific heat at constant pressure
!   mmGas       Molecular mass
!   nx,ny,nz    Components of unit normal vector
!   rl          Density
!   rul         x-momentum component
!   rvl         y-momentum component
!   rwl         z-momentum component
!   fs          Grid speed
!   pl          Pressure
!
! Output: 
!   pl          Pressure
!
! Notes: 
!   1. Valid only for thermally and calorically perfect gas.
!
! ******************************************************************************

  SUBROUTINE RFLU_SetRindStateSlipWallPerf(cpGas,mmGas,nx,ny,nz,rl,rul,rvl, &
                                           rwl,fs,pl)
 
    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================  
!   Arguments 
! ==============================================================================  

    REAL(RFREAL), INTENT(IN) :: cpGas,fs,mmGas,nx,ny,nz,rl,rul,rvl,rwl
    REAL(RFREAL), INTENT(INOUT) :: pl

! ==============================================================================  
!   Locals 
! ==============================================================================  

    REAL(RFREAL) :: al,gGas,irl,ql,rGas,term,ul,vl,wl    
          
! ******************************************************************************
!   Compute wall pressure
! ******************************************************************************

    rGas = MixtPerf_R_M(mmGas)
    gGas = MixtPerf_G_CpR(cpGas,rGas)
 
    irl = 1.0_RFREAL/rl          
    ul  = irl*rul
    vl  = irl*rvl
    wl  = irl*rwl 
    ql  = ul*nx + vl*ny + wl*nz - fs
 
    al  = MixtPerf_C_DGP(rl,gGas,pl)

    IF ( ql < 0.0_RFREAL ) THEN           
      term = 1.0_RFREAL + 0.5_RFREAL*(gGas-1.0_RFREAL)*ql/al          
      pl   = pl*term**(2.0_RFREAL*gGas/(gGas-1.0_RFREAL))
    ELSE 
      term = (gGas+1.0_RFREAL)/4.0_RFREAL
      pl   = pl + term*rl*ql*(ql + SQRT(al*al + term*term*ql*ql)/term)
    END IF ! ql
 
! ******************************************************************************
!   End
! ******************************************************************************

  END SUBROUTINE RFLU_SetRindStateSlipWallPerf

! ******************************************************************************
!
! Purpose: Set rind state for slip-wall boundaries and perfect gas.
!
! Description: None.
!
! Input:
!   pRegion
!   cpGas       Specific heat at constant pressure
!   mmGas       Molecular mass
!   nx,ny,nz    Components of unit normal vector
!   rl          Density
!   rul         x-momentum component
!   rvl         y-momentum component
!   rwl         z-momentum component
!   fs          Grid speed
!   pl          Pressure
!   Y           Explosive Mass Fraction
!
! Output:
!   pl          Pressure
!
! Notes:
!   1. Valid only for mixture of perfect gas and explosive product governed by
!   JWL EOS.
!
! ******************************************************************************

  SUBROUTINE RFLU_SetRindStateSlipWallJWL(pRegion,c1,cpGas,mmGas, &
                  nx,ny,nz,rl,rul,rvl,rwl,fs,Y,pl)

    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================
!   Arguments
! ==============================================================================

    TYPE(t_region), POINTER :: pRegion
    INTEGER :: c1
    REAL(RFREAL), INTENT(IN) :: cpGas,fs,mmGas,nx,ny,nz,rl,rul,rvl,rwl,Y
    REAL(RFREAL), INTENT(INOUT) :: pl

! ==============================================================================
!   Locals
! ==============================================================================

    REAL(RFREAL) :: al,gGas,irl,ql,rGas,term,ul,vl,wl,e,T,rldum
        
! ******************************************************************************
!   Compute wall pressure
! *******************************

    rGas = MixtPerf_R_M(mmGas)
    gGas = MixtPerf_G_CpR(cpGas,rGas)

    irl = 1.0_RFREAL/rl
    ul  = irl*rul
    vl  = irl*rvl
    wl  = irl*rwl
    ql  = ul*nx + vl*ny + wl*nz - fs

        rldum  = rl/(1.0_RFREAL - pRegion%mixt%piclVF(c1))
    CALL RFLU_JWL_ComputeEnergyMixt(pRegion,c1,gGas,rGas,pl,rldum,Y,al,e,T)

    IF ( ql < 0.0_RFREAL ) THEN
      term = 1.0_RFREAL + 0.5_RFREAL*(gGas-1.0_RFREAL)*ql/al
      pl   = pl*term**(2.0_RFREAL*gGas/(gGas-1.0_RFREAL))
    ELSE
      term = (gGas+1.0_RFREAL)/4.0_RFREAL
      pl   = pl + term*rl*ql*(ql + SQRT(al*al + term*term*ql*ql)/term)
    END IF ! ql

! ******************************************************************************
!   End
! ******************************************************************************

  END SUBROUTINE RFLU_SetRindStateSlipWallJWL


! ******************************************************************************
!
! Purpose: Set rind state for slip-wall boundaries and perfect gas. 
!          New implementation
!
! Description: None.
!
! Input:
!   cpGas       Specific heat at constant pressure
!   mmGas       Molecular mass
!   nx,ny,nz    Components of unit normal vector
!   h           distance of cell center from ghost cell
!   rl          Density at cell center
!   u           x-velocity at wall
!   v           y-velocity at wall
!   w           z-velocity at wall
!   fs          Grid speed
!   pl          Pressure at cell center
!
! Output: 
!   rg          Density at ghost cell
!   pg          Pressure at ghost cell
!
! Notes: 
!   1. Valid only for thermally and calorically perfect gas.
!
! ******************************************************************************

  SUBROUTINE RFLU_SetRindStateSlipWallPerf1(cpGas,mmGas,nx,ny,nz,h,rl,u,v,w, &
                                            fs,pl,rg,pg)
 
    IMPLICIT NONE

! ******************************************************************************
!   Declarations and definitions
! ******************************************************************************

! ==============================================================================  
!   Arguments 
! ==============================================================================  

    REAL(RFREAL), INTENT(IN) :: cpGas,fs,h,mmGas,nx,ny,nz,u,v,w,pl,rl
    REAL(RFREAL), INTENT(OUT) :: pg,rg

! ==============================================================================  
!   Locals 
! ==============================================================================  

    REAL(RFREAL) :: A,B,convergence,gGas,irl,p_w,Radius,rGas,rho_w,tolerance, &
                    ul,vel2_w,vel_normal,vl,wl    
          
! ******************************************************************************
!   Compute wall pressure
! ******************************************************************************

    rGas = MixtPerf_R_M(mmGas)
    gGas = MixtPerf_G_CpR(cpGas,rGas)
 
    vel_normal = u*nx + v*ny + w*nz

    ! parallel (slip) velocity squared
    vel2_w = (u*u + v*v + w*w) - vel_normal**2.0_RFREAL

    ! compute coefficients
    Radius = 0.006125_RFREAL

    pg = pl - h*rl*vel2_w/Radius
    rg = rl*(pg/pl)**(1.0_RFREAL/rGas)

! TEMPORARY 
!    ! compute coefficients
!    Radius = 0.006125_RFREAL
!    A = vel2_w*h*(rl**gGas)/(Radius*pl)
!    B = rl**gGas
!
!    ! set parameters
!    tolerance = 1E-14_RFREAL
!
!    ! initial guess for wall density
!    rho_w = rl 
! 
!    convergence = evaluate_function(A,B,gGas,rho_w)
!
!    DO WHILE ( convergence .GT. tolerance )
!      rho_w = rho_w - evaluate_function(A,B,gGas,rho_w) &
!                     /evaluate_dfunction(A,B,gGas,rho_w)
! 
!      convergence = evaluate_function(A,B,gGas,rho_w)
!    END DO
!
!    ! obtain pressure from wall density
!    p_w = pl - rho_w*vel2_w*h/Radius
!
!    ! set rl,p1 equal to rho_w,p_w as rl,pl are used in caller subroutine
!    rg = rho_w
!    pg = p_w
! END TEMPORARY
! ******************************************************************************
!   End
! ******************************************************************************

  END SUBROUTINE RFLU_SetRindStateSlipWallPerf1




END MODULE RFLU_ModRindStates

! ******************************************************************************
!
! RCS Revision history:
!
! $Log: RFLU_ModRindStates.F90,v $
! Revision 1.2  2016/02/04 19:58:58  fred
! Adding iterative JWL EOS capabilities for the cylindrical detonation case
!
! Revision 1.1.1.1  2015/01/23 22:57:50  tbanerjee
! merged rocflu micro and macro
!
! Revision 1.1.1.1  2014/07/15 14:31:36  brollin
! New Stable version
!
! Revision 1.5  2008/12/06 08:43:45  mtcampbe
! Updated license.
!
! Revision 1.4  2008/11/19 22:16:57  mtcampbe
! Added Illinois Open Source License/Copyright
!
! Revision 1.3  2007/06/18 18:31:32  mparmar
! Fixed comments
!
! Revision 1.2  2007/06/18 18:03:26  mparmar
! Added subroutines for implementation of curvature corrected slipwall BC
!
! Revision 1.1  2007/04/09 18:49:26  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.1  2007/04/09 18:00:42  haselbac
! Initial revision after split from RocfloMP
!
! Revision 1.4  2006/04/07 15:19:20  haselbac
! Removed tabs
!
! Revision 1.3  2004/12/27 23:29:50  haselbac
! Added setting of rind state for farf bc
!
! Revision 1.2  2004/10/19 19:28:31  haselbac
! Added procedure to set rind state for injecting boundaries
!
! Revision 1.1  2004/04/14 02:05:11  haselbac
! Initial revision
!
! ******************************************************************************

