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

% 3. Smooth averaging
function smoothed = temporal_smoothing(frames, window)
    n = length(frames);
    half = floor(window/2);
    
    smoothed = {};
    idx = 0;
    
    for i = (1+half):(n-half)
        sum_img = zeros(size(frames{1}));
        
        for j = -half:half
            sum_img = sum_img + double(frames{i+j});
        end
        
        avg = uint8(sum_img / window);
        
        idx = idx + 1;
        smoothed{idx} = avg;
    end
end

smooth_frames = temporal_smoothing(frames, 5); % pick

figure;
%imshow(smooth_frames{1});
%title('Average smoothing');

%imshowpair(frames{3}, smooth_frames{1}, 'montage');
%title('Before vs After (Temporal Smoothing)');

%for k = 1:5
%    figure;
%    imshowpair(frames{k+2}, smooth_frames{k}, 'montage');
%    title(['Frame ', num2str(k)]);
%end

for k = 1:5
    original = frames{k+2};
    smooth = smooth_frames{k};
    diff = uint8(abs(double(original) - double(smooth)));
    
    figure;
    subplot(1,3,1); imshow(original); title('Original');
    subplot(1,3,2); imshow(smooth); title('Smoothed');
    subplot(1,3,3); imshow(diff); title('Difference');
end