function [PC,msg] = pc(D2)
%监督分类
%多维随机向量
%特征变换
%K-L PCA refer to https://blog.csdn.net/luoluonuoyasuolong/article/details/90711318?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-4.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-4.control
mul=double(D2);
[r ,c ,bands]=size(mul);
pixels = r*c;
% reshape成pixels*channel
mul = reshape(mul, [pixels,bands]);%改变为2维矩阵
tempMul = mul;
% 求各通道的均值
meanValue =  mean(mul,1);
% 数据去中心化，各个波段减去其均值
mul = mul - repmat(meanValue,[r*c,1]);%加快计算
% 求协方差矩阵
correlation = (mul'*mul)/pixels;
%求特征向量与特征值
[vector ,value] = eig(correlation);
% 特征值和特征向量从大到小排序
vector = fliplr(vector);%向量
% Y=AX（X中列为样本，若X行为样本，则Y =XA。这里X为变量tempMul其size为Pixels bands所以Y=XA）
% PCA正变换
PC = tempMul*vector; 
%占有信息量
for i=1:bands
    v(i)=value(i,i);
end
v = fliplr(v);%特征值
for i=1:bands
    msg(i)=roundn(v(i)/sum(v),-3);
    format short;
end

% 提取多光谱图像的各个主成分
% for i = 1:bands
%     outPic = PC(:,i);
%     min_value = min(outPic);
%     max_value = max(outPic);
%     outPic = reshape(outPic,[r,c]);
%     imshow(outPic,[min_value,max_value]);title(str);
%    filename = sprintf('%d%s',i,'.jpg');
%    imwrite(outPic,filename);
% end

% 错误算法
% [N,M,~]=size(D2);
% Y=zeros(N,M,bands);
% for i=1:bands-1
%     X=D2(:,:,i);%多光谱的一个光谱矢量
%     [N,~,~]=size(X);
%     S=cov(X);%协方差,通过training data检验
%     %计算特征值eg和特征向量Ev
%     [Ev,eg]=eig(S);
%     %从大到小排序（翻转）
%     eg = fliplr(eg);
%     Ev = fliplr(Ev);
%     Y(:,:,i)=X*Ev;
% end
% for i = 1:bands
%     outPic = PC(:,i);
%     min_value = min(outPic);
%     max_value = max(outPic);
%     outPic = reshape(outPic,[r,c]);
%     figure;
%     str = sprintf('%s%d%s','第',i,'主成分');
%     imshow(outPic,[min_value,max_value]);title(str);
%     filename = sprintf('%d%s',i,'.jpg');
%     imwrite(outPic,filename);
% end
% Y1=cov(Y1);
% a=Y1(1,1)
% b=Y1(3,1)

% pca压缩算法 X错误，X正确形式为tempMul变量值。
% 设置好规格矩阵
% COEFF=zeros(N,M-1,bands);
% SCORE=zeros(N,M-1,bands);
% latent=zeros(M-1,1,bands);
% tsquare=zeros(M,1,bands);
% for i=1:bands
%     X=D2(:,:,i);%多光谱的一个光谱矢量
%     [COEFF1,SCORE1,latent1,tsquare1] = pca(X);
%     COEFF(:,:,i)=COEFF1;%主成分系数:即原始数据线性组合生成主成分数据中每一维数据前面的系数.
%     SCORE(:,:,i)=SCORE1;%原始数据在新生成的主成分空间里的坐标值
%     latent(:,:,i)=latent1;%?
%     tsquare(:,:,i)=tsquare1;%每个观察到中心距离
% end


