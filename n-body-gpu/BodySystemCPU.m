classdef BodySystemCPU < BodySystem
    %BodySystemCPU Summary of this class goes here
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
        
        function obj = BodySystemCPU(numBodies)
           
            obj.initialised = false;
            obj.force = 0;
            obj.softeningSquared = 0.00125;
            obj.damping = 0.995;
                        
            obj = obj.initialise(numBodies);
            
        end
        
        function obj = initialise(obj, numBodies)
            
            assert(~obj.initialised, 'BodySystemCPU not initialised');
            
            obj.numBodies = numBodies;
            
            obj.pos = zeros(obj.numBodies, 3);
            obj.vel = zeros(obj.numBodies, 3);
            obj.force = zeros(obj.numBodies, 3);
            
            obj.mass = ones(obj.numBodies, 1);
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

            for i = 1:obj.numBodies

                % acceleration = force / mass; 
                % new velocity = old velocity + acceleration * deltaTime
                obj.vel(i, :) = obj.vel(i, :) + (obj.force(i, :) * obj.invMass(i)) * deltaTime;

                obj.vel(i, :) = obj.vel(i, :) * obj.damping;

                % new position = old position + velocity * deltaTime
                obj.pos(i, :) = obj.pos(i, :) + obj.vel(i, :) * deltaTime;

            end
            
        end % integrateNBodySystem
        
        function obj = computeNBodyGravitation(obj)
        %COMPUTENBODYGRAVITATION calculates the force on each body

            obj.force = zeros(obj.numBodies, 3);

            for i = 1:obj.numBodies

                acc = zeros(1, 3);

                for j = 1:obj.numBodies

                    acc = BodySystemCPU.bodyBodyInteraction(acc, obj.pos(i, :), obj.pos(j, :), obj.mass(j), obj.softeningSquared);

                end

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
        
        function accel = bodyBodyInteraction(accel, pos1, pos2, mass2, ...
                                             softeningSquared)
        %BODYBODYINTERACTION calculates acceleration of body due to interaction
        %with another body and accumulates result

            % r_12
            r = pos2 - pos1;

            % d^2 + e^2
            distSqr = norm(r);

            distSqr = distSqr + softeningSquared;

            % invDistCube = 1/distSqr^(3/2)
            invDist = 1.0 / sqrt(distSqr);
            invDistCube = invDist.^3;

            % s = m_j * invDistCube
            s = mass2 * invDistCube;

            % (m_2 * r_12) / (d^2 + e^2)^(3/2)
            accel = accel + r * s;
            
        end   
    
    end % methods(Static)
    
end
