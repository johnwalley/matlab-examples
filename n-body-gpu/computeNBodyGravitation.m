function [a1, a2, a3] = computeNBodyGravitation(p1, q1, p2, q2, p3, q3, m, softeningSquared)
%COMPUTENBODYGRAVITATION calculates the force on each body

r1 = q1 - p1;
r2 = q2 - p2;
r3 = q3 - p3;

% d^2 + e^2
distSqr = r1^2 + r2^2 + r3^2;

distSqr = distSqr + softeningSquared;

% invDistCube = 1/distSqr^(3/2)
invDist = 1.0 / sqrt(distSqr);
invDistCube = invDist^3;

% s = m_j * invDistCube
s = m * invDistCube;

a1 = r1 * s;
a2 = r2 * s;
a3 = r3 * s;

end % computeNBodyGravitation   