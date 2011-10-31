function nbody(varargin)

% Create an instance of the inputParser class.
p = inputParser;

% Define inputs that default when not passed:
p.addParamValue('benchmark', false, @(x)islogical(x));
p.addParamValue('useCpu', false, @(x)islogical(x));

p.parse(varargin{:});

benchmark = p.Results.benchmark;
useCpu = p.Results.useCpu;
compareToCpu = false;

flopsPerInteraction = 20;

fpsCount = 0;
fpsLimit = 5;

numBodies = 16;
numIterations = 0; % Run until exit

demoParams = struct('timestep', {0.016, 0.016}, ...
                     'clusterScale', {1.54, 0.68}, ...
                     'velocityScale', {8.0, 20.0}, ...
                     'softening', {0.1, 0.1}, ...
                     'damping', {1.0, 1.0}, ...
                     'pointSize', {1.0, 0.8}, ...
                     'x', {0, 0}, ...
                     'y', {-2, -2}, ...
                     'z', {-100, -30});
                
numDemos = numel(demoParams);
activeDemo = 1;                  

activeParams = demoParams(activeDemo);
                  
demo = NBodyDemo;
demo = init(demo, numBodies, useCpu);
demo = reset(demo);

if benchmark
    
    if (numIterations <= 0) 
        numIterations = 10;
    end
    
    runBenchmark(demo, numIterations);
    
elseif compareToCpu
    
    testResults = compareResults(demo, numBodies);
    
    if testResults
        fprintf('QA_PASSED');
    else
        fprintf('QA_FAILED');
    end
    
else
    
    t = tic;
    
    for iStep = 1:2500
        
        demo = updateSimulation(demo);
        
        fpsCount = fpsCount + 1;
        
        if fpsCount >= fpsLimit        
        
            milliseconds = 1000.0 * toc(t);
            t = tic;

            [interactionsPerSecond, gflops] = computePerfStats( milliseconds, ...
                                                                1)      
             
            milliseconds = milliseconds / fpsCount;
            
            ifps = 1 / (milliseconds / 1000);
            
            fps = sprintf('N-Body (%d bodies): %0.1f fps | %0.1f BIPS | %0.1f GFLOP/s', ...
                           numBodies, ifps, interactionsPerSecond, gflops);
     
            demo.renderer.setWindowTitle(fps);
            
            fpsCount = 0; 
            
            if ifps > 1
                fpsLimit = ifps;
            else
                fpsLimit = 1;
            end
            
        end
        
        demo.renderer.pos = demo.nbody.pos;
        demo.renderer.display();
    end
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function out = NBodyDemo
        
        out = struct('nbody', 0, 'nbodyCuda', 0, 'nbodyCpu', 0, ...
                     'renderer', 0, 'hPos', 0, 'hVel', 0, 'hColor', 0);
    
    end % NBodyDemo

    function out = init(out, numBodies, useCpu)

        if useCpu
            out.nbodyCpu = BodySystemCPU(numBodies);
            out.nbody = out.nbodyCpu;
            out.nbodyCuda = 0;
        else
            out.nbodyCpu = BodySystemCUDA(numBodies);
            out.nbody = out.nbodyCuda;
            out.nbodyCpu = 0;
        end

        out.nbody.softening = 0.1;
        out.nbody.damping = 1.0;

        % Create timer

        if (~benchmark && ~compareToCpu)
            out.renderer = ParticleRenderer(out.nbody.pos);
            resetRenderer(out);
        end

    end % init

    function out = reset(out)

        [hPos, hVel, hColor] = randomiseBodies(activeParams.clusterScale, ...
                                               activeParams.velocityScale, ...
                                               numBodies);    
        
        out.nbody.pos = hPos;
        out.nbody.vel = hVel;

    end % reset

    function resetRenderer(out)

        colour = [0.4 0.8 0.1 1.0];
        %out.renderer.baseColour = colour;

        %obj.renderer.colors = obj.hColour;

    end % resetRenderer

    function out = updateSimulation(out)
        
        out.nbody = out.nbody.update(activeParams.timestep);
        
    end % updateSimulation

    function passed = compareResults(out, numBodies)

        assert(out.nbodyCuda, 'CUDA implementation must be initialised');

        passed = true;

        out.nbody.update(0.001);

        out.nbodyCpu = BodySytemCPU(numBodies);

        out.nbodyCpu.pos = out.hPos;
        out.nbodyCpu.vel = out.hVel;

        out.nbodyCpu.update(0.001);

        cudaPos = nbodyCuda.pos;
        cpuPos = nbodyCpu.pos;

        tolerance = 0.0005;

        for iBody = 1:numBodies

            if abs(cpuPos(iBody) - cudaPos(iBody)) > tolerance
                passed = false;
            end

        end

    end % compareResults

    function runBenchmark(out, iterations)

        % Once without timing to prime device
        if ~useCpu
            out.nbody = out.nbody.update(activeParams.timestep);
        end

        t = tic;

        for i = 1:iterations
            out.nbody = out.nbody.update(activeParams.timestep);
        end

        milliseconds = toc(t);

        [interactionsPerSecond, gFlops] = computePerfStats(milliseconds, ...
                                                           iterations);

        fprintf('%d bodies, total time for %d iterations: %.3f ms\n', ...
                     numBodies, iterations, milliseconds);       
        fprintf('= %.3f billion interactions per second\n', ...
                     interactionsPerSecond);
        fprintf('= %.3f GFLOP/s at %d flops per interaction\n', ...
                     gFlops, flopsPerInteraction);            
    
    end % runBenchmark

    function [interactionsPerSecond, gflops] = computePerfStats(milliseconds, ...
                                                                iterations)
        % double precision uses intrinsic operation followed by refinement,
        % resulting in higher operation count per interaction.
        % (Note Astrophysicists use 38 flops per interaction no matter what,
        % based on "historical precident", but they are using FLOP/s as a 
        % measure of "science throughput". We are using it as a measure of 
        % hardware throughput.  They should really use interactions/s...
        % const int flopsPerInteraction = fp64 ? 30 : 20;

        interactionsPerSecond = numBodies^2;
        interactionsPerSecond = interactionsPerSecond * 1e-9 * iterations * 1000 / milliseconds;
        gflops = interactionsPerSecond * flopsPerInteraction;

    end % computePerfStats

end % nbody

function [pos, vel, colour] = randomiseBodies(clusterScale, ...
                                              velocityScale, ...
                                              numBodies)
                     
    scale = clusterScale * max(1.0, numBodies / 1024.0);  
    vscale = velocityScale * scale;
    
    i = 1;
    
    while i <= numBodies
        
        point = 2*rand(1, 3) - 1;
        lenSqr = dot(point, point);
        if lenSqr > 1
            continue;
        end
        velocity = 2*rand(1, 3) - 1;
        lenSqr = dot(velocity, velocity);
        if lenSqr > 1
            continue;
        end
        
        pos(i, :) = point * scale;
        vel(i, :) = velocity * vscale;
        
        i = i + 1;
        
    end
    
    if nargout >=3
        colour = rand(numBodies, 3);
    end 

end % randomiseBodies
