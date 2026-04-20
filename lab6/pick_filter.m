function [text, score] = pick_filter(imgPath, filterIdx)

%% READ IMAGE
img = imread(imgPath);

if size(img,3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

%% DEFINE FILTERS
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

%% CHECK INPUT
if filterIdx < 1 || filterIdx > 5
    error('filterIdx must be from 1 to 5');
end

%% SELECT FILTER
selectedImg  = filteredImgs{filterIdx};
selectedName = filterNames{filterIdx};

%% BINARIZATION
img_uint8 = im2uint8(selectedImg);
level = graythresh(img_uint8);
bw = imbinarize(img_uint8, level);

if mean(bw(:)) > 0.5
    bw = ~bw;
end

bw_clean = bwareaopen(bw, 30);

%% OCR
ocrResult = ocr(bw_clean, 'LayoutAnalysis', 'Block');
text = strtrim(ocrResult.Text);

%% CONFIDENCE
conf = ocrResult.CharacterConfidences;
conf = conf(~isnan(conf) & conf >= 0);

if isempty(conf)
    meanConf = 0;
    medianConf = 0;
else
    meanConf = mean(conf);
    medianConf = median(conf);
end

%% SCORING
textClean = regexprep(text, '\s+', '');

expectedLength = 5;
lenScore = min(length(textClean) / expectedLength, 1);

validChars = regexp(textClean, '[A-Za-z0-9]', 'match');
if length(validChars) < 3
    penalty = 0.3;
else
    penalty = 1.0;
end

score = (0.6 * meanConf + 0.2 * medianConf + 0.2 * lenScore) * penalty * 100;

%% OUTPUT
fprintf('\n');
fprintf('\nFILTER: %s\n', selectedName);
fprintf('\n');
fprintf('Score: %.2f%%\n', score);
fprintf('\n');
fprintf('Text:\n"\n%s\n"\n\n', text);

end