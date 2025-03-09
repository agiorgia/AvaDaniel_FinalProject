%% Image Pre-Processing
% Read Image
im = imread('f06ba705-5509-479b-8067-127ffb37c5b6_DEVIM.png');
 
% Convert Image to Grayscale, Reduce Dimensionality
im_g = rgb2gray(im);

% Enhance Contrast to Assist ML
im_adj = imadjust(im_g);
