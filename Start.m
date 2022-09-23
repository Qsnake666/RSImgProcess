function varargout = Start(varargin)
% START MATLAB code for Start.fig
%      START, by itself, creates a new START or raises the existing
%      singleton*.
%
%      H = START returns the handle to a new START or the handle to
%      the existing singleton*.
%
%      START('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in START.M with the given input arguments.
%
%      START('Property','Value',...) creates a new START or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Start_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Start_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Start

% Last Modified by GUIDE v2.5 04-Jun-2021 14:40:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Start_OpeningFcn, ...
                   'gui_OutputFcn',  @Start_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);       
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Start is made visible.
function Start_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Start (see VARARGIN)

% Choose default command line output for Start
handles.output = hObject;
axis off image;%拒绝显示坐标轴 
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Start wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Start_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'*.hdr;*.tif;*.ply;*.txt;*.las','data Files(*.hdr;*.tif;*.ply;*.txt;*.las)'},'选择一幅图像，仅支持hdr和tif格式');
if(isempty(pathname))
    return;
end
set(handles.text5,'string','正在打开文件，请稍候');
pause(0.1);
filepath=strcat(pathname,filename);
%img = imread(filepath);
%[m,n,bands]=size(img)
%img = double(img); %将数据转换为double类型
%img = uint8(img); %将im扩充到[0 255]
%colormap(gray);
%imshow(img(:,:,1)); %显示波段1的图像
a=strfind(filepath,'.hdr');
b=strfind(filepath,'.ply');
c=strfind(filepath,'.txt');
d=strfind(filepath,'.las');
if ~isempty(a)
    fid = fopen(filepath, 'r');
    info = fread(fid,'char=>char');
    info=info'; %默认读入列向量，须要转置为行向量才适于显示
    fclose(fid);
    [D,D2,bands,s,format,interleave,machine,b,text3,text6]=envidataread(filepath,info);
    handles.format=format;
    handles.interleave=interleave;
    handles.machine=machine;
elseif ~isempty(b) || ~isempty(c)
    [data,ptcloud,color,type]=pcdataread(filepath);
elseif ~isempty(d)
    [data,ptcloud,color] = lasdataread(filepath);
else
    [ D,D2,b,s,bands,text3,text6 ] = tifdataread(filepath);
end
try
    %colormap(gray);
    %imshow(uint8(D));%转置并显示图像,但是成为有损显示
    D1=stretch(D,0,1);
    subplot(1,1,1);
    imshow(D1);
    title('遥感影像RGB图');
    set(handles.listbox1,'string',s);
    set(handles.text3,'string',text3);
    set(handles.text6,'string',text6);
    set(handles.text5,'string','就绪');
    pause(1);
    str=sprintf('%s%s','使用非监督分类模块时需要等待。使用算法1会减少五分之四的时间。计算时间在10s左右。其中算法2是系统算法。',+newline,'                    等待期间请勿执行其他操作。');
    set(handles.text5,'string',str);
    handles.D=D;
    handles.D2=D2;
    handles.bands=bands;
    handles.b=b;
    guidata(hObject,handles);
catch
    try
        pcshow(data,color);
    catch
        pcshow(pointCloud(data));
    end
    set(handles.text5,'string','就绪');
    handles.pcdata=data;
    handles.pccolor=color;
    handles.ptcloud=ptcloud;
    handles.filepath=filepath;
    guidata(hObject,handles);
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom out


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
D2=handles.D2;
bands=handles.bands;
D2=stretch(D2,0,1);%先统一范围
set(handles.text5,'string','正在处理');
pause(0.5);
modenum = get(handles.popupmenu1,"Value");
switch modenum
    case 1
        [PC,msg] = pc(D2);
        m=ceil(sqrt(bands));
        n=ceil(bands/m);
        mul=double(D2);
        [r ,c ,bands]=size(mul);
        for i=1:bands
            subplot(n,m,i);
            outPic = PC(:,i);
            min_value = min(outPic);
            max_value = max(outPic);
            outPic = reshape(outPic,[r,c]);
            str = sprintf('%s%d%s%s%d','第',i,'主成分','信息量',msg(i));
            imshow(outPic,[min_value,max_value]);%stretch矫正后的灰度范围
            title(str);
        end
        PC=reshape(PC,r,c,bands);
        guidata(hObject,handles);
    
    case 2
        PC = hatchange(D2);
        m=ceil(sqrt(bands));
        n=ceil(bands/m);
        mul=double(D2)/255;
        [r ,c ,bands]=size(mul);
        for i=1:bands
            subplot(n,m,i);
            outPic = PC(i,:);
            min_value = min(outPic);
            max_value = max(outPic);
            outPic = reshape(outPic,[r,c]);
            str = sprintf('%s%d%s','第',i,'波段');
            imshow(outPic,[min_value,max_value]);%stretch矫正后的灰度范围  
            title(str);
        end
        guidata(hObject,handles);
end
handles.PC=PC;%特征变换后的矩阵(r,c,bands)
set(handles.text5,'string','就绪');
guidata(hObject,handles);
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
D=handles.D;
b=handles.b;
set(handles.text5,'string','正在处理');
pause(0.5);
try
    D1=handles.D1;
catch
end
try
modep=handles.modep;
catch
    modep=2;
end
if modep~=1
    m=ceil(sqrt(3));
    n=ceil(3/m);
    D1=stretch(D,0,1);
    for i=1:3
        subplot(n,m,i);
        imhist(D1(:,:,i));
        t=strcat('波段',num2str(b(i)));
        title(t);
        ylabel('像素数');
    end
else
    subplot(1,1,1);
    imhist(D1);
end
set(handles.text5,'string','就绪');

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text5,'string','正在处理');
pause(0.5);
D2=handles.D2; %更新：应该使用PC特征变换值
D3=1;
[SI,pglcm,ASM,ENT,IDM] = gcm(D2,D3);
SI=stretch(SI,0,1);
subplot(1,1,1);
imshow(SI);
title('灰度共生归一化图 SI');
handles.SI=SI;
handles.pglcm=pglcm;
handles.ASM=ASM;
handles.ENT=ENT;
handles.IDM=IDM;
guidata(hObject,handles);
set(handles.text5,'string','就绪');
% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
set(handles.text5,'string','正在处理');
pause(0.5);
D=handles.D;
D1 = stretch(D,0,1);
popupmenu2value = hObject.Value;
subplot(1,1,1);
modep=1;
switch popupmenu2value
    case 1
        imshow(D1);
        title('遥感影像RGB图');
        modep=2;
    case 2
        set(handles.text5,'string','正在执行，请勿添加新命令');
        pause(0.5);
        [rmin,rmax] = ls(D1,1);
        imshow(imadjust(D1,[rmin,rmax],[0,1]));%小于rmin全赋值rmin灰度，[0,1]0-1输出。
        title('遥感影像RGB图 Line stretch1%');
        D1=imadjust(D1,[rmin,rmax],[0,1]);
        handles.D1=D1;
    case 3
        set(handles.text5,'string','正在执行，请勿添加新命令');
        pause(0.5);
        [rmin,rmax] = ls(D1,2);
        imshow(imadjust(D1,[rmin,rmax],[]));
        title('遥感影像RGB图 Line stretch2%');
        D1=imadjust(D1,[rmin,rmax],[0,1]);
        handles.D1=D1;
    case 4
        set(handles.text5,'string','正在执行，请勿添加新命令');
        pause(0.5);
        [rmin,rmax] = ls(D1,5);
        imshow(imadjust(D1,[rmin,rmax],[]));
        title('遥感影像RGB图 Line stretch5%'); 
        D1=imadjust(D1,[rmin,rmax],[0,1]);
        handles.D1=D1;
    case 5
        set(handles.text5,'string','正在执行，请勿添加新命令');
        pause(0.5);
        D1=histeq(D1);
        imshow(D1);
        title('遥感影像RGB图 直方图均衡'); 
        handles.D1=D1;
end
handles.modep=modep;
set(handles.text5,'string','就绪');
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
D2=handles.D2;
text5=handles.text5;
mode=get(handles.popupmenu3,'value');
iteration=str2double(get(handles.edit1,'string'));
m=get(handles.popupmenu4,'value');
[nc] = usc(D2,mode,iteration,m,text5);
subplot(1,1,1);
nc=stretch(nc,0,1);
imshow(nc);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PC=handles.PC;
[un] = sift(PC);
figure
imshow(un);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcdata=handles.pcdata;
pccolor=handles.pccolor;
text5=handles.text5;
rSearch=str2double(get(handles.edit3,'string'));
mineNeighbor=str2double(get(handles.edit4,'string'));
mode=get(handles.popupmenu5,'value');
switch mode
    case 1
        [pclsordata,pclsorcolor] = pclsor2(pcdata,pccolor,text5);
        subplot(1,1,1);
        if pclsorcolor==1
            set(text5,'string','就绪');
            pcshow(pclsordata);
        else
            set(text5,'string','就绪');
            pcshow(pclsordata,pclsorcolor);
        end
        handles.pclosrdata=pclsordata;
    case 2
        [pclsordata,pclsorcolor] = pclsor(pcdata,pccolor,text5);
        subplot(1,1,1);
        if pclsorcolor==1
            set(text5,'string','就绪');
            pcshow(pclsordata);
        else
            set(text5,'string','就绪');
            pcshow(pclsordata,pclsorcolor);
        end
        handles.pclosrdata=pclsordata;
    case 3
        [pclrordata] = pclror(pcdata,pccolor,mineNeighbor,rSearch,text5);
        set(text5,'string','就绪');
        pcshow(pclrordata);
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    pcdata=handles.pcsordata;
catch
    pcdata=handles.pcdata;
    pccolor=handles.pccolor;
end
text5=handles.text5;
[normE,n] = pcpca(pcdata,pccolor,text5);
pcshowpair(pointCloud(pcdata),pointCloud(normE));
handles.pclnormE=normE;
handles.pcln=n;
guidata(hObject,handles);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ps=handles.pcdata;
filepath=handles.filepath;
text5=handles.text5;
% [ a ] = icp(ps);
[ps,pqq,ptc] = pclicp(ps,text5);
set(text5,'string','就绪');
pause(0.1);
pcshowpair(pointCloud(ps),pointCloud(ptc));
% figure;
% pcshowpair(pointCloud(pqq),pointCloud(ptc));

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcdata=handles.pcdata;
n=handles.pcln;
text5=handles.text5;
[eigvalue] = pclpfh(pcdata,n,text5);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcdata=handles.pcdata;
text5=handles.text5;
[tri] = pcltin(pcdata,text5);
