//自适应实验
dataset_self = cell(1, 8);
for i = 1:8
    model = models_bst{i};
    train_range = model.train_range;
    train_size = length(train_range);
    test_range = model.test_range;
    dataset.train_range{1} = train_range;
    train_end = train_range(end)+1;
    dataset.test_range{1} = test_range;
    for j = 2:10
        test_range = train_end+(j-1)*900+randperm(900);
        train_range = (train_end+(j-1)*900-train_size+1) : (train_end+(j-1)*900);
        dataset.test_range{j} = sort(test_range(1:300));
        dataset.train_range{j} = train_range;
    end
    dataset_self{i} = dataset;
end
save dataset_self dataset_self;