function A=Gauss(NP,A)%����Ԫ��ȥ�������Է�����
for k=1:NP%��
    Amax=0.0;
    Imax=0;
    for i=k:NP%��
        if (abs(A(i,k))>Amax)%��������������ÿ�о���ֵ���ֵ
            Amax=abs(A(i,k));
            Imax=i;
        end
    end
    if (abs(Amax)<1.0e-32)%�����ֵ̫С��ʹ֮Ϊ1
        fprintf('%d,%d,%f\n',k,k,Amax);
        A(Imax,k)=1.0;
    end
    for j=k:NP+1%�ӵ�k�п�ʼ������k�����imax��,��k��˳����Ĺ淶��
        T=A(k,j);
        A(k,j)=A(Imax,j);
        A(Imax,j)=T;
    end
    Amax=A(k,k);
    for j=k:NP+1
        A(k,j)=A(k,j)/Amax;%��1�й淶��
    end
    for i=k+1:NP
        T=A(i,k);
        for j=k:NP+1
            A(i,j)=A(i,j)-T*A(k,j);
        end
    end
end%�����ǳ��ȱ任Ϊ��������
for k=NP:-1:1
    T=A(k,NP+1);
    for i=k-1:-1:1
        A(i,NP+1)=A(i,NP+1)-T*A(i,k);
    end
end
end