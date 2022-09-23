function [pclsordata,pclsorcolor] = pclsor(pcdata,pccolor,text5)
%pcl-StatisticalOutlierRemoval
%统计滤波器 去除离群的点
set(text5,'string','正在执行初始化,请稍等');
t0=cputime;
pause(1);
meanK=50; %临近点个数阀值 自定50
std_mul = 1.5; %自定
set(text5,'string','正在滤波...');
pause(1);
kdtree=KDTreeSearcher(pcdata);
size(pcdata)
for i = 1:length(pcdata)
    try %预防因删除值导致超出矩阵范围
        tmpdata=pcdata(i,:);
        [idx,dist]=knnsearch(kdtree,tmpdata,'k',meanK+1);
        dist(1)=[];
        md=mean(dist);
        sd=std(dist);
        for j=1:meanK
            if dist(j) > md+std_mul*sd
                 pcdata(idx(j),:)=[];
            end
        end
    catch
        break;
    end
%     per=i*100/count;
%     info=strcat('正在执行第',num2str(i),'个数','/当前共计',num2str(count),'个点','  总进度',num2str(per),'%');
%     set(text5,'string',info);
%     pause(0); %浪费过多时间，进度条
end
size(pcdata)
pclsorcolor=1;
pclsordata=pcdata;
pause(1);
t1 = cputime;
during = t1 - t0;
disp('耗时：');
disp(during);

