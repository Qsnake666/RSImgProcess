function interplocation
%插值尺度空间极值位置和尺度
% i = 1;
% while (i<=5) %5次迭代
%     X=-diff(diff(D(x,y,s)))^-1*diff(D(x,y,s))
%     
% end
syms x %每次使用重新声明
syms y
syms sigma
G(x,y,sigma2)=(1/(2*pi*sigma^2))*exp(-(x^2+y^2)/(2*sigma^2));%高斯核 
