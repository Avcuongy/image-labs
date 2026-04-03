clc; clear; close all;

video = VideoReader('sample.avi');

frames = {};
enhanced_frames = {};
count = 0;

while hasFrame(video)
    frame = readFrame(video);
    gray = rgb2gray(frame);
    
    count = count + 1;
    frames{count} = gray;

    % áp dụng CLAHE ngay
    enhanced_frames{count} = adapthisteq(gray);
end

fprintf('Total frames: %d\n', count);

% chọn frame
idx = 10;

figure;

% ảnh
subplot(2,2,1);
imshow(frames{idx});
title('Before');

subplot(2,2,2);
imshow(enhanced_frames{idx});
title('After adapthisteq');

% hist
subplot(2,2,3);
imhist(frames{idx});
title('Histogram Before');

subplot(2,2,4);
imhist(enhanced_frames{idx});
title('Histogram After');