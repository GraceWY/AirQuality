% 特征选择实验
% 单核 RQard
% 

clear;clc;
load dataset;
ii = 2;
iteration = 50;
feature = [2:9]; 

covfunc = {@covRQard};
hyp.cov = log(rand(length(feature)+2, 1));

likfunc = @likGauss;
hyp.lik = log(0.1);

meanfunc = [];
rmse = 0;
for jj = 1:8
    trainset = dataset{ii, jj}.train(:, [1 feature]);
    testset = dataset{ii, jj}.test(:, [1 feature]);

    hyp = minimize(hyp, @gp, iteration, @infExact, [], covfunc, likfunc, trainset(:, 2:end), trainset(:, 1));
    [test_esti, ~] = gp(hyp, @infExact, [], covfunc, likfunc, trainset(:, 2:end), trainset(:, 1), testset(:, 2:end));
    rmse = rmse + sqrt(sum((test_esti-testset(:, 1)).^2)/size(testset, 1));
end
rmse = rmse/8;




