clc; clear; close all;

%% load 
% thử Peppers.png
img = imread('british-coins.jpg');

% convert sang RGB giả
%rgb = repmat(img, [1 1 3]);
rgb = img

% Đảm bảo grayscale
gray = rgb2gray(rgb);

%% Adaptive threshold
BW_adapt = imbinarize(gray, 'adaptive', 'Sensitivity', 0.5);

figure;
subplot(1,3,1);imshow(gray);title('Grayscale');
subplot(1,3,2);imshow(BW_adapt);title('Adaptive Threshold');
subplot(1,3,3);imhist(gray);title('Histogram');

% Làm sạch
% Loại nhiễu nhỏ
BW_clean = bwareaopen(BW_adapt, 50);

% Fill lỗ trong coin
BW_filled = imfill(BW_clean, 'holes');

figure;
subplot(1,2,1);imshow(BW_adapt);title('Before cleaning');
subplot(1,2,2);imshow(BW_filled);title('After cleaning');