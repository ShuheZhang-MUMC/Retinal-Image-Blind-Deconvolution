% Solving Richardson-Lucy deconvolution with Hessian regularization and illumination correction
% using (sub)gradient descent. The optimizer is NAdam

function [cost,out] = deconvHessianLucy_ic(img,psf,dark,iter,lambda,I0)

[m,n,~] = size(img);



rho1 = 0.9;
rho2 = 0.999;
step = 0.05;


q.para = img;
q.mom1 = 0;
q.mom2 = 0;

a.para = 0.5;
a.mom1 = 0;
a.mom2 = 0;

fft_s = fft2(img);
H = psf2otf(psf,[m,n]);


for con = 1:iter
    disp(['proceding Lucy-Hessian deconvolution at ',num2str(con),'-iter'])
    if lambda ~= 0

        gxx = imfilter(q.para,[1,-2,-1],'replicate');
        gyy = imfilter(q.para,[1;-2;-1],'replicate');
        gxy = imfilter(q.para,[-1,1;1,-1],'replicate');
        
        ss = sqrt(gxx.^2 + gyy.^2 + gxy.^2) + eps;
        
        gxx = gxx./ss;
        gyy = gyy./ss;
        gxy = gxy./ss;
        
        gxx = imfilter(gxx,[1,-2,-1],'replicate');
        gyy = imfilter(gyy,[1;-2;-1],'replicate');
        gxy = imfilter(gxy,[-1,1,0;1,-1,0;0,0,0],'replicate');
        
        Hessian = lambda * (gxx + gyy + gxy);
    else
        Hessian = 0;
    end
    
    
    ill = 1 - a.para * dark;
    
    temp_HQ = H.*fft2(ill.*q.para);
    
    cost(con) = mean(mean(mean((real(ifft2(temp_HQ)) - img).^2)));

    L2_den = real(ifft2( conj(H) .* (temp_HQ - fft_s)));
    
    temp = (img./(ill + eps) - I0) .* img.*dark./(ill.^2 + eps);
    
    Grad_q = L2_den .* ill + Hessian;
    Grad_a = mean(temp(:));
    
    q = optimizer_nadam(q,Grad_q,rho1,rho2,step,con);
    a = optimizer_nadam(a,Grad_a,rho1,rho2,2*step,con);
    
    
%     figure(2022);
%     imshow(q.para,[])
    
    if cost(con) < 3e-5
        break
    end
end
a.para

out = gather(q.para);


end

function para_new = optimizer_nadam(para_old,grad,rho1,rho2,step,iter)

para_new = para_old;
para_new.mom1 = rho1 * para_old.mom1 + (1 - rho1) * grad;
para_new.mom2 = rho2 * para_old.mom2 + (1 - rho2) * grad.^2;

m1 = para_new.mom1/(1 - rho1^iter);
m2 = para_new.mom2/(1 - rho2^iter);

para_new.para = para_old.para - step * 1./(sqrt(m2) + eps).*...
                                 (rho1 * m1 + (1 - rho1) * grad);
end
