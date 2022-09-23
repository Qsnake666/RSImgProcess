function [eigvalue] = pclpfh(pcdata,n,text5)
%Point Feature Histograms,PFH
%PCL 特征
% refer to https://wenku.baidu.com/view/c028e94d0b4c2e3f572763b7.html
%Intrinsic Shape Signature算法
t0=cputime;
set(text5,'string','parparing...');
pause(0);
kdtree = KDTreeSearcher(pcdata);%default 'euclidean' distance  
[m,~]=size(pcdata);
for i=1:m
    ns=n(i,:);
    Ds=pcdata(i,:);
    [index, ~] = knnsearch(kdtree, Ds, 'K', 6);
    for j=1:5
        nt=n(index(j+1),:);
        D1=-Ds+pcdata(index(j+1),:);
%         i=D1(1,2).*n(1,3)-D1(1,3).*n(1,2);
%         j=D1(1,1).*n(1,3)-D1(1,3).*n(1,1);
%         k=D1(1,1).*n(1,2)-D1(1,2).*n(1,1);
        U=ns;
        V=cross(U,D1/sqrt(dot(D1,D1)));%向量乘法（外积）
        W=cross(U,V);
        %点特征直方图描述子
        d=(D1(1,1)^2+D1(1,2)^2+D1(1,3)^2)^0.5;
        alpha=angcount(V,nt);
        phi=angcount(U,D1/d);
        theta=angcount(U+W,nt);%不知道是否推算正确
        eigvalue=[alpha,phi,theta];
    end
end


    