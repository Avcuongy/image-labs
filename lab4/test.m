%% 1. Load ảnh
I = imread('crackfull.png');
if size(I, 3) == 3
    I_gray = rgb2gray(I);
else
    I_gray = I;
end

%% 2. Binarization
level = graythresh(I_gray);
J2 = imbinarize(I_gray, level);
figure; imshow(J2); title('Binarization');

%% 3. Dilation và Erosion 5x5
se = strel('square', 5);
J_dilate = imdilate(J2, se);
J_erode  = imerode(J2, se);
figure;
subplot(1,2,1); imshow(J_dilate); title('Dilation');
subplot(1,2,2); imshow(J_erode);  title('Erosion');

%% 4. Morphological Gradient → thấy rõ vết nứt nhất
se = strel('square', 5);
J_dilate = imdilate(J2, se);
J_erode  = imerode(J2, se);
J_cracks = imsubtract(J_dilate, J_erode);  % Gradient = Dilation - Erosion
figure;
imshow(J_cracks); title('Vết nứt/Biên gạch - Morphological Gradient');

%% 5. Xóa vết nứt → J5
J2_inv   = ~J2;
se_close = strel('square', 10);
J5_inv   = imclose(J2_inv, se_close);
J5_inv   = bwareaopen(J5_inv, 100);
se_erode = strel('square', 2);
J5_inv   = imerode(J5_inv, se_erode);
J5       = ~J5_inv;
figure;
subplot(1,2,1); imshow(J_cracks); title('Vết nứt/Biên gạch');
subplot(1,2,2); imshow(J5);       title('Đã xóa nứt');

%% 6. Đếm số viên gạch
[L, ~] = bwlabel(J5);
stats   = regionprops(L, 'Area', 'Extent', 'Solidity');
areas      = [stats.Area];
extents    = [stats.Extent];
solidities = [stats.Solidity];

threshold_area     = 2000;
threshold_extent   = 0.7;
threshold_solidity = 0.7;

valid_labels = find( ...
    areas      > threshold_area     & ...
    extents    > threshold_extent   & ...
    solidities > threshold_solidity ...
);
num = length(valid_labels);
fprintf('Số lượng ô gạch đếm được là: %d\n', num);

L_filtered = ismember(L, valid_labels);
[L2, ~]    = bwlabel(L_filtered);
RGB_label  = label2rgb(L2, @jet, 'k', 'shuffle');
figure;
imshow(RGB_label); title(['Số ô gạch: ', num2str(num)]);

%% 7. Lọc nhiễu Median thủ công
I_noise      = imnoise(I_gray, 'salt & pepper', 0.10);
[rows, cols] = size(I_noise);
J_median     = zeros(rows, cols, 'uint8');

for i = 2:rows-1
    for j = 2:cols-1
        temp          = I_noise(i-1:i+1, j-1:j+1);
        sorted_vector = sort(temp(:));
        J_median(i,j) = sorted_vector(5);  % phần tử giữa trong 9 phần tử
    end
end

figure;
subplot(1,2,1); imshow(I_noise);   title('Ảnh 10% nhiễu');
subplot(1,2,2); imshow(J_median);  title('Lọc Median thủ công');