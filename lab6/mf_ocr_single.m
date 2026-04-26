function resultText = mf_ocr_single(imgPath, templates)

%% READ
img = imread(imgPath);

if size(img,3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

%% PREPROCESS
gray = medfilt2(gray, [3 3]);

bw = imbinarize(gray);

if mean(bw(:)) > 0.5
    bw = ~bw;
end

bw = imopen(bw, strel('disk', 5));
bw = imfill(bw, 'holes');
bw = bwareaopen(bw, 10);

%% SEGMENT
cc = bwconncomp(bw);
stats = regionprops(cc, 'BoundingBox');

if isempty(stats)
    disp('No characters detected.');
    resultText = '';
    return;
end

boxes = cat(1, stats.BoundingBox);
[~, idx] = sort(boxes(:,1));
stats = stats(idx);

%% MATCH
keys = templates.keys;
resultText = '';

threshold = 0.3;
N = length(stats);

figure('Name','OCR FINAL (Topology + Hybrid)');
tiledlayout(3, N, 'Padding','compact');

se = strel('disk',3);
imgSize = [36 34];

for i = 1:N
    
    bbox = stats(i).BoundingBox;
    
    %% PADDING
    pad = 8;
    x = max(floor(bbox(1)) - pad, 1);
    y = max(floor(bbox(2)) - pad, 1);
    
    w = min(ceil(bbox(3)) + 2*pad, size(bw,2) - x);
    h = min(ceil(bbox(4)) + 2*pad, size(bw,1) - y);
    
    bboxPad = [x y w h];
    
    charImg = imcrop(bw, bboxPad);
    charImg = imresize(charImg, imgSize, 'nearest');
    
    %% CENTER + CLEAN
    charImg = charImg > 0;
    charImg = imfill(charImg, 'holes');
    charImg = bwareafilt(charImg, 1);
    
    %% THICKEN
    charImg = imdilate(charImg, se);
    
    %% DISTANCE TRANSFORM
    X = bwdist(~charImg);
    X = X / (max(X(:)) + 1e-6);
    Xn = X - mean(X(:));
    
    %% TOPOLOGY (input)
    topoX = extractTopology(charImg);
    
    bestScore = -inf;
    bestChar = '?';
    bestTemplate = [];
    
    %% MATCH LOOP
    for k = 1:length(keys)
        
        key = keys{k};
        templateList = templates(key);
        
        for t = 1:length(templateList)
            
            T = templateList{t};
            T = imresize(T, imgSize, 'nearest');
            
            T = imdilate(T, se);
            
            %% DISTANCE
            Td = bwdist(~T);
            Td = Td / (max(Td(:)) + 1e-6);
            Tn = Td - mean(Td(:));
            
            corrScore = sum(sum(Xn .* Tn)) / ...
                (norm(Xn(:)) * norm(Tn(:)) + 1e-6);
            
            %% TOPOLOGY (template)
            topoT = extractTopology(T);
            
            topoDiff = abs(topoX.numBranches - topoT.numBranches) + ...
                       abs(topoX.numEnds     - topoT.numEnds) + ...
                       abs(topoX.numPeaks    - topoT.numPeaks);
                   
            topoScore = exp(-0.5 * topoDiff);
            
            %% HYBRID SCORE
            score = 0.7 * corrScore + 0.3 * topoScore;
            
            %% RULE FIX (M vs V)
            if key == 'M' && topoX.numPeaks < 2
                score = score - 0.3;
            end
            
            if key == 'V' && topoX.numPeaks > 1
                score = score - 0.3;
            end
            
            %% BEST MATCH
            if score > bestScore
                bestScore = score;
                bestChar = key;
                bestTemplate = T;
            end
        end
    end
    
    %% DECISION
    if bestScore < threshold
        resultText = [resultText ' '];
        label = sprintf('Unknown\n%.2f', bestScore);
    else
        resultText = [resultText bestChar];
        label = sprintf('%s\n%.2f', bestChar, bestScore);
    end
    
    %% VISUALIZATION
    nexttile(i);
    imshow(charImg);
    title(sprintf('Char %d', i));
    
    nexttile(i + N);
    imshow(bestTemplate, []);
    title(['Template: ' bestChar]);
    
    nexttile(i + 2*N);
    imshow(abs(X - bestTemplate), []);
    title(label);
    
end

fprintf('Result: "%s"\n', resultText);

end