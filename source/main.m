% Author: Ahmet Furkan Biyik
% ID: 21501084
% Date: 14.12.2019

% !!!!!
%   You need external source for SLIC segmentation.
%   You need to download and compile authors' codes provided in description from the link 
%   "https://ivrl.epfl.ch/research-2/research-current/research-superpixels/"
%   You only need to compile "slicomex.c" file in the source folder.
%   You can compile C file using "mex slicomex.c".
%   If you don't have compiler, you can download MinGW compiler from Home/Add-Ons.
%   Make sure you have compiled slicomex before running.
% !!!!!
% ========================================================================
% You can create ImageSuperpixel object with image path
% After you create object it generates oversegmented labels.
%   obj = ImageSuperpixel('image.jpg');
% You can show image with showImage method.
%   obj.showImage();
% You can show Gabor result with showGaborResult method.
%   obj.showGaborResult();
% You can merge superpixel with mergePixels method.
% Note that when you do merging, you loose previous label data.
%   obj = obj.mergePixels(type);
%   type can be 1,2,3.
%   1 for Gabor merging.
%   2 for color merging.
%   3 for combined merging
% You can reset original oversegmentation labels with resetPixels method.
%   obj = obj.resetPixels();
% ========================================================================
% Code below:
% Reads all ".jpg" images in "data" folder outside of source folder.
% For each image:
%   Shows labelled image and saves figure.
%   Merge pixels with Gabor features.
%   Shows labelled image and saves figure.
%   Merge pixels with color features.
%   Shows labelled image and saves figure.
%   Merge pixels with combined features.
%   Shows labelled image and saves figure.
%   Shows Gabor result and saves figure.
%   closes opened figures. You can keep figures by commenting out "close all"
% End of script
% ========================================================================
% Note that this script process 21 images more than an hour. 

close all;
clear;
clc;

resultPath = '../results';
dataPath = '../data';

if exist(resultPath, 'dir')
    rmdir(resultPath, 's'); % delete directory
end

mkdir(resultPath); % create directory

imgpath = dir(fullfile(dataPath,'*.jpg'));
images(1, size(imgpath, 1)) = ImageSuperpixel;

for i = 1 : 1%size(imgpath, 1)
    % read image
    images(i) = ImageSuperpixel( [imgpath(i).folder '/' imgpath(i).name]);
    images(i).showImage();
    title('Before merge');
    saveas(gcf, fullfile(resultPath, sprintf('%d_org.png', i)));
    % merge with Gabor fetures
    images(i) = images(i).mergePixels(1);
    images(i).showImage();
    title('Merge with gabor features');
    saveas(gcf,fullfile(resultPath, sprintf('%d_gabor_merge.png', i)));
    % merge with color features
    images(i) = images(i).mergePixels(2);
    images(i).showImage();
    title('Merge with color features');
    saveas(gcf,fullfile(resultPath, sprintf('%d_color_merge.png', i)));
    % merge with combined features
    images(i) = images(i).mergePixels(3);
    images(i).showImage();
    title('Merge with combined features');
    saveas(gcf,fullfile(resultPath, sprintf('%d_combined_merge.png', i)));
    % show gabor result
    images(i).showGaborResult();
    saveas(gcf,fullfile(resultPath, sprintf('%d_gabor.png', i)));
    
    % if you want to keep opened figures, comment out "close all".
    close all;
end