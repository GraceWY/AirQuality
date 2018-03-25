% 验证实验：方差越小，数据质量越高
clear;clc;
N = 500;
D = 7;
rand('seed', 7);
i = 1;
imean = 20;
iteration = 100;
for ivar = [1 10 30 50 70 90 100]
    trainset = normrnd(imean,ivar, N, D); 
    testset = normrnd(imean, ivar, 200, D);
    train_x = trainset(:, 2:end);
    train_y = trainset(:, 1);
    test_x = testset(:, 2:end);
    test_y = testset(:, 1);
    covfunc = {@covRQard};
    hyp.cov = log(rand(D+1, 1));

    likfunc = @likGauss;
    hyp.lik = log(0.1);
    meanfunc = [];

    hyp = minimize(hyp, @gp, iteration, @infExact, [], covfunc, likfunc, train_x, train_y);
    [test_esti, ~] = gp(hyp, @infExact, [], covfunc, likfunc, train_x, train_y, test_x);
    rmse(i) = sqrt(sum((test_esti-test_y).^2/size(test_x, 1)));
    i = i+1;
end
save rmse rmse;
