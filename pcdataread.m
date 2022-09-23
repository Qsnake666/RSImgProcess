function [data,ptcloud,color,type] = pcdataread(filepath)
%point cloud read
try
    ptcloud = pcread(filepath); %读入数据 
    data(:,1)= double(ptcloud.Location(1:5:end,1));   %根据图中Location参数 提取所有点的三维坐标 步长5
    data(:,2)= double(ptcloud.Location(1:5:end,2));
    data(:,3)= double(ptcloud.Location(1:5:end,3)); 
    try
        color(:,1)=double(ptcloud.Color(1:5:end,1));
        color(:,2)=double(ptcloud.Color(1:5:end,2));
        color(:,3)=double(ptcloud.Color(1:5:end,3));
        color=stretch(color,0,1);
    catch
        color=1;
    end
    type=1;
catch
    tmp=importdata(filepath);
    data1=tmp(1:5:end,1:3);
    %data2=tmp(1:5:end,5:7);
    data=[data1];
    [data] = cst(data);
%     type1=tmp(1:5:end,4);
%     type2=tmp(1:5:end,8);
%     type=[type1;type2];
    type=1;
    ptcloud=data;
    color=1;
end

