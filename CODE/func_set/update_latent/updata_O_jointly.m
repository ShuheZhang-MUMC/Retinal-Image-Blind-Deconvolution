function [q,o] = updata_O_jointly(img,dark_w,ker,lambda1,lambda2)


[m,n] = size(img);


H = psf2otf(ker,[m,n]);
HT = conj(H);


Dx = psf2otf([-1,1],[m,n]);
Dy = psf2otf([-1;1],[m,n]);
Dxy = 0*psf2otf([1,-1;-1,1],[m,n]);
Dyx = 0*psf2otf([-1,1;1,-1],[m,n]);

fft_s = fft2(img);

rho1 = 0.9;
rho2 = 0.999;
step = 0.05;

g_size = round(sqrt(m*n)/10);
ic = imfilter(dark_w,fspecial('gaussian',2*g_size,g_size),'replicate');

o0.para = img ./(ic + eps);
o0.mom1 = 0;
o0.mom2 = 0;


q0.para = ic;
q0.mom1 = 0;
q0.mom2 = 0;

for con = 1:25
    den = real(ifft2(HT.*H.*fft2(q0.para.*o0.para) - HT.*fft_s));
    
    Grad_o = 2 * q0.para .* den + lambda1 * prox_L0(o0.para,Dx,Dy,Dxy,Dyx,8);
    Grad_i = 2 * o0.para .* den + lambda2 * prox_L1(q0.para,Dx,Dy);
    
    
    o0 = optimizer_nadam(o0,Grad_o,rho1,rho2,step,con);
    q0 = optimizer_nadam(q0,Grad_i,rho1,rho2,step,con);
    q = q0.para;
    
%     
    q(q < 0.01) = 0.01;
    q(q > 1) = 1;
    
    q0.para = q;
end

o = o0.para;
q = q0.para;

end

function out = prox_L0(o,dx,dy,dxy,dyx,beta)
    fft_q = fft2(o);
    
    gx = real(ifft2(fft_q.*dx));
    gy = real(ifft2(fft_q.*dy));
    gxy = real(ifft2(fft_q.*dxy));
    gyx = real(ifft2(fft_q.*dyx));
    
    sss = sqrt(gx.^2 + gy.^2 + gxy.^2 + gyx.^2);
    
%     v1 = beta * exp(- beta * abs(gx)) .* sign(gx);
%     v2 = beta * exp(- beta * abs(gy)) .* sign(gy);
%     v3 = beta * exp(- beta * abs(gxy)) .* sign(gxy);
%     v4 = beta * exp(- beta * abs(gyx)) .* sign(gyx);

    v1 = beta * exp(- beta * abs(gx)) .* gx./(sss + eps);
    v2 = beta * exp(- beta * abs(gy)) .* gy./(sss + eps);
    v3 = beta * exp(- beta * abs(gxy)) .* gxy./(sss + eps);
    v4 = beta * exp(- beta * abs(gyx)) .* gyx./(sss + eps);
   
    gx = real(ifft2(fft2(v1) .* conj(dx)));
    gy = real(ifft2(fft2(v2) .* conj(dy)));
    gxy = real(ifft2(fft2(v3) .* conj(dxy)));
    gyx = real(ifft2(fft2(v4) .* conj(dyx)));
    
    out = (gx + gy + gxy + gyx);
end

function out = prox_L1(o,dx,dy)
    fft_q = fft2(o);
    
    gx = real(ifft2(fft_q.*dx));
    gy = real(ifft2(fft_q.*dy));
    ss = sqrt(gx.^2 + gy.^2);   
 
     v1 = gx./(ss + eps);
     v2 = gy./(ss + eps);
%    v1 = beta * exp(- beta * abs(gx)) .* sign(gx);
%    v2 = beta * exp(- beta * abs(gy)) .* sign(gy);

    gx = real(ifft2(fft2(v1) .* conj(dx)));
    gy = real(ifft2(fft2(v2) .* conj(dy)));
        
    out = (gx + gy);
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
