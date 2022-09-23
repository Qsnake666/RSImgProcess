function [pclrordata] = pclror(pcdata,pccolor,mineNeighbor,rSearch,text5)
%PCL radius outlier removal
set(text5,'string','正在滤波...');
pause(0);
kdtree = KDTreeSearcher(pcdata);
for i=1:length(pcdata)
    try
        tmpdata=pcdata(i,:);
        [~,d] = knnsearch(kdtree,tmpdata,'k',mineNeighbor+1);
        check=find(d>rSearch);
        if ~isempty(check)
            pcdata(i,:)=[];
            i=i-1;
        end
    catch
        break
    end
end
pclrordata=pcdata;

