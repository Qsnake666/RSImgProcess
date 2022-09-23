function [pclsordata,pclsorcolor] = pclsor2(pcdata,pccolor,text5)
set(text5,'string','正在执行初始化,请稍等');
t0=cputime;
pause(1);
%pcl-StatisticalOutlierRemoval
%统计滤波器 去除离群的点
meanK=50; %临近点个数阀值 自定50
std_mul = 1.5; %自定
[m,~]=size(pcdata);
set(text5,'string','正在滤波...');
pause(1);
count=m;
size(pcdata)
for i = 1:length(pcdata)
    try %预防因删除值导致超出矩阵范围
        x=pcdata(i,1);
        y=pcdata(i,2);
        z=pcdata(i,3);
        tempdist=sqrt((pcdata(:,1)-x).^2+(pcdata(:,2)-y).^2+(pcdata(:,3)-z).^2);
        tempdist2=sort(tempdist);
        dist=tempdist2(1:meanK,:);
        md=mean(dist);
        sd=std(dist);
        rcount=1;
        for j=1:meanK
            if dist(j) > md+std_mul*sd
                remove(rcount)=dist(j);
                rcount=rcount+1;
            end
        end
        for k=1:rcount
            try 
                index=find(tempdist==remove(k));
                remp=pcdata(index);
                if ~isempty(remp)
                    %rempc=remp
                    pcdata(index,:)=[];
                    pccolor(index,:)=[];
                end
            catch
                break;
            end
        end
%        count=count-rcount+1;
    catch
        break;
    end
%     per=i*100/count;
%     info=strcat('正在执行第',num2str(i),'个数','/当前共计',num2str(count),'个点','  总进度',num2str(per),'%');
%     set(text5,'string',info);
%     pause(0); %浪费过多时间，进度条
end
size(pcdata)
pclsordata=pcdata;
pclsorcolor=pccolor;
set(text5,'string','就绪');
pause(1);
t1 = cputime;
during = t1 - t0;
disp('耗时：');
disp(during);

