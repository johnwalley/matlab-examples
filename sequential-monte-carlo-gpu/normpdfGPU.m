function y = normpdfGPU(x, mu, sigma)
%NORMPDFGPU Summary of this function goes here
%   Detailed explanation goes here

    y = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);

end

