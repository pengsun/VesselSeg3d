sz = [15,15,15];
ind = floor( prod(sz)/2 );
ind = double(ind(:));
yy = rand(27, numel(ind), 'single');
%%
img = acc_y_g27s5(sz, ind, yy);