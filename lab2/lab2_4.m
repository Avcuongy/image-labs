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

% 4. Hist toàn video
all_pixels = [];

for i = 1:length(frames)
    all_pixels = [all_pixels; frames{i}(:)];
end

figure;
imhist(all_pixels(:), 256);
title('Histogram toàn video');