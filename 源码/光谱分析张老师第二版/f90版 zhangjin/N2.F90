Module DT
  public
real*8 :: Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
real :: h0,C0,E0,KB,PI
real :: G1(4),G2(4),B1(5),B2(5),Ve,Q12(5)
real :: Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50) !P(50):拟合参数;NPeak:峰数;Xcal:振动峰位;
real :: SP0(100),SQ0(100),SR0(100)
real*8 :: AA(50,50)
CHARACTER FLNAME*16,Fitname*16
DATA Xcal/315.65,313.44,311.52,310.07,0.0,0.0,0.0,0.0,0.0,0.0/
	     !N2第二正带的(i,i-1)振动带振动峰峰位
DATA LVib/1,2,3,4,0,0,0,0,0,0/!上能级振动量子数
DATA G1/2047.178,-28.445,2.0883,-0.535/
DATA G2/1733.391,-14.1221,-0.05688,0.003612/
DATA B1/1.8154,1.7933,1.7694,1.7404,1.6999/
DATA B2/1.6285,1.6285,1.6105,1.5922,1.5737/
DATA Q12/0.4527,0.3949,0.3413,0.2117,0.126/
DATA Ve/29671.03/
DATA KB/1.38062E-23/,h0/6.6262E-34/,PI/3.14159265/
DATA C0/2.997925E8/,E0/1.602192E-19/
end Module
!******************* 主程序 *******************
program fitting
  use DT

  !write (*,*) 'Please input file name='
  !write (*,*) '输入实验数据文件名='
 ! read(*,*) FLNAME
  FLNAME="d:\t25hz.txt"
  NPeak=4						   !振动峰数量
  open(3,FILE=FLNAME,STATUS='OLD')
  read(3,*) NPoint			       !数据点数量
  read(3,*) (Xorg(i),Yorg(i),i=1,NPoint)
  close(3)
!****************** Initializing ******************************
	Ishape=2					   !发光峰线性选择0-Lorentz,1-Gauss,2-Voigt
	Jmax=30	     				   !最大转动能级量子数
	WA=Xorg(1)					   !最小波长
	WB=Xorg(NPoint)				   !最大波长
	TStep=0.3					   !收敛步长
	Err=1.0E-3					   !拟合误差限制
	Nmax=50					       !迭代次数限制
	P(1)=4550.0					   !振动温度初值
	P(2)=450.0					   !转动温度初值
	P(3)=0.09					   !谱仪分辨率初值
	P(4)=600					   !背景噪声初值
	P(5)=2.0                       !比例因子
	NQ=5
	do i=1,NPeak		    	   
	   write(*,*) 'Peak',I,'=',Xcal(i)
       P(i+NQ)=Xcal(i)				   !将振动峰峰位设置为拟合参数
    enddo
	NP=NQ+NPeak				   !拟合参数个数
!****************** the second positive band of N2 ****************
	LM12=1
	Ldt=0
	call HONLLONDON(LM12,Ldt)
!****************** 函数拟合以及输出 ****************

  call Pfit(1,NP,NPoint,Tstep,Err,Nmax,Ishape)
    write(*,*) '标准方差 Error=',Err            !标准方差
	write(*,*) '输入拟合结果文件名='
	read (*,*) Fitname

	open(20,FILE=Fitname,STATUS='New')
    write(20,1010) Err
	do j=1,NP
         write(*,1000) j,P(j)   !分别向屏幕和文件中输入拟合参数
         write(20,1000) j,P(j)
    enddo

1000  format(2x,'Parameter',I2,'=',E12.6)
1010  format(2x,'Standard Error=',E12.6)
!************* Fine result simulation ************
	do j=1,NPoint
	   write(20,2000) Xorg(j),Yorg(j),Ycal(1,j)
    enddo
2000  format(3(2x,E12.6))
300 continue
    P(3)=0.01             !谱仪分辨率
	XRange=Xorg(NPoint)-Xorg(1) !波长范围
	Xmin=Xorg(1)   !波长最小值
	NPoint=20000   !数据个数
	XStep=XRange/float(NPoint-1) !波长平均间距
    do i=1,NPoint
    Xorg(i)=Xmin+XStep*float(i-1)
	enddo
    call spectra(NPoint,Ishape)
    do i=1,NPoint
	   Yorg(i)=Ysub(i)
   enddo

CONTAINS
!*************** 拟合常数最优化 ****************
SUBROUTINE Pfit(NFit,NP,NZ,Tstep,Err,Nmax,Ishape)
  use DT

  if (Nfit.eq.1) then
	Y0sum=0.0
    do ja=1,NZ
      Y0sum=Y0sum+Yorg(ja)*Yorg(ja)
	enddo
	Niter=0
60	Niter=Niter+1 !notice 

    Call PFun(NP,NZ,Ishape)
	
	DYsum=0.0
	do jb=1,NZ
	   Ycal(1,jb)=Ycal(1,jb)-Yorg(jb)
	   DYsum=DYsum+Ycal(1,jb)*Ycal(1,jb)
    enddo
    Error=DYsum/Y0sum
    Error=sqrt(Error/float(NZ))
	if ((Error).lt.Err) goto 300
 	write(*,1000) Niter,Error
1000	format(1x,'Iteration=',I3,'            Sigma=',F8.6)
      if (Niter.eq.Nmax) goto 300
!*********************** 构造高斯矩阵 *******************
    do i=1,NP
	  do j=1,NP
	    AA(i,j)=0.0
	     do k=1,NZ
     		AA(i,j)=AA(i,j)+Ycal(i+1,k)*Ycal(j+1,k)
		 enddo
	  enddo
	   AA(i,NP+1)=0.0
	   do k=1,NZ
      	  AA(i,NP+1)=AA(i,NP+1)+Ycal(i+1,k)*Ycal(1,k)
       enddo
    enddo

	Call Gauss(NP)
	do j=1,NP
	   DPJ=Tstep*AA(j,NP+1)
         P(j)=P(j)-DPJ
    enddo
    goto 60  !notice
	endif
300	 Err=Error
      do j=1,NZ
         Ycal(1,j)=Ycal(1,j)+Yorg(j)
      enddo
    return
end subroutine
!*************** 最优化函数 ****************
SUBROUTINE PFun(NFun,NZ,Ishape)
  use DT

  real*8 :: Porg(50),Y1(20000),Y2(20000)
  DP0=0.0001
	do i=1,NFun
      Porg(i)=P(i)      !存储拟合参数
	enddo					  
    call Spectra(NZ,Ishape) 		  !计算发射光谱强度

	do i=1,NZ
	   Ycal(1,i)=Ysub(i)			  !存储计算的发射光谱强度
	enddo

	do j=1,NFun					      !拟合参数微分对光谱强度的影响
	   DP=Porg(j)*DP0
	   P(j)=Porg(j)-DP
       call Spectra(NZ,Ishape)
	   do i=1,NZ
	     Y1(i)=Ysub(i)
       enddo
	   P(j)=Porg(j)+DP
       call Spectra(NZ,Ishape)
	   do i=1,NZ
         Y2(i)=Ysub(i)
       enddo
	   do i=1,NZ
	      DY12=0.5*(Y2(i)-Y1(i))/DP
    	  Ycal(j+1,i)=DY12
       enddo
	   P(j)=Porg(j)

    enddo
end subroutine
!****************** 拟合光谱计算 ****************	
SUBROUTINE Spectra(NZ,Is)
  use DT

  do i=1,NZ
    Ysub(i)=0.0
  enddo

  do k=1,NPeak
	   V1=1 !Lvib(i)+0.5
	   Gup=G1(1)*V1+G1(2)*V1**2+G1(3)*V1**3+G1(4)*V1**4
	   Tup=(Gup*h0*C0*100.0)/KB	    !振动量子数为V1的理论振动能(温度单位)
	   call INTEN(k+1,Tup,NZ,Is) 	!光谱强度计算，i+1用于指定振动峰系数

  enddo
  		   	  
  do i=1,NZ
      Ysub(i)=Ysub(i)*P(5)+P(4)
  enddo
end subroutine
!*************  Honl-London 因子的计算 ***********
SUBROUTINE HONLLONDON(LM12,Ldt)
  use DT

  integer :: J
  real :: SP,SQ,SR
  do J=0,99
	if (Ldt.eq.0) then
	   SP=float((J+1+LM12)*(J+1-LM12)/(J+1))
	   if (J.gt.0) then
	      SR=float((J+LM12)*(J-LM12)/J)
	   else
	      SR=0.0
	   endif
	   if (LM12.gt.0) then
	      if (J.gt.0) then
	         SQ=float((2*J+1)*LM12*LM12/(J*(J+1)))
	      else
	         SQ=0.0
	      endif
	   else
	      SQ=0.0
	   endif
	endif
	if (Ldt.eq.1) then
	   SP=float((J+1-LM12)*(J+2-LM12)/(J+1)/4)
	   if (J.gt.0) then
	      SR=float((J+LM12)*(J-1+LM12)/J/4)
	      SQ=float((2*J+1)*(J+LM12)*(J+1-LM12)/(4*J*(J+1)))
	   else
	      SR=0.0
	      SQ=0.0
	   endif
	endif
	if (Ldt.eq.-1) then
	   SP=float((J+1+LM12)*(J+2+LM12)/(J+1)/4)
	   if (J.gt.0) then
	      SR=float((J-LM12)*(J-1-LM12)/J/4)
	      SQ=float((2*J+1)*(J-LM12)*(J+1+LM12)/(4*J*(J+1)))
	   else
	      SR=0.0
	      SQ=0.0
	   endif
	endif
	SP0(J+1)=SP
	SQ0(J+1)=SQ
	SR0(J+1)=SR
  enddo
end subroutine
!********************* 光强计算 ********************
SUBROUTINE INTEN(N,T00,NPoint,Ishape)
  use DT

  Tvib=P(1)  !振动温度
  Trot=P(2)  !转动温度
  Whalf=P(3) !谱仪分辨率
 
  G12=1.0E7/P(N-1+NQ)-Ve

  W=2.0*PI*C0*G12
  D1=4.0*B1(N)**3/W**2
  D2=4.0*B2(N)**3/W**2
      	 
  Dstep=(Xorg(NPoint)-Xorg(1))/float(NPoint-1)!数据步长估计
  NRange=1.0/DStep
 		             	    !发光峰数据点范围
  do J=0,Jmax
	   Fup=J*(J+1)*(B1(N)-D1*J*(J+1))    !上能级转动能(波数单位)
	   Tup=Fup*h0*C0*100.0/KB		     !计算转动能(温度单位)
	   FP=(J+2)*(J+1)*(B2(N)-D2*(J+2)*(J+1)) !下能级转动能(波数单位)
	   FQ=J*(J+1)*(B2(N)-D2*J*(J+1))		 !下能级转动能(波数单位)
	   FR=J*(J-1)*(B2(N)-D2*J*(J-1))		 !下能级转动能(波数单位)
	   SP=SP0(J+1)
	   SQ=SQ0(J+1)
	   SR=SR0(J+1)
	   FP12=Fup-FP					!上下能级转动能量差
	   FQ12=Fup-FQ					!上下能级转动能量差
	   FR12=Fup-FR					!上下能级转动能量差
	   WP=1.0E7/P(N-1+NQ)+FP12		!计算发射光谱波数
	   WQ=1.0E7/P(N-1+NQ)+FQ12
	   WR=1.0E7/P(N-1+NQ)+FR12
	   WLP=1.0E7/WP					!计算发射光谱波长(单位nm)
	   WLQ=1.0E7/WQ					!计算发射光谱波长(单位nm)
	   WLR=1.0E7/WR					!计算发射光谱波长(单位nm)
	   WP=1.0e-4*WP
	   WQ=1.0e-4*WQ
	   WR=1.0e-4*WR
	   PP=WP**4*Q12(N)*exp(-T00/Tvib)*SP*exp(-Tup/Trot)	!计算发射强度
	   PQ=WQ**4*Q12(N)*exp(-T00/Tvib)*SQ*exp(-Tup/Trot)	!计算发射强度
	   PR=WR**4*Q12(N)*exp(-T00/Tvib)*SR*exp(-Tup/Trot)	!计算发射强度
	NWL=int((WLQ-Xorg(1))/Dstep+0.5)+1
	Imin=NWL-NRange
	Imax=NWL+NRange
	if (Imin.lt.1) Imin=1
	if (Imax.gt.NPoint) Imax=NPoint
	if (Ishape.eq.1) then
!******************** Gauss Function for Peak ******************
	 Wgauss=1.0/sqrt(PI/2.0)/Whalf  !Gauss函数系数
    do i=Imin,Imax
	      XX=Xorg(i)
	      DXP=-2.0*((XX-WLP)/Whalf)**2
	      DXQ=-2.0*((XX-WLQ)/Whalf)**2
	      DXR=-2.0*((XX-WLR)/Whalf)**2
		  Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR))
    enddo
	else
!******************** Lorentz Function for Peak ******************

	if (Ishape.eq.0) then
	   WLorentz=2.0*Whalf/PI          !Lorentz函数系数
       do i=Imin,Imax
	      XX=Xorg(i)
	      DXP=4.0*(XX-WLP)**2+Whalf**2
	      DXQ=4.0*(XX-WLQ)**2+Whalf**2
	      DXR=4.0*(XX-WLR)**2+Whalf**2
		  Ysub(i)=Ysub(i)+WLorentz*(PP/DXP+PQ/DXQ+PR/DXR)
       enddo
	else
!******************** Voigt Function for Peak ******************
	    Ratio=0.5
	    Para=log(4.0)
	    Wgauss=Ratio*Para/sqrt(PI/2.0)/Whalf  !Gauss函数系数
        do i=Imin,Imax
	        XX=Xorg(i)
	        DXP=-2.0*Para*((XX-WLP)/Whalf)**2
	        DXQ=-2.0*Para*((XX-WLQ)/Whalf)**2
	        DXR=-2.0*Para*((XX-WLR)/Whalf)**2
		    Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR))
        enddo
	    WLorentz=(1-Ratio)*2.0*Whalf/PI          !Lorentz函数系数
        do i=Imin,Imax
	      XX=Xorg(i)
	      DXP=4.0*(XX-WLP)**2+Whalf**2
	      DXQ=4.0*(XX-WLQ)**2+Whalf**2
	      DXR=4.0*(XX-WLR)**2+Whalf**2
		  Ysub(i)=Ysub(i)+WLorentz*(PP/DXP+PQ/DXQ+PR/DXR)
        enddo
      endif
      endif
    enddo
end subroutine
!*************** Gauss Eqution Soluting ****************
SUBROUTINE Gauss(NP)
  USE DT
!解线性方程,NP为矩阵的秩
  do k=1,NP
	   Amax=0.0
	   Imax=0
	   do i=k,NP	!判断选择A的最大值A(:,k)
	      if (abs(AA(i,k)).gt.Amax) then
	         Amax=abs(AA(i,k))
	         Imax=i
	      endif
      enddo
	   if (abs(Amax).lt.1.0e-32) then
	      write(*,*) k,k,Amax
	      AA(Imax,k)=1.0
	   endif
       do j=k,NP+1
	      T=AA(k,j)
	      AA(k,j)=AA(Imax,j)
	      AA(Imax,j)=T
       enddo
       Amax=AA(k,k)
         do j=k,NP+1
           AA(k,j)=AA(k,j)/Amax
         enddo
	   do i=k+1,NP
	      T=AA(i,k)
	      do j=k,NP+1
            AA(i,j)=AA(i,j)-T*AA(k,j)
          enddo
	   enddo
  enddo
      do k=NP,1,-1
	    T=AA(k,NP+1)
	     do i=k-1,1,-1
	       AA(i,NP+1)=AA(i,NP+1)-T*AA(i,k)
          enddo
      enddo
end subroutine
  
end program fitting
