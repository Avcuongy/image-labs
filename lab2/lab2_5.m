clc; clear; close all;

video = VideoReader('sample.avi');

frames = {}; % mỗi phần tử là 1 ảnh 2D
count = 0;

while hasFrame(video)
    frame = readFrame(video);
    gray = rgb2gray(frame);
    
    count = count + 1;
    frames{count} = gray;
end

fprintf('Total frames: %d\n', count);

% 5. adapthisteq
enhanced_frames = {};

% Áp dụng từng frame
for i = 1:length(frames)
    enhanced_frames{i} = adapthisteq(frames{i});
end

idx = 10;

figure;

subplot(1,2,1);
imhist(frames{idx});
title('Before');

subplot(1,2,2);
imhist(enhanced_frames{idx});
title('After adapthisteq');