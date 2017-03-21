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
