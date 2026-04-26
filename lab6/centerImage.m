function out = centerImage(img)

props = regionprops(img, 'BoundingBox');

if isempty(props)
    out = img;
    return;
end

crop = imcrop(img, props(1).BoundingBox);

h = size(img,1);
w = size(img,2);

out = zeros(h,w);

ch = size(crop,1);
cw = size(crop,2);

y = floor((h - ch)/2) + 1;
x = floor((w - cw)/2) + 1;

out(y:y+ch-1, x:x+cw-1) = crop;

end