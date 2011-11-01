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
            
            rgb = imread('images\starfield.png');
            imshow(rgb, 'XData', [-obj.XMax obj.XMax], 'YData', [-obj.XMax obj.XMax], 'Parent', obj.Axes);

            hold on
            c = imread('images\point.gif');
            
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
            
            [~, idx] = sort(obj.pos(:, 3));
            
            scaling = 0.1 + (-obj.pos(:, 3) + max(obj.pos(:, 3))  ) ./ (max(obj.pos(:, 3)) - min(obj.pos(:, 3)));
            
            for iParticle = 1:max(idx)
                
                set( obj.Particles(iParticle), ...
                     'XData', [obj.pos(idx(iParticle), 1)-scaling(idx(iParticle))*obj.spriteSize, obj.pos(idx(iParticle), 1)+scaling(idx(iParticle))*obj.spriteSize], ...
                     'YData', [obj.pos(idx(iParticle), 2)-scaling(idx(iParticle))*obj.spriteSize, obj.pos(idx(iParticle), 2)+scaling(idx(iParticle))*obj.spriteSize] );
                                
            end
 
        end % drawPoints
        
    end
    
end

