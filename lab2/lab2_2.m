clc; clear; close all;

video = VideoReader('sample.avi');

frames = {}; % mỗi phần tử là 1 ảnh 2D
count = 0;

while hasFrame(video)
    frame = readFrame(video);
    gray = rgb2gray(frame);
    
    count = count + 1;
    frames{count} = gray;
end

fprintf('Total frames: %d\n', count);

% 2. 
function results = frame_subtraction(frames, k)
    n = length(frames);
    results = {};
    
    idx = 0;
    for i = k+1:n
        diff = imabsdiff(frames{i}, frames{i-k});
        
        idx = idx + 1;
        results{idx} = diff;
    end
end

diff_5  = frame_subtraction(frames, 5);
diff_10 = frame_subtraction(frames, 10);
diff_15 = frame_subtraction(frames, 15);

figure;
subplot(1,3,1); imshow(diff_5{1});  title('k = 5');
subplot(1,3,2); imshow(diff_10{1}); title('k = 10');
subplot(1,3,3); imshow(diff_15{1}); title('k = 15');