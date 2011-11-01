classdef BodySystemGPU < BodySystem
    %BODYSYSTEMGPU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numBodies
        initialised
        pos
        vel
        force
        mass
        invMass
        
        damping
    end
    
    properties (SetAccess = private)
    	softeningSquared
    end
    
    properties (Dependent, GetAccess = private)
    	softening
    end    
    
    methods
        
        function obj = BodySystemGPU(numBodies)
           
            obj.initialised = false;
            obj.force = 0;
            obj.softeningSquared = 0.00125;
            obj.damping = 0.995;
                        
            obj = obj.initialise(numBodies);
            
        end
        
        function obj = initialise(obj, numBodies)
            
            assert(~obj.initialised, 'BodySystemCPU not initialised');
            
            obj.numBodies = numBodies;
            
            obj.pos = parallel.gpu.GPUArray.zeros(obj.numBodies, 3);
            obj.vel = parallel.gpu.GPUArray.zeros(obj.numBodies, 3);
            obj.force = parallel.gpu.GPUArray.zeros(obj.numBodies, 3);
            
            obj.mass = parallel.gpu.GPUArray.ones(obj.numBodies, 1);
            obj.invMass = 1 ./ obj.mass;
            
            obj.initialised = true;            
            
        end
        
        function obj = update(obj, deltaTime)
           
            assert(obj.initialised, 'BodySystemCPU not initialised');
            
            obj = obj.integrateNBodySystem(deltaTime);
            
        end
        
        function obj = integrateNBodySystem(obj, deltaTime)
        %INTEGRATENBODYSYSTEM performs a single integration for the time period
        %deltaTime

            obj = obj.computeNBodyGravitation();
 
            % acceleration = force / mass; 
            % new velocity = old velocity + acceleration * deltaTime
            obj.vel = obj.vel + obj.force .* repmat(obj.invMass, 1, 3) * deltaTime;

            obj.vel = obj.vel * obj.damping;

            % new position = old position + velocity * deltaTime
            obj.pos = obj.pos + obj.vel * deltaTime;
            
        end % integrateNBodySystem
        
        function obj = computeNBodyGravitation(obj)
        %COMPUTENBODYGRAVITATION calculates the force on each body

            for i = 1:obj.numBodies

                acc = BodySystemGPU.bodyBodyInteraction(obj.pos(i, :), obj.pos, obj.mass, obj.softeningSquared);

                obj.force(i, :) = acc;

            end
            
        end % computeNBodyGravitation   
        
        function obj = set.softening(obj, softening)
           
            obj.softeningSquared = softening^2;
            
        end % set.softening
        
        function softening = get.softening(obj)
           
            softening = sqrt(obj.softeningSquared);
            
        end % get.softening        
        
    end % methods
    
    methods(Static)
        
        function accel = bodyBodyInteraction(pos1, pos2, mass2, softeningSquared)
        %BODYBODYINTERACTION calculates acceleration of body due to interaction
        %with another body and accumulates result

            % r_12
            numBodies = size(pos2, 1);
            r = pos2 - repmat(pos1, numBodies, 1);

            % d^2 + e^2
            distSqr = sum(r.^2, 2);

            distSqr = distSqr + softeningSquared;

            % invDistCube = 1/distSqr^(3/2)
            invDist = 1.0 ./ sqrt(distSqr);
            invDistCube = invDist.^3;

            % s = m_j * invDistCube
            s = mass2 .* invDistCube;

            % (m_2 * r_12) / (d^2 + e^2)^(3/2)
            accel = 3*sum(r .* repmat(s, 1, 3));
            
        end % bodyBodyInteraction
    
    end % methods(Static)
    
end
