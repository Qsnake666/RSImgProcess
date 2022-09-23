function [tri] = pcltin(pcdata,text5)
%pcl-tin create
x=pcdata(:,1);
y=pcdata(:,2);
z=pcdata(:,3);
tri=delaunay(x,y);   %以X,Y为准生成Delaunay triangulation（三角网）
trisurf(tri,x,y,z);  %将该三角网显示出来
colormap autumn;
end

