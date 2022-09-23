function [nc] = usc(D2,mode,iteration,m,text5)
%unsupervised classification 非监督分类
set(text5,'string','正在执行初始化,请稍等');
pause(1);
t0=cputime;
%K-means 使每一聚类中，多模式点到该类别中心的距离平方和最小。
%m 为类别数量
%iteration为最大迭代次数
D2=double(D2);
[r,c,bands]=size(D2);
set(text5,'string','准备迭代');
pause(1);
if mode==1
    seed1 = zeros(m,bands);%迭代前
    seed2 = zeros(m,bands);%迭代后
    % 每个波段产生m个随机种子点作为遥感图像各地物类别的种子像元
    % 每个波段随机出不重复的m个行列号组合
    index_record = zeros(1,m);
    for i = 1:m 
        index_i = round(rand()*r*c);
        judge = find(index_record == index_i);
        %如果已经有这个值了，那么重新循环取值
        if isempty(judge) == 0
            i = i-1;
            continue;
        end
        index_record(i) = index_i;
        %计算取到的随机值对应图像的行列号
        r_index = floor(index_i/c);%行号（负无穷取整）
        c_index = index_i - r_index*c;%列号
        %将该种子像元的bands个波段值存入
        seed1(i,:) = D2(r_index,c_index,:);
    end
    % 进行迭代，如果本次分别所有类新得到的像元数目变化在change_threshold内，则认为分类完毕。
    new_class_label = zeros(r,c);%距离索引矩阵
    n=1; %计数器（计算迭代次数）
    while 1
        if n==iteration+1
            q=n-1;
        else
            q=n;
        end
        str=strcat('正在执行第',num2str(q),'次迭代');
        set(text5,'string',str);
        pause(0.5);
        distance_matrix = zeros(r,c,m);
        %欧式距离计算 ||X-Mi||^2
        for kind = 1:m
            sum = 0;
            for i=1:bands
               temp = power(abs(D2(:,:,i)-seed1(kind,i)),2);%平方  灰度值的计算 相似计算
               sum = sum+temp;
            end
            %每个像元与初始m个类别中心的欧式距离
            ou_distance = sqrt(sum);
            distance_matrix(:,:,kind) = ou_distance;
        end
        %给给各类别赋值类别标注
        for i=1:r
            for j=1:c
                currentpixel_vector = distance_matrix(i,j,:);
                currentpixel_class = find(currentpixel_vector == min(currentpixel_vector));
                new_class_label(i,j) = currentpixel_class(1);%找到当前像元与m类中心距离最小的一类 范围是1-m的整数，当存在重复时取第一个
            end
        end
        %计算新的各类别中心
        for i=1:m
            id = find(new_class_label==i); %按类匹配相同类的元素，得出其在矩阵中坐标
            for j=1:bands
                temp1 = D2(:,:,j);
                temp2 = temp1(id); %通过坐标得出其具体参数
                seed2(i,j)= mean(temp2(:)); %找到新的中心点的灰度参数
            end
        end    
        new_class_pixcel_number = zeros(1,m);
        for i=1:m
            new_class_pixcel_number(i) = length(find(new_class_label(:)==i));
        end
        % 这里下一个版本引入ENVI图像参数！！
        change_threshold=0.05; %ENVI default 
        if n == 1
            old_class_pixcel_number = ones(1,m);
        end
        try
        if max(abs((new_class_pixcel_number-old_class_pixcel_number)./old_class_pixcel_number)) < change_threshold || n>iteration
            break;
        end %结束迭代条件：change_threshold变化阈值，ENVI中默认为0.05，计算得到的变化阈值小于ENVI标准或者超过迭代次数
        catch
            msgbox('请输入一个最大迭代次数');
            break;
        end
        n=n+1;
        if max(abs((new_class_pixcel_number-old_class_pixcel_number)./old_class_pixcel_number)) >change_threshold
            %old_class_label = new_class_label;
            old_class_pixcel_number = new_class_pixcel_number;
            seed1 = seed2; %将得到的中心点参数seed2赋给seed1重新开始迭代
            continue;
        end 
    end
    nc=new_class_label;
    t1 = cputime;
    set(text5,'string','正在成图，请等待');
    pause(0.5);
    during = t1 - t0;
    disp('耗时：');
    disp(during);
    set(text5,'string','就绪！');
else
    %matlab自带的kmeans使用方法:
    %matlab K-means算法要求输入矩阵是一个列向量组成的矩阵，列数为波段数，每一列为pixels的像元值
    pixels = r*c;
    % reshape成pixels*channel
    mul = reshape(D2, [pixels,bands]);
    set(text5,'string','正在迭代，过程可能要花费几十秒，请耐心等待');
    pause(1);
    class_result = kmeans(mul,m,'Replicates',iteration);%分m类
    set(text5,'string','正在成图，请等待');
    pause(0.5);
    out_data = reshape(class_result,r,c);
    nc=out_data;
    t1 = cputime;
    during = t1 - t0;
    disp('耗时：');
    disp(during);
    set(text5,'string','就绪！');
end






