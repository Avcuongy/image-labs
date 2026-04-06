clc; clear; close all;

%% load 
% thử Peppers.png
img = imread('coins.png');

% convert sang RGB giả
rgb = repmat(img, [1 1 3]);
%rgb = img

% Đảm bảo ảnh là grayscale
gray = rgb2gray(rgb);

%% Threshold cố định
T = 100;
BW_global = gray > T;

figure;
subplot(1,3,1); imshow(gray); title('Grayscale');
subplot(1,3,2); imshow(BW_global); title(['Global Threshold = ' num2str(T)]);
subplot(1,3,3); imhist(gray); hold on; xline(T, 'r', 'LineWidth', 2); title('Histogram + Threshold');

%% Làm sạch
% Loại bỏ nhiễu nhỏ
BW_clean = bwareaopen(BW_global, 50);

% Fill lỗ trong coin
BW_filled = imfill(BW_clean, 'holes');

figure;
subplot(1,2,1);imshow(BW_global);title('Before cleaning');
subplot(1,2,2);imshow(BW_filled);title('After cleaning');