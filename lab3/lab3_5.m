clc; clear; close all;

%% load 
% thử Peppers.png
img = imread("coins.png");

% convert sang RGB giả
rgb = repmat(img, [1 1 3]);
%rgb = img

% Đảm bảo grayscale
gray = rgb2gray(rgb);

%% Otsu
% Tìm threshold ([0, 1])
level = graythresh(gray);
disp(level);

% Phân tách
BW_otsu = imbinarize(gray, level);

figure;
subplot(1,3,1);imshow(gray);title('Grayscale');
subplot(1,3,2);imshow(BW_otsu);title(['Otsu Result (level = ' num2str(level) ')']);
subplot(1,3,3);imhist(gray);hold on;xline(level*255, 'r', 'LineWidth', 2);title('Histogram + Otsu Threshold');

%% Làm sạch
% Loại nhiễu nhỏ
BW_clean = bwareaopen(BW_otsu, 50);

% Fill lỗ trong coin
BW_filled = imfill(BW_clean, 'holes');

figure;
subplot(1,2,1);imshow(BW_otsu);title('Before cleaning');
subplot(1,2,2);imshow(BW_filled);title('After cleaning');