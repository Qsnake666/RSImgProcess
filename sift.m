function [un] = sift(PC)
clc
%sift refer to https://blog.csdn.net/hggjgff/article/details/83749031?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-1&spm=1001.2101.3001.4242
%尺度不变特征变换
%尺度空间
pc=PC(:,:,1);%临时选择第一波段作为特征波段
% figure; test img
% pc=stretch(pc,0,1);
% imshow(pc)
%pc=stretch(pc,0,1) 不清楚是否需要拉伸 待更新
[m,n]=size(pc);
pc2=reshape(pc,m*n,1);
sigma=0.8; %二维图像正态分布标准差,直接赋值？
s=3; 
k=2^(1/s);
sigma2=ones(1,s+3);
sigma2(1)=sigma;
sigma2(2)=sigma*sqrt(k*k-1);
%构建金字塔
for s=1:5
    sigma2(s+2)=sigma2(s+1)*k;
%     for x=1:m
%         for y=1:n
%             G(x,y,z)=(1/(2*pi*sigma2(z)^2))*exp(-(x^2+y^2)/(2*sigma2(z)^2));%高斯核 
%         end
%     end
end
% %调整图像大小，扩大2倍 
% pcs=imresize(pc,2);
% [a,b]=size(pcs) a,b 都翻倍
%Gaussian平滑 更新：利用高斯核
hsize=fix((6*sigma+1)^2);%滤波器的大小
f1=fspecial('gaussian',hsize,sigma);
pcs=imfilter(pc,f1,'replicate');
pcs=stretch(pcs,0,1);
% figure;
% imshow(pcs) img test
% 计算金字塔组数
octvs=floor(log(min(size(pcs)))/log(2)-2);
[h,w]=size(pcs);
pyr=cell(octvs,1);
% 图片大小 每层一个h，w
% 构建金字塔
for i = 1:octvs
    if i~=1
        [a,b,~]=size(imresize(pyr{i-1},0.5));
        pyr{i} = zeros(a,b,s+3);
    else
    pyr{i} = zeros(h,w,s+3);%每组s+3层 dogs+2层 保证每个尺度极点检测
    end
end

%对分组的每一层操作
for i = 1:octvs
    for j = 1:s+3
        if i==1 && j==1
            pyr{i}(:,:,j) = pcs; %每一组第一层原图像
        % 从前一个组的s+1图像以八度为单位对第一个图像采样
        elseif i~=1 && j==1
            pyr{i}(:,:,j)=imresize(pyr{i-1}(:,:,j),0.5);            
        else
        % 上层高斯卷积成果
           f2=fspecial('gaussian',hsize,sigma2(j));
           gpyr=imfilter(pyr{i}(:,:,j-1),f2,'replicate');
           pyr{i}(:,:,j)=stretch(gpyr,0,1);
           %[a,b]=size(gpyr) check
        end
    end
end
%LoG近似DoG找到关键点
%为了寻找尺度空间的极值点，每一个采样点要和它所有的相邻点比较，看其是否比它的图像域和尺度域的相邻点大或者小。
%中间的检测点和它同尺度的8个相邻点和上下相邻尺度对应的9×2个点共26个点比较，以确保在尺度空间和二维图像空间都检测到极值点。 
%一个点如果在DOG尺度空间本层以及上下两层的26个领域中是最大或最小值时，就认为该点是图像在该尺度下的一个特征点。

%差分金字塔
%差分高斯函数是尺度规范化的高斯拉普拉斯函数的近似，而高斯拉普拉斯函数的极大值和极小值点是一种非常稳定的特征点。
dog_pyr = cell(octvs,1);
for i = 1:octvs
    [a,b,~]=size(pyr{i});
    dog_pyr{i} = zeros(a,b,s+2);
    for j = 1:s+2
        dog_pyr{i}(:,:,j)=pyr{i}(:,:,j+1)-pyr{i}(:,:,j); %逐差得到差值
    end
end
% syms sigma
% syms x
% syms y
% [m,n]=size(pc);
% for x=1:m
% for y=1:n
% for i = 1:octvs
%     for j = 1:s+3
%         if i==1 && j==1
%            pyr{i}(:,:,j) = pcs; %每一组第一层原图像
%            f2=0;
%            f3=sym(fspecial('gaussian',hsize,sigma2(j+1)));
%         % 从前一个组的s+1图像以八度为单位对第一个图像采样
%         elseif i~=1 && j==1
%            pyr{i}(:,:,j)=imresize(pyr{i-1}(:,:,j),0.5);
%            f2=0;
%            f3=sym(fspecial('gaussian',hsize,sigma2(j+1)));
%         elseif i~=1 && j==2
%         % 上层高斯卷积成果
%            f2=sym(fspecial('gaussian',hsize,sigma2(j)));
%            f3=sym(fspecial('gaussian',hsize,sigma2(j+1)));
%            %[a,b]=size(gpyr) check
%         end
%     end
% end
% D(x,y,sigma2)=stretch((f3-f2)*pc(x,y),0,1);
% end
% end

        
%低对比度筛选（阀值T lowe小于0.04的极值点可以抛弃）
contrast_r=0.04;
%检测主曲率是否在某阀值
curve_v = 10 ;
prelimcontrast_r=0.5*contrast_r/s; %0.5*T/s
for i = 1:octvs
    %中心极值 本尺度空间以及上下两层最大点
    for j=2 :s+1
        dog_imgs=dog_pyr{i};
        dog_img=stretch(dog_imgs(:,:,j),0,1);
        dog_imgu=stretch(dog_imgs(:,:,j+1),0,1);%上层空间
        dog_imgd=stretch(dog_imgs(:,:,j-1),0,1);%下方空间        
        [m,n]=size(dog_img);
        %本层
        for x = 2:m-1
            for y = 2:n-2
                %第0轮推举（阈值检测）
                if abs(dog_img(x,y)) > prelimcontrast_r
                    %第一轮选举（极值检测） 26点选择
                    count=1;
                    for a=x-1:x+1
                        for b=y-1:y+1
                            valueu(count)=dog_imgu(a,b);
                            valued(count)=dog_imgd(a,b);
                            value(count)=dog_img(x,y);
                            count=count+1;
                        end
                    end
                    maxu=max(valueu);
                    maxd=max(valued);
                    maxi=max(value);
                    temp=[maxu,maxd,maxi];
                    if dog_img(x,y)==max(temp)
                        % 第二轮选举（极值点精确定位）
                        pyr{i}(x,y,j)=12;
                        DX=dog_img(x,y)+diff(D(x,y,sigma),x,y,sigma)+1/2*
                    end
                end
            end
        end
    end
end
un=pyr{3}(:,:,2);
                        

                
