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
