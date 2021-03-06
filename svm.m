%run cvx_startup.m
% author: Jorge Guevara Diaz, 2013
% email: jorge.jorjasso@gmail.com

rand('seed',88);
n = 10;
X1 = rand(n,2);
X2 = rand(n,2) + 0.5*ones(n,1)*[1 2];
y = [ones(n,1) ; -ones(n,1)];

X = [X1;X2];
[n,d] = size(X)

%-----------------------------matrices
Dy=diag(y);
e=ones(n,1);

%%
%Active set SVM
clc
Gtmp=Dy*X;
G=Gtmp*Gtmp';

I0=zeros(n,1);   
I=[1;n/2+1];     
alpha0=[1;1];
zero=[-0.1,0.01];
%---------------------------------------------objective function
q=[];
q=[q,0.5*alpha0'*G(I,I)*alpha0-e(I)'*alpha0];
l = sqrt(eps);
flag_0=1;
while(flag_0)    
    %-------[alpha,b]=[G,y,y',0]\[1;0]---------------------    
    L=chol(G(I,I)+l*eye(length(I)));
    Ge=L\(L'\e(I));
    Gy=L\(L'\y(I));
    b=(y(I)'*Ge)/(y(I)'*Gy);
    alpha1=L\(L'\(e(I)-y(I)*b));        
    %--------------------------------------------------
    %-----alpha<0----I->IO-----------------------------
    if ((max(alpha1<0)==1))
        %--------------------------
        t=-alpha0./(alpha1-alpha0); ineg=find(alpha1<0); [t pos] = min(t(ineg));        
        alpha1=alpha0+t*(alpha1-alpha0);               
        ind0=ineg(pos);  alpha1(ind0)=[];  I(ind0)=[];alpha0=alpha1;        
    else %I0->I_alpha   
    %---------------------------------------------------------------
    %----------------coarse search----------------------------------
        if (n>500)            
            Index=[1:n];    Index(I)=[];  flag=1; p=1;    step=50;    s=step;
            tam_index=length(Index);            
            while (flag)
                II=Index(p:s); M=G(II,I)*alpha1+b*y(II)-e(II);inI=find(M <-sqrt(eps));
                %------forward-----------
                if isempty(inI)
                    if (s==tam_index) alpha0=alpha1; flag=0; flag_0=0;
                    else
                        p=s+1;  s=s+step;
                        if (s>tam_index)  s=tam_index; end
                    end
                %--------I0->I------------------    
                else
                    [minValue,ind_min]=min(M);
                    ind_min=Index(p+ind_min-1);
                    p=s+1;  s=s+step;  flag=0;
                    %------------------
                    if (s>tam_index) s=tam_index; end
                    I=[I;ind_min]; alpha0=[alpha1;0];
                end
            end
     %------------end coarse search----------------------------------
     %---------------------------------------------------------------
        else
     %--------I0->I-----------------------------------------------            
            M=G(:,I)*alpha1+b*y-e;            
            inI=find(M <zero(1));
            if isempty(inI)                
                alpha0=alpha1;   flag_0=0;                
            else
                [minValue,ind_min]=min(M);
                I=[I;ind_min]; alpha0=[alpha1;0];
            end
        end
    end
    q=[q,0.5*alpha0'*G(I,I)*alpha0-e(I)'*alpha0]; disp(q(end))
end

figure
plot(q)
plotHiperplane(X, X1,X2,y, alpha0,b,I)
clear

