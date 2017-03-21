function final
clc;clear
Xcal=[315.65,313.44,311.52,310.07,0.0,0.0,0.0,0.0,0.0,0.0];%N2�ڶ�������(i,i-1)�񶯴��񶯷��λ
%******************************************************************
FLNAME='d:\t25hz.txt';%input('����ʵ�������ļ���:','s');
NPoint=textread(FLNAME,'%d',1);
[Xorg,Yorg]=textread(FLNAME,'%f%f','headerlines', 1);
NPeak=4;					%�񶯷�����
Ishape=2;	%���������ѡ��0-Lorentz,1-Gauss,2-Voigt
% Jmax=30;	%���ת���ܼ�������
% WA=Xorg(1);	%��С����
% WB=Xorg(NPoint);%��󲨳�
Tstep=0.3;	%��������
Err=1.0E-3;	%����������
Nmax=50	;	%������������
NQ=5;
NP=NQ+NPeak;%��ϲ�������,9
P(1:NP)=0;
P(1)=4550.0;%���¶ȳ�ֵ
P(2)=450.0;	%ת���¶ȳ�ֵ
P(3)=0.09;	%���Ƿֱ��ʳ�ֵ
P(4)=600;	%����������ֵ
P(5)=2.0;   %��������
for i=1:NPeak		%NPeak=4Ϊ�񶯷���
    fprintf('Peak%d=%f\n',i,Xcal(i));
    P(i+NQ)=Xcal(i);			 %���񶯷��λ����Ϊ��ϲ���,P(6)��P(9)
end

%******************************************************************
[P,Ycal,Error]=Pfit(1,NP,NPoint,Tstep,Err,Nmax,Ishape,Yorg,P,NPeak,Xorg);
%��Ϸ�,��������,���ݵ����,����,�����,����������,����
%���ͷ����Ϣ
fprintf( '��׼���� Error=%f\n',Error); %��׼����
%Fitname=input('������Ͻ���ļ���=');
fid2=fopen('d:\txw.txt','wt');
fprintf(fid2,'  Standard Error=%e\n', Error);%��д������
for i=1:NP
    fprintf('  Parameter%d =%e\n',i,P(i)); %��д��ϳ��Ĳ���,һ����ʾһ��д���ļ���
    fprintf(fid2,'  Parameter%d =%e\n',i,P(i));
end
%Fine result simulation ************
for i=1:NPoint%д��ԭ��������ֵ
    fprintf(fid2,'  %12.6e   %12.6e     %12.6e\n',Xorg(i),Yorg(i),Ycal(1,i));
end
fclose(fid2);
end%�������
function A=Gauss(NP,A)%����Ԫ��ȥ�������Է�����
for k=1:NP%��
    Amax=0.0;
    Imax=0;
    for i=k:NP%��
        if (abs(A(i,k))>Amax)%��������������ÿ�о���ֵ���ֵ
            Amax=abs(A(i,k));
            Imax=i;
        end
    end
    if (abs(Amax)<1.0e-32)%�����ֵ̫С��ʹ֮Ϊ1
        fprintf('%d,%d,%f\n',k,k,Amax);
        A(Imax,k)=1.0;
    end
    for j=k:NP+1%�ӵ�k�п�ʼ������k�����imax��,��k��˳����Ĺ淶��
        T=A(k,j);
        A(k,j)=A(Imax,j);
        A(Imax,j)=T;
    end
    Amax=A(k,k);
    for j=k:NP+1
        A(k,j)=A(k,j)/Amax;%��1�й淶��
    end
    for i=k+1:NP
        T=A(i,k);
        for j=k:NP+1
            A(i,j)=A(i,j)-T*A(k,j);
        end
    end
end%�����ǳ��ȱ任Ϊ��������
for k=NP:-1:1
    T=A(k,NP+1);
    for i=k-1:-1:1
        A(i,NP+1)=A(i,NP+1)-T*A(i,k);
    end
end
end
%Intensity calculation ***************************
function [Ysub,Tup]=intensity(N,T00,NPoint,Ishape,P,Xorg,Ysub)
%���ܼ�����������,�������¶�,���ݵ����,����,����
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON1/h0,C0,E0,KB,PI
C0=2.997925E8;%����
PI=3.14159265;%Բ����
h0=6.6262E-34;%���ʿ˳���
KB=1.38062E-23;%������������
% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% COMMON/Honl/SP0(100),SQ0(100),SR0(100)
% double precision Ysub
% real KB
NQ=5;
Jmax=30;	%���ת���ܼ�������
%the second positive band of N2 ****************
LM12=1;Ldt=0;
[SP0,SQ0,SR0]=honllondon(LM12,Ldt);%���J=0 TO 99ʱ��SP0(100),SQ0(100),SR0(100)����ֵ
B1=[1.8154,1.7933,1.7694,1.7404,1.6999];%�ߵ���̬��ת������B,�����������й�
%v=1,2,3,4
B2=[1.6285,1.6285,1.6105,1.5922,1.5737];%�͵���̬,˵�������̬Ҳ�й�
%v=0,1,2,3
Ve=29671.03;%��������λ
Q12=[0.4527,0.3949,0.3413,0.2117,0.126];
Tvib=P(1);%���¶�
Trot=P(2);%ת���¶�
Whalf=P(3);%���Ƿֱ��ʳ�ֵ
G12=1.0E7/P(N-1+NQ)-Ve;%��n-1�����ԾǨƵ��(cm-1)
W=2.0*PI*C0*G12*100;%��ʽ��Ӧ��ԲƵ��
D1=4.0*B1(N)^3/W^2;%�ߵ���̬��ת������D
D2=4.0*B2(N)^3/W^2;
DStep=(Xorg(NPoint)-Xorg(1))/(NPoint-1);    %���ݲ�������
NRange=1.0/DStep ; 		             	%��������ݵ㷶Χ
for J=0:Jmax
    Fup=J*(J+1)*(B1(N)-D1*J*(J+1));         %���ܼ�ת����(������λ)
    Tup=Fup*h0*C0*100.0/KB;                 %����ת����(�¶ȵ�λ)
    FP=(J+2)*(J+1)*(B2(N)-D2*(J+2)*(J+1));  %���ܼ�ת����(������λ)
    FQ=J*(J+1)*(B2(N)-D2*J*(J+1));          %���ܼ�ת����(������λ)
    FR=J*(J-1)*(B2(N)-D2*J*(J-1));          %���ܼ�ת����(������λ)
    SP=SP0(J+1);
    SQ=SQ0(J+1);
    SR=SR0(J+1);
    FP12=Fup-FP;				%�����ܼ�ת��������
    FQ12=Fup-FQ	;				%�����ܼ�ת��������
    FR12=Fup-FR	;				%�����ܼ�ת��������
    WP=1.0E7/P(N-1+NQ)+FP12	;	%���㷢����ײ���
    WQ=1.0E7/P(N-1+NQ)+FQ12;
    WR=1.0E7/P(N-1+NQ)+FR12;
    WLP=1.0E7/WP;					%���㷢����ײ���(��λnm)
    WLQ=1.0E7/WQ;					%���㷢����ײ���(��λnm)
    WLR=1.0E7/WR;					%���㷢����ײ���(��λnm)
    WP=1.0e-4*WP;                   %(um-1)�൱�ڵ���P(5)�ĳ߶�..�Ӷ���Ч�ĳ�ֵҲ����
    WQ=1.0e-4*WQ;
    WR=1.0e-4*WR;
    PP=WP^4*Q12(N)*exp(-T00/Tvib)*SP*exp(-Tup/Trot);	%���㷢��ǿ��
    PQ=WQ^4*Q12(N)*exp(-T00/Tvib)*SQ*exp(-Tup/Trot);	%���㷢��ǿ��
    PR=WR^4*Q12(N)*exp(-T00/Tvib)*SR*exp(-Tup/Trot);	%���㷢��ǿ��
    NWL=fix((WLQ-Xorg(1))/DStep+0.5)+1;                 %fixȡ��,��ԭ���ǵڼ�������
    Imin=fix(NWL-NRange)+1;
    Imax=fix(NWL+NRange);
    if (Imin<1)
        Imin=1;
    end
    if (Imax>NPoint)
        Imax=NPoint;
    end
    if (Ishape==1)
        % Gauss Function for Peak ***************************
        Wgauss=1.0/sqrt(PI/2.0)/Whalf;  %Gauss����ϵ��
        for i=Imin:Imax
            XX=Xorg(i);
            DXP=-2.0*((XX-WLP)/Whalf)^2;
            DXQ=-2.0*((XX-WLQ)/Whalf)^2;
            DXR=-2.0*((XX-WLR)/Whalf)^2;
            Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR));
        end
    else
        % Lorentz Function for Peak ***************************
        if (Ishape==0)
            WLorentz=2.0*Whalf/PI;          %Lorentz����ϵ��
            for i=Imin:Imax
                XX=Xorg(i);
                DXP=4.0*(XX-WLP)^2+Whalf^2;
                DXQ=4.0*(XX-WLQ)^2+Whalf^2;
                DXR=4.0*(XX-WLR)^2+Whalf^2;
                Ysub(i)=Ysub(i)+WLorentz*(PP/DXP+PQ/DXQ+PR/DXR);
            end
        else
            % Voigt Function for Peak ***************************
            Ratio=0.5;
            Para=log(4.0);
            Wgauss=Ratio*Para/sqrt(PI/2.0)/Whalf;  %Gauss����ϵ��
            for i=Imin:Imax
                XX=Xorg(i);
                DXP=-2.0*Para*((XX-WLP)/Whalf)^2;
                DXQ=-2.0*Para*((XX-WLQ)/Whalf)^2;
                DXR=-2.0*Para*((XX-WLR)/Whalf)^2;
                Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR));
            end
            WLorentz=(1-Ratio)*2.0*Whalf/PI;          %Lorentz����ϵ��
            for i=Imin:Imax
                XX=Xorg(i);
                DXP=4.0*(XX-WLP)^2+Whalf^2;
                DXQ=4.0*(XX-WLQ)^2+Whalf^2;
                DXR=4.0*(XX-WLR)^2+Whalf^2;
                Ysub(i)=Ysub(i)+WLorentz*(PP/DXP+PQ/DXQ+PR/DXR);
            end
        end
    end
end
end
function [sp,sq,sr]=honllondon(alpha1,dalpha)%ctrl+A=>ctrl+I��������
sp=zeros(1,100);sq=sp;sr=sp;
    for j=0:99
        if dalpha==0
                sp(j+1)=(j+1+alpha1)*(j+1-alpha1)/(j+1);
            if j>0
              sr(j+1)=(j+alpha1)*(j-alpha1)/j;
            else
                sr(j+1)=0.0;
            end
            if (alpha1>0)
                if (j>0)
                    sq(j+1)=(2*j+1)*alpha1*alpha1/(j*(j+1));
                else
                    sq(j+1)=0.0;
                end
            else
                sq(j+1)=0.0;
            end
        end

        if (dalpha==1)
            sp(j+1)=(j+1-alpha1)*(j+2-alpha1)/(j+1)/4;
            if (j>0) 
                sr(j+1)=(j+alpha1)*(j-1+alpha1)/j/4;
                sq(j+1)=(2*j+1)*(j+alpha1)*(j+1-alpha1)/(4*j*(j+1));
            else
                sr(j+1)=0.0;
                sq(j+1)=0.0;
            end
        end

        if (dalpha==-1)
            sp(j+1)=(j+1+alpha1)*(j+2+alpha1)/(j+1)/4;
            if (j>0)
            sr(j+1)=(j-alpha1)*(j-1-alpha1)/j/4;
            sq(j+1)=(2*j+1)*(j-alpha1)*(j+1+alpha1)/(4*j*(j+1));
            else
            sr(j+1)=0.0;
            sq(j+1)=0.0;
            end
        end
    end
end
function [P,Ycal,Error]=Pfit(Nfit,NP,NPoint,Tstep,Err,Nmax,Ishape,Yorg,P,NPeak,Xorg)
%��Ϸ�ʽ,��������,���������,��ϲ���,���,������������,����
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% COMMON/Gau/AA(50,50)
if Nfit==1
    [Ycal,P,Error]=loop(NP,NPoint,Tstep,Err,Nmax,Ishape,P,Yorg,NPeak,Xorg);
    j=1:NPoint;
    Ycal(1,j)=Ycal(1,j)+Yorg(j)';%�õ�����ֵ,Yorg��������
end
end
function [Ycal,P,Error]=loop(NP,NPoint,Tstep,Err,Nmax,Ishape,P,Yorg,NPeak,Xorg)
j=1:NPoint;
Y0sum=Yorg(j)'*Yorg(j);%ԭyֵƽ����
for Niter=1:Nmax%��������
    Ycal=PFun(NP,NPoint,Ishape,P,NPeak,Xorg);%�������������
    
    j=1:NPoint;
    Ycal(1,j)=Ycal(1,j)-Yorg(j)';%������ƽ����
    Error=Ycal(1,j)*Ycal(1,j)'/Y0sum;%������
    Error=sqrt(Error/NPoint);
    fprintf(' Iteration=%3d,            Sigma=%8.6f\n',Niter,Error);
    if Error<Err
        return%������Ҫ����������
    end
    
    %ͨ����������߹����˹����,�ҳ����������������뼫С�ĵ�.
    k=1:NPoint;
    AA=zeros(NP,NP+1);
    for i=1:NP
        for j=1:NP
            AA(i,j)=Ycal(i+1,k)*Ycal(j+1,k)';%ͨ��Ycal�ĵ�2��10�м���A(1:9,1:9)
        end
        AA(i,NP+1)=Ycal(i+1,k)*Ycal(1,k)';%ͨ��Ycal�ĵ�2��10�к͵�1�е��ڻ�����A(1:9,10),Ycal(1,j)=Ycal(1,j)-Yorg(j)'�����ֵ!!
    end
    %��˹�任
    AA=Gauss(NP,AA);
    
    j=1:NP;
    P(j)=P(j)-Tstep*AA(j,NP+1)';%��������
end
end
function Ycal= PFun(NP,NPoint,Ishape,P,NPeak,Xorg)
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON1/h0,C0,E0,KB,PI
% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% DIMENSION Porg(50),Y1(20000),Y2(20000)
% double precision Ysub
DP0=0.0001;
i=1:NP;
Porg(i)=P(i);					  %�洢��ϲ���
Ysub=Spectra(NPoint,Ishape,P,NPeak,Xorg); 		  %���㷢�����ǿ��
i=1:NPoint;
Ycal(1,i)=Ysub(i);			  %�洢����ķ������ǿ��

for j=1:NP					  %��ϲ���΢�ֶԹ���ǿ�ȵ�Ӱ��
    DP=Porg(j)*DP0;
    P(j)=Porg(j)-DP;
    Ysub=Spectra(NPoint,Ishape,P,NPeak,Xorg);
    i=1:NPoint;
    Y1=zeros(1,NPoint);
    Y1(i)=Ysub(i);
    P(j)=Porg(j)+DP;
    Ysub=Spectra(NPoint,Ishape,P,NPeak,Xorg);
    Y2=zeros(1,NPoint);
    Y2(i)=Ysub(i);
    Ycal(j+1,i)=0.5*(Y2(i)-Y1(i))/DP;
    P(j)=Porg(j);
end
end
function Ysub=Spectra(NPoint,Ishape,P,NPeak,Xorg)
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON1/h0,C0,E0,KB,PI
% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% double precIshapeion Ysub
% real KB
h0=6.6262E-34;%���ʿ˳���
C0=2.997925E8;%����
KB=1.38062E-23;%������������

% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5)
G1=[2047.178,-28.445,2.0883,-0.535];%�񶯳���
Lvib=[1,2,3,4,0,0,0,0,0,0];%���ܼ���������
Ysub(1:NPoint)=0.0;
for i=1:NPeak
    V1=Lvib(i)+0.5;
    Gup=G1(1)*V1+G1(2)*V1^2+G1(3)*V1^3+G1(4)*V1^4;
    Tup=(Gup*h0*C0*100.0)/KB;	    %��������ΪV1����������(�¶ȵ�λ)
    Ysub=intensity(i+1,Tup,NPoint,Ishape,P,Xorg,Ysub); 	%����ǿ�ȼ��㣬i+1����ָ���񶯷�ϵ��
end
i=1:NPoint;
Ysub(i)=Ysub(i)*P(5)+P(4);%�����������ֵ
end