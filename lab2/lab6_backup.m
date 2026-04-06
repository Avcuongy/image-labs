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

%fprintf('Total frames: %d\n', count);


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

function print_zero_padded_windows(frame, mask, max_print)

    [h, w] = size(frame);
    printed = 0;

    for i = 1:h
        for j = 1:w
            % Not border
            %not_border = (i > 2) && (i < h-1) && (j > 2) && (j < w-1);

            if mask(i,j) % && not_border

                % tạo window 5x5 zero-padding nếu ở biên
                window = zeros(5,5);

                for u = -2:2
                    for v = -2:2
                        r = i + u;
                        c = j + v;

                        if r >= 1 && r <= h && c >= 1 && c <= w
                            window(u+3, v+3) = frame(r,c);
                        else
                            window(u+3, v+3) = 0;
                        end
                    end
                end

                % in thông tin
                fprintf('Pixel (%d,%d): original = %d\n', i, j, frame(i,j));
                disp('Window 5x5 (zero-padded):');
                disp(window);
                fprintf('-------------------------\n');

                printed = printed + 1;

                if printed >= max_print
                    return;
                end
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

figure;
imshowpair(frame, smoothed, 'montage');
title('Before vs After');

print_zero_padded_windows(frame, mask, 100);