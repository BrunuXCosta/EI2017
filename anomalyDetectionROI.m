%% Initialization
clear;
clc;
close all;
m = 2;
v = VideoReader('atrium.avi');
vw = VideoWriter('plot.mp4', 'MPEG-4');
open(vw);
scale = 1/6;
v.currentTime = 0;
maxFrames = v.Duration * v.FrameRate;
frame = readFrame(v);
invscale = 1/scale;
scaledHeight = size(imresize(frame, scale), 1);
scaledWidth = size(imresize(frame, scale), 2);
for i = 1 : scaledHeight
    for j = 1 : scaledWidth
        clouds(i, j) = teda();
    end
end
k = 1;
kk = [0]; red = [0]; green = [0]; blue = [0]; ecc = [0]; th = [0];
ax1 = subplot(2, 1, 1);
ax2 = subplot(2, 1, 2);
f = figure(1), p = plot(ax1, kk, red, kk, green, kk, blue);
figure(1), p2 = plot(ax2, kk, th, kk, ecc);
title(ax1, 'Raw Pixels');
title(ax2, 'Eccentricity');
p(1).Color = 'red';
p(2).Color = 'green';
p(3).Color = 'blue';

%% Stream processing
% Can be replaced for infinite size stream
while (v.CurrentTime <= v.Duration - 0.05)   
    originalFrame = readFrame(v);
    frame = imresize(originalFrame, scale);
    newFrame = ones(scaledHeight, scaledWidth);    
    for i = 1 : size(newFrame, 1)
        for j = 1 : size(newFrame, 2)            
            pixel = frame(i, j, :);
            % Input for TEDA
            x(:) = double(pixel);
            [clouds(i, j), E] = clouds(i, j).AddPoint(x, k);
            % Plot ROI info            
            if (i == floor(172 * scale) && j == floor(574 * scale))
                kk(k) = k;
                red(k) = x(1);
                green(k) = x(2);
                blue(k) = x(3);
                ecc(k) = E;
                th(k) = (m ^ 2 + 1)/(2 * k);
                p(1).XData = kk;
                p(2).XData = kk;
                p(3).XData = kk;
                p(1).YData = red;
                p(2).YData = green;
                p(3).YData = blue;
                p2(1).XData = kk;
                p2(2).XData = kk;
                p2(1).YData = th;
                p2(2).YData = ecc;
                ax2.YLim = [0 0.2];
            end
            if (E > (m ^ 2 + 1)/(2 * k))                
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
    pframe = getframe(f);
    writeVideo(vw, pframe);
    figure(2), imshow(originalFrame, 'Border','tight');             
    v.currentTime = v.currentTime + 0.05;
    k = k + 1;
end
close(vw);