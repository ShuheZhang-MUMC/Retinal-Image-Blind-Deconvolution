clc;
clear;
% close all;
tic

path0 = genpath('func_set//');
addpath(path0)


%% deblurring parameters
opts.prescale = 1;        %% downsampling
opts.xk_iter = 5;         %% the iterations
opts.k_thresh = 1/20;
opts.kernel_size = 51;  


%% load image
[img_name, img_path]=uigetfile('*.*');
img_raw0 = imresize(double(imread([img_path,img_name]))/255,1);

mult = 1;
color_threshold = 20;
[m0,n0,~] = size(img_raw0);
gauss_size = fix(sqrt(m0*n0)/10);
[img_raw0,mask] = prepossing(img_raw0,color_threshold,gauss_size,mult);
figure();imshow(img_raw0,[])

[~,~,c] = size(img_raw0);
if c > 1
    img_raw = 0.3*img_raw0(:,:,1) + 0.6*img_raw0(:,:,2) + 0.1*img_raw0(:,:,3);
else
    img_raw = mean(img_raw0,3);
end

img_raw_temp = img_raw;

w = fspecial('gaussian',[3,3],1);
img_raw_temp = imfilter(img_raw_temp,w,'replicate');
img_raw_gray = img_raw_temp;          



%% blind-deconvolution
tic
lambda1 = 0.0025;  % gradient-L0 penalty for latent image
lambda2 = 2;      % gradient-L1 (TV) penalty for latent illumination pattern
show_iter = false;
%
% parameter can be fine-tuned for better performance.
%

[latant_ill,latent,psf] = BDIC_core_joint(img_raw_gray,img_raw0, lambda1, ...
                                          lambda2,show_iter,opts); % 
toc


%% Hessian non-blind deconvolution
psf = psf / sum(psf(:));
ill_dark = 1 - latant_ill;
iter_max = 100;

NN = [1 -2 1;-2 4 -2;1 -2 1];
SN = imfilter(mean(img_raw0,3),NN,'replicate');

lambda_Hessian = mean(abs(SN(:)))/50;
aim_intensity = 0.55;

tic
[cost,out] = deconvHessianLucy_ic(img_raw0,psf,ill_dark,...
                                  iter_max,...
                                  lambda_Hessian,...
                                  aim_intensity);
toc

%% save image
if ~exist(['results//',img_name(1:end-4)],'dir')
    mkdir(['results//',img_name(1:end-4)])
end

kk = mult*gauss_size;
raw_temp = img_raw0; 
out_img0 = raw_temp .* mask;
out_img_cut0 = out_img0(kk+1:end-kk,kk+1:end-kk,:);  
% raw image
imwrite(out_img_cut0,['results//',img_name(1:end-4),'//',img_name(1:end-4),'raw.png'])


Lat_temp = out;
out_img0 = Lat_temp .* mask;
out_img_cut0 = out_img0(kk+1:end-kk,kk+1:end-kk,:);
% enhanced image
imwrite(out_img_cut0,['results//',img_name(1:end-4),'//',img_name(1:end-4),'out.png'])

save(['results//',img_name(1:end-4),'//',img_name(1:end-4),'_1.mat'],...
                                     'psf','latant_ill','img_raw0','mask')

