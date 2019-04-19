v = VideoReader('../Angry Birds In-game Trailer.avi');

%% Read all video frames.
% while hasFrame(v)
%     video = readFrame(v);
% end
% whos video

% v.currentTime = 10;

%% Read video starting at a specific time
% currAxes = axes;
% while hasFrame(v)
%     vidFrame = readFrame(v);
%     image(vidFrame, 'Parent', currAxes);
%     currAxes.Visible = 'off';
%     pause(1/v.FrameRate);
% end

%% Read and play back video
vidWidth = v.Width;
vidHeight = v.Height;

mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);

k = 1;
while hasFrame(v) % v.CurrentTime <= 0.9
    mov(k).cdata = readFrame(v);
    if k == 450
        imshow(mov(k).cdata);
        hold on
        rectangle('Position', [60, 80, 30, 30], 'EdgeColor','r', 'LineWidth', 3);
        F = getframe;
        mov(k).cdata = F;
%         hold on
%         mov(450).cdata = rectangle('Position', [60, 80, 30, 30], 'EdgeColor','r', 'LineWidth', 3);
    end
    k = k+1; 
end

%% Draw bounding box of red bird on frame 450
% mov(450).cdata = rectangle('Position', [60, 80, 30, 30], 'EdgeColor','r', 'LineWidth', 3);
% insertShape(mov,'Rectangle',[60, 80, 30, 30],'EdgeColor','r','LineWidth',3);

% hf = figure;
% set(hf,'position',[150 150 vidWidth vidHeight]);
% 
% movie(hf,mov,1,v.FrameRate);

% Resize the current figure and axes based on the video's width and height
% and play at video's rate
set(gcf,'position',[150 150 v.Width v.Height]);
set(gca,'units','pixels');
set(gca,'position',[0 0 v.Width v.Height]);

F = getframe;
plot(rand(5))
movie(mov,1,v.FrameRate);

close

%% Display frames
%% Frame 450 (or try 460)
% image(mov(450).cdata);
% thisFrame = mov(450).cdata;

%% Frame at 15 secs in video (same as above Frame 450)
v.CurrentTime = 15;
imageData = readFrame(v);

%% RGB of pixel col 1 row 2
zz = impixel(imageData,1,2);
% zzz = impixel(thisFrame,1,2);
%% zz and zzz are equivalent

% imshow(imageData);

rChannel = imageData(:,:,1);
bChannel = imageData(:,:,2);
gChannel = imageData(:,:,3);

% imagesc(rChannel);
% imagesc(bChannel);
% imagesc(gChannel);

%% make copy as grayscale, canny edge detection, compare with original R channel
grayImage = rgb2gray(imageData);
edges_canny = edge(grayImage,'Canny');
edges_prewitt = edge(grayImage,'Prewitt');
edges_roberts = edge(grayImage,'Roberts');
edges_sobel = edge(grayImage,'Sobel');

figure();
subplot(2,2,1);
imshow(edges_canny);
title("Canny Edge");

subplot(2,2,2);
imshow(edges_prewitt);
title("Prewitt Edge");

subplot(2,2,3);
imshow(edges_roberts);
title("Roberts Edge");

subplot(2,2,4);
imshow(edges_sobel);
title("Sobel Edge");

%% "Crop" the bird/pig, get their location (row/col)
bird_rCh = rChannel(80:120,50:100);

bird_canny = grayImage(80:120,50:100);

% measurements = regionprops(logical(bird_canny), 'BoundingBox');
% bBox = measurements.BoundingBox;
% hold on;
% rectangle('Position', bBox, 'EdgeColor', 'r');

figure();
imagesc(imageData);
% hold on
rectangle('Position', [60, 80, 30, 30], 'EdgeColor','r', 'LineWidth', 3)

%% alt: histogram 