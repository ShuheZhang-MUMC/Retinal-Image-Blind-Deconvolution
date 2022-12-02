function [len,point_data] = BresenhamLine(x0,y0,x1,y1)

count = 0;
if x0 == x1 && y0 ==y1
    x0=round(x0);
    y0=round(y0);
    len = 1;
    point_data = [x0;y0];
else
    steep = abs(y1-y0) > abs(x1-x0);
    if steep
        temp = x0;x0 = y0;y0 = temp;
        temp = x1;x1 = y1;y1 = temp;  
    end
%     if x0 > x1
%         temp = x0;x0 = x1;x1 = temp;
%         temp = y0;y0 = y1;y1 = temp;  
%     end
    deltax = abs(x1 - x0);
    deltay = abs(y1 - y0);
    error = deltax / 2;
    y = y1;
    ystep = sign(y1 - y0);
    
    len = abs(x1 - x0) + 1;
    point_data = zeros(2,len);
    for x = x1:sign(x0-x1):x0
        count = count + 1;
        if steep
            point_data(1,count) = x;
            point_data(2,count) = y;
        else
            point_data(1,count) = y;
            point_data(2,count) = x;
        end
        error = error - deltay;
        if error < 0
            y = y - ystep;
            error = error + deltax;
        end
    end
end





end
