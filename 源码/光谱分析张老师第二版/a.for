C*******************  Main Program of OES-Dfit  *******************
C*         This program is used to fit the emission spectrum of  *
C*         molecular with double atoms                            *
C******************************************************************
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
 COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
 COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
 COMMON/Honl/SP0(100),SQ0(100),SR0(100)
 COMMON/Gau/AA(50,50)
 double precision AA,Ysub
 DATA Xcal/315.65,313.44,311.52,310.07,0.0,0.0,0.0,0.0,0.0,0.0/
      !N2�ڶ�������(i,i-1)�񶯴��񶯷��λ
 DATA LVib/1,2,3,4,0,0,0,0,0,0/!���ܼ���������
 CHARACTER FLNAME*16,Fitname*16
 REAL KB
 write (*,*) 'Please input file name='
 write (*,*) '����ʵ�������ļ���='
 read(*,*) FLNAME
C FLNAME='T50Hz.txt'      !�����ļ���
 NPeak=4         !�񶯷�����
 open(3,FILE=FLNAME,STATUS='OLD')
 read(3,*) NPoint      !���ݵ�����
 read(3,*) (Xorg(i),Yorg(i),i=1,NPoint)! ��������
 close(3)
C****************** Initializing ******************************
 Ishape=2        !���������ѡ��0-Lorentz,1-Gauss,2-Voigt
 Jmax=30             !���ת���ܼ�������
 WA=Xorg(1)        !��С����
 WB=Xorg(NPoint)       !��󲨳�
 TStep=0.3        !��������
 Err=1.0E-3        !����������
 Nmax=50            !������������
 P(1)=4550.0        !���¶ȳ�ֵ
 P(2)=450.0        !ת���¶ȳ�ֵ
 P(3)=0.09        !���Ƿֱ��ʳ�ֵ
 P(4)=600        !����������ֵ
 P(5)=2.0                       !��������
 NQ=5
 do 40 i=1,NPeak  !NPeak=4Ϊ�񶯷���        
    write(*,*) 'Peak',I,'=',Xcal(i)
40    P(i+NQ)=Xcal(i)       !���񶯷��λ����Ϊ��ϲ���,P(6)��P(9)
      NP=NQ+NPeak        !��ϲ�������,9
C****************** the second positive band of N2 ****************
 LM12=1
 Ldt=0
 call HONLLONDON(LM12,Ldt)!���J=0 TO 99ʱ��SP0(100),SQ0(100),SR0(100)����ֵ
C******************************************************************
 call Pfit(1,NP,NPoint,Tstep,Err,Nmax,Ishape)
      write(*,*) '��׼���� Error=',Err !��׼����
 write(*,*) '������Ͻ���ļ���='
 read (*,*) Fitname
 open(20,FILE=Fitname,STATUS='New')
      write(20,1010) Err!��д������
 do 100 i=1,NP
         write(*,1000) i,P(i)!��д��ϳ��Ĳ���,һ����ʾһ��д���ļ���
         write(20,1000) i,P(i)
100   continue
1000  format(2x,'Parameter',I2,'=',E12.6)
1010  format(2x,'Standard Error=',E12.6)
C************* Fine result simulation ************
 do 200 i=1,NPoint!д��ԭ��������ֵ
    write(20,2000) Xorg(i),Yorg(i),Ycal(1,i)
200   continue
2000  format(3(2x,E12.6))
300   continue
      P(3)=0.01
 XRange=Xorg(NPoint)-Xorg(1)
 Xmin=Xorg(1)
 NPoint=20000
 XStep=XRange/float(NPoint-1)
      do 400 i=1,NPoint
400   Xorg(i)=Xmin+XStep*float(i-1)
      call spectra(NPoint,Ishape)

      do 500 i=1,NPoint
    Yorg(i)=Ysub(i)
C    write(30,2000) Xorg(i),Yorg(i)
500   continue

 pause
      stop
 end!�������
          
C*************** Fitting Parameters Optimizing ****************
 SUBROUTINE Pfit(NFit,NP,NZ,Tstep,Err,Nmax,Ishape)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
 COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
 COMMON/Gau/AA(50,50)
 double precision AA,Ysub
      if (Nfit.eq.1) then
 Y0sum=0.0
      do 50 j=1,NZ
50    Y0sum=Y0sum+Yorg(j)*Yorg(j)
 Niter=0
60 Niter=Niter+1
      Call PFun(NP,NZ,Ishape)
 DYsum=0.0
 do 100 j=1,NZ
    Ycal(1,j)=Ycal(1,j)-Yorg(j)
    DYsum=DYsum+Ycal(1,j)*Ycal(1,j)
100 continue
      Error=DYsum/Y0sum
      Error=sqrt(Error/float(NZ))
 if ((Error).lt.Err) goto 300
  write(*,1000) Niter,Error
1000 format(1x,'Iteration=',I3,'            Sigma=',F8.6)
      if (Niter.eq.Nmax) goto 300
C*********************** �����˹���� *******************
      do 180 i=1,NP
    do 150 j=1,NP
       AA(i,j)=0.0
       do 150 k=1,NZ
            AA(i,j)=AA(i,j)+Ycal(i+1,k)*Ycal(j+1,k)
150    continue
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
300 Err=Error
      do 400 j=1,NZ
         Ycal(1,j)=Ycal(1,j)+Yorg(j)
400   continue
      return
 end
C*************** Optimizing Function ****************
 SUBROUTINE PFun(NFun,NZ,Ishape)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
 COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
 COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
 DIMENSION Porg(50),Y1(20000),Y2(20000)
 double precision Ysub
 DP0=0.0001
 do 50 i=1,NFun
50    Porg(i)=P(i)       !�洢��ϲ���
      call Spectra(NZ,Ishape)     !���㷢�����ǿ��
 do 80 i=1,NZ
80    Ycal(1,i)=Ysub(i)     !�洢����ķ������ǿ��
 do 300 j=1,NFun       !��ϲ���΢�ֶԹ���ǿ�ȵ�Ӱ��
    DP=Porg(j)*DP0
    P(j)=Porg(j)-DP
         call Spectra(NZ,Ishape)
    do 120 i=1,NZ
120    Y1(i)=Ysub(i)
    P(j)=Porg(j)+DP
         call Spectra(NZ,Ishape)
    do 180 i=1,NZ
180      Y2(i)=Ysub(i)
    do 200 i=1,NZ
       DY12=0.5*(Y2(i)-Y1(i))/DP
200    Ycal(j+1,i)=DY12
    P(j)=Porg(j)
300 continue
 return
 end
C****************** Calculation of the fitting spectra **************** 
 SUBROUTINE Spectra(NZ,Is)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
 COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
 COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
 double precision Ysub
 real KB
 do 20 i=1,NZ
20    Ysub(i)=0.0
 do 100 i=1,NPeak
    V1=float(Lvib(i))+0.5
    Gup=G1(1)*V1+G1(2)*V1**2+G1(3)*V1**3+G1(4)*V1**4
    Tup=(Gup*h0*C0*100.0)/KB     !��������ΪV1����������(�¶ȵ�λ)
    call INTEN(i+1,Tup,NZ,Is)  !����ǿ�ȼ��㣬i+1����ָ���񶯷�ϵ��
100   continue
 do 200 i=1,NZ
200   Ysub(i)=Ysub(i)*P(5)+P(4)
 return
 end
C****************** This is the parameters used in fitting **************** 
      BLOCK DATA CONST
 COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
 REAL KB
 DATA G1/2047.178,-28.445,2.0883,-0.535/
  DATA G2/1733.391,-14.1221,-0.05688,0.003612/
 DATA B1/1.8154,1.7933,1.7694,1.7404,1.6999/
 DATA B2/1.6285,1.6285,1.6105,1.5922,1.5737/
 DATA Q12/0.4527,0.3949,0.3413,0.2117,0.126/
 DATA Ve/29671.03/
 DATA KB/1.38062E-23/,h0/6.6262E-34/,PI/3.14159265/
 DATA C0/2.997925E8/,E0/1.602192E-19/
 END
C*************  Calculation of Honl-London Parameters ***********
      SUBROUTINE HONLLONDON(LM12,Ldt)
 COMMON/Honl/SP0(100),SQ0(100),SR0(100)!���J=0 TO 99ʱ��������ֵ
 do 100 J=0,99
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
100   continue
 return
 end
C********************* Intensity calculation ********************
      SUBROUTINE INTEN(N,T00,NPoint,Ishape)
      COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
 COMMON/CON1/h0,C0,E0,KB,PI
      COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
 COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
 COMMON/Honl/SP0(100),SQ0(100),SR0(100)
 double precision Ysub
 real KB
 Tvib=P(1)
 Trot=P(2)
 Whalf=P(3)
 G12=1.0E7/P(N-1+NQ)-Ve
  W=2.0*PI*C0*G12
  D1=4.0*B1(N)**3/W**2
 D2=4.0*B2(N)**3/W**2
 Dstep=(Xorg(NPoint)-Xorg(1))/float(NPoint-1)!���ݲ�������
 NRange=1.0/DStep                       !��������ݵ㷶Χ
      do 200 J=0,Jmax
    Fup=J*(J+1)*(B1(N)-D1*J*(J+1))    !���ܼ�ת����(������λ)
    Tup=Fup*h0*C0*100.0/KB       !����ת����(�¶ȵ�λ)
    FP=(J+2)*(J+1)*(B2(N)-D2*(J+2)*(J+1)) !���ܼ�ת����(������λ)
    FQ=J*(J+1)*(B2(N)-D2*J*(J+1))   !���ܼ�ת����(������λ)
    FR=J*(J-1)*(B2(N)-D2*J*(J-1))   !���ܼ�ת����(������λ)
    SP=SP0(J+1)
    SQ=SQ0(J+1)
    SR=SR0(J+1)
    FP12=Fup-FP     !�����ܼ�ת��������
    FQ12=Fup-FQ     !�����ܼ�ת��������
    FR12=Fup-FR     !�����ܼ�ת��������
    WP=1.0E7/P(N-1+NQ)+FP12  !���㷢����ײ���
    WQ=1.0E7/P(N-1+NQ)+FQ12
    WR=1.0E7/P(N-1+NQ)+FR12
    WLP=1.0E7/WP     !���㷢����ײ���(��λnm)
    WLQ=1.0E7/WQ     !���㷢����ײ���(��λnm)
    WLR=1.0E7/WR     !���㷢����ײ���(��λnm)
    WP=1.0e-4*WP
    WQ=1.0e-4*WQ
    WR=1.0e-4*WR
    PP=WP**4*Q12(N)*exp(-T00/Tvib)*SP*exp(-Tup/Trot) !���㷢��ǿ��
    PQ=WQ**4*Q12(N)*exp(-T00/Tvib)*SQ*exp(-Tup/Trot) !���㷢��ǿ��
    PR=WR**4*Q12(N)*exp(-T00/Tvib)*SR*exp(-Tup/Trot) !���㷢��ǿ��
 NWL=int((WLQ-Xorg(1))/Dstep+0.5)+1
 Imin=NWL-NRange
 Imax=NWL+NRange
 if (Imin.lt.1) Imin=1
 if (Imax.gt.NPoint) Imax=NPoint
 if (Ishape.eq.1) then
C******************** Gauss Function for Peak ******************
     Wgauss=1.0/sqrt(PI/2.0)/Whalf  !Gauss����ϵ��
         do 60 i=Imin,Imax
       XX=Xorg(i)
       DXP=-2.0*((XX-WLP)/Whalf)**2
       DXQ=-2.0*((XX-WLQ)/Whalf)**2
       DXR=-2.0*((XX-WLR)/Whalf)**2
    Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR))
60    continue
 else
C******************** Lorentz Function for Peak ******************
   if (Ishape.eq.0) then
    WLorentz=2.0*Whalf/PI          !Lorentz����ϵ��
         do 80 i=Imin,Imax
       XX=Xorg(i)
       DXP=4.0*(XX-WLP)**2+Whalf**2
       DXQ=4.0*(XX-WLQ)**2+Whalf**2
       DXR=4.0*(XX-WLR)**2+Whalf**2
    Ysub(i)=Ysub(i)+WLorentz*(PP/DXP+PQ/DXQ+PR/DXR)
80    continue
   else
C******************** Voigt Function for Peak ******************
     Ratio=0.5
     Para=log(4.0)
     Wgauss=Ratio*Para/sqrt(PI/2.0)/Whalf  !Gauss����ϵ��
         do 100 i=Imin,Imax
       XX=Xorg(i)
       DXP=-2.0*Para*((XX-WLP)/Whalf)**2
       DXQ=-2.0*Para*((XX-WLQ)/Whalf)**2
       DXR=-2.0*Para*((XX-WLR)/Whalf)**2
    Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR))
100    continue
    WLorentz=(1-Ratio)*2.0*Whalf/PI          !Lorentz����ϵ��
         do 120 i=Imin,Imax
       XX=Xorg(i)
       DXP=4.0*(XX-WLP)**2+Whalf**2
       DXQ=4.0*(XX-WLQ)**2+Whalf**2
       DXR=4.0*(XX-WLR)**2+Whalf**2
    Ysub(i)=Ysub(i)+WLorentz*(PP/DXP+PQ/DXQ+PR/DXR)
120    continue
         endif
      endif
180   continue
200   continue
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
       write(*,*) k,k,Amax
       A(Imax,k)=1.0
    endif
         do 30 j=k,NP+1
       T=A(k,j)
       A(k,j)=A(Imax,j)
30       A(Imax,j)=T
         Amax=A(k,k)
         do 40 j=k,NP+1
40       A(k,j)=A(k,j)/Amax
    do 50 i=k+1,NP
       T=A(i,k)
       do 50 j=k,NP+1
50          A(i,j)=A(i,j)-T*A(k,j)
100 continue
      do 200 k=NP,1,-1
    T=A(k,NP+1)
    do 210 i=k-1,1,-1
210    A(i,NP+1)=A(i,NP+1)-T*A(i,k)
200   continue
      return
 end
                 

