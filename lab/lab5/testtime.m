% testtime\

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

model = importdata('model_reem.mat');
data = importdata('data_norm.mat');
test_range_fir = model.test_range(1);
test_range_size = [300 500 1000 3000 5000 10000];
times = zeros(1, length(test_range_size));
results = zeros(1, length(test_range_size));
idx = 1;
for n = test_range_size
    test_range = (test_range_fir:(test_range_fir+n-1));
    test_set = data(test_range, :);
    test_x = test_set(:, 2:end);
    test_y = test_set(:, 1);
    [test_result, test_time] = test_model(model, hyp_model, model.train_set, test_x);
    rmse = sqrt(sum((test_result-test_y).^2/size(test_x, 1)));
    times(idx) = test_time;
    results(idx) = rmse;
    idx = idx+1;
    disp(num2str(idx));
end
save times times;
save results results;

