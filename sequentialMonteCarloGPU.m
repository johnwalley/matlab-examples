%% Sequential Monte Carlo Volatility Estimation
%sequentialMonteCarloGPU estimates the volatility of an underlying
%instrument using a sequential monte carlo (SMC) method. Performance is compared
%for several different implementations
%
%   sequentialMonteCarloGPU estimates the volatility of an underlying
%   instrument using a sequential monte carlo (SMC) method. Performance is
%   compared for several different implementations:
% 
%   1. CPU: All calculations are performed by MATLAB on the host CPU.
%
%   2. GPU (simple):
%
%   3. GPU arrayfun
%
%   4. CUDAKernal:
%
%   See also:  gpuArray

% Copyright 2011 John Walley

%% Introduction
% It is assumed that the volatility behaves according to the Heston
% stochastic volatility model [1]. We simulate a single path via a second order
% discretisation process [2].
%
% The SMC method is a recursive filter which represents the probability
% density function as a set of weighted 'particles'. It consists of three
% main steps:
%
% 1. Propagate particle states according model dynamics
%
% 2. Update particle weights using observations to calculate likelihood
%
% 3. Resample particle population if degenerate, e.g. too much weight
%    associated with a small number of particles

%% Problem Setup

N = 1000; % Number of time steps

T_stop = 1; % Stopping time
M = 1; % Number of paths to simulate
T = linspace(0, T_stop, N+1); % Vector of times

X0 = [100; 0.04]; % Initial conditions
K = 100; % Strike price
r = 0.05;  % Interest rate
k = 1.2; % Speed
th = 0.04; % Level 
s = 0.3; % Vol of vol
s1 = -0.5*s;
s2 = (sqrt(3)/2)*s;

% Simulate 
[S, V] = HestonSDE2(r,k,th,s1,s2,X0,T,M);

ret = tick2ret(S,T');




