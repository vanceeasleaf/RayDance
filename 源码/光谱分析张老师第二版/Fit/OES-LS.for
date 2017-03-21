C******************* 	Main Program of OES-Dfit  *******************
C*         This program is used to fit the emission spectrum of 	*
C*         molecular with double atoms                            *
C******************************************************************
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
	COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),Be1,Ae1,Ge1,A1,Be2,Ae2,Ge2,A2
	COMMON/CON3/Jmax,Xcal(10),Q12(5),LVib(10),NPeak,NQ,P(50)
	COMMON/CON4/N0,Nd,Ratio,PRange
	COMMON/Gau/AA(50,50)
	double precision AA,Ysub
C****************** the second positive band of N2 ****************
C	DATA Q12/0.1330,0.2536,0.3367,0.0,0.0/	  	    !2-0 Franck-Condon因子
C	DATA Q12/0.3949,0.3413,0.2117,0.126,0.0/		!1-0 Franck-Condon因子
	DATA Q12/0.4527,0.02157,0.02348,0.08817,0.1075/ !0-0 Franck-Condon因子
C	DATA Q12/0.3291,0.2033,0.06345,0.004811,0.003908/!0-1 Franck-Condon因子
C	DATA Q12/0.1462,0.1990,0.1605,0.09426,0.04242/	!0-2 Franck-Condon因子
C	DATA Xcal/297.50,296.00,295.02,0.0,0.0,0.0,0.0,0.0,0.0,0.0/		!2-0
C	DATA Xcal/315.6,313.4,311.5,310.0,0.0,0.0,0.0,0.0,0.0,0.0/  	!1-0
	DATA Xcal/337.0,333.6,330.5,328.6,326.6,0.0,0.0,0.0,0.0,0.0/	!0-0
C      DATA Xcal/357.6,353.6,349.9,346.8,344.5,0.0,0.0,0.0,0.0,0.0/	!0-1
C	DATA Xcal/380.0,375.2,370.5,367.0,364.0,0.0,0.0,0.0,0.0,0.0/	!0-2
	     !N2第二正带的(V1,V2)振动带振动峰峰位
	DATA LVib/0,1,2,3,4,5,6,7,8,9/!上能级振动量子数
	CHARACTER FLNAME*16,Fitname*16
	REAL KB
	LM12=1				 !与第二正带有关的控制参数
	Ldt=0				 !与第二正带有关的控制参数
	N0=0				 !第二正带振动峰带头量子数
	Nd=0				 !第二正带振动峰量子数差值
	NPeak=5				 !振动峰数量
	Ifine=0				 !精细光谱输出控制
	call HONLLONDON(4,8)
	call Rotation(4,8,1.0,1.0)
	write (*,*) 'Please input file name='
	write (*,*) '输入实验数据文件名='
	read(*,*) FLNAME
	open(3,FILE=FLNAME,STATUS='OLD')
	read(3,*) NPoint			   !数据点数量
	read(3,*) (Xorg(i),Yorg(i),i=1,NPoint)
	close(3)
C****************** Initializing ******************************
	Ratio=0.5	!发光峰线性选择0-Lorentz,1-Gauss,(0,1)-Voigt
	PRange=3.0	!发光峰范围(nm)
	Jmax=85	    !最大转动能级量子数
	TStep=0.5	!收敛步长
	Err=1.0E-3	!拟合误差限制
	Nmax=30		!迭代次数限制
	P(1)=4550.0	!振动温度初值
	P(2)=450.0	!转动温度初值
	P(3)=2.0e-4	!谱仪分辨率初值
	P(4)=800	!背景噪声初值
	P(5)=0.1    !比例因子
	NQ=5
	do 40 i=1,NPeak		    	   
	   write(*,*) 'Peak',I,'=',Xcal(i)
40    P(i+NQ)=Xcal(i)				   !将振动峰峰位设置为拟合参数
      NP=NQ+NPeak					   !拟合参数个数
C******************************************************************
	call Pfit(1,NP,NPoint,Tstep,Err,Nmax)
      write(*,*) '标准方差 Error=',Err !标准方差
	write(*,*) '输入拟合结果文件名='
	read (*,*) Fitname
	open(20,FILE=Fitname,STATUS='New')
      write(20,1010) Err
	do 100 i=1,NP
         write(*,1000) i,P(i)
         write(20,1000) i,P(i)
100   continue
	do 200 i=1,NPoint
	   write(20,2000) Xorg(i),Yorg(i),Ycal(1,i)
200   continue
1000  format(2x,'Parameter',I2,'=',E12.6)
1010  format(2x,'Standard Error=',E12.6)
2000  format(3(2x,E12.6))
      if (Ifine.eq.0) goto 600
C************* Fine result simulation ************
	write(*,*) '输入精细光谱分辨率='
	read (*,*) P(3)					  !谱仪分辨率设置
	XRange=Xorg(NPoint)-Xorg(1)
	Xmin=Xorg(1)
	NPoint=Int(10.0*XRange/P(3))
	if (NPoint.gt.20000) NPoint=20000
	XStep=XRange/float(NPoint-1)
      do 400 i=1,NPoint
400   Xorg(i)=Xmin+XStep*float(i-1)
      call spectra(NPoint)
      do 500 i=1,NPoint
	   Yorg(i)=Ysub(i)
	   write(30,2000) Xorg(i),Yorg(i)
500   continue
600   continue
	pause
      stop
	end		   	    
C*************** Fitting Parameters Optimizing ****************
	SUBROUTINE Pfit(NFit,NP,NZ,Tstep,Err,Nmax)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
	COMMON/CON3/Jmax,Xcal(10),Q12(5),LVib(10),NPeak,NQ,P(50)
	COMMON/Gau/AA(50,50)
	double precision AA,Ysub
      if (Nfit.eq.1) then
	Y0sum=0.0
      do 50 j=1,NZ
50    Y0sum=Y0sum+Yorg(j)*Yorg(j)
	Niter=0
60	Niter=Niter+1
      Call PFun(NP,NZ)
	DYsum=0.0
	do 100 j=1,NZ
	   Ycal(1,j)=Ycal(1,j)-Yorg(j)
	   DYsum=DYsum+Ycal(1,j)*Ycal(1,j)
100	continue
      Error=DYsum/Y0sum
      Error=sqrt(Error/float(NZ))
	if ((Error).lt.Err) goto 300
 	write(*,1000) Niter,Error
1000	format(1x,'Iteration=',I3,'            Sigma=',F8.6)
      if (Niter.eq.Nmax) goto 300
C*********************** 构造高斯矩阵 *******************
      do 180 i=1,NP
	   do 150 j=1,NP
	      AA(i,j)=0.0
	      do 150 k=1,NZ
     		     AA(i,j)=AA(i,j)+Ycal(i+1,k)*Ycal(j+1,k)
150	   continue
	   AA(i,NP+1)=0.0
	   do 160 k=1,NZ
      	  AA(i,NP+1)=AA(i,NP+1)+Ycal(i+1,k)*Ycal(1,k)
160      continue
180   continue
	Call Gauss(NP)
	do 200 j=1,NP
	   DPJ=Tstep*AA(j,NP+1)
         P(j)=P(j)-DPJ
200   continue
      goto 60
	endif
300	Err=Error
      do 400 j=1,NZ
         Ycal(1,j)=Ycal(1,j)+Yorg(j)
400   continue
      return
	end
C*************** Optimizing Function ****************
	SUBROUTINE PFun(NFun,NZ)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
	COMMON/CON1/h0,C0,E0,KB,PI
	COMMON/CON3/Jmax,Xcal(10),Q12(5),LVib(10),NPeak,NQ,P(50)
	DIMENSION Porg(50),Y1(20000),Y2(20000)
	double precision Ysub
	DP0=0.0001
	do 50 i=1,NFun
50    Porg(i)=P(i)					    !存储拟合参数
      call Spectra(NZ) 	            	!计算发射光谱强度
	do 80 i=1,NZ
80	   Ycal(1,i)=Ysub(i)			    !存储计算的发射光谱强度
	do 300 j=1,NFun					    !拟合参数微分对光谱强度的影响
	   DP=Porg(j)*DP0
	   P(j)=Porg(j)-DP
         call Spectra(NZ)
	   do 120 i=1,NZ
120	   Y1(i)=Ysub(i)
	   P(j)=Porg(j)+DP
         call Spectra(NZ)
	   do 180 i=1,NZ
180      Y2(i)=Ysub(i)
	   do 200 i=1,NZ
	      DY12=0.5*(Y2(i)-Y1(i))/DP
200	   Ycal(j+1,i)=DY12
	   P(j)=Porg(j)
300	continue
	return
	end
C****************** This is the parameters used in fitting ****************	
      BLOCK DATA CONST
	COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),Be1,Ae1,Ge1,A1,Be2,Ae2,Ge2,A2
	REAL KB
	DATA G1/2047.178,-28.445,2.0883,-0.535/
 	DATA G2/1733.391,-14.1221,-0.05688,0.003612/
	DATA Be1,Ae1,Ge1,A1/1.82473,0.018683,-2.275e-3,39.51/	  !1.82473
	DATA Be2,Ae2,Ge2,A2/1.63745,0.017906,-7.71e-5,42.2564/
	DATA KB/1.38062E-23/,h0/6.6262E-34/,PI/3.14159265/
	DATA C0/2.997925E8/,E0/1.602192E-19/
	END
C****************** Calculation of the fitting spectra ****************	
	SUBROUTINE Spectra(NPoint)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
	COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),Be1,Ae1,Ge1,A1,Be2,Ae2,Ge2,A2
	COMMON/CON3/Jmax,Xcal(10),Q12(5),LVib(10),NPeak,NQ,P(50)
	COMMON/CON4/N0,Nd,Ratio,PRange
      COMMON/Rot1/F10(50,100),F11(50,100),F12(50,100)
      COMMON/Rot2/F20(50,100),F21(50,100),F22(50,100)
	COMMON/Hon1/SP1(5,9,100),SQ1(5,9,100),SR1(5,9,100)
	COMMON/Hon2/SP2(5,9,100),SQ2(5,9,100),SR2(5,9,100)
	COMMON/Hon3/SP3(5,9,100),SQ3(5,9,100),SR3(5,9,100)
	double precision Ysub
	real KB
	do 50 i=1,NPoint
50    Ysub(i)=0.0
	Dstep=(Xorg(NPoint)-Xorg(1))/float(NPoint-1)!数据步长估计
	NRange=PRange/DStep   	      !发光峰数据点范围
	const=h0*C0*100.0/KB
	Tvib=P(1)
	Trot=P(2)
	Doppl=7.2e-7*sqrt(Trot/28.0)  !Doppler展宽因子
	Resol=P(3)
	Qvib=0.0
	P0=1e-12					  !光谱强度控制
	do 60 i=0,5
	   V1=float(i)+0.5
	   Gup=G1(1)*V1+G1(2)*V1**2+G1(3)*V1**3+G1(4)*V1**4
	   T00=Gup*const	          !振动量子数为V1的理论振动能(温度单位)
	   Qvib=Qvib+exp(-T00/Tvib)
60	continue
	do 200 i=1,NPeak
	   N1=Lvib(N0+i)+1			  !上能级振动量子数+1
	   Jmax=85
	   if (N1.eq.1) Jmax=65		  !Predissociation
	   if (N1.eq.2) Jmax=55		  !Predissociation
	   if (N1.eq.3) Jmax=43		  !Predissociation
	   if (N1.eq.4) Jmax=28		  !Predissociation
	   N2=N1-Nd+1				  !下能级振动量子数+1
	   V1=float(N1-1)+0.5
	   V2=V1-float(Nd)
	   Gup=G1(1)*V1+G1(2)*V1**2+G1(3)*V1**3+G1(4)*V1**4
	   T00=Gup*const	          !振动量子数为V1的理论振动能(温度单位)
C******************* 发射强度计算基于麦克斯韦分布假设 *****************
         do 100 J=0,Jmax
	      Fup=F10(N1,J+1)         !上能级转动能(波数单位)
	      Tup=Fup*const	          !上能级转动能(温度单位)
	      PD=P0*Q12(I)*exp(-T00/Tvib)*exp(-Tup/Trot)/Qvib/Trot
C******************* PI0支P支发射强度计算 *****************
	      JP=J+1
	      SP=SP1(N1,N2,J+1)
		  FP=F20(N2,JP+1)         !下能级P转动能(波数单位)
	      FP12=Fup-FP			  !上下能级转动能量差
	      WP=1.0E7/P(I+NQ)+FP12	  !计算P支发射光谱波数
	      WLP=1.0E7/WP			  !计算P支发射光谱波长(单位nm)
	      PP=WP**4*PD*SP	      !计算发射强度
	      NWL=int((WLP-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLP,Imin,Imax,PP,Doppl)
C******************* PI0支R支发射强度计算 *****************
	      JR=J-1
	      if (JR.GE.0) then
	      SR=SR1(N1,N2,J+1)
	      FR=F20(N2,JR+1)		  !下能级R转动能(波数单位)
	      FR12=Fup-FR			  !上下能级转动能量差
	      WR=1.0E7/P(I+NQ)+FR12	  !计算R支发射光谱波数
	      WLR=1.0E7/WR			  !计算R支发射光谱波长(单位nm)
	      PR=WR**4*PD*SR	      !计算发射强度
	      NWL=int((WLR-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLR,Imin,Imax,PR,Doppl)
	      endif
100      continue
         do 120 J=1,Jmax
	      Fup=F11(N1,J+1)         !上能级转动能(波数单位)
	      Tup=Fup*const	          !上能级转动能(温度单位)
	      PD=P0*Q12(I)*exp(-T00/Tvib)*exp(-Tup/Trot)/Qvib/Trot
C******************* PI1支P支发射强度计算 *****************
	      JP=J+1
	      SP=SP2(N1,N2,J+1)
		  FP=F21(N2,JP+1)         !下能级P转动能(波数单位)
	      FP12=Fup-FP			  !上下能级转动能量差
	      WP=1.0E7/P(I+NQ)+FP12	  !计算P支发射光谱波数
	      WLP=1.0E7/WP			  !计算P支发射光谱波长(单位nm)
	      PP=WP**4*PD*SP	      !计算发射强度
	      NWL=int((WLP-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLP,Imin,Imax,PP,Doppl)
C******************* PI1支Q支发射强度计算 *****************
	      JQ=J
	      SQ=SQ2(N1,N2,J+1)
		  FQ=F21(N2,JQ+1)         !下能级Q转动能(波数单位)
	      FQ12=Fup-FQ			  !上下能级转动能量差
	      WQ=1.0E7/P(I+NQ)+FQ12	  !计算Q支发射光谱波数
	      WLQ=1.0E7/WQ			  !计算Q支发射光谱波长(单位nm)
	      PP=WP**4*PD*SP	      !计算发射强度
	      NWL=int((WLQ-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLQ,Imin,Imax,PQ,Doppl)
C******************* PI1支R支发射强度计算 *****************
	      JR=J-1
	      if (JR.GE.1) then
	      SR=SR2(N1,N2,J+1)
	      FR=F21(N2,JR+1)		  !下能级R转动能(波数单位)
	      FR12=Fup-FR			  !上下能级转动能量差
	      WR=1.0E7/P(I+NQ)+FR12	  !计算R支发射光谱波数
	      WLR=1.0E7/WR			  !计算R支发射光谱波长(单位nm)
	      PR=WR**4*PD*SR	      !计算发射强度
	      NWL=int((WLR-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLR,Imin,Imax,PR,Doppl)
	      endif
120      continue
         do 150 J=2,Jmax
	      Fup=F12(N1,J+1)         !上能级转动能(波数单位)
	      Tup=Fup*const	          !上能级转动能(温度单位)
	      PD=P0*Q12(I)*exp(-T00/Tvib)*exp(-Tup/Trot)/Qvib/Trot
C******************* PI2支P支发射强度计算 *****************
	      JP=J+1
	      SP=SP3(N1,N2,J+1)
		  FP=F22(N2,JP+1)         !下能级P转动能(波数单位)
	      FP12=Fup-FP			  !上下能级转动能量差
	      WP=1.0E7/P(I+NQ)+FP12	  !计算P支发射光谱波数
	      WLP=1.0E7/WP			  !计算P支发射光谱波长(单位nm)
	      PP=WP**4*PD*SP	      !计算发射强度
	      NWL=int((WLP-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLP,Imin,Imax,PP,Doppl)
C******************* PI2支Q支发射强度计算 *****************
	      JQ=J
	      SQ=SQ3(N1,N2,J+1)
		  FQ=F22(N2,JQ+1)         !下能级Q转动能(波数单位)
	      FQ12=Fup-FQ			  !上下能级转动能量差
	      WQ=1.0E7/P(I+NQ)+FQ12	  !计算Q支发射光谱波数
	      WLQ=1.0E7/WQ			  !计算Q支发射光谱波长(单位nm)
	      PP=WP**4*PD*SP	      !计算发射强度
	      NWL=int((WLQ-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLQ,Imin,Imax,PQ,Doppl)
C******************* PI2支R支发射强度计算 *****************
	      JR=J-1
	      if (JR.GE.2) then
	      SR=SR3(N1,N2,J+1)
	      FR=F22(N2,JR+1)		  !下能级R转动能(波数单位)
	      FR12=Fup-FR			  !上下能级转动能量差
	      WR=1.0E7/P(I+NQ)+FR12	  !计算R支发射光谱波数
	      WLR=1.0E7/WR			  !计算R支发射光谱波长(单位nm)
	      PR=WR**4*PD*SR	      !计算发射强度
	      NWL=int((WLR-Xorg(1))/Dstep+0.5)+1 !计算发射光谱中心波长位置
	      Imin=NWL-NRange
	      Imax=NWL+NRange
	      if (Imin.lt.1) Imin=1
	      if (Imax.gt.NPoint) Imax=NPoint
	      call FPeak(Resol,WLR,Imin,Imax,PR,Doppl)
	      endif
150      continue
200   continue
	do 300 i=1,NPoint
300   Ysub(i)=Ysub(i)*P(5)+P(4)
	return
	end
C******************** Voigt Function for Peak ******************
      SUBROUTINE FPeak(Resol,WL,Imin,Imax,PT,Doppl)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
	COMMON/CON1/h0,C0,E0,KB,PI
	double precision Ysub
	REAL KB
	Para=log(16.0)
	Wdopp=Doppl*WL
 	Whalf=Resol*WL+Wdopp
	Ratio=Wdopp/Whalf
	Wgauss=Ratio*sqrt(Para/PI)/Whalf  !Gauss函数系数
      do 100 i=Imin,Imax
	   XX=Xorg(i)
	   DX=-Para*((XX-WL)/Whalf)**2
	   Ysub(i)=Ysub(i)+Wgauss*PT*exp(DX)
100	continue
	WLorentz=(1.0-Ratio)*2.0*Whalf/PI     !Lorentz函数系数
      do 120 i=Imin,Imax
	   XX=Xorg(i)
	   DX=4.0*(XX-WL)**2+Whalf**2
	   Ysub(i)=Ysub(i)+WLorentz*PT/DX
120	continue
	return
	end
C****************** Calculation of rotational energy ****************	
	SUBROUTINE Rotation(Lvib1,Lvib2,Rl1,Rl2)
      COMMON/CON2/G1(4),G2(4),Be1,Ae1,Ge1,A1,Be2,Ae2,Ge2,A2
      COMMON/Rot1/F10(50,100),F11(50,100),F12(50,100)
      COMMON/Rot2/F20(50,100),F21(50,100),F22(50,100)
 	W01=G1(1)
 	W02=G2(1)
	do 120 i=0,Lvib1
	   V1=float(i)+0.5
C	   Av1=Ae1-0.00228*V1**2+0.000733*V1**3-0.00015*V1**4
	   B1=Be1-Ae1*V1+Ge1*V1**2				   !Bv
C	   B1=1.82682-0.0243*V1+0.00192*V1**2-0.00062*V1**3
C 	   D1=4.0*B1**3/W01**2					   !Dv
C	   DB=8.0*G1(2)/G1(1)-3.0*Ae1/Be1-Ae1**2*G1(1)/Be1**3/24.0
C	   H1=2.0*D1*(12.0*Be1**2-Ae1*G1(1))/3.0/G1(1)**3  !Hv
C	   D1=D1*(1.0+DB*(V1+0.5))				   !Dv
	   D1=(0.5112+0.222*V1-0.139*V1**2+0.024*V1**3)*1e-5
	   Y1=(A1-0.692*V1+0.111*V1**2-0.041*V1**3)/B1 !A随振动能级增加而减小
         do 100 J=0,99
	      RJ=float(J)
		  FJ=float(J*(J+1))
C		  if (RJ.GT.Rl1-1.0) then
		     ZA1=Rl1**2*Y1*(Y1-4.0)+4.0/3.0+4.0*FJ
	         ZB1=(Rl1**2*Y1*(Y1-1.0)-4.0/9.0-2.0*FJ)/3.0/ZA1
	         F1=B1*(FJ-sqrt(ZA1)-2.0*ZB1)-D1*(RJ-0.5)**4 !上0转动能(波数单位)
	         F2=B1*(FJ+4.0*ZB1)-D1*(RJ+0.5)**4			 !上1转动能(波数单位)
	         F3=B1*(FJ+sqrt(ZA1)-2.0*ZB1)-D1*(RJ+1.5)**4 !上2转动能(波数单位)
C	         F10(I+1,J+1)=F1+H1*FJ**3		   !注意数组编号比量子数+1
C	         F11(I+1,J+1)=F2+H1*FJ**3		   !注意数组编号比量子数+1
C	         F12(I+1,J+1)=F3+H1*FJ**3		   !注意数组编号比量子数+1
	         F10(I+1,J+1)=F1		   !注意数组编号比量子数+1
	         F11(I+1,J+1)=F2		   !注意数组编号比量子数+1
	         F12(I+1,J+1)=F3		   !注意数组编号比量子数+1
C	      endif
100	   continue
120	continue
	do 220 i=0,Lvib2
	   V2=float(i)+0.5
	   B2=Be2-Ae2*V2+Ge2*V2**2
C	 B2=1.637698-0.017861*V2-0.000144*V2**2+1.05e-5*V2**3-4.2e-6*V2**4
C	   D2=4.0*B2**3/W02**2
C	   DB=8.0*G2(2)/G2(1)-3.0*Ae2/Be2-Ae2**2*G2(1)/Be2**3/24.0
C	   H2=2.0*D2*(12.0*Be2**2-Ae2*G2(1))/3.0/G2(1)**3
C	   D2=D2*(1.0+DB*(V2+0.5))
	   D2=(0.5888+0.001312*V2)*1e-5
	   Y2=(A2-0.0453*V2-0.00107*V2**2-1.34e-4)/B2	!A随振动能级增加而减小
         do 200 J=0,99
	      RJ=float(J)
	      FJ=float(J*(J+1))
C		  if (RJ.GT.Rl2-1.0) then
		     ZA2=Rl2**2*Y2*(Y2-4.0)+4.0/3.0+4.0*FJ
	         ZB2=(Rl2**2*Y2*(Y2-1.0)-4.0/9.0-2.0*FJ)/3.0/ZA2
	         F1=B2*(FJ-sqrt(ZA2)-2.0*ZB2)-D2*(RJ-0.5)**4 !下0转动能
	         F2=B2*(FJ+4.0*ZB2)-D2*(RJ+0.5)**4  		 !下1转动能
	         F3=B2*(FJ+sqrt(ZA2)-2.0*ZB2)-D2*(RJ+1.5)**4 !下2转动能
C	         F20(I+1,J+1)=F1+H2*FJ**3
C	         F21(I+1,J+1)=F2+H2*FJ**3
C	         F22(I+1,J+1)=F3+H2*FJ**3
	         F20(I+1,J+1)=F1
	         F21(I+1,J+1)=F2
	         F22(I+1,J+1)=F3
C	      endif
200	   continue
220	continue
      return
	end
C*************  Calculation of Honl-London Parameters ***********
      SUBROUTINE HONLLONDON(Lvib1,Lvib2)
      COMMON/CON2/G1(4),G2(4),Be1,Ae1,Ge1,A1,Be2,Ae2,Ge2,A2
	COMMON/Hon1/SP1(5,9,100),SQ1(5,9,100),SR1(5,9,100)
	COMMON/Hon2/SP2(5,9,100),SQ2(5,9,100),SR2(5,9,100)
	COMMON/Hon3/SP3(5,9,100),SQ3(5,9,100),SR3(5,9,100)
	DIMENSION C11(100),C12(100),C13(100),C21(100),C22(100),C23(100)
	DIMENSION Up1(100),Uq1(100),Up2(100),Uq2(100)
	DIMENSION Wp1(100),Wq1(100),Wp2(100),Wq2(100)
	do 600 i1=0,Lvib1
	   V1=float(i1)+0.5
	   B1=Be1-Ae1*V1+Ge1*V1**2
	   Y1=A1/B1
	   do 600 i2=0,Lvib2
	      V2=float(i2)+0.5
	      B2=Be2-Ae2*V2+Ge2*V2**2
	      Y2=A2/B2
	      do 100 J=0,96
	         G=float(J)
			 u01=sqrt(Y1*(Y1-4.0)+4.0*G*G)
	         u02=sqrt(Y2*(Y2-4.0)+4.0*G*G)
	         w01=sqrt(Y1*(Y1-4.0)+4.0*(G+1)*(G+1))
	         w02=sqrt(Y2*(Y2-4.0)+4.0*(G+1)*(G+1))
	         Up1(J+1)=u01+(Y1-2.0)
	         Uq1(J+1)=u01-(Y1-2.0)
	         Up2(J+1)=u02+(Y2-2.0)
	         Uq2(J+1)=u02-(Y2-2.0)
	         Wp1(J+1)=w01+(Y1-2.0)
	         Wq1(J+1)=w01-(Y1-2.0)
	         Wp2(J+1)=w02+(Y2-2.0)
	         Wq2(J+1)=w02-(Y2-2.0)
	         C11(J+1)=Y1*(Y1-4)+2*(G+G+1)*(G-1)
	         C12(J+1)=Y1*(Y1-4)+4*G*(G+1)
	         C13(J+1)=Y1*(Y1-4)*(G-1)*(G+2)+2*(G+G+1)*G*(G+1)*(G+2)
	         C21(J+1)=Y2*(Y2-4)+2*(G+G+1)*(G-1)
	         C22(J+1)=Y2*(Y2-4)+4*G*(G+1)
	         C23(J+1)=Y2*(Y2-4)*(G-1)*(G+2)+2*(G+G+1)*G*(G+1)*(G+2)
100		  continue
            do 200 J=0,90
	         H=float(J)
C*************  Calculation of PI0 ********************
			 G=H+1.0								 !J2=J1+1
			 I=J+1									 !J2=J1+1
			 A=8.0*(G-2)*(G-1)*G*(G+1)
	         B=(G-2)*(G+2)*Uq1(I)*Uq2(I+1)
	         C=G*G*Up1(I)*Up2(I+1)
	         if (J.GE.0) then						  
			    D=1.0/16.0/G**3/C11(I)/C21(I+1)
	            SP1(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
			 else
	            SP1(i1+1,i2+1,J+1)=0.0
	         endif
C			 G=H								     !J2=J1
C			 I=J									 !J2=J1
C			 A=4.0*(G-1)*(G+1)*(G+1)
C	         B=(G+2)*Uq1(J+1)*Uq2(J+1)
C	         C=0.0
C	         if (J.GE.0) then
C	            D=(G-1)**2*(G+G+1)/4.0/G**3/(G+1)**3/C11(J+1)/C21(J+1)
C	            SQ1(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
C			 else
C	            SQ1(i1+1,i2+1,J+1)=0.0
C	         endif
			 G=H-1.0								 !J2=J1-1
			 I=J-1									 !J2=J1-1
			 A=8.0*(G-1)*G*(G+1)*(G+2)
	         B=(G-1)*(G+3)*Uq1(I+2)*Uq2(I+1)
	         C=(G+1)*(G+1)*Up1(I+2)*Up2(I+1)
	         if (J.GE.1) then
			    D=1.0/16.0/(G+1)**3/C11(I+2)/C21(I+1)
	            SR1(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
	         else
	            SR1(i1+1,i2+1,J+1)=0.0
			 endif 
C*************  Calculation of PI1 ********************
			 G=H+1.0								 !J2=J1+1
			 I=J+1									 !J2=J1+1
			 A=(Y1-2)*(Y2-2)
	         B=2.0*(G-2)*(G+2)
	         C=2.0*G*G
	         if (J.GE.1) then
	            D=(G-1)*(G+1)/G/C12(I)/C22(I+1)
	            SP2(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
			 else
	            SP2(i1+1,i2+1,J+1)=0.0
	         endif
			 G=H     								 !J2=J1+1
			 I=J									 !J2=J1+1
			 A=(Y1-2)*(Y2-2)
	         B=4.0*(G-1)*(G+2)
	         C=0.0
	         if (J.GE.1) then
	            D=(G+G+1)/G/(G+1)/C12(J+1)/C22(J+1)
	            SQ2(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
			 else
	            SQ2(i1+1,i2+1,J+1)=0.0
	         endif
			 G=H-1.0								 !J2=J1-1
			 I=J-1									 !J2=J1-1
			 A=(Y1-2)*(Y2-2)
	         B=2.0*(G-1)*(G+3)
	         C=2.0*(G+1)*(G+1)
	         if (J.GE.2) then
	            D=G*(G+2)/(G+1)/C12(I+2)/C22(I+1)
	            SR2(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
	         else
	            SR2(i1+1,i2+1,J+1)=0.0
	         endif
C*************  Calculation of PI2 ********************
			 G=H+1.0								 !J2=J1+1
			 I=J+1									 !J2=J1+1
			 A=8.0*(G-1)*G*(G+1)*(G+2)
	         B=(G-2)*(G+2)*Wp1(I)*Wp2(I+1)
	         C=G*G*Wq1(I)*Wq2(I+1)
	         if (J.GE.2) then
	            D=(G-1)*(G+1)/16.0/G/C13(I)/C23(I+1)
	            SP3(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
			 else
	            SP3(i1+1,i2+1,J+1)=0.0
	         endif
			 G=H    								 !J2=J1+1
			 I=J									 !J2=J1+1
			 A=4.0*G*G*(G+2)
	         B=(G-1)*Wp1(J+1)*Wp2(J+1)
	         C=0.0
	         if (J.GE.2) then
	            D=(G+2)*(G+2)*(G+G+1)/4.0/G/(G+1)/C13(J+1)/C23(J+1)
	            SQ3(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
			 else
	            SQ2(i1+1,i2+1,J+1)=0.0
	         endif
			 G=H-1.0								 !J2=J1-1
			 I=J-1									 !J2=J1-1
			 A=8.0*G*(G+1)*(G+2)*(G+3)
	         B=(G-1)*(G+3)*Wp1(I+2)*Wp2(I+1)
	         C=(G+1)*(G+1)*Wq1(I+2)*Wq2(I+1)
	         if (J.GE.3) then
	            D=G*(G+2)/16.0/(G+1)/C13(I+2)/C23(I+1)
	            SR3(i1+1,i2+1,J+1)=(A+B+C)*(A+B+C)*D
	         else
	            SR3(i1+1,i2+1,J+1)=0.0
	         endif
C	write(10,*) J,SP1(i1+1,i2+1,J+1),SR1(i1+1,i2+1,J+1)
C	RR2=SR2(i1+1,i2+1,J+1)
C	write(20,*) J,SP2(i1+1,i2+1,J+1),SQ2(i1+1,i2+1,J+1),RR2
C	RR3=SR3(i1+1,i2+1,J+1)
C	write(30,*) J,SP3(i1+1,i2+1,J+1),SQ3(i1+1,i2+1,J+1),RR3
200         continue
600	continue
 	return
	end
C*************** Gauss Eqution Soluting ****************
	SUBROUTINE Gauss(NP)
	COMMON/Gau/A(50,50)
	double precision A
	do 100 k=1,NP
	   Amax=0.0
	   Imax=0
	   do 20 i=k,NP
	      if (abs(A(i,k)).gt.Amax) then
	         Amax=abs(A(i,k))
	         Imax=i
	      endif
20       continue
	   if (abs(Amax).lt.1.0e-32) then
	      write(*,*) '拟合参数初值设置问题'
	      write(*,*) k,k,Amax
	      Stop
	   endif
         do 30 j=k,NP+1
	      T=A(k,j)
	      A(k,j)=A(Imax,j)
30	      A(Imax,j)=T
         Amax=A(k,k)
         do 40 j=k,NP+1
40       A(k,j)=A(k,j)/Amax
	   do 50 i=k+1,NP
	      T=A(i,k)
	      do 50 j=k,NP+1
50          A(i,j)=A(i,j)-T*A(k,j)
100	continue
      do 200 k=NP,1,-1
	   T=A(k,NP+1)
	   do 210 i=k-1,1,-1
210	   A(i,NP+1)=A(i,NP+1)-T*A(i,k)
200   continue
      return
	end
						  	 		     