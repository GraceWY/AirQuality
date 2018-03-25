clear;clc;
load modelsRQ;
load data_norm;
dat = data_norm(1:70000, :);
for i = 4:5
    vec = models{i}.train_set(1, :);
    mat = repmat(vec, 70000, 1);
    re = sum(abs(dat-mat), 2);
    idx = find(re == 0);
    idx = idx(1);
    n_next = size(models{i}.train_set, 1);
    train_range = idx+ceil(n_next/2) : idx+ceil(n_next*3/2)-1;
    test_range = idx+ceil(n_next*3/2)+randperm(600);
    test_range = sort(test_range(1:300));
    nextdata{i-3}.train_halfnext = data_norm(train_range, :);
    nextdata{i-3}.test_halfnext = data_norm(test_range, :);
    train_range = idx+n_next : idx+2*n_next-1;
    test_range = idx+2*n_next+randperm(600);
    test_range = sort(test_range(1:300));
    nextdata{i-3}.train_next = data_norm(train_range, :);
    nextdata{i-3}.test_next = data_norm(test_range, :);
end
save nextdata nextdata;