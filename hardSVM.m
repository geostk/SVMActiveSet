%run cvx_startup.m
% author: Jorge Guevara Diaz, 2013
% email: jorge.jorjasso@gmail.com

%-----------------------------Data
rand('seed',88);
n  = 50;
X1 = rand(n,2);    X2 = rand(n,2) + 0.5*ones(n,1)*[1 2];
X  = [X1;X2];   y  = [ones(n,1) ; -ones(n,1)]; [n,d] = size(X);

%-----------------------------matrices
Dy=diag(y);
e=ones(n,1);

%-----------------------------Optimization problem
H=[eye(d), zeros(d,1); zeros(1,d),0];
A=[Dy*X,y];

cvx_begin
    variable z(d+1)
    dual variable alpha;
        minimize( 0.5*z'*H*z)
        subject to
            alpha : A*z-e>=0;
cvx_end
%-----------------------------solutions
w=z(1:d);
b=z(d+1);
%----------------------------plot
figure
I=find(alpha>0.00001);
plot(X1(:,1),X1(:,2),'+')
hold on
plot(X2(:,1),X2(:,2),'*r')
plot(X(I,1),X(I,2),'oc')

ax = axis;
xmin = ax(1);
xmax = ax(2);

ymin=(-w(1)*xmin-b)/w(2);
ymax=(-w(1)*xmax-b)/w(2);
plot([xmin xmax],[ymin ymax],'g')
plot([xmin xmax],[ymin ymax]+1/norm(w),'g')
plot([xmin xmax],[ymin ymax]-1/norm(w),'g')
