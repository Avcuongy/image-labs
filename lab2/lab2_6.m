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


% padding
function padded = pad_image(img)
    padded = padarray(img, [2 2], 'symmetric');
end

% mask random
function mask = random_mask(sz, ratio)
    total = sz(1) * sz(2);
    num = round(total * ratio);
    
    mask = false(sz);
    
    idx = randperm(total, num);
    mask(idx) = true;
end

% smooth
function [result, mean_values] = smooth_marked_pixels(frame, mask)
    % Padding 2 pixel
    padded = padarray(frame, [2 2], 'symmetric');
    
    result = frame;
    [h, w] = size(frame);
    mean_values = []; % lưu giá trị trung bình

    for i = 1:h
        for j = 1:w
            if mask(i,j) == true
                % lấy window 5x5
                window = padded(i:i+4, j:j+4);
                
                % tính trung bình
                m = mean(sub_window(:));

                result(i,j) = m;
                mean_values(end+1) = m;
            end
        end
    end
end


frame = frames{10};   % lấy frame

mask = random_mask(size(frame), 0.1);

[smoothed, mean_vals] = smooth_marked_pixels(frame, mask);

%imshowpair(frame, smoothed, 'montage');
%title('Before vs After');


orig_vals = frame(mask);
new_vals  = smoothed(mask);

figure;
subplot(1,2,1);
histogram(orig_vals, 256);
title('Before');

subplot(1,2,2);
histogram(new_vals, 256);
title('After');
