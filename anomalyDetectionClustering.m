%% Initialization
clear;
clc;
close all;
m = 3;
v = VideoReader('atrium.avi');
vw = VideoWriter('clustering.mp4', 'MPEG-4');
open(vw);
scale = 1/6;
v.currentTime = 0;
maxFrames = v.Duration * v.FrameRate;
frame = readFrame(v);
invscale = 1/scale;
scaledHeight = size(imresize(frame, scale), 1);
scaledWidth = size(imresize(frame, scale), 2);
colors = {'green', 'red', 'cyan', 'magenta', 'blue', 'white', 'yellow', 'black'};
for i = 1 : scaledHeight
    for j = 1 : scaledWidth
        clouds(i, j) = teda();
    end
end
k = 1;

%% Stream processing
% Can be replaced for infinite size stream
while (v.CurrentTime <= v.Duration - 0.05)   
    originalFrame = readFrame(v);
    frame = imresize(originalFrame, scale);
    newFrame = ones(scaledHeight, scaledWidth);
    objectClusterer = AutoCloud(m);    
    for i = 1 : size(newFrame, 1)
        for j = 1 : size(newFrame, 2)            
            pixel = frame(i, j, :);
            x(:) = double(pixel);
            [clouds(i, j), E] = clouds(i, j).AddPoint(x, k);            
            if (E > (m ^ 2 + 1)/(2 * k))
                input = [i j];
                objectClusterer = objectClusterer.addPoint(input);
                % Highlight anomaly areas
                for l = floor(-invscale) : 0
                    for o = floor(-invscale) : 0
                        current = squeeze(originalFrame(max(min(i*invscale + l, size(originalFrame, 1)), 1), max(min(j*invscale + o, size(originalFrame, 2)), 1), :));
                        highlighted = uint8(0.5 * current') + uint8(0.5 * [255 255 0]);
                        originalFrame(max(min(i*invscale + l, size(originalFrame, 1)), 1), max(min(j*invscale + o, size(originalFrame, 2)), 1), :) = highlighted;
                    end                    
                end                            
            end
        end        
    end    
    % Show resulting image and draw cluster centers    
    f = figure(1), imshow(originalFrame, 'Border','tight');         
    for l = 1 : size(objectClusterer.cloudList, 2) 
        if (objectClusterer.cloudList(1).var == 0), break; end;
        pos = [objectClusterer.cloudList(l).mu(2) * invscale, objectClusterer.cloudList(l).mu(1) * invscale] - 10;
        f = figure(1), rectangle('Position', [pos 20 20], 'LineWidth', 1, 'FaceColor', colors{l}, 'EdgeColor', colors{l}, 'Curvature', [1, 1]);
    end      
    pframe = getframe(f);
    writeVideo(vw, pframe);
    v.currentTime = v.currentTime + 0.05;
    k = k + 1
end
close(vw);