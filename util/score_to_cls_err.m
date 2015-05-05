function [err, err_one, err_two] = score_to_cls_err(Ypre, Y)
% score to binary classification error
% Ypre: [1, N]
% Y: [1,N]

% the error
th = 0.5;
label_pre = (Ypre >= th);
label     = (Y >= th);
N = numel(label);
err = sum( label_pre ~= label ) / N;

% the class 1 error
one_pre = ( Ypre < th );
one_gt  = ( Y < th );
a_one = sum( one_gt & one_pre ) ./ (sum(one_gt)+eps);
err_one = 1 - a_one;

% the class 2 error
two_pre = (Ypre >= th );
two_gt  = (Y >= th );
a_two = sum( two_gt & two_pre ) ./ (sum(two_gt)+eps);
err_two = 1 - a_two; 