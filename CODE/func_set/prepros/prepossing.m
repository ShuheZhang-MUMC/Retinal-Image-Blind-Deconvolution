function [out,mask] = prepossing(raw_img,holdV,gaussian_kernal_size,mult)

raw_img = padarray(raw_img,mult*[gaussian_kernal_size,gaussian_kernal_size],0,'both');
mask = raw_img(:,:,1) > holdV/255;
mask = imfill(mask,'holes');
se = strel('square', 3);          % Í¼Ïñ¸¯Ê´Ë¢×Ó
mask = imerode(mask, se);
raw_img = raw_img .* mask;

out = reflected_padding(raw_img,mask);

end