function [r_red] = icp_red_r(r)

for i = 1:3
    r_(i,:) = (1/length(r))*sum(r(i,:));
end

r_red = r - r_;

end