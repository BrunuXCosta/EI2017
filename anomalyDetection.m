%% Initialization
clear;
clc;
close all;
m = 2;
v = VideoReader('atrium.avi');
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

%% Stream processing
vmap = zeros(size(clouds));
% Can be replaced for infinite size stream
while (v.CurrentTime <= v.Duration - 0.05)     
    originalFrame = readFrame(v);
    frame = imresize(originalFrame, scale);
    newFrame = ones(scaledHeight, scaledWidth);       
    for i = 1 : size(newFrame, 1)
        for j = 1 : size(newFrame, 2)               
            pixel = frame(i, j, :);
            % Input for TEDA
            x = squeeze(double(pixel))';              
            [clouds(i, j), E] = clouds(i, j).AddPoint(x, k);              
            vmap(i, j) = clouds(i, j).var;            
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
    vmap = vmap - min(min(vmap));
    vmap = vmap/max(max(vmap));
    imshowpair(originalFrame, imresize(vmap, invscale), 'montage')
    v.currentTime = v.currentTime + 0.05;    
    k = k + 1
end