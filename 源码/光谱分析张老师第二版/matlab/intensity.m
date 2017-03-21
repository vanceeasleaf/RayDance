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