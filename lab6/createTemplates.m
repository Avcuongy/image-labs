function templates = createTemplates()

templates = containers.Map();

chars = ['A':'Z' '0':'9'];

fonts = {
    'Arial', ...
    'Calibri', ...
    'Verdana', ...
    'Comic Sans MS', ...
    'Segoe Print', ...
    'Arial Rounded MT Bold', ...
    "Tahoma", ...
    "Times New Roman"
};

fontSizes = [36 40 44];

imgSize = [80 60];
outSize = [32 32];

for i = 1:length(chars)
    
    ch = chars(i);
    templateList = {};
    
    for f = 1:length(fonts)
        for s = 1:length(fontSizes)
            
            img = zeros(imgSize, 'uint8');
            
            img = insertText(img, [5 5], ch, ...
                'Font', fonts{f}, ...
                'FontSize', fontSizes(s), ...
                'BoxOpacity', 0, ...
                'TextColor', 'white');
            
            if size(img,3) == 3
                img = rgb2gray(img);
            end
            
            bw = imbinarize(img);
            
            if mean(bw(:)) > 0.5
                bw = ~bw;
            end
            
            bw = bwareaopen(bw, 10);
            
            props = regionprops(bw, 'BoundingBox');
            if ~isempty(props)
                bw = imcrop(bw, props(1).BoundingBox);
            end
            
            bw = imresize(bw, outSize);
            
            templateList{end+1} = bw;
        end
    end
    
    templates(ch) = templateList;
end

end