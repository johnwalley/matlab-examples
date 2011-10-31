classdef NBodyDemo < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (Access = private)
        nbody
        nbodyCuda
        nbodyCpu
        
        renderer
        
        hPos
        hVel
        hColor
    end
    
    methods
        
        function init(obj, numBodies, useCpu)
            
            if useCpu
                obj.nbodyCpu = BodySystemCPU(numBodies);
                obj.nbody = obj.nbodyCpu;
                obj.nbodyCuda = 0;
            else
                obj.nbodyCpu = BodySystemCUDA(numBodies);
                obj.nbody = obj.nbodyCuda;
                obj.nbodyCpu = 0;
            end
            
            obj.nbody.softening = 0.1;
            obj.nbody.damping = 1.0;
            
            % Create timer
            
            if ~benchmark
                obj.renderer = ParticleRenderer;
                obj.resetRenderer();
            end
                
        end
        
        function reset(obj, numBodies, pos, vel)
            
            obj.pos = pos;
            obj.vel = vel;
            
        end
        
        function resetRenderer(obj)
           
            colour = [0.4 0.8 0.1 1.0];
            obj.renderer.baseColour = colour;
            
            %obj.renderer.colors = obj.hColour;
            
        end
        
        function passed = compareResults(obj, numBodies)
            
            assert(obj.nbodyCuda, 'CUDA implementation must be initialised');
            
            passed = true;
            
            obj.nbody.update(0.001);
            
            obj.nbodyCpu = BodySytemCPU(numBodies);
            
            obj.nbodyCpu.pos = obj.hPos;
            obj.nbodyCpu.vel = obj.hVel;
            
            obj.nbodyCpu.update(0.001);
            
            cudaPos = nbodyCuda.pos;
            cpuPos = nbodyCpu.pos;
            
            tolerance = 0.0005;
            
            for i = 1:numBodies
            
                if abs(cpuPos(i) - cudaPos(i)) > tolerance
                    passed = false;
                end
                
            end
            
        end
        
        function runBenchmark(obj, iterations)
            
            % Once without timing to prime device
            if ~useCpu
                obj.nbody.update(activeParams.timestep);
            end
            
            % Create time
            
            for i = 1:iterations
                obj.nbody.update(activeParams.timestep);
            end
            
            milliseconds = 0;
            
            % Get timer value
            
            interactionsPerSecond = 0;
            gFlops = 0;
            % computePerfStats(interactionsPerSecond, gFlops, milliseconds,
            % iterations)
            
            disp(sprintf('%d bodies, total time for %d iterations: %.3f ms\n', ...
                         numBodies, iterations, milliseconds));       
            disp(sprintf('= %.3f billion interactions per second\n', ...
                         interactionsPerSecond));
            disp(sprintf('= %.3f GFLOP/s at %d flops per interaction\n', ...
                         gflops, flopsPerInteraction));            
        end        
     
        function display(obj)
            obj.renderer.display();
        end         
        
        
        
    end
    
end

