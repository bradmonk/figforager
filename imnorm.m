function [IMG] = imnorm(imgpath)
%% imgcon.m

% filedir = uigetdir();
% imgFiles = dir([filedir,'/*Y.jpg']); 
% imgFiles = dir([filedir,'/*Y.*']);
% imgFileNames = {imgFiles(:).name}';
% imgpath = [filedir, '/', imgFileNames{1}];

iminfo = imfinfo(imgpath);
[im, map] = imread(imgpath);


im_size = size(im);
im_nmap = numel(map);
im_ctype = iminfo.ColorType;
hasAlpha = 0;


if numel(im_size) > 2 && strcmp(im_ctype, 'truecolor') && strcmp(iminfo.Format, 'png')
    try
        imtrans = iminfo.Transparency;
    catch exception
        imtrans = 'noalpha';
    end
    if strcmp(imtrans, 'alpha')
        hasAlpha = 1;
    end    
end


if numel(im_size) > 2 && strcmp(im_ctype, 'truecolor') && hasAlpha==1
    
    [im, map, alpha] = imread(imgpath,'BackgroundColor',[1 1 1]);
    IMG = rgb2gray(im);
    IMG = im2double(IMG);

elseif strcmp(im_ctype, 'truecolor') || numel(im_size) > 2

    IMG = rgb2gray(im);
    IMG = im2double(IMG);

elseif strcmp(im_ctype, 'indexed')

    IMG = ind2gray(im,map);
    IMG = im2double(IMG);

elseif strcmp(im_ctype, 'grayscale')

    IMG = im2double(im);

else

    IMG = im;

end


end














