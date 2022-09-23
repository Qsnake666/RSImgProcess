function [r] = icp_transformation(s, R, l, t)
for i = 1:length(l)
   r = s*R*l;   
   r = r+t;   
end
end