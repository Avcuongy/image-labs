clc; clear; close all;

%% load 
% thử Peppers.png
img = imread("coins.png");

% convert sang RGB giả
rgb = repmat(img, [1 1 3]);
%rgb = img

% grayscale chuẩn
gray1 = rgb2gray(rgb);

% lấy từng kênh
R = rgb(:,:,1);
G = rgb(:,:,2);
B = rgb(:,:,3);

figure;
subplot(2,2,1); imshow(gray1); title('Grayscale - rgb2gray');
subplot(2,2,2); imshow(R); title('Red channel');
subplot(2,2,3); imshow(G); title('Green channel');
subplot(2,2,4); imshow(B); title('Blue channel');

figure;
subplot(2,2,1); imhist(gray1); title('Histogram - rgb2gray');
subplot(2,2,2); imhist(R); title('Histogram - R');
subplot(2,2,3); imhist(G); title('Histogram - G');
subplot(2,2,4); imhist(B); title('Histogram - B');