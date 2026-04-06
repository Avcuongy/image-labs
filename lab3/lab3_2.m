clc; clear; close all;

%% load 
% thử Peppers.png
img = imread('coins.png');

% convert sang RGB giả
rgb = repmat(img, [1 1 3]);
%rgb = img

figure;
subplot(1,2,1); imshow(img); title("original");
subplot(1,2,2); imshow(rgb); title("rgb");

xyz = rgb2xyz(rgb);
lab = rgb2lab(rgb);
hsv = rgb2hsv(rgb);

figure;

% XYZ
subplot(3,3,1); imshow(xyz(:,:,1), []); title('X');
subplot(3,3,2); imshow(xyz(:,:,2), []); title('Y');
subplot(3,3,3); imshow(xyz(:,:,3), []); title('Z');

% LAB
subplot(3,3,4); imshow(lab(:,:,1), []); title('L');
subplot(3,3,5); imshow(lab(:,:,2), []); title('a');
subplot(3,3,6); imshow(lab(:,:,3), []); title('b');

% HSV
subplot(3,3,7); imshow(hsv(:,:,1), []); title('H');
subplot(3,3,8); imshow(hsv(:,:,2), []); title('S');
subplot(3,3,9); imshow(hsv(:,:,3), []); title('V');

% CYMK
rgb_double = im2double(rgb);

C = 1 - rgb_double(:,:,1);
M = 1 - rgb_double(:,:,2);
Y = 1 - rgb_double(:,:,3);

K = min(cat(3,C,M,Y), [], 3);

% Tránh chia cho 0
C = (C - K) ./ (1 - K + eps);
M = (M - K) ./ (1 - K + eps);
Y = (Y - K) ./ (1 - K + eps);

figure;
subplot(1,4,1); imshow(C); title('C');
subplot(1,4,2); imshow(M); title('M');
subplot(1,4,3); imshow(Y); title('Y');
subplot(1,4,4); imshow(K); title('K');