% main For GP

clear;clc;close all;

load dataset;
load pm25_std;
load pm25_mean;
rand('seed', 13);
hyp_cell = cell(1);
% cov function
% covfunc = {@covRQard};
% hyp_cell.cov = log(rand(1, 8+2));

% lik function
likfunc = @likGauss;
hyp_cell.lik = log(0.1);
% mean function
meanfunc = [];

Kappa = 9;
iteration = 50;

X = 5;
Y = 8;
models_gp = cell(X, Y);
result_gp = zeros(X, Y);
for i = 1:X
    rmse_bst = inf;
    for j = 1:Y
        train_set = dataset{i, j}.train;
        test_set = dataset{i, j}.test;
        samples = size(train_set, 1);
        % train model
        t1 = clock;
        models_gp{i, j}.hyp = minimize(hyp_cell, @gp, -iteration, @infExact, [], covfunc, likfunc, train_set(:, 2:end), train_set(:, 1));
        t2 = clock;
        train_time = etime(t2, t1);
        models_gp{i, j}.train_set = train_set;
        models_gp{i, j}.test_set = test_set;
        models_gp{i, j}.train_time = train_time;
        test_x = test_set(:, 2:end);
        test_y = test_set(:, 1)*pm25_std+pm25_mean;
        [test_result, ~] = gp(hyp_cell, @infExact, [], covfunc, likfunc, train_set(:, 2:end), train_set(:, 1), test_x);
        test_result = test_result*pm25_std+pm25_mean;
        
        rmse = sqrt(sum((test_result-test_y).^2/size(test_x, 1)));
        result_gp(i, j) = rmse;
        if rmse < rmse_bst
            rmse_bst = rmse;
        end
    end
    disp(['rmse_bst = ' num2str(rmse_bst)]);
end
save result_gp result_gp;
save models_gp models_gp;