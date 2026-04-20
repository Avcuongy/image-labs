function [results, bestIdx] = m_filter(imgPath)

%% READ IMAGE
img = imread(imgPath);

if size(img,3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

%% FILTERS
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

%% OCR + SCORING
fprintf('\nRESULTS:\n');

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

    if isempty(conf)
        meanConf   = 0;
        medianConf = 0;
    else
        meanConf   = mean(conf);
        medianConf = median(conf);
    end
    
    % Text clean
    textClean = regexprep(text, '\s+', '');
    
    % Length score
    expectedLength = 5;
    lenScore = min(length(textClean) / expectedLength, 1);
    
    % Valid text check
    validChars = regexp(textClean, '[A-Za-z0-9]', 'match');
    if length(validChars) < 3
        penalty = 0.3;
    else
        penalty = 1.0;
    end
    
    % Final score
    score = (0.6 * meanConf + 0.2 * medianConf + 0.2 * lenScore) * penalty * 100;

    results{i,1} = filterNames{i};
    results{i,2} = text;
    results{i,3} = score;

    % Dùng score (không phải avgConf)
    fprintf('[%d] %-18s | %6.2f%% | "%s"\n', ...
        i, filterNames{i}, score, strrep(text, newline, ' '));
end

%% Best option
scores = cell2mat(results(:,3));
[~, bestIdx] = max(scores);

fprintf('\nBEST: %s (%.2f%%)\n', ...
    filterNames{bestIdx}, scores(bestIdx));
fprintf('\n')

end