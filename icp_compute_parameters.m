function[R, s, t] = icp_compute_parameters(r, l)
% 去中心化
l_red = icp_red_l(l);
r_red = icp_red_r(r);

% compute R
S = icp_compute_S(l_red, r_red);
R = icp_compute_R(S);

% compute scale
s = icp_compute_scale(l_red, r_red);

% compute translation 
t = icp_compute_translation(r, s, R, l);

end