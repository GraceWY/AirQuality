% how to mask

clc;clear all; close all;

dataset = importdata('dataset.mat');

trainset = dataset{1, 2}.train;

testset = dataset{1, 2}.test;

x = trainset(:, 2:end);

xs = testset(:, 2:end);



D = 8;

Q = 2;% 在函数内部改的，参数传不进去 

w = ones(Q, 1)/Q; m = rand(D, Q); v = rand(D, Q);

csm = {@covSM, Q}; hypsm = log([w;m(:);v(:)]);



cgi = {'covSEiso'};

hypgi = log(ones(2, 1)*w(1));

mask1 = [0, 1, 1, 1, 1, 1, 1, 1];

cmgi = {'covMask', {mask1, cgi{:}}};



% cprod = {'covProd', {cgi, csm}}; hyp.cov = [hypgi; hypsm.cov];

% hyp.lik = log(0.1);



mask2 = [1, 0, 0, 0, 0, 0, 0, 0];                     

cmsm = {@covMask, {mask2, csm{:}}};



% cov = {'covProd', {cmgi, cmsm}}; hyp.cov = [hypgi;hypsm];

cov = csm; hyp.cov = hypsm;

hyp.lik = log(0.1);



hyp = minimize(hyp, @gp, -100, @infExact, [], cov, @likGauss, x, trainset(:, 1));

test_y = gp(hyp, @infExact, [], cov, @likGauss, x, trainset(:, 1), xs);

rmse = sqrt(sum((test_y-testset(:, 1)).^2/size(test_y, 1)))