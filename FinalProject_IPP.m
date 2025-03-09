%% Image Pre-Processing
clear

% Get names of all images in folder
imdir = [pwd,'\Images'];
imlist = dir(imdir);
imlist = imlist(~ismember({imlist.name},{'.','..'}));

outfile = 'CellStats.xlsx';
outpath = [pwd,'\Outputs\'];

for im_idx = 1:length(imlist)
    % Read Image
    imname = imlist(im_idx).name;
    im = imread([imdir,'\',imname]);

    % Convert Image to Grayscale, Reduce Dimensionality
    im_g = rgb2gray(im);

    % Enhance Contrast to Assist Binarization
    im_adj = imadjust(im_g);

    % Binarize Image
    bw = imbinarize(im_adj);

    % Invert the Binarized Image to Highlight the Cells
    bw_c = imcomplement(bw);

    % Extract Edges
    bw_edges = edge(im_adj);

    %% Image Processing
    % Fill: Close Gaps in Cells
    bw_f = imfill(bw_c,'holes');

    % Open: Erosion folled by Dilation, Remove Small/Noise from Image
    SE_r = 20;
    SE_n = 8;
    SE = strel("disk",SE_r,SE_n);
    bw_o = imopen(bw_f,SE);

    % Area Open: Remove Any Component Smaller than 0.8*AverageArea
    area_array = table2array(struct2table(regionprops(bw_o,'Area')));
    avg_area = mean(area_array);
    bw_ao = bwareaopen(bw_o,floor(avg_area*0.8));

    % Subtract Area Open: Remove Any Component Larger Than 2*AverageArea
    bw_final =  bw_ao - bwareaopen(bw_o,floor(avg_area*2));

    % Visualize Connected Components
    L = bwlabel(bw_final,8);

    % Display Results
    figure
    subplot(3,3,1)
    imshow(im)
    title('Original')

    subplot(3,3,2)
    imshow(im_g)
    title('Grayscale')

    subplot(3,3,3)
    imshow(im_adj)
    title('Contrast Enhanced')

    subplot(3,3,4)
    imshow(bw_c)
    title('Binarized')

    subplot(3,3,5)
    imshow(bw_f)
    title('Filled')

    subplot(3,3,6)
    imshow(bw_o)
    title('Morphologically Opened')

    subplot(3,3,7)
    imshow(bw_ao)
    title('Small Objects Cleared')

    subplot(3,3,8)
    imshow(bw_final)
    title('Large Objects Cleared')
    
    fig = gca;
    saveas(fig,[outpath,imname(1:end-4),'_IPP.jpg'])
    close

    %% Measurement
    % Find objects
    CC = bwconncomp(bw_final,8);

    % Best fit ellipses for all
    stats = regionprops(CC,"MajorAxisLength","MinorAxisLength");
    stats = struct2table(stats);
    out = bwferet(CC,"all");

    % Generate excel sheet with major axis and minor axis information
    writetable(stats,[outpath,outfile],'Sheet',im_idx,'Writemode','overwrite')

end
