clc; clear; close all;

video = VideoReader('sample.avi');

figure;

while hasFrame(video)
    frame = readFrame(video);
    gray = rgb2gray(frame);

    % Hiển thị frame
    subplot(1,2,1);
    imshow(gray);
    title('Video Frame');

    % Hiển thị hist
    subplot(1,2,2);
    imhist(gray, 256);
    title('Histogram');

    drawnow; % cập nhật hình
end