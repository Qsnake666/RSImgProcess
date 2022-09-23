function [data] = cst(data)
%坐标系平移
%   Coordinate system translation
    m1=mean(data(:,1));
    m2=mean(data(:,2));
    arg1=fix(m1/100000);
    arg11=m1-arg1*100000;
    arg111=fix(arg11/10000);
    data(:,1)=data(:,1)-arg1*100000-arg111*10000;
    arg2=fix(m2/100000);
    arg21=m2-arg2*100000;
    arg211=fix(arg21/10000);
    data(:,2)=data(:,2)-arg2*100000-arg211*10000;
end

