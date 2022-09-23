function [ang]=angcount(a,b)
    s=dot(a,b);
    ts1=sqrt(dot(a,a));
    ts2=sqrt(dot(b,b));
    ang=acos(s/(ts1*ts2));
end
