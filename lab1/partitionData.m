clear;clc;
close all;
data = importdata('data_norm.mat');
% 在数据集中随机取samples个数据
samples = 10000;
Kappa = 9; % 自底向上数Kappa层
idx = 1000;
train_range = idx:(idx+samples-1);
if samples <= 2^(Kappa-1)
    layer_std = 1;
else
    layer_std = ceil(log2(samples))-Kappa+1;
end

trainingSet = data(train_range, :);
% figure;
% plot(trainingSet(:, 3), trainingSet(:, 4), 'b.');
% hold on;
save trainingSet trainingSet;

tree = kd_buildtree(trainingSet, 0);
nodeset_cell = generateSubset(tree, 1, layer_std);
save nodeset_cell nodeset_cell;

% pm25
v_ori = var(trainingSet(:, 1));
v_nodes = zeros(size(nodeset_cell, 2), 1);
v_subnodes = zeros(size(nodeset_cell, 2)*2, 1);
for i = 1:size(nodeset_cell, 2)
    dat = trainingSet(nodeset_cell{i}.recordnum, :);
%     figure;
%     plot(dat(:, 2), dat(:, 1), 'b.');
%     close all;
    v_nodes(i) = var(dat(:, 1));
    imax = max(dat(:, 1));
    imin = min(dat(:, 1));
    imean = mean(dat(:, 1));
    v_subnodes((i-1)*2+1) = var(dat(dat(:, 1)>=imin & dat(:, 1)<imean, 1));
    v_subnodes((i-1)*2+2) = var(dat(dat(:, 1)>=imean & dat(:, 1)<=imax, 1));
end
% hold off;
figure;
set(gcf,'color','white','paperpositionmode','auto');
bar([v_ori; v_nodes]);
figure;
set(gcf,'color','white','paperpositionmode','auto');
bar([v_ori; v_subnodes]);
% title(['the scale is : ' num2str(no/v_ori)]);