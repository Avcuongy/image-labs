%% ============================================================
%  HANDWRITING OCR - 5 FILTERS ONLY
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

%% --- 2. APPLY 5 FILTERS ---
med        = medfilt2(gray, [3 3]);
gauss      = imgaussfilt(gray, 1.5);
med_gauss  = imgaussfilt(medfilt2(gray, [3 3]), 1.0);

se          = strel('disk', 1);
morph_open  = imopen(gray, se);
morph_close = imclose(gray, se);

filterNames = {
    'Median', ...
    'Gaussian', ...
    'Median+Gaussian', ...
    'Morph Opening', ...
    'Morph Closing'
};

filteredImgs = {
    med, gauss, med_gauss, ...
    morph_open, morph_close
};

%% --- 3. OCR ---
fprintf('\n===== OCR RESULTS =====\n');

numFilters = length(filterNames);
results    = cell(numFilters, 3);

for i = 1:numFilters
    img_uint8 = im2uint8(filteredImgs{i});

    % Binarization
    level = graythresh(img_uint8);
    bw    = imbinarize(img_uint8, level);

    if mean(bw(:)) > 0.5
        bw = ~bw;
    end

    bw_clean = bwareaopen(bw, 30);

    % OCR
    ocrResult = ocr(bw_clean, 'LayoutAnalysis', 'Block');
    text      = strtrim(ocrResult.Text);

    % Confidence
    conf = ocrResult.CharacterConfidences;
    conf = conf(~isnan(conf) & conf >= 0);
    avgConf = mean(conf) * 100;

    results{i,1} = filterNames{i};
    results{i,2} = text;
    results{i,3} = avgConf;

    fprintf('[%d] %-18s | %6.2f%% | "%s"\n', ...
        i, filterNames{i}, avgConf, strrep(text, newline, ' '));
end

%% --- 4. BEST FILTER ---
scores = cell2mat(results(:,3));
[~, bestIdx] = max(scores);

fprintf('\n>>> BEST: %s (%.2f%%)\n', ...
    filterNames{bestIdx}, scores(bestIdx));

fprintf('>>> TEXT:\n%s\n', results{bestIdx,2});

%% --- 5. VISUALIZATION ---
figure;
bar(scores);
set(gca, 'XTickLabel', filterNames, 'XTickLabelRotation', 30);
ylabel('Confidence (%)');
title('OCR Comparison (5 Filters)');
grid on;

hold on;
bar(bestIdx, scores(bestIdx)); % highlight best