clc; clear; close all;

%% load 
% thử Peppers.png
img = imread("coins.png");

% convert sang RGB giả
rgb = repmat(img, [1 1 3]);
%rgb = img

% Đảm bảo grayscale
gray = rgb2gray(rgb);

%% Compare
% threshold = 100 cố định
T = 100;
BW_global = gray > T;

% Otsu
level = graythresh(gray);
BW_otsu = imbinarize(gray, level);

% Adaptive threshold
BW_adapt = imbinarize(gray, 'adaptive', 'Sensitivity', 0.5);

% show
figure;
subplot(1,3,1); imshow(BW_global); title('Global');
subplot(1,3,2); imshow(BW_otsu); title('Otsu');
subplot(1,3,3); imshow(BW_adapt); title('Adaptive');

% đếm số lượng vùng
[~, num_global] = bwlabel(BW_global);
[~, num_otsu]   = bwlabel(BW_otsu);
[~, num_adapt]  = bwlabel(BW_adapt);
disp([num_global, num_otsu, num_adapt]);

%% Gán nhãn
% Chọn phương pháp tốt nhất
BW_best = BW_global;

figure;imshow(BW_best);title('Best Segmentation Result');

% làm sạch
BW_clean = bwareaopen(BW_best, 50); % Loại nhiễu nhỏ
BW_clean = imfill(BW_clean, 'holes'); % Fill lỗ trong coin

figure;imshow(BW_clean);title('Cleaned Binary Image');

% Gán nhãn vùng
[L, num_coins] = bwlabel(BW_clean);
figure;
imshow(label2rgb(L)); title(['Labeled Regions - Total: ' num2str(num_coins)]);

%% count coins
stats = regionprops(L, 'BoundingBox', 'Centroid');
figure;imshow(BW_clean);hold on;
for i = 1:num_coins
    % Vẽ khung
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 1);
    % Đánh dấu tâm
    plot(stats(i).Centroid(1), stats(i).Centroid(2), 'b*');
    % Ghi số thứ tự
    text(stats(i).Centroid(1), stats(i).Centroid(2), num2str(i), 'Color', 'black');
end
title(['Detected Coins: ', num2str(num_coins)]);