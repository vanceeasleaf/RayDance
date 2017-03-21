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