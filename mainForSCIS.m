clear;clc;close all;

dataset = importdata('dataset.mat');
load pm25_mean;
load pm25_std;

hyp_cell = cell(1);
% cov function
Q = 2;
D = 8;
% covfunc = {@covSM, Q};
% hyp_cell.cov = log(rand(1,(1+2*8)*Q));

% covfunc = {@covSDM_noise, Q};
% hyp_cell.cov = log(rand(13+3*Q, 1));

% covfunc = {@covSEiso};
% hyp_cell.cov = log(rand(1, 2));

% covfunc = {@covSCIS_noise, Q};
% hyp_cell.cov = log(rand(3+3*Q, 1)*10);
w = ones(Q, 1)*10/Q; m = rand(D, Q); v = rand(D, Q);
covfunc = {@covSM, Q};

% lik function
likfunc = @likGauss;
hyp_cell.lik = log(0.1);
% mean function
meanfunc = [];

Kappa = 9;
iteration = 100;

hyp_model = initial_model(Q, iteration, covfunc, hyp_cell, likfunc, meanfunc);
for i = 1:8
    for j = 1
        disp(['i = ' num2str(i) '    j = ' num2str(j)]);
        train_set = dataset{i, j}.train;
        train_range = dataset{i, j}.train_range;
        test_set = dataset{i, j}.test;
        test_range = dataset{i, j}.test_range;
        samples = size(train_set, 1);
        if samples <= 2^(Kappa-1)
            hyp_model.layer_std = 1;
        else
            hyp_model.layer_std = ceil(log2(samples))-Kappa+1;
        end
        rmse_bst = inf;
        for t = 1 % 随机10次取最好
            % train model
            w = ones(Q, 1)/Q; m = rand(D, Q);v = rand(D, Q);
            hyp_model.hyp_cell.cov = log([w;m(:);v(:)]);
            [model, train_time] = train_model(hyp_model, train_set);
            model.train_set = train_set;
            model.train_range = train_range;
            model.test_set = test_set;
            model.test_range = test_range;
            model.train_time = train_time;
            test_x = test_set(:, 2:end);
            test_y = test_set(:, 1);
            test_y_ori = test_set(:, 1)*pm25_std+pm25_mean;
            [test_result, test_time] = test_model(model, hyp_model, train_set, test_x);
            % revise answer
            model.test_result = test_result;
            model.test_time = test_time;
            test_result_ori = test_result*pm25_std+pm25_mean;

            rmse = sqrt(sum((test_result-test_y).^2/size(test_x, 1)));
            rmse_ori = sqrt(sum((test_result_ori-test_y_ori).^2/size(test_x, 1)));
            if rmse < rmse_bst
                rmse_bst = rmse;
                rmse_bst_ori = rmse_ori;
                model.cov_ori = log([w;m(:);v(:)]);
                model_bst = model;
            end
        end
        models{i, j} = model_bst;
        rmses(i, j) = rmse_bst;
        rmses_ori(i, j) = rmse_ori;
        save models models;
        save rmses rmses;
        save rmses_ori rmses_ori;
    end
end
save models models;
save rmses rmses;
save rmses_ori rmses_ori;