function [ps,pqq,ptc] = pclicp(ps,text5)
%pcl-iterative closest points
%配准算法 刚性变换
pqq=ps;
[filename,pathname] = uigetfile({'*.ply;*.txt','data Files(*.ply;*.txt)'},'选择目标点云数据');
if(isempty(pathname))
    return;
end
set(text5,'string','正在打开文件，请稍候');
pause(0.1);
try
    filepath=strcat(pathname,filename);
    ptcloud2 = pcread(filepath); %读入数据 
    ptc(:,1)= double(ptcloud2.Location(1:5:end,1));  
    ptc(:,2)= double(ptcloud2.Location(1:5:end,2));
    ptc(:,3)= double(ptcloud2.Location(1:5:end,3)); 
catch
    tmp=importdata(filepath);
    data1=tmp(1:5:end,1:3);
%     data2=tmp(1:5:end,5:7);
    ptc=[data1];
%     type1=tmp(:,4);
%     type2=tmp(:,8);
%     pttype=[type1;type2];
end
%开始滤波。
% [ps,~] = pclsor(ps,1,text5);
% [ptc,~] = pclsor(ptc,1,text5);
n=size(ps,1);
m=size(ptc,1);
set(text5,'string','正在迭代');
pause(0.1);
%粗匹配 
%距离模型
pt=[];
for i=1:n
    msdis=ps(i,:)-mean(ps);
    psdis(i)=dot(msdis,msdis);
end
% [tpsd,indx]=sort(psdis);
% for i=1:3
%     mpsdis(i)=tpsd(end-i+1); %距离前3部分要拟合相等，3点定位
%     mps(i,:)=ps(indx(end-i+1),:);
% end

for i=1:m
    mtdis=ptc(i,:)-mean(ptc);
    ptdis(i)=dot(mtdis,mtdis);
end
% tptd=sort(ptdis);
% for i=1:3
%     mptdis(i)=tptd(end-i+1); %距离前3部分要拟合相等，3点定位
% end
% if dot(mpsdis-mptdis,mpsdis-mptdis)>0.00001 %质心点移位
%     syms x y z
%     eqn1=(mps(1,1)-x)^2+(mps(1,2)-y)^2+(mps(1,3)-z)^2==mptdis(1);
%     eqn2=(mps(2,1)-x)^2+(mps(2,2)-y)^2+(mps(2,3)-z)^2==mptdis(2);
%     eqn3=(mps(3,1)-x)^2+(mps(3,2)-y)^2+(mps(3,3)-z)^2==mptdis(3);
%     [Sx,Sy,Sz]=solve(eqn1,eqn2,eqn3,x,y,z);
%     meanps=[double(Sx),double(Sy),double(Sz)]
%     meanps=meanps(2,:);
%     mean(ps)
% end
% qq=mps(1,:)-meanps;
% qq=dot(qq,qq)
% qq=mps(2,:)-meanps;
% qq=dot(qq,qq)
% qq=mps(3,:)-meanps;
% qq=dot(qq,qq)
% for i=1:n
%     msdis=ps(i,:)-meanps;
%     psdis(i)=dot(msdis,msdis);
% end
%控制点集
% r=round(rand(round(n/10),1)*n);
for i=1:n
    pst(i,:)=ps(i,:);
    tmp=abs(psdis(i)-ptdis);
    [~,indx]=min(tmp);
    ptt(i,:)=ptc(indx,:);
end
ps=pst;
pt=ptt;
psa=mean(ps);
pta=mean(pt);
psi=ps-psa;
pti=pt-pta;
H=psi'*pti;
[U,~,V]=svd(H);
R=V*U';
t=pta'-R*psa';
newps=R*ps'+t;
ps=newps';
% kdtree=KDTreeSearcher(pt);
% for iter=1:10 %最大迭代10次
%     %使用欧式距离最近的点作为对应点，遍历筛选
% %     for i=1:n
% %         difference=(ptc-ps(i,:)).^2;  
% %         distance=sum(difference,2);
% %         [~,minIndex]=min(distance);
% %         pt(i,:)=ptc(minIndex,:);    %保存对应点  需要更新 kdtree结构，复杂度减少
% %     end
%     [idx,~]=knnsearch(kdtree, ps, 'K', 1);
%     pt=ptc(idx,:);
%     psa=mean(ps);
%     pta=mean(pt);
%     psi=ps-psa;
%     pti=pt-pta;
%     H=psi'*pti;
%     [U,~,V]=svd(H);
%     s = sqrt(sum(norm(ps)^2)/sum(norm(pt)^2));
%     R=s*V*U';
%     t=pta'-R*psa';
%     newps=R*ps'+repmat(t,1,length(ps));
%     ps=newps';
%     delta=sum(sum((ps-pt).^2,2));	%计算新的点集P到对应点的平均距离%中间迭代的误差
%     if(delta<0.0001)
%         break;
%     end
% end