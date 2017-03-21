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