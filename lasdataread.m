function [data,ptcloud,color] = lasdataread(filepath)
% 提取las文件需要处理数据
ptcloud=lasread(filepath);
% xyz参数
try
    data(:,1)=double(ptcloud.x);
    data(:,2)=double(ptcloud.y);
    data(:,3)=double(ptcloud.z);
%     tmpm=num2str(round(mean(mean(data))));
%     tmpl=length(tmpm);
%     arg=10^(tmpl-2);
%     data=data/arg;
    [data] = cst(data);
catch
    error('no xyz parameter');
end
% color参数
try
    color(:,1)=double(ptcloud.red);
    color(:,2)=double(ptcloud.green);
    color(:,3)=double(ptcloud.blue);
    color=stretch(color,0,1);
catch
    disp('no color parameter');
    color=1;
end
