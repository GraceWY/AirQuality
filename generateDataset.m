clear;clc;close all;

load data_norm;

rand('seed', 6);

dataset = cell(8);
i = 1;
for samples = [300 500 800 1000 3000 5000 10000 20000]
    j = 1;
    for idx = [1000 6000 9000 12000 15000 20000 40000 70000]
        train_range = idx : (idx+samples-1);
        test_range = idx+samples+randperm(900);
        test_range = sort(test_range(1:300));
        dataset{i, j}.train = data_norm(train_range, :);
        dataset{i, j}.test = data_norm(test_range, :);
        dataset{i, j}.train_range = train_range;
        dataset{i, j}.test_range = test_range;
        j = j+1;
    end
    i = i+1;
end
save dataset dataset;