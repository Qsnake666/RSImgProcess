function [SI,pglcm,ASM,ENT,IDM] = gcm(D2,D3)
%灰度共生矩阵纹理特征提取
%在theta方向上相隔d距离分别具有i和j出现的概率
%refer to https://blog.csdn.net/lang_yubo/article/details/79151132
%D3是特征选择的波段值
D2=stretch(D2,0,255);
X=D2(:,:,D3);
[glcm,SI]=graycomatrix(X,'GrayLimits',[],'NumLevels',8,'offset', [0 1], 'Symmetric', true);%0度，灰度级为8
[m,n]=size(glcm);
%归一化，得到glcm概率矩阵，先验概率
sumglcm=sum(sum(glcm));
for j=1:m
    for k = 1:n
        pglcm(j,k)= glcm(j,k)/sumglcm;
    end
end
%能量（角二阶距）（Angular Second Moment, ASM)
for j=1:m
    for k = 1:n
        ASM(j,k)= sum(pglcm(j,k).^2);
    end
end
%熵（Entropy, ENT)
for j=1:m
    for k = 1:n
        ENT=sum(pglcm(j,k)*(-log10(pglcm(j,k)))); 
    end
end
%反差分矩阵（Inverse Differential Moment, IDM)
for j=1:m
    for k = 1:n
        IDM=sum(pglcm(j,k)/(1+(j-k)^2)); 
    end
end