function [D,D2,bands,s,format,interleave,machine,b,text3,text6]=envidataread(filepath,info)
%D为转换的图像文件
if nargin < 2
    error('请检查输入数据是否符合标准');
end

%查找列数
a=strfind(info,'samples = ');
b=length('samples = ');
c=strfind(info,'lines');
samples=[];
for i=a+b:c-1
samples=[samples,info(i)];
end
samples=str2double(samples);
%查找行数
a=strfind(info,'lines   = ');
b=length('lines   = ');
c=strfind(info,'bands');
lines=[];
for i=a+b:c-1
lines=[lines,info(i)];
end
lines=str2double(lines);
%查找波段数
a=strfind(info,'bands   = ');
b=length('bands   = ');
c=strfind(info,'data type');
bands=[];
for i=a+b:c-1
bands=[bands,info(i)];
end
bands=str2double(bands);
%查找数据类型
a=strfind(info,'data type = ');
b=length('data type = ');
c=strfind(info,'interleave');
datatype=[];
for i=a+b:c-1
datatype=[datatype,info(i)];
end
datatype=str2double(datatype);
%查找存储的字节排列方式
a=strfind(info,'byte order = ');
b=length('byte order = ');
c=strfind(info,'map info');
byteorder=[];
for i=a+b:c-1
byteorder=[byteorder,info(i)];
end
byteorder=str2double(byteorder);
%查找interleave 交错
a=strfind(info,'interleave = ');
b=length('interleave = ');
c=strfind(info,'file type');
interleave=[];
for i=a+b:c-3
interleave=[interleave,info(i)];
end
%查找file type
a=strfind(info,'file type = ');
b=length('file type = ');
c=strfind(info,'header offset');
filetype=[];
for i=a+b:c-3
filetype=[filetype,info(i)];
end
switch byteorder %数据存储的字节排列方式，有'ieee-le'(小端)，'ieee-be'(大端)
    case 0
        machine = 'ieee-le';
    case 1
        machine = 'ieee-be';
    otherwise
        machine = 'n';
end
 
switch datatype
    case 1
        format='uint8=>uint8';%头文件中datatype=1对应ENVI中数据类型为Byte，对应MATLAB中数据类型为uint8
    case 2
        format='int16=>int16';%头文件中datatype=2对应ENVI中数据类型为Integer，对应MATLAB中数据类型为int16
    case 12
        format='uint16=>uint16';%头文件中datatype=12对应ENVI中数据类型为Unsighed Int，对应MATLAB中数据类型为uint16
    case 3
        format='int32=>int32';%头文件中datatype=3对应ENVI中数据类型为Long Integer，对应MATLAB中数据类型为int32
    case 13
        format='uint32=>uint32';%头文件中datatype=13对应ENVI中数据类型为Unsighed Long，对应MATLAB中数据类型为uint32
    case 4
        format='float32=>float32';%头文件中datatype=4对应ENVI中数据类型为Floating Point，对应MATLAB中数据类型为float32
    case 5
        format='double=>double';%头文件中datatype=5对应ENVI中数据类型为Double Precision，对应MATLAB中数据类型为double
    otherwise
        msgbox('错误的文件格式或内容');%除以上几种常见数据类型之外的数据类型视为无效的数据类型
end

% *** BSQ Format ***
% [Band 1]
% R1: C1, C2, C3, ...
% R2: C1, C2, C3, ...
%  ...
% RN: C1, C2, C3, ...
%
% [Band 2]
%  ...
% [Band N]

% *** BIL Format ***
% [Row 1]
% B1: C1, C2, C3, ...
% B2: C1, C2, C3, ...
%
%  ...
% [Row N]

% *** BIP Format ***
% Row 1
% C1: B1 B2 B3, ...
% C2: B1 B2 B3, ...
% ...
% Row N

a=strfind(filepath,'.hdr');
filepath2=[];
for i=1:a
filepath2=[filepath2,filepath(i)];
end
filepath2=[filepath2,'dat'];
%智能匹配波段算法
try
    a=strfind(info,'wavelength = ');
    b=length('wavelength = ');
    c=strfind(info,'fwhm');
    wave=[];
    for j=a+b:c-7
    wave=[wave,info(j+3)];
    end
    wavelength=regexp(wave,'\,','split');
    wavelength=str2double(wavelength);%波长读取值
    [b] = selectbands(wavelength,bands);
catch
    msgbox('没有相关波段数据，默认选择波段！');
    b=[1,2,3];
end
if strcmp(filetype, 'ENVI Classification')%比较两个字符串，判定归属
   D=multibandread(filepath2,[lines,samples,bands],'uint8',0,interleave,machine,{'Band','Direct',[b(1),b(2),b(3)]});
   D2=multibandread(filepath2,[lines,samples,bands],'uint8',0,interleave,machine);
else 
   D=multibandread(filepath2,[lines,samples,bands],format,0,interleave,machine,{'Band','Direct',[b(1),b(2),b(3)]});
   D2=multibandread(filepath2,[lines,samples,bands],format,0,interleave,machine);
%skip 0
end

format1=[];
i = strfind(format,"=>");
for i = 1:i-1
    format1 = [format1,format(i)];
end
s1 = "行数：";
s2 = "列数：";
s3 = "波段数：";
s4 = "数据类型：" ;
s5 = "数据储存格式：";
s6 = "字节排列方式：";

s7 = sprintf('<HTML><A color="%s">█</A><A>%s', "red", "Red&emsp波段:  "+num2str(b(1))+newline);
s8 = sprintf('<HTML><A color="%s">█</A>%s', '#00FA9A', "Green波段:  "+num2str(b(2))+newline);
s9 = sprintf('<HTML><A color="%s">█</A><A>%s', '#00BFFF', "Blue&emsp波段:  "+num2str(b(3)));

s = [s7,s8,s9];
text3 = [];
text3 = [text3,s1,s2,s3,s4,s5,s6];
text6 = {lines,samples,bands,format1,interleave,machine};
% s = [];
% s0 = strcat('波段数：',num2str(bands),'段');
% s02=newline;
% s1 = sprintf('<HTML><A color="%s">██<A>%s', 'red', "Red波段： "+num2str(b(1)));%html改变某个特定字符的值
% s12=newline;
% s2 = sprintf('<HTML><A color="%s">██<A>%s', '#00FA9A', "Green波段： "+num2str(b(2)));%这里的"Green.."不可改用'，会导致编码错误
% s22=newline;
% s3 = sprintf('<HTML><A color="%s">██<A>%s', '#00BFFF', "Blue波段： "+num2str(b(3)));
% s = [s,s0,s02,s1,s12,s2,s22,s3];


% Dimensions问题
% a=['asd';'bsc';'2']
% Error using vertcat
% Dimensions of arrays being concatenated are not consistent. 

% a=["asd";"bsc";"2"]
% a = 
%   3×1 string array
%     "asd"
%     "bsc"
%     "2"

% n=samples*bands*lines;
% fid=fopen(filepath2);
% D = fread(fid,n,format,0,machine);%skip 0
% fclose(fid);
% 关闭文件
% 显示图像
% D = reshape(D,[samples,bands,lines]);
% D = permute(D,[3,1,2]);
% 
% switch lower(interleave)%小写转换
%    case 'bsq'
%        D = reshape(D,[samples,lines,bands]);
%        D = permute(D,[2,1,3]);
%    case 'bil'
%        D = reshape(D,[samples,bands,lines]);
%        D = permute(D,[3,1,2]);
%    case 'bip'
%        D = reshape(D,[bands,samples,lines]);
%        D = permute(D,[3,2,1]);
% end
% D=multibandread(filepath2,[lines,samples,bands],format,0,interleave,machine);

% 检测波段灰度范围
% a=max(D);
% a=a(:,:,6)'; 
% a=max(a)
% a=max(D);
% a=a(:,:,5)'; 
% a=max(a)
% a=max(D);
% a=a(:,:,4)'; 
% a=max(a)
% a=max(D);
% a=a(:,:,3)'; 
% a=max(a)
% a=max(D);
% a=a(:,:,2)'; 
% a=max(a)
% a=max(D);
% a=a(:,:,1)'; 
% a=max(a)
