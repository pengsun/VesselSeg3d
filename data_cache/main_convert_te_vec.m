%%
load('te_slice48c3.mat');
%%
old = Y;
Y = zeros([2, numel(old)], 'like',old);
Y(1, old==0) = 1; % class 1
Y(2, old==1) = 1; % class 2
%%
save('te_slice48c3_cen2.mat', 'X','Y','-v7.3');