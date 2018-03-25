% chou qu xun lian shi jian he ce shi shi jian
%clear;clc;
%models = importdata('models.mat');
test_time = zeros(8);
train_time = zeros(8);
for i = 1:8
    for j = 1:8
        if i == 8 && (j == 7 || j == 8)
            test_time(i, j) = 0;
            train_time(i, j) = 0;
        else
            test_time(i, j) = models{i, j}.test_time;
            train_time(i, j) = models{i, j}.train_time;
        end
    end
end
save testtime test_time;
save traintime train_time;
test_time_ = mean(test_time, 2);
test_time_(8) = mean(test_time(8, 1:6));
train_time_ = mean(train_time, 2);
train_time_(8) = mean(train_time(8, 1:6));
figure;
set(gcf,'color','white','paperpositionmode','auto');
bar(test_time_);
figure;
set(gcf,'color','white','paperpositionmode','auto'); 
bar(train_time_);