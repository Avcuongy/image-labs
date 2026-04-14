I = imread('crackfull.png');
if size(I, 3) == 3
    I_gray = rgb2gray(I);
else
    I_gray = I;
end

level = graythresh(I_gray);
J2 = imbinarize(I_gray, level);

% Tạo cửa sổ neighborhood 5x5
se = strel('square', 5);

% Thực hiện Dilation (Nở) và Erosion (Co)
J_dilate = imdilate(J2, se);
J_erode = imerode(J2, se);

J_cracks = imsubtract(J_dilate, J_erode);

% B1: Đảo ảnh (vết nứt đen → trắng để closing lấp được)
J2_inv = ~J2;

% B2: Closing để lấp vết nứt
se_close = strel('square', 15);
J5_inv = imclose(J2_inv, se_close);

% B3: Opening để loại nhiễu trắng nhỏ còn sót
se_open = strel('square', 5);
J5_inv = imopen(J5_inv, se_open);

% B4: Đảo lại
J5 = ~J5_inv;

figure;
subplot(1,2,1); imshow(J_cracks); title('Vết nứt/Biên gạch');
subplot(1,2,2); imshow(J5); title('Đã xóa nứt');