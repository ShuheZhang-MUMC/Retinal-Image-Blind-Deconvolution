function img_out = reflected_padding(img_in,mask)
%% reflecting padding the retinal imag using mask
img_out = img_in .* mask;

[m,n,~] = size(img_out);

img_part{1} = img_out(1:round(m/2),1:round(n/2),:);
img_part{2} = img_out(1:round(m/2),round(n/2)+1:n,:);
img_part{3} = img_out(round(m/2)+1:m,1:round(n/2),:);
img_part{4} = img_out(round(m/2)+1:m,round(n/2)+1:n,:);


img_mask{1} = mask(1:round(m/2),1:round(n/2));
img_mask{2} = mask(1:round(m/2),round(n/2)+1:n);
img_mask{3} = mask(round(m/2)+1:m,1:round(n/2));
img_mask{4} = mask(round(m/2)+1:m,round(n/2)+1:n);

cor{1} = [round(m/2),round(n/2)];
cor{2} = [round(m/2),1];
cor{3} = [1,round(n/2)];
cor{4} = [1,1];

for pool = 1:4
    this_img = img_part{pool};
    this_mask = img_mask{pool};
    cor1 = cor{pool}(1);
    cor2 = cor{pool}(2);
    
for con_m = 1:size(this_img,1)
    for con_n = 1:size(this_img,2)
        if this_mask(con_m,con_n) == 0
            [len,point_data] = BresenhamLine(cor1,cor2,con_m,con_n);
            for con_len = 1:len
                if this_mask(point_data(2,con_len),point_data(1,con_len)) == 1
                    break
                end
            end
            this_img(con_m,con_n,:) = this_img(point_data(2,min(2*con_len-1,len)),point_data(1,min(2*con_len-1,len)),:);
        end
    end
end
img_part{pool} = this_img;
end


img_out(1:round(m/2),1:round(n/2),:) = img_part{1};
img_out(1:round(m/2),round(n/2)+1:n,:) = img_part{2};
img_out(round(m/2)+1:m,1:round(n/2),:) = img_part{3};
img_out(round(m/2)+1:m,round(n/2)+1:n,:) = img_part{4};





end

function [len,point_data] = bresenham_line(m0,n0,m1,n1,size)
%{
    计算直线穿过的坐标，还没看懂 (⊙﹏⊙)b。
    同时也能生成直线
    I  生成的图像。
    point_data 坐标信息。
    [m0,n0] 起点坐标
    [m1,n1] 终点坐标
%}
% I=1;
% grayfill = 1;
count = 1;
len = 1;
% p_x = zeros(1,1000);
% p_y = zeros(1,1000);
if m0 == m1 && n0 ==n1
    m0=round(m0);
    n0=round(n0);
    m1=round(m1);
    n1=round(n1);
    p_x = 1;
    p_y = 1;
%     I(m0, n0) = grayfill;
else
     if m0<m1
        x0=m0;
        y0=n0;
        x1=m1;
        y1=n1;
    else
        x0=m1;
        y0=n1;
        x1=m0;
        y1=n0;
    end
    dx=abs(x1-x0);
    dy=abs(y1-y0);  

    e=-0.5;  
    x=x0;
    y=y0;
    if y1>y0
        if abs(dy)>abs(dx)
            len = abs(dy);
            k=abs(dx)/abs(dy);
            p_y = zeros(1,abs(dy));
            p_x = y + (0:1:dy);
            
            for i=0:1:dy
                p_y(count) = x;
                count = count + 1;

                e=e+k;
                if(e>=0)
                    x=x+1;
                    e=e-1;
                end
            end
        else
            k=abs(dy)/abs(dx);
            len = abs(dx);
            p_x = zeros(1,abs(dx));
            p_y = x + (0:1:dx);
            for i=0:1:dx

                p_x(count) = y;

                count = count + 1;

                e=e+k;
                if(e>=0)
                    y=y+1;
                    e=e-1;
                end
            end
        end  
    else  % y1<y0时
        if abs(dy)>abs(dx)
            k=abs(dx)/abs(dy);
            len = abs(dy);
            p_x = y - (0:1:abs(dy));
            p_y = zeros(1,abs(dy));
            for i=0:1:abs(dy)

                p_y(count) = x;
                count = count + 1;

                e=e+k;
                if(e>=0)
                    x=x+1;
                    e=e-1;
                end
            end
        else
            k=abs(dy)/abs(dx);
            len = abs(dx);
            p_x = zeros(1,abs(dx));
            p_y = x + (0:1:abs(dx));
            for i=0:1:abs(dx)

                p_x(count) = y;

                count = count + 1;

                e=e+k;
                if(e>=0)
                    y=y-1;
                    e=e-1;
                end
            end
        end
    end
end
% [p_x,p_y] = find(I > 0);

p_x((p_x==0)) = [];
p_y((p_y==0)) = [];
if m0<m1
    point_data = fliplr([p_x;p_y]);
else
    point_data = [p_x;p_y];
end
end

%

