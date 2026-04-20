clc; clear; close all;

I = imread('crackfull.png'); 
if size(I, 3) == 3
    I_gray = rgb2gray(I);
else
    I_gray = I;
end

I = im2uint8(I);

level = graythresh(I_gray);
J2 = imbinarize(I_gray, level);


% 1. Giữ lại đường kẻ dọc
se_v = strel('line', 48, 90); 
vertical_lines = imerode(imdilate(J2, se_v), se_v);

% 2. Giữ lại đường kẻ ngang
se_h = strel('line', 40, 0); 
horizontal_lines = imerode(imdilate(J2, se_h), se_h);

J5 = vertical_lines & horizontal_lines;
se = strel('square', 5); 

J5_erosion = imerode(J5, se);
figure;
imshow(J5_erosion); title('Ảnh J5 Xóa nứt');




% Đảo ảnh J2
J2_inv = ~J2;

% Closing trên ảnh đảo để lấp vết nứt
% close lấp nứt
se_close = strel('square', 10);
J5_inv = imclose(J2_inv, se_close);

% Loại bỏ các vùng trắng nhỏ hơn ngưỡng
J5_inv = bwareaopen(J5_inv, 100);

% Erosion
se_erode = strel('square', 2);
J5_inv = imerode(J5_inv, se_erode);

% Đảo ngược lại
J5 = ~J5_inv;

figure;
imshow(J5); title('Đã xóa nứt');

