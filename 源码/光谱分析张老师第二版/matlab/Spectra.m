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