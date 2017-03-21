% Main Program of OES-Dfit  *******************
% This program is used to fit the emission spectrum of 	*
% molecular with double atoms                            *
% This is the parameters used in fitting ****************
% 选中后ctrl+r,取消是ctrl+t
function OES_Dfit
clc;clear
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON1/h0,C0,E0,KB,PI
% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% COMMON/Honl/SP0(100),SQ0(100),SR0(100)
% COMMON/Gau/AA(50,50)
% COMMON/CON1/h0,C0,E0,KB,PI

Xcal=[315.65,313.44,311.52,310.07,0.0,0.0,0.0,0.0,0.0,0.0];%N2第二正带的(i,i-1)振动带振动峰峰位

%******************************************************************
FLNAME='d:\t25hz.txt';%input('输入实验数据文件名:','s');
NPoint=textread(FLNAME,'%d',1);
%disp(NPoint)
%fid1=fopen(FLNAME,'rt');
%NPoint=fscanf(fid1,'%d'); 	%读入数据点数量
[Xorg,Yorg]=textread(FLNAME,'%f%f','headerlines', 1);
%f=fscanf(fid1,'%f%f',[NPoint,2]);
%Xorg=f(:,1);Yorg=f(:,2);    %读入数组
%fclose(fid1);
%Initializing ******************************
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
%已经完成数据输出
% 300   continue
% P(3)=0.01;%仪器分辨率
% XRange=Xorg(NPoint)-Xorg(1);%x的范围
% Xmin=Xorg(1);
% NPoint=20000;
% XStep=XRange/(NPoint-1);%X的步长
% for i=1:NPoint
%     Xorg(i)=Xmin+XStep*(i-1);
% end
% spectra(NPoint,Ishape)
% for i=1:NPoint
%     Yorg(i)=Ysub(i);
%     %	   	write(30,2000) Xorg(i),Yorg(i)
% end
end%程序结束
