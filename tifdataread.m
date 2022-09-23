function [ D,D2,b,s,bands,text3,text6 ] = tifdataread(filepath)
try
    a = strfind(filepath,'_B');
    tiftxt = [];
    for i=1:a
            tiftxt=[tiftxt,filepath(i)];
    end
    txtfile = strcat(tiftxt,'MTL.txt');
    fid = fopen(txtfile, 'r');
    info = fread(fid,'char=>char');
    info=info'; %默认读入列向量，须要转置为行向量才适于显示
    fclose(fid);
    % 查找波段
    i = 1;
    a = '';
    thebands = [];
    while(1)
        bandtxt = strcat('RADIANCE_MULT_BAND_',num2str(i),' = ');
        a=strfind(info,bandtxt);
        b=length(bandtxt);
        c=strfind(info,strcat('RADIANCE_MULT_BAND_',num2str(i+1),' = '));
        breaknum = 0;
        if isempty(c)
            c=strfind(info,'RADIANCE_ADD_BAND');
            breaknum = 'true';
        end
        theband=[];
        for j=a+b:c-1
        theband=[theband,info(j)];
        end
    %   theband = str2double(theband);
        thebands(i) = string(theband);
        i = i+1;
        if(breaknum)
            break;
        end
    end

    %查找文件日期
    a=strfind(info,'FILE_DATE = ');
    b=length('FILE_DATE = ');
    c=strfind(info,'STATION_ID');
    filedata=[];
    for i=a+b:c-6
    filedata=[filedata,info(i)];
    end
    filedata=string(filedata);

    %查找卫星型号
    a=strfind(info,'SPACECRAFT_ID = ');
    b=length('SPACECRAFT_ID = ');
    c=strfind(info,'SENSOR_ID = ');
    spacecraftid=[];
    for i=a+b:c-7
    spacecraftid=[spacecraftid,info(i)];
    end
    spacecraftid=string(spacecraftid);

    %查找传感器类型
    a=strfind(info,'SENSOR_ID = ');
    b=length('SENSOR_ID = ');
    c=strfind(info,'WRS_PATH = ');
    sensorid=[];
    for i=a+b:c-6
    sensorid=[sensorid,info(i)];
    end
    sensorid=string(sensorid);

    % 查找投影方式
    a=strfind(info,'MAP_PROJECTION = ');
    b=length('MAP_PROJECTION = ');
    c=strfind(info,'DATUM = ');
    maproject=[];
    for i=a+b:c-6
    maproject=[maproject,info(i)];
    end
    maproject=string(maproject);

    %查找椭球
    a=strfind(info,'ELLIPSOID = ');
    b=length('ELLIPSOID = ');
    c=strfind(info,'UTM_ZONE =');
    ellipsoid=[];
    for i=a+b:c-6
    ellipsoid=[ellipsoid,info(i)];
    end
    ellipsoid=string(ellipsoid);

    % 查找带号
    a=strfind(info,'UTM_ZONE =');
    b=length('UTM_ZONE =');
    c=strfind(info,'GRID_CELL_SIZE_REFLECTIVE');
    utmzone=[];
    for i=a+b:c-6
    utmzone=[utmzone,info(i)];
    end
    utmzone=string(utmzone);

    bands = length(thebands);
    b = selectbands(thebands,bands);
catch
    bands=3; %普通tif图片 Single
    b = [1,2,3];%RGB
end
d=imread(filepath);
[r,c,~]=size(d);
D2=zeros(r,c,bands);
D = zeros(r,c,length(b));
try
    n=strfind(filepath,'_B');
    filepathA=[];
    for i=1:n
        filepathA=[filepathA,filepath(i)];
    end
    for i=1:length(thebands)
        filepathi=strcat(filepathA,'B',num2str(i),'.tif');
        d=imread(filepathi);
        D2(:,:,i)=d;
    end

    for i=1:length(b)
        filepathi=strcat(filepathA,'B',num2str(b(i)),'.tif');
        d=imread(filepathi);
        D(:,:,i)=d;
    end


    s1 = "FILE_DATE :"+newline;
    s2 = "SPACECRAFT_ID :";
    s3 = "SENSOR_ID :";
    s4 = "MAP_PROJECTION :" ;
    s5 = "ELLIPSOID :";
    s6 = "UTM_ZONE :";

    text3 = [];
    text3 = [text3,s1,s2,s3,s4,s5,s6];
    text6 = [filedata,spacecraftid,sensorid,maproject,ellipsoid,utmzone];

    for i = 1:length(text6)
        try
            temp=[];
            temp=text6(i);
            temp=temp(1:10);
            for j=1:3
                temp(14-j)='.';
            end
            text6(i)=temp;
        catch
        end
    end
 
    s7 = sprintf('<HTML><A color="%s">█</A><A>%s', "red", "Red&emsp波段:  "+num2str(b(1))+newline);
    s8 = sprintf('<HTML><A color="%s">█</A>%s', '#00FA9A', "Green波段:  "+num2str(b(2))+newline);
    s9 = sprintf('<HTML><A color="%s">█</A><A>%s', '#00BFFF', "Blue&emsp波段:  "+num2str(b(3)));

    s = [s7,s8,s9];
catch
    d=imread(filepath);
    for i=1:bands
        D(:,:,i)=d(:,:,b(i));
    end
    D2=imread(filepath);
    s7 = sprintf('<HTML><A color="%s">█</A><A>%s', "red", "Red&emsp波段:  "+num2str(b(1))+newline);
    s8 = sprintf('<HTML><A color="%s">█</A>%s', '#00FA9A', "Green波段:  "+num2str(b(2))+newline);
    s9 = sprintf('<HTML><A color="%s">█</A><A>%s', '#00BFFF', "Blue&emsp波段:  "+num2str(b(3)));
    s = [s7,s8,s9];
    text3='图片位置';
    text6=filepath;
end