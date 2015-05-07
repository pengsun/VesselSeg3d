function [err, err_one, err_two] = get_bin_cls_err(Ypre, Y)
% prediction to binary classification error
% Ypre: [K, N], K can be 1 or 2
% Y: [K,N]

assert( all(size(Ypre)==size(Y)) );

K = size(Ypre,1);
if (K==1)
  [err, err_one, err_two] = score_to_cls_err(Ypre, Y);
elseif (K==2)
  [err, err_one, err_two] = vec_to_cls_err(Ypre, Y);
else
  error('Binary classification only, K = 1 or 2.');
end

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


function [err, err_one, err_two] = vec_to_cls_err(Ypre, Y)
% vector-valued prediction to binary classification error
% Ypre: [K, N]
% Y: [K,N]

% the error
[~, label_pre] = max(Ypre,[], 1);
[~, label]     = max(Y,[],    1);
N = numel(label);
err = sum( label_pre ~= label ) / N;

% the class 1 error
one_pre = ( Ypre(1,:) > Ypre(2,:) );
one_gt  = ( Y(1,:) > Y(2,:) );
a_one = sum( one_gt & one_pre ) ./ (sum(one_gt)+eps);
err_one = 1 - a_one;

% the class 2 error
two_pre = (Ypre(2,:) > Ypre(1,:));
two_gt  = (Y(2,:) > Y(1,:));
a_two = sum( two_gt & two_pre ) ./ (sum(two_gt)+eps);
err_two = 1 - a_two; 