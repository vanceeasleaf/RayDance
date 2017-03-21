function [sp,sq,sr]=honllondon(alpha1,dalpha)%ctrl+A=>ctrl+I可以整理
sp=zeros(1,100);sq=sp;sr=sp;
    for j=0:99
        if dalpha==0
                sp(j+1)=(j+1+alpha1)*(j+1-alpha1)/(j+1);
            if j>0
              sr(j+1)=(j+alpha1)*(j-alpha1)/j;
            else
                sr(j+1)=0.0;
            end
            if (alpha1>0)
                if (j>0)
                    sq(j+1)=(2*j+1)*alpha1*alpha1/(j*(j+1));
                else
                    sq(j+1)=0.0;
                end
            else
                sq(j+1)=0.0;
            end
        end

        if (dalpha==1)
            sp(j+1)=(j+1-alpha1)*(j+2-alpha1)/(j+1)/4;
            if (j>0) 
                sr(j+1)=(j+alpha1)*(j-1+alpha1)/j/4;
                sq(j+1)=(2*j+1)*(j+alpha1)*(j+1-alpha1)/(4*j*(j+1));
            else
                sr(j+1)=0.0;
                sq(j+1)=0.0;
            end
        end

        if (dalpha==-1)
            sp(j+1)=(j+1+alpha1)*(j+2+alpha1)/(j+1)/4;
            if (j>0)
            sr(j+1)=(j-alpha1)*(j-1-alpha1)/j/4;
            sq(j+1)=(2*j+1)*(j-alpha1)*(j+1+alpha1)/(4*j*(j+1));
            else
            sr(j+1)=0.0;
            sq(j+1)=0.0;
            end
        end
    end
end