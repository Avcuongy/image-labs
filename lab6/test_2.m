%% ============================================================
%  HANDWRITING OCR + EXPORT HTML REPORT (FULL)
%% ============================================================
clc; clear; close all;

%% --- 1. READ IMAGE ---
imgPath = 'test.jpg';
img     = imread(imgPath);

if size(img,3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

%% --- 2. FILTERS ---
med         = medfilt2(gray, [3 3]);
gauss       = imgaussfilt(gray, 1.5);
med_gauss   = imgaussfilt(medfilt2(gray, [3 3]), 1.0);

se          = strel('disk', 1);
morph_open  = imopen(gray, se);
morph_close = imclose(gray, se);

logKernel   = fspecial('log', [5 5], 1.0);
matched     = mat2gray(abs(imfilter(double(gray), logKernel, 'replicate')));

wiener_img  = wiener2(gray, [5 5]);
sharp       = imsharpen(gray, 'Radius', 2, 'Amount', 1.5);
clahe_img   = adapthisteq(gray, 'ClipLimit', 0.02);

filterNames = {
    'Median', 'Gaussian', 'Median+Gaussian', ...
    'Morph Opening', 'Morph Closing', ...
    'Matched (LoG)', 'Wiener', 'Sharpen', ...
    'CLAHE'
};

filteredImgs = {
    med, gauss, med_gauss, ...
    morph_open, morph_close, ...
    uint8(matched * 255), ...
    wiener_img, sharp, clahe_img
};

numFilters = length(filterNames);
results    = cell(numFilters, 3);

%% --- 3. OCR ---
for i = 1:numFilters
    img_uint8 = im2uint8(filteredImgs{i});

    level = graythresh(img_uint8);
    bw    = imbinarize(img_uint8, level);

    if mean(bw(:)) > 0.5
        bw = ~bw;
    end

    bw_clean = bwareaopen(bw, 30);

    ocrResult = ocr(bw_clean, 'LayoutAnalysis', 'Block');
    text      = strtrim(ocrResult.Text);

    conf = ocrResult.CharacterConfidences;
    conf = conf(~isnan(conf) & conf >= 0);
    avgConf = mean(conf) * 100;

    results{i,1} = filterNames{i};
    results{i,2} = text;
    results{i,3} = avgConf;

    % Lưu ảnh filter để show trong HTML
    imwrite(img_uint8, sprintf('filter_%02d.png', i));
end

scores = cell2mat(results(:,3));
[~, bestIdx] = max(scores);