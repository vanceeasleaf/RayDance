!************** 计算中的常量 *************
  Module parmt
   ! implicit none
	public                   !默认模块中的变量为公共变量  
  real :: q(0:10,0:10),SP(0:100),SQ(0:100),SR(0:100)                  !Frank-Condon因子和Honnel_London因子
  real :: G1(0:10),G2(0:10),D(0:10),F1(0:5,0:100),F2(0:5,0:100)        !振动谱项和转动谱项
  real :: B1(0:5),B2(0:5)
  real :: It(20000),Wave(20000),T(20000)                               !光强和波长
  real*8 :: h,k,c,Pi,K0                                                !常量
  real :: Te1,Te2,We1,We2,Wx1,Wx2,Be1,Be2,ae1,ae2
  real :: wvir(50)
  DATA Te1,Te2/89147,59626/,We1,We2/2035.1,1734.11/,Wx1,Wx2/17.08,14.47/
  DATA Be1,Be2/1.8259,1.6380/,ae1,ae2/0.0197,0.0184/
  DATA h/6.626068E-27/,k/1.3806503E-16/,c/3.0E10/,Pi/3.141592654/   !质量--g,长度--cm,时间--s
  end module
!*********** N2第二正带拟合 ******************
program N2_fitting
  use parmt            !引用常量模块
!  implicit none

  integer :: i,j,j1,j2,v,v1,v2,lam1=1,lam2=1,N,nvir,nup(100),ndown(100),nall
  real :: Ev,Ej                               !基态振动能和基态转动能
  real :: Tv,Tr                               !振动温度和转动温度
  real :: maxi,Wn,In,wave1,wave2,detaw
  real :: I0,Whale                            !背景初值，分辨率
  real :: IP,IQ,IR
  I0=600.0
  Whalf=0.09       !分辨率
!********** 计算振动和转动谱项 ***************
  do v=0,4
    D(v)=(5.8-0.001*(v+0.5))*1.0E-6
	B1(v)=Be1-ae1*(v+0.5)
	B2(v)=Be2-ae2*(v+0.5)
  enddo
  do v=0,4
    G1(v)=We1*(v+0.5)-Wx1*(v+0.5)**2
	G2(v)=We2*(v+0.5)-Wx2*(v+0.5)**2
	do j=0,100
	  F1(v,j)=B1(v)*j*(j+1)-D(v)*j*j*(j+1)*(j+1)
      F2(v,j)=B2(v)*j*(j+1)-D(v)*j*j*(j+1)*(j+1)
	enddo
  enddo
!********* 计算Honnel-London因子,读Frank-Condon因子 **************	  
  call HL(lam1,lam2)
  open(unit=10,file='frank.txt')
  do i=0,4
    read(10,*) q(i,0),q(i,1),q(i,2),q(i,3),q(i,4),q(i,5) 
  enddo
  close(10)
!**************** 计算波长和强度 *********************************
  print*,'输入波长范围:(以nm为单位)'
  read(*,*) wave1,wave2
  N=1
  Tv=4550.0
  Tr=450.0
  K0=1.0E-16
  nall=1000        !波长点数
  detaw=(wave2-wave1)/nall
  do i=0,nall    !平分波长范围
    Wave(i+1)=wave1+detaw*i
	T(i+1)=1.0E7/Wave(i+1)
  enddo
  nvir=4
  open(20,file='wvir.txt')
  do v1=0,3
    do v2=0,4
	  Wn=1.0E7/(Te1-Te2+G1(v1)-G2(v2))
	  if(v1-v2==1) then       !考虑(i,i-1)振动峰
	  !if(Wn>wave1.and.Wn<wave2) then      !选出波长范围内的振动中心带
	    wvir(nvir)=Wn
		write(20,*) 'v1=',v1,'v2=',v2,Wn
		nup(nvir)=v1
		ndown(nvir)=v2
		nvir=nvir+1
	  endif
    enddo
  enddo
  close(20)
  nvir=nvir-1   !转动中心数
!************** 计算波长点的强度 ********************
Wgauss=1.0/sqrt(PI/2.0)/Whalf  !Gauss函数系数
It=I0
do i=1,nvir
   kup=nup(i)
   kdown=ndown(i)
   Ev=h*c*(G1(kup)-G1(0))
  do j=1,nall+1
    do j1=1,30                !以振动中心算高斯型峰
	   TP=Te1-Te2+G1(kup)-G2(kdown)+F1(kup,j1)-F2(kdown,j1+1)  !振转波数
	   TQ=Te1-Te2+G1(kup)-G2(kdown)+F1(kup,j1)-F2(kdown,j1)
	   TR=Te1-Te2+G1(kup)-G2(kdown)+F1(kup,j1)-F2(kdown,j1-1)
    !do j2=0,30
	 ! if((j1/=0).OR.(j2/=0)) then
	    !if(j1-j2==1) then
		  Ej=h*c*(F1(kup,j1)-F1(kup,0))   !转动能
		  !T(N)=Te1-Te2+G1(v1)-G2(v2)+F1(v1,j1)-F2(v2,j2)
		  !Wave(N)=1.0/T(N)*1.0E7
		  IR=K0*TP**4*q(kup,kdown)*exp(-Ev/k/Tv)*SR(j1)*exp(-Ej/k/Tr)   !k的单位一统一
		  !N=N+1
		 !endif
       !if(j1-j2==0) then
	     !Ej=h*c*(F1(v1,j1)-F1(v1,0))
		 !T(N)=Te1-Te2+G1(v1)-G2(v2)+F1(v1,j1)-F2(v2,j2)
		 !Wave(N)=1.0/T(N)*1.0E7
		 IQ=K0*TQ**4*q(v1,v2)*exp(-Ev/k/Tv)*SQ(j1)*exp(-Ej/k/Tr)
		! N=N+1
	   !endif
	   !if(j1-j2==-1) then
	     !Ej=h*c*(F1(v1,j1)-F1(v1,0))
		 !T(N)=Te1-Te2+G1(v1)-G2(v2)+F1(v1,j1)-F2(v2,j2)
		 !Wave(N)=1.0/T(N)*1.0E7
		 IP=K0*TP**4*q(v1,v2)*exp(-Ev/k/Tv)*SP(j1)*exp(-Ej/k/Tr)
		 WLP=1.0E7/TP
		 WLQ=1.0E7/TQ
		 WLR=1.0E7/TR
		 XX=Wave(j)
	     DXP=-2.0*((XX-WLP)/Whalf)**2
	     DXQ=-2.0*((XX-WLQ)/Whalf)**2
	     DXR=-2.0*((XX-WLR)/Whalf)**2
		 It(j)=It(j)+Wgauss*(IP*exp(DXP)+IQ*exp(DXQ)+IR*exp(DXR)) !计算光强(P,Q,R支的光强贡献之和)
		 !N=N+1
	   !endif
	  !endif
	enddo
  enddo
enddo
 ! read(*,*)
 ! N=N-1
 ! write(*,*) N
 ! call arrange(Wave(1:N),It(1:N))
  !maxi=maxval(It(1:N))
  open(unit=100,file='cal.txt')
    do i=1,nall
	  !if(It(i)>maxi*1.0E-5) then
	  write(100,*) Wave(i),It(i)
	  !endif
	enddo
  close(100)
		  

  CONTAINS
!********** Calculation of HONNEL-LONDON factor ******************
  subroutine HL(lamda1,lamda2)
  use parmt            !引用常量模块
!  implicit none
  INTEGER :: lamda1,lamda2         !电子轨道量子数
  REAL :: j1                       !初态转动能级
  do j1=1,100
  if(lamda1==lamda2) then
	SR(j1)=(j1+lamda1)*(j1-lamda1)/j1
	SQ(j1)=(2*j1+1)*lamda1*lamda1/j1/(j1+1)
	SP(j1)=(j1+1+lamda1)*(j1+1-lamda1)/(j1+1)

	elseif((lamda1-lamda2)==1) then
    SR(j1)=(j1+lamda1)*(j1-1+lamda1)/(4*j1)
	SQ(j1)=(j1+lamda1)*(j1+1-lamda1)*(2*j1+1)/(4*j1)/(j1+1)
	SP(j1)=(j1+1-lamda1)*(j1+2-lamda1)/4.0/(j1+1)

	elseif((lamda2-lamda1)==1) then
	SR(j1)=(j1+1-lamda1)*(j1-1-lamda1)/(4*j1)
    SQ(j1)=(j1-lamda1)*(j1+1+lamda1)*(2*j1+1)/(4*j1)/(j1+1)
	SP(j1)=(j1+1+lamda1)*(j1+2+lamda1)/4.0/(j1+1)

	else 
    SR(j1)=0.0
	SQ(j1)=0.0
	SP(j1)=0.0
  endif
  enddo
end subroutine

!******以第一个数组(a)为基准，将a,b从小到大排列******
  subroutine arrange(a,b)
!  implicit none
  real :: a(:),b(:)
  real :: ta,tb,min
  integer :: n1,n2,i,j

  n1=size(a)
  n2=size(b)
  if(n1/=n2) then
    stop 'The size of a and b do not match!'
  endif
  min=a(1)
  do i=1,n1
    do j=i+1,n1
	  if(a(i)>a(j)) then
	    ta=a(i)
		a(i)=a(j)
		a(j)=ta
		tb=b(i)
		b(i)=b(j)
		b(j)=tb
		endif
	enddo
  enddo
  end subroutine
end program N2_fitting
  
   
