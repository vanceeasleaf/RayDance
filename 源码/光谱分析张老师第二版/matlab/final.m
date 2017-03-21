function final
clc;clear
Xcal=[315.65,313.44,311.52,310.07,0.0,0.0,0.0,0.0,0.0,0.0];%N2第二正带的(i,i-1)振动带振动峰峰位
%******************************************************************
FLNAME='d:\t25hz.txt';%input('输入实验数据文件名:','s');
NPoint=textread(FLNAME,'%d',1);
[Xorg,Yorg]=textread(FLNAME,'%f%f','headerlines', 1);
NPeak=4;					%振动峰数量
Ishape=2;	%发光峰线型选择0-Lorentz,1-Gauss,2-Voigt
% Jmax=30;	%最大转动能级量子数
% WA=Xorg(1);	%最小波长
% WB=Xorg(NPoint);%最大波长
Tstep=0.3;	%收敛步长
Err=1.0E-3;	%拟合误差限制
Nmax=50	;	%迭代次数限制
NQ=5;
NP=NQ+NPeak;%拟合参数个数,9
P(1:NP)=0;
P(1)=4550.0;%振动温度初值
P(2)=450.0;	%转动温度初值
P(3)=0.09;	%谱仪分辨率初值
P(4)=600;	%背景噪声初值
P(5)=2.0;   %比例因子
for i=1:NPeak		%NPeak=4为振动峰数
    fprintf('Peak%d=%f\n',i,Xcal(i));
    P(i+NQ)=Xcal(i);			 %将振动峰峰位设置为拟合参数,P(6)到P(9)
end

%******************************************************************
[P,Ycal,Error]=Pfit(1,NP,NPoint,Tstep,Err,Nmax,Ishape,Yorg,P,NPeak,Xorg);
%拟合法,参数个数,数据点个数,步长,误差限,最大迭代次数,线型
%输出头部信息
fprintf( '标准方差 Error=%f\n',Error); %标准方差
%Fitname=input('输入拟合结果文件名=');
fid2=fopen('d:\txw.txt','wt');
fprintf(fid2,'  Standard Error=%e\n', Error);%先写拟合误差
for i=1:NP
    fprintf('  Parameter%d =%e\n',i,P(i)); %再写拟合出的参数,一边显示一边写到文件里
    fprintf(fid2,'  Parameter%d =%e\n',i,P(i));
end
%Fine result simulation ************
for i=1:NPoint%写出原数组和拟和值
    fprintf(fid2,'  %12.6e   %12.6e     %12.6e\n',Xorg(i),Yorg(i),Ycal(1,i));
end
fclose(fid2);
end%程序结束
function A=Gauss(NP,A)%列主元消去法解线性方程组
for k=1:NP%列
    Amax=0.0;
    Imax=0;
    for i=k:NP%行
        if (abs(A(i,k))>Amax)%在下三角阵中找每列绝对值最大值
            Amax=abs(A(i,k));
            Imax=i;
        end
    end
    if (abs(Amax)<1.0e-32)%若最大值太小则使之为1
        fprintf('%d,%d,%f\n',k,k,Amax);
        A(Imax,k)=1.0;
    end
    for j=k:NP+1%从第k列开始交换第k行与第imax行,第k个顺序阵的规范化
        T=A(k,j);
        A(k,j)=A(Imax,j);
        A(Imax,j)=T;
    end
    Amax=A(k,k);
    for j=k:NP+1
        A(k,j)=A(k,j)/Amax;%第1行规范化
    end
    for i=k+1:NP
        T=A(i,k);
        for j=k:NP+1
            A(i,j)=A(i,j)-T*A(k,j);
        end
    end
end%以上是初等变换为上三角阵
for k=NP:-1:1
    T=A(k,NP+1);
    for i=k-1:-1:1
        A(i,NP+1)=A(i,NP+1)-T*A(i,k);
    end
end
end
%Intensity calculation ***************************
function [Ysub,Tup]=intensity(N,T00,NPoint,Ishape,P,Xorg,Ysub)
%高能级整动量子数,理论振动温度,数据点个数,线型,参数
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON1/h0,C0,E0,KB,PI
C0=2.997925E8;%光速
PI=3.14159265;%圆周率
h0=6.6262E-34;%普朗克常量
KB=1.38062E-23;%玻尔兹曼常量
% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% COMMON/Honl/SP0(100),SQ0(100),SR0(100)
% double precision Ysub
% real KB
NQ=5;
Jmax=30;	%最大转动能级量子数
%the second positive band of N2 ****************
LM12=1;Ldt=0;
[SP0,SQ0,SR0]=honllondon(LM12,Ldt);%算出J=0 TO 99时的SP0(100),SQ0(100),SR0(100)三个值
B1=[1.8154,1.7933,1.7694,1.7404,1.6999];%高电子态的转动常数B,与振动量子数有关
%v=1,2,3,4
B2=[1.6285,1.6285,1.6105,1.5922,1.5737];%低电子态,说明与电子态也有关
%v=0,1,2,3
Ve=29671.03;%电子谱线位
Q12=[0.4527,0.3949,0.3413,0.2117,0.126];
Tvib=P(1);%振动温度
Trot=P(2);%转动温度
Whalf=P(3);%谱仪分辨率初值
G12=1.0E7/P(N-1+NQ)-Ve;%第n-1个峰的跃迁频率(cm-1)
W=2.0*PI*C0*G12*100;%上式对应的圆频率
D1=4.0*B1(N)^3/W^2;%高电子态的转动常数D
D2=4.0*B2(N)^3/W^2;
DStep=(Xorg(NPoint)-Xorg(1))/(NPoint-1);    %数据步长估计
NRange=1.0/DStep ; 		             	%发光峰数据点范围
for J=0:Jmax
    Fup=J*(J+1)*(B1(N)-D1*J*(J+1));         %上能级转动能(波数单位)
    Tup=Fup*h0*C0*100.0/KB;                 %计算转动能(温度单位)
    FP=(J+2)*(J+1)*(B2(N)-D2*(J+2)*(J+1));  %下能级转动能(波数单位)
    FQ=J*(J+1)*(B2(N)-D2*J*(J+1));          %下能级转动能(波数单位)
    FR=J*(J-1)*(B2(N)-D2*J*(J-1));          %下能级转动能(波数单位)
    SP=SP0(J+1);
    SQ=SQ0(J+1);
    SR=SR0(J+1);
    FP12=Fup-FP;				%上下能级转动能量差
    FQ12=Fup-FQ	;				%上下能级转动能量差
    FR12=Fup-FR	;				%上下能级转动能量差
    WP=1.0E7/P(N-1+NQ)+FP12	;	%计算发射光谱波数
    WQ=1.0E7/P(N-1+NQ)+FQ12;
    WR=1.0E7/P(N-1+NQ)+FR12;
    WLP=1.0E7/WP;					%计算发射光谱波长(单位nm)
    WLQ=1.0E7/WQ;					%计算发射光谱波长(单位nm)
    WLR=1.0E7/WR;					%计算发射光谱波长(单位nm)
    WP=1.0e-4*WP;                   %(um-1)相当于调整P(5)的尺度..从而等效的初值也变了
    WQ=1.0e-4*WQ;
    WR=1.0e-4*WR;
    PP=WP^4*Q12(N)*exp(-T00/Tvib)*SP*exp(-Tup/Trot);	%计算发射强度
    PQ=WQ^4*Q12(N)*exp(-T00/Tvib)*SQ*exp(-Tup/Trot);	%计算发射强度
    PR=WR^4*Q12(N)*exp(-T00/Tvib)*SR*exp(-Tup/Trot);	%计算发射强度
    NWL=fix((WLQ-Xorg(1))/DStep+0.5)+1;                 %fix取整,带原点是第几个数据
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
        Wgauss=1.0/sqrt(PI/2.0)/Whalf;  %Gauss函数系数
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
            WLorentz=2.0*Whalf/PI;          %Lorentz函数系数
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
            Wgauss=Ratio*Para/sqrt(PI/2.0)/Whalf;  %Gauss函数系数
            for i=Imin:Imax
                XX=Xorg(i);
                DXP=-2.0*Para*((XX-WLP)/Whalf)^2;
                DXQ=-2.0*Para*((XX-WLQ)/Whalf)^2;
                DXR=-2.0*Para*((XX-WLR)/Whalf)^2;
                Ysub(i)=Ysub(i)+Wgauss*(PP*exp(DXP)+PQ*exp(DXQ)+PR*exp(DXR));
            end
            WLorentz=(1-Ratio)*2.0*Whalf/PI;          %Lorentz函数系数
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
function [sp,sq,sr]=honllondon(alpha1,dalpha)%ctrl+A=>ctrl+I可以整理
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
%拟合方式,参数个数,样本点个数,拟合步长,误差,迭代次数限制,线型
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% COMMON/Gau/AA(50,50)
if Nfit==1
    [Ycal,P,Error]=loop(NP,NPoint,Tstep,Err,Nmax,Ishape,P,Yorg,NPeak,Xorg);
    j=1:NPoint;
    Ycal(1,j)=Ycal(1,j)+Yorg(j)';%得到返回值,Yorg是列向量
end
end
function [Ycal,P,Error]=loop(NP,NPoint,Tstep,Err,Nmax,Ishape,P,Yorg,NPeak,Xorg)
j=1:NPoint;
Y0sum=Yorg(j)'*Yorg(j);%原y值平方和
for Niter=1:Nmax%迭代计数
    Ycal=PFun(NP,NPoint,Ishape,P,NPeak,Xorg);%迭代出拟合曲线
    
    j=1:NPoint;
    Ycal(1,j)=Ycal(1,j)-Yorg(j)';%拟合误差平方和
    Error=Ycal(1,j)*Ycal(1,j)'/Y0sum;%相对误差
    Error=sqrt(Error/NPoint);
    fprintf(' Iteration=%3d,            Sigma=%8.6f\n',Niter,Error);
    if Error<Err
        return%满足了要求跳出跌代
    end
    
    %通过算出的曲线构造高斯矩阵,找出曲面上与给定点距离极小的点.
    k=1:NPoint;
    AA=zeros(NP,NP+1);
    for i=1:NP
        for j=1:NP
            AA(i,j)=Ycal(i+1,k)*Ycal(j+1,k)';%通过Ycal的第2到10行计算A(1:9,1:9)
        end
        AA(i,NP+1)=Ycal(i+1,k)*Ycal(1,k)';%通过Ycal的第2到10行和第1行的内积计算A(1:9,10),Ycal(1,j)=Ycal(1,j)-Yorg(j)'是相对值!!
    end
    %高斯变换
    AA=Gauss(NP,AA);
    
    j=1:NP;
    P(j)=P(j)-Tstep*AA(j,NP+1)';%参数修正
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
Porg(i)=P(i);					  %存储拟合参数
Ysub=Spectra(NPoint,Ishape,P,NPeak,Xorg); 		  %计算发射光谱强度
i=1:NPoint;
Ycal(1,i)=Ysub(i);			  %存储计算的发射光谱强度

for j=1:NP					  %拟合参数微分对光谱强度的影响
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
h0=6.6262E-34;%普朗克常量
C0=2.997925E8;%光速
KB=1.38062E-23;%玻尔兹曼常量

% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5)
G1=[2047.178,-28.445,2.0883,-0.535];%振动常数
Lvib=[1,2,3,4,0,0,0,0,0,0];%上能级振动量子数
Ysub(1:NPoint)=0.0;
for i=1:NPeak
    V1=Lvib(i)+0.5;
    Gup=G1(1)*V1+G1(2)*V1^2+G1(3)*V1^3+G1(4)*V1^4;
    Tup=(Gup*h0*C0*100.0)/KB;	    %振动量子数为V1的理论振动能(温度单位)
    Ysub=intensity(i+1,Tup,NPoint,Ishape,P,Xorg,Ysub); 	%光谱强度计算，i+1用于指定振动峰系数
end
i=1:NPoint;
Ysub(i)=Ysub(i)*P(5)+P(4);%所求的纵坐标值
end