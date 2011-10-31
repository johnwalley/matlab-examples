classdef ParticleRenderer < handle
    %PARTICLERENDERER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        pos
        numParticles
        pointSize
        spriteSize
        
    end
    
    properties (Access=private)
        
        Window
        Axes
        Particles
        
        XMax = 20
        
    end
    
    methods
        
        function obj = ParticleRenderer(pos)
            
            obj.spriteSize = 0.75;
        
            obj.Window = figure( ...
                'Name', sprintf('N-Body (%d bodies): 0.0 fps | 0.0 BIPS | 0.0 GFLOP/s', obj.numParticles), ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'Renderer', 'OpenGL' );
             
            obj.Axes = axes( ...
                'Parent', obj.Window, ...
                'Position', [0 0 1 1], ...
                'Color', 'black', ...
                'XLim', [-obj.XMax obj.XMax], ...
                'YLim', [-obj.XMax obj.XMax], ...
                'XTick', [], ...
                'YTick', [], ...
                'XLimMode', 'manual', ...
                'YLimMode', 'manual');             
            
%             obj.Particles = line( ...
%                 'XData', pos(:, 1), ...
%                 'YData', pos(:, 2), ...
%                 'LineStyle', 'none', ...
%                 'Marker', '.', ...
%                 'Color', 'white', ...
%                 'Parent', obj.Axes);
            
            rgb = imread('starfield.png');
            imshow(rgb, 'XData', [-obj.XMax obj.XMax], 'YData', [-obj.XMax obj.XMax], 'Parent', obj.Axes);

            hold on
            c = imread('point.gif');
            
            for iParticle = 1:size(pos, 1)
                
               h  = imshow( repmat(c, [1 1 3]), ...
                            'XData', [pos(iParticle, 1)-obj.spriteSize, pos(iParticle, 1)+obj.spriteSize], ...
                            'YData', [pos(iParticle, 2)-obj.spriteSize, pos(iParticle, 2)+obj.spriteSize], ...
                            'Parent', obj.Axes ); 
                
                set(h, 'AlphaData', double(c)/255);
                
                obj.Particles(iParticle) = h;
                
            end
            
            hold off
        
        end % ParticleRenderer
        
        function display(obj)

            obj.drawPoints();
            
            drawnow();
            
        end % display
        
        function setWindowTitle(obj, fps)
            
        	set(obj.Window, 'Name', fps);
   
        end % setWindowTitle
        
    end
    
    methods (Access=protected)
        
        function drawPoints(obj, colour)
            
            for iParticle = 1:size(obj.pos, 1)
                
                set( obj.Particles(iParticle), ...
                     'XData', [obj.pos(iParticle, 1)-obj.spriteSize, obj.pos(iParticle, 1)+obj.spriteSize], ...
                     'YData', [obj.pos(iParticle, 2)-obj.spriteSize, obj.pos(iParticle, 2)+obj.spriteSize] );
                                
            end
 
        end % drawPoints
        
    end
    
end

