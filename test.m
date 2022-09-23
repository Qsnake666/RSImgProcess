%for specific pic
clc;
filepath='/Users/wangjinhong/Desktop/1/202109mosaic_liaoning.hdr';
fid = fopen(filepath, 'r');
    info = fread(fid,'char=>char');
    info=info'; %默认读入列向量，须要转置为行向量才适于显示
    fclose(fid);

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
bands=6;
interleave='bsq';
byteorder=0;
datatype=12;
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
b=[3,2,1];
if strcmp(filetype, 'ENVI Classification')%比较两个字符串，判定归属
   D=multibandread(filepath2,[lines,samples,bands],'uint32',0,interleave,machine,{'Band','Direct',[b(1),b(2),b(3)]});
   D2=multibandread(filepath2,[lines,samples,bands],'uint32',0,interleave,machine);
else 
   D=multibandread(filepath2,[lines,samples,bands],format,0,interleave,machine,{'Band','Direct',[b(1),b(2),b(3)]});
   D2=multibandread(filepath2,[lines,samples,bands],format,0,interleave,machine);
%skip 0
end
format='uint32=>double';
D=double(D);
D=stretch(D,0,1);
whos D
imshow(D)


% imshow(D);
