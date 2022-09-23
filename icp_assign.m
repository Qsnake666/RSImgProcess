function [r_new] = icp_assign(l_in, r_in)
%控制点匹配
    r_inn=r_in';
    kdtree = KDTreeSearcher(r_inn);
    [idx,~]=knnsearch(kdtree, l_in', 'k', 1);
%     len = length(l_in(1,:));
%     dist = ones(len, len);
%     r_new = r_in;
% 
%     for i=1:len 
%         for j=1:len
%             dist(j,i)=sqrt((r_in(1,j) - l_in(1,i))^2+(r_in(2,j) - l_in(2,i))^2+(r_in(3,j) - l_in(3,i))^2);
%         end
%    
%     [~,Imin] = min(dist(j,:));
    for i=1:length(l_in)
        r_new(:,i) = r_inn(idx(i),:)';
    end
end