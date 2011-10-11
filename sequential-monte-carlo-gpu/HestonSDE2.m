function [S,V] = HestonSDE2(r,k,th,s1,s2,X0,T,M)

% X = HestonModel(r,k,th,s1,s2,N,M)
%
% Monte Carlo simulation of the Heston model via a second order
% discretisation process
%
% $$ dS_{t} = r S_{t} dt + \sqrt{V_{t}} S_{t} dW1_{t} $$
%
% $$ dV_{t} = k(th-V_{t}) dt + \sqrt{V_{t}} (s1 dW1_{t} + s2 dW2_{t}) $$
%

S0 = X0(1);
V0 = X0(2);

N = numel(T);

Z1 = randn(N-1,M); Z12 = Z1.^2;
Z2 = randn(N-1,M); Z22 = Z2.^2;
Z1Z2 = Z1.*Z2;
xi = 2*round(rand(N-1,M))-1;

S = zeros(N,M); S(1,:) = S0;
V = zeros(N,M); V(1,:) = V0;

s_2 = s1^2+s2^2;

r2 = r^2;
k2 = k^2;
k3_2 = k*3/2;
K1 = (r+(s1-k)/4);
K2 = (k*th/4-s_2/16);
s12 = s1^2;
s22 = s2^2;
s1s2 = s1*s2;

for ii = 2:N
    h = T(ii)-T(ii-1);
    sqrth = sqrt(h);
    h3_2 = h*sqrth;
    sqV = sqrt(V(ii-1,:));

    S(ii,:) = S(ii-1,:).*(1+r.*h+sqV.*sqrth.*Z1(ii-1,:))+0.5.*r2.*S(ii-1,:).*h^2+...
        (K1.*S(ii-1,:).*sqV+K2.*S(ii-1,:)./sqV).*h.*sqrth.*Z1(ii-1,:)+...
        0.5.*S(ii-1,:).*(V(ii-1,:)+s1/2).*(h.*Z12(ii-1,:)-h)+...
        0.25.*s2*S(ii-1,:).*(h.*Z1Z2(ii-1,:)-h.*xi(ii-1,:));

    V(ii,:) = abs(k*th*h+(1-k*h)*V(ii-1,:)+sqV.*sqrth.*(s1.*Z1(ii-1,:)+s2.*Z2(ii-1,:))-...
        .5*k2*(th-V(ii-1,:))*h^2+(K2./sqV-k3_2*sqV).*(s1*Z1(ii-1,:)+s2*Z2(ii-1,:))*h3_2+...
        0.25*s12.*(Z12(ii-1,:)-1)*h+0.25*s22.*(Z22(ii-1,:)-1)*h+s1s2*h*Z1Z2(ii-1,:)); % Avoid imaginery nastiness

end



end
