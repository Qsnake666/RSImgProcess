function [ a ] = icp(ps)
% load data sets
l = ps';
[filename,pathname] = uigetfile({'*.ply;*.txt','data Files(*.ply;*.txt)'},'选择目标点云数据');
if(isempty(pathname))
    return;
end
filepath2=strcat(pathname,filename);
r = loadPly(filepath2);

% set OG parameters
R = [sqrt(2)/2 -sqrt(2)/2   0;
     sqrt(2)/2  sqrt(2)/2   0;
     0    0     1];
s = 1;
t = [1; 10;  3];

% transform left data set
l_t = icp_transformation(s, R, l , t);

% Iteration until convergenve
counter = 0;
mse = 0.0;
c = 0;
for i=1:10 
    c = c + 1;
    mse_2 = mse;
    % assign point clouds
    r_new = icp_assign(l_t, r); %控制点匹配
    % estimate R_e, s_e, t_e
    [R_e, s_e, t_e] = icp_compute_parameters(r_new, l_t)
    % transform with estimated parameters
    l_t = icp_transformation(s_e, R_e, l_t, t_e);
    mse = sum(sum((r_new - l_t).^ 2));
    if mse<0.001
        break
    end
%     mse_xyz(c,:) = sum(abs(r_new - l_t).^ 2);
%     mseDiff = abs(mse - mse_2); 
    counter=counter+1
end 

% print final parameters
newps=R_e*l+t_e;
l=newps';
r=r';
a=1;
pcshowpair(pointCloud(l),pointCloud(r));
% plot mse
% figure;
% hold on;
% plot(mse_xyz(:,1),'r');
% plot(mse_xyz(:,2),'g');
% plot(mse_xyz(:,3),'b');
% legend('MSE_x', 'MSE_y', 'MSE_z')
% xlabel('Number of iterations')
% ylabel('MSE')
%     
    
    
    
% plot point clouds
% figure
% scatter3(l(1,:), l(2,:), l(3,:),'.');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% title('Left data set');
% axis equal
% grid on
% 
% figure
% scatter3(r(1,:), r(2,:), r(3,:),'.');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% title('Right data set');
% axis equal
% grid on
% 
% figure
% scatter3(l(1,:), l(2,:), l(3,:),'.');
% hold on
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% scatter3(r(1,:), r(2,:), r(3,:),'.');
% axis equal
% grid on
