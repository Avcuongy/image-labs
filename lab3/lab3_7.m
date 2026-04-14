clc; clear; close all;

%% Load ảnh
img = imread('british-coins.jpg');

% Nếu ảnh grayscale thì convert về RGB giả
if size(img,3) == 1
    rgb = repmat(img, [1 1 3]);
else
    rgb = img;
end

gray = rgb2gray(rgb);

%% Threshold (Otsu tốt nhất cho case này)
level = graythresh(gray);
BW = imbinarize(gray, level);

figure; imshow(BW); title('Otsu Gud');

%% đảo ảnh (coin -> trắng)
BW = ~BW;

%% Làm sạch mạnh luôn !!!

% 1. Xoá chi tiết nhỏ bên trong coin
BW = imopen(BW, strel('disk',5));

% 2. Loại nhiễu nhỏ
BW = bwareaopen(BW, 200);

% 3. Đóng biên coin
BW = imclose(BW, strel('disk',7));

% 4. Fill toàn bộ coin
BW = imfill(BW, 'holes');

figure; imshow(BW); title('Cleaned Binary');

%% Lọc theo hình dạng
stats = regionprops(BW, 'Area', 'Perimeter', 'BoundingBox', 'Centroid');

BW_final = false(size(BW));
count = 0;

for i = 1:length(stats)
    area = stats(i).Area;
    perim = stats(i).Perimeter;
    
    % circularity (độ tròn)
    circularity = 4*pi*area / (perim^2 + eps);
    
    % Điều kiện giữ lại coin
    if area > 500 && circularity > 0.6
        count = count + 1;
        BW_final = BW_final | ismember(bwlabel(BW), i);
    end
end

figure; imshow(BW_final); title('Filtered Coins');

%% Gán nhãn
[L, num_coins] = bwlabel(BW_final);

figure;
imshow(label2rgb(L));
title(['Total Coins: ', num2str(num_coins)]);

%% Vẽ bounding box
stats = regionprops(L, 'BoundingBox', 'Centroid');

figure; imshow(BW_final); hold on;
for i = 1:num_coins
    rectangle('Position', stats(i).BoundingBox, ...
        'EdgeColor', 'r', 'LineWidth', 1);
    
    plot(stats(i).Centroid(1), stats(i).Centroid(2), 'b*');
    
    text(stats(i).Centroid(1), stats(i).Centroid(2), ...
        num2str(i), 'Color', 'yellow');
end

title(['Detected Coins: ', num2str(num_coins)]);