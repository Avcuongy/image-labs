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
function [result, mean_values] = smooth_padding_original_only(frame, mask)

    [h, w] = size(frame);
    padded = padarray(frame, [2 2], 'symmetric');
    
    result = frame;
    mean_values = [];

    for i = 1:h
        for j = 1:w
            if mask(i,j)
                
                % Window 5x5 trên padded
                window = padded(i:i+4, j:j+4);
                
                % Xác định vùng hợp lệ trong ảnh gốc
                r1 = max(1, i-2);
                r2 = min(h, i+2);
                c1 = max(1, j-2);
                c2 = min(w, j+2);

                % Kích thước vùng hợp lệ
                valid_h = r2 - r1 + 1;
                valid_w = c2 - c1 + 1;

                % Lấy phần tương ứng trong window
                row_start = 3 - (i - r1);
                col_start = 3 - (j - c1);

                sub_window = window(row_start:row_start+valid_h-1, col_start:col_start+valid_w-1);

                % Tính trung bình chỉ trên ảnh gốc
                m = mean(sub_window(:));

                result(i,j) = m;
                mean_values(end+1) = m;
            end
        end
    end
end

frame = frames{10};   % lấy frame

mask = random_mask(size(frame), 0.1);

smoothed = smooth_padding_original_only(frame, mask);

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
