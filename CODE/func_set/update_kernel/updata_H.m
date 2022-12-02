function ker_est = updata_H(O,Bx,By,ker_est,threshold)

[latent_x, latent_y, ~]= threshold_pxpy_v1(O,max(size(ker_est)),threshold); 
k_prev = ker_est;
ker_est = estimate_psf_CG(Bx, By, latent_x, latent_y, 0.01, size(k_prev));
% 
CC = bwconncomp(ker_est,8);
for ii=1:CC.NumObjects
    currsum=sum(ker_est(CC.PixelIdxList{ii}));
    if currsum<.1 
        ker_est(CC.PixelIdxList{ii}) = 0;
    end
end
ker_est(ker_est<0) = 0;
ker_est=ker_est/sum(ker_est(:));

% imshow(ker_est,[])
    
end