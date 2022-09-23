function [b] = selectbands(wavelength,bands)
%波段颜色判定
b=[];
countr=0;
countg=0;
countb=0;
for i=1:bands
    if wavelength(i)>=0.59&&wavelength(i)<=0.76
        countr=countr+1;
        brw(countr)=wavelength(i);%R
    elseif wavelength(i)>=0.52&&wavelength(i)<0.59
        countg=countg+1;
        bgw(countg)=wavelength(i);%G
    elseif wavelength(i)>=0.43&&wavelength(i)<0.52
        countb=countb+1;
        bbw(countb)=wavelength(i);%B 
    end
end
%红色波段匹配选择
try
    count=0;
    try
        for i=1:countr
            if brw(i)>=0.69
                brc(i)=brw(i)-0.69;
                count=count+1;
            end
        end
        br1=min(brc);
    catch
    end
    try
        for i=1:countr
            if brw(i)<0.69
                brc2(i)=-brw(i)+0.69;
            end
        end
        br2=min(brc2);
    catch
    end
    try
        br3=[br1,br2];
    catch
        try
            br3=br1;
        catch
            br3=br2;
        end
    end
    br4=min(br3);
    index=find(br3==br4);
    if index<=count
        br=br3(index)+0.69;
    else
        br=-br3(index)+0.69;%还原最佳波段的波长
    end
catch
    %msgbox('无匹配红色波段！请手动选择。');
    for i=1:bands
        brr(i)=abs(wavelength(i)-0.69);
    end
    tmp=min(brr);
    index=find(brr==tmp);
    br=brr(index)+0.69;
    index2=find(wavelength==br);
    if ~isempty(index2)
    else
        br=-(brr(index)-0.69);
    end
end
%绿色波段匹配选择
try
    count=0;
    try
        for i=1:countg
            if bgw(i)>=0.53
                bgc(i)=bgw(i)-0.53;
                count=count+1;
            end
        end
        bg1=min(bgc);
    catch
    end
    try
        for i=1:countg
            if bgw(i)<0.53
                bgc2(i)=-bgw(i)+0.53;
            end
        end
        bg2=min(bgc2);
    catch
    end
    try
        bg3=[bg1,bg2];
    catch
        try
            bg3=bg1;
        catch
            bg3=bg2;
        end
    end
    bg4=min(bg3);
    index=find(bg3==bg4);
    if index<=count
        bg=bg3(index)+0.53;
    else
        bg=-bg3(index)+0.53;
    end
catch
    for i=1:bands
        bgg(i)=abs(wavelength(i)-0.53);
    end
    tmp=min(bgg);
    index=find(bgg==tmp);
    bg=bgg(index)+0.53;
    index2=find(wavelength==bg);
    if ~isempty(index2)
    else
        bg=-(bgg(index)-0.53);
    end
end
%蓝色波段匹配选择
try
    count=0;
    try
        for i=1:countb
            if bbw(i)>=0.45
                bbc(i)=bbw(i)-0.45;
                count=count+1;
            end
        end
        bb1=min(bbc);
    catch
    end
    try
        for i=1:countb
            if bbw(i)<0.45
                bbc2(i)=-bbw(i)+0.45;
            end
        end
        bb2=min(bbc2);
    catch
    end
    try
        bb3=[bb1,bb2];
    catch
        try
            bb3=bb1;
        catch
            bb3=bb2;
        end
    end
    bb4=min(bb3);
    index=find(bb3==bb4);
    if index<=count
        bb=bb3(index)+0.45;
    else
        bb=-bb3(index)+0.45;
    end
catch
    %msgbox('无匹配蓝色波段！请手动选择。');
    for i=1:bands
        bbb(i)=abs(wavelength(i)-0.45);
    end
    tmp=min(bbb);
    index=find(bbb==tmp);
    bb=bbb(index)+0.45;
    index2=find(wavelength==bb);
    if ~isempty(index2)
    else
        bb=-(bbb(index)-0.45);
    end
end
b(1)=find(wavelength==br);
b(2)=find(wavelength==bg);
b(3)=find(wavelength==bb);
