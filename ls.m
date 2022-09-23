function [rmin,rmax] = ls(D,value)
%线性拉伸（辐射增强）Line Stretch
DD = D(:);%reshape [sample*lines] 1维矩阵
Y = zeros(256,1);%竖轴 0-255，256个值，用imhist找到共256个区间，直方图是区间
for j=1:length(DD)
    if(DD(j)<0.5)%只用在左边循环，加快运算速度
        for i = 1/256:1/256:0.5
            if(DD(j)<=i && DD(j)>i-1/256)
                Y(round(i*256)) = Y(round(i*256))+1;%代表0-1/256-1之间的像素数量+1，步长为1/256
                break;
            end
        end
    else
        for i = 0.5+1/256:1/256:1
            if(DD(j)<=i && DD(j)>i-1/256)
                Y(round(i*256)) = Y(round(i*256))+1;
                break;
            end
        end
    end
end

judge = max(Y)/100*value;%max(Y)灰度值最集中的数量*n%，最多的n%都达不到就舍去
rmin = 0;
rmax = 0;
for i = 1:256%从左计数
    if(Y(i)<judge)
      rmin = rmin+1;
    else
        break;
    end
end
for i = 256:-1:1%从右计数
    if(Y(i)<judge)
      rmax = rmax+1;
    else
        break;
    end
end
rmax = 256-rmax;
X = linspace(0,1,256);%灰度值
rmin = X(rmin);
rmax = X(rmax);
% subplot(2,2,1);
% X = imadjust(D,[rmin,rmax],[]);
% subplot(2,2,2);
% stem(X(rmin:rmax)',Y(rmin:rmax),'Marker','none');