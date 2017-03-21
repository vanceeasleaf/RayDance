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