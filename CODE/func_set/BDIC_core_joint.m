function [latant_ill,latent_est,ker_est] = BDIC_core_joint(img_raw,img_rgb, lambda1, lambda2,show_iter, opts, patch_r)


if ~exist('patch_r','var')              % patch size
    opts.r = floor(0.025*mean(size(img_raw)));
else
    opts.r = patch_r;
end

%% initializing the optical parameters

ret = sqrt(0.5);
iter_num = max(floor(log(5/min(opts.kernel_size))/log(ret)),0);
scal_num = iter_num + 1;
opts.scales = scal_num;

[m,n] = size(img_raw);
m_img_list = ceil(m * ret.^(0:iter_num));
n_img_list = ceil(n * ret.^(0:iter_num));
k_img_list = ceil(opts.kernel_size * ret.^(0:iter_num));

dx = ([-1,1;0,0]);
dy = ([-1,0;1,0]);

% v = VideoWriter('demo_video2.avi');
% open(v);
% a = 0.5;

Q = 1;
for this_scal = scal_num:-1:1
    %% initiating kernel:ker_est and latent image: img_ds
    
    img_m_size = m_img_list(this_scal);
    img_n_size = n_img_list(this_scal);
    img_ds = (imresize(img_raw,[img_m_size,img_n_size],'lanczos3'));
    img_rgb_ds = (imresize(img_rgb,[img_m_size,img_n_size],'lanczos3'));
%     dark_ds = (imresize(dark_raw,[img_m_size,img_n_size],'lanczos3'));

    if this_scal == scal_num
        ker_size = k_img_list(this_scal);
        ker_est = (zeros(ker_size));
        
        ker_est(ceil((ker_size - 1)/2), ceil((ker_size - 1)/2:(ker_size - 1)/2)+1) = 1/2;
        [~, ~, threshold] = threshold_pxpy_v1(img_ds,max(size(ker_est)));
        
    else
        ker_size = k_img_list(this_scal);
        ker_est = (imresize(ker_est,[ker_size,ker_size],'lanczos3'));
        ker_est(ker_est<0) = 0;
        ker_est = ker_est / sum(ker_est(:));
    end
    opts.s = this_scal;
    
    fprintf('Processing scale %d/%d; kernel size %dx%d; image size %dx%d\n', ...
            this_scal, scal_num, ker_size, ker_size, img_m_size, img_n_size);
     
    vchan_ds = max(img_rgb_ds,[],3);
    
    img_ds_w = wrap_boundary_liu(img_ds, (size(img_ds)+size(ker_est)-1));
    vchan_ds = wrap_boundary_liu(vchan_ds, (size(vchan_ds)+size(ker_est)-1));   
    [H,W] = size(img_ds);

    otf_dx = psf2otf(dx,[H,W]);
    otf_dy = psf2otf(dy,[H,W]);
    Bx_temp = real(ifft2(fft2(img_ds).*otf_dx));Bx = Bx_temp(1:H-1,1:W-1);
    By_temp = real(ifft2(fft2(img_ds).*otf_dy));By = By_temp(1:H-1,1:W-1);
    
    lambda1_temp = lambda1;
    lambda2_temp = lambda2;
    for iter = 1:opts.xk_iter 
        [Q,O] = updata_O_jointly_conv(img_ds_w,vchan_ds,ker_est, lambda1_temp,lambda2_temp);
   
        QO = O .* Q; QO = QO(1:H,1:W);
        ker_est = updata_H((QO),Bx,By,ker_est,threshold);
        
        if show_iter
            figure(1);
            subplot(121);imshow(O,[])
            subplot(122);imshow(ker_est,[])
            figure(2);
            imshow(Q,[0,1]);
            drawnow;
        end
        lambda1_temp = max(lambda1_temp/1.1, 5e-4);
        lambda2_temp = max(lambda2_temp/1.1, 5e-4);
    end
    
    ker_est(ker_est<0) = 0;  
    ker_est = ker_est ./ sum(ker_est(:));  
    
    %% center the kernel
    if this_scal ~= 1
        ker_est = adjust_psf_center(ker_est);
        ker_est(ker_est<0) = 0;
        ker_est = ker_est./sum(ker_est(:));
    end
   
    %% set elements below threshold to 0
    if (this_scal == 1)
        if opts.k_thresh>0
            ker_est(ker_est(:) < (max(ker_est(:)) * opts.k_thresh)) = 0;
        else
            ker_est(ker_est(:) < 0) = 0;
        end
        ker_est = ker_est / sum(ker_est(:));
    end
        
end
latent_est = O(1:H,1:W);
latant_ill = Q(1:H,1:W);
ker_est = adjust_psf_max_center(ker_est);
% close(v);

end
