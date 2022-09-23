function [l_red] = icp_red_l(l)

for i = 1:3
    l_(i,:) = (1/length(l))*sum(l(i,:));
end

l_red = l - l_;

end