function [PC] = hadama(D2)
%监督分类
%多维随机向量
%特征变换
mul=double(D2);
[r ,c ,bands]=size(mul);
pixels = r*c;
% reshape成pixels*channel
mul = reshape(mul, [pixels,bands]);%改变为2维矩阵
PC = hadamard(pixels)*mul;
