classdef ParticleRenderer < handle
    %PARTICLERENDERER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        
        pos
        numParticles
        pointSize
        spriteSize
        
    end
    
    properties (Access=private)
        
        Window
        Axes
        
        DisplayFcn
        
        Demo
        
    end    
    
    methods
        
        function obj = ParticleRenderer(demo)
        
            obj.Window = figure( ...
                'Name', sprintf('N-Body (0 bodies): 0.0 fps | 0.0 BIPS | 0.0 GFLOP/s', obj.numParticles), ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'Renderer', 'OpenGL' );
             
            obj.Axes = axes( ...
                'Parent', obj.Window, ...
                'Position', [0 0 1 1], ...
                'XLim', [-1 1], ...
                'YLim', [-1 1], ...
                'XTick', [], ...
                'YTick', [] );    
            
            obj.Demo = demo;
            
        end % ParticleRenderer
        
        function setDisplayFcn(obj, fcn)
            
            obj.DisplayFcn = fcn;
            
        end % setDisplayFcn
        
        function mainLoop(obj)
            
            for i = 1:100
            
                obj.DisplayFcn(obj.Demo.nbody);
                
            end
            
        end
        
        function display(obj)
            
           
            obj.drawPoints();
            
        end % display
        
    end
    
    methods (Access=protected)
        
        function drawPoints(obj, colour)
            
           disp(obj.Demo.nbody.pos(1,:));
            
        end % drawPoints
        
    end
    
end

