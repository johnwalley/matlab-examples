function x = f(x, k, th, h, sqV, sqrth, s1, Z1, s2, Z2, k2, K2, k3_2, h3_2, s12, Z12, s22, Z22, s1s2, Z1Z2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x = abs(k*th*h+(1-k*h)*x+sqV.*sqrth.*(s1.*Z1+s2.*Z2)-...
    .5*k2*(th-x)*h^2+(K2./sqV-k3_2*sqV).*(s1*Z1+s2*Z2)*h3_2+...
    0.25*s12.*(Z12-1)*h+0.25*s22.*(Z22-1)*h+s1s2*h*Z1Z2);

end

