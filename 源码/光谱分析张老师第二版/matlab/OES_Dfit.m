% Main Program of OES-Dfit  *******************
% This program is used to fit the emission spectrum of 	*
% molecular with double atoms                            *
% This is the parameters used in fitting ****************
% ѡ�к�ctrl+r,ȡ����ctrl+t
function OES_Dfit
clc;clear
% COMMON/FUN/Xorg(20000),Yorg(20000),Ycal(50,20000),Ysub(20000)
% COMMON/CON1/h0,C0,E0,KB,PI
% COMMON/CON2/G1(4),G2(4),B1(5),B2(5),Ve,Q12(5),
% COMMON/CON3/Jmax,Xcal(10),LVib(10),NPeak,NQ,P(50)
% COMMON/Honl/SP0(100),SQ0(100),SR0(100)
% COMMON/Gau/AA(50,50)
% COMMON/CON1/h0,C0,E0,KB,PI

Xcal=[315.65,313.44,311.52,310.07,0.0,0.0,0.0,0.0,0.0,0.0];%N2�ڶ�������(i,i-1)�񶯴��񶯷��λ

%******************************************************************
FLNAME='d:\t25hz.txt';%input('����ʵ�������ļ���:','s');
NPoint=textread(FLNAME,'%d',1);
%disp(NPoint)
%fid1=fopen(FLNAME,'rt');
%NPoint=fscanf(fid1,'%d'); 	%�������ݵ�����
[Xorg,Yorg]=textread(FLNAME,'%f%f','headerlines', 1);
%f=fscanf(fid1,'%f%f',[NPoint,2]);
%Xorg=f(:,1);Yorg=f(:,2);    %��������
%fclose(fid1);
%Initializing ******************************
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
%�Ѿ�����������
% 300   continue
% P(3)=0.01;%�����ֱ���
% XRange=Xorg(NPoint)-Xorg(1);%x�ķ�Χ
% Xmin=Xorg(1);
% NPoint=20000;
% XStep=XRange/(NPoint-1);%X�Ĳ���
% for i=1:NPoint
%     Xorg(i)=Xmin+XStep*(i-1);
% end
% spectra(NPoint,Ishape)
% for i=1:NPoint
%     Yorg(i)=Ysub(i);
%     %	   	write(30,2000) Xorg(i),Yorg(i)
% end
end%�������
