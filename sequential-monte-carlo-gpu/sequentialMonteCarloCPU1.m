function Ex = sequentialMonteCarloCPU1(Np, N, resamplingThreshold, X0, s1, s2, k, th, T, ret, r)

    % Initialise particles
    x = X0(2)*ones(Np,1);
    x_new = ones(Np,1);
    w = ones(Np,1)/Np;

    Ex = [sum(w.*x); zeros(N,1)];

    s_2 = s1^2+s2^2;

    k2 = k^2;
    k3_2 = k*3/2;
    K2 = (k*th/4-s_2/16);
    s12 = s1^2;
    s22 = s2^2;
    s1s2 = s1*s2;

    for ii=2:N+1

        % Draw from distribution
        h = T(ii)-T(ii-1);
        sqrth = sqrt(h);
        h3_2 = h*sqrth;
        sqV = sqrt(x);

        Z1 = randn(Np, 1); Z12 = Z1.^2;
        Z2 = randn(Np, 1); Z22 = Z2.^2;
        Z1Z2 = Z1.*Z2;

        x = abs(k*th*h+(1-k*h)*x+sqV.*sqrth.*(s1.*Z1+s2.*Z2)-...
            .5*k2*(th-x)*h^2+(K2./sqV-k3_2*sqV).*(s1*Z1+s2*Z2)*h3_2+...
            0.25*s12.*(Z12-1)*h+0.25*s22.*(Z22-1)*h+s1s2*h*Z1Z2);

        % Evaluate likelihood
        l = normpdf(ret(ii-1), r*h, sqrt(x*h));

        % Calculate modified weights
        w = l.*w;
        w = w./sum(w);

        % Calculate effective sample size
        ess = 1./sum(w.^2);
        
        if ess < resamplingThreshold*Np 
            
            u = sort(rand(Np, 1));
            
            j = 1;
            t = u(1);
            
            for n=1:Np
                
                mu = u(n);
                
                while u(n)<t                
                    t = t + w(n);
                    j = j + 1;               	
                end
                
                x_new(n, 1) = x(j);
                
            end
            
            x = x_new;
            w = ones(Np, 1)/Np;
            
        end

        Ex(ii) = sum(w.*x);

    end

end % sequentialMonteCarloCPU1