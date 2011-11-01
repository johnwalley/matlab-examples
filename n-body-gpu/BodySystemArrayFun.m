classdef BodySystemArrayFun < BodySystem
    %BODYSYSTEMARRAYFUN Summary of this class goes here
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
        
        function obj = BodySystemArrayFun(numBodies)
           
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
            
            p1 = repmat(obj.pos(:, 1), 1, obj.numBodies);
            p2 = repmat(obj.pos(:, 2), 1, obj.numBodies);
            p3 = repmat(obj.pos(:, 3), 1, obj.numBodies);
        
            m = repmat(obj.mass, 1, obj.numBodies);
            
            s2 = obj.softeningSquared;
            
            [a1, a2, a3] = arrayfun(@computeNBodyGravitation, p1, p1', p2, p2', p3, p3', m, s2);
 
            force = 5 * [sum(a1, 2) sum(a2, 2) sum(a3, 2)];
            
            % acceleration = force / mass; 
            % new velocity = old velocity + acceleration * deltaTime
            obj.vel = obj.vel + force .* repmat(obj.invMass, 1, 3) * deltaTime;

            obj.vel = obj.vel * obj.damping;

            % new position = old position + velocity * deltaTime
            obj.pos = obj.pos + obj.vel * deltaTime;
            
        end % integrateNBodySystem
                
        function obj = set.softening(obj, softening)
           
            obj.softeningSquared = softening^2;
            
        end % set.softening
        
        function softening = get.softening(obj)
           
            softening = sqrt(obj.softeningSquared);
            
        end % get.softening        
        
    end % methods
        
end
