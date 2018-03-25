clear;clc;
models = importdata('models.mat');
rmses = zeros(8);

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
    for j = 1:8
        disp([num2str(i) ' ' num2str(j)]);
        if i == 8 && (j == 7 || j == 8)
            continue;
        end
        model = models{i, j};
        test_x = model.test_set(:, 2:end);
        test_y = model.test_set(:, 1);
        [test_result, test_time] = test_model(model, hyp_model, model.train_set, test_x);
        rmse = sqrt(sum((test_result-test_y).^2/size(test_x, 1)));
        rmses(i, j) = rmse;
    end
end
save rmses rmses;