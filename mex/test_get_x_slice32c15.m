%% read mha
fn_mha = 'D:\data\defactoSeg2\02-010-PMF\t.mha';
z = mha_read_volume(fn_mha);
%% the index
% M = 256*16;
M = 500;
% M = ceil( 32*32*32/(48*48*3) ) * 20000;
% M = ceil( 32*32*32*256/(48*48*3) );
N = numel(z);
ind = randsample(N, M);
%% time it
T = 3;

te = tic;
for t = 1 : T
  X = get_x_slice32c15(z, ind(:));
end
te = toc(te);

fprintf('avg time = %4.3f\n', te/T);