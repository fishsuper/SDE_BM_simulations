%MILSTRONG Test strong convergence of Milstein: vectorized % 
% Solves dX = r*X*(K-X) dt + beta*X dW, X(0) = Xzero, % where r = 2, K= 1, beta = 1 and Xzero = 0.5.
% % Discretized Brownian path over [0,1] has dt = 2^(-11).
% Milstein uses timesteps 128*dt, 64*dt, 32*dt, 16*dt (also dt for reference). %
% Examines strong convergence at T=1: E | X_L - X(T) |.
% Code is vectorized: all paths computed simultaneously.

rand('state',100)
r = 2; K = 1; beta = 0.25; Xzero = 0.5;
T = 1; N = 2^(11); dt = T/N;
M = 500;

R = [1; 16; 32; 64; 128];
dW = sqrt(dt)*randn(M,N); Xmil = zeros(M,5); 

for p = 1:5
% problem parameters %
% number of paths sampled
% Milstein stepsizes are R*dt
% Brownian increments 
% preallocate array
    Dt = R(p)*dt; L = N/R(p); 
    Xtemp = Xzero*ones(M,1); 
    for j = 1:L
% L timesteps of size Dt = R dt
    Winc = sum(dW(:,R(p)*(j-1)+1:R(p)*j),2);
    Xtemp = Xtemp + Dt*r*Xtemp.*(K-Xtemp) + beta*Xtemp.*Winc ...
            + 0.5*beta^2*Xtemp.*(Winc.^2 - Dt); 
    end
Xmil(:,p) = Xtemp;
% store Milstein solution at t =1
end

Xref = Xmil(:,1);
Xerr = abs(Xmil(:,2:5) - repmat(Xref,1,4)); 
mean(Xerr); Dtvals = dt*R(2:5);

subplot(224) 
loglog(Dtvals,mean(Xerr),'b*-'), hold on 
loglog(Dtvals,Dtvals,'r--'), hold off 
axis([1e-3 1e-1 1e-4 1]) 
xlabel('\Delta t')
ylabel('Sample average of | X(T) - X_L |') 
title('milstrong.m','FontSize',10)
% Reference solution % Error in each path % Mean pathwise erorrs % Milstein timesteps used
% lower RH picture
% reference slope of 1
%%%% Least squares fit of error = C * Dt^q %%%%
A = [ones(4,1), log(Dtvals)]; rhs = log(mean(Xerr)'); 
sol = A\rhs; q = sol(2) 
resid = norm(A*sol - rhs)
