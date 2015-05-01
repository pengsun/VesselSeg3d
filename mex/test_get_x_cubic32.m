function test_get_x_cubic32
%% read mha
fn_mha = 'D:\data\defactoSeg2\02-010-PMF\t.mha';
z = mha_read_volume(fn_mha);
%% the index
% M = 256*16;
M = 20000;
% M = ceil( 32*32*32/(48*48*3) ) * 20000;
% M = ceil( 32*32*32*256/(48*48*3) );
N = numel(z);
ind = randsample(N, M);
%% time it
T = 3;

te = tic;
for t = 1 : T
  X = get_x_cubic32(z, ind(:));
end
te = toc(te);

fprintf('avg time = %4.3f\n', te/T);

%% time it: taking out mean
% T = 2;
% mu = zeros(48,48,3, 'single');
% vM = 1000;
% vm = 1000;
% 
% function rv = pro_x (a, b)
%   rv = a - b;
%   if (rv > 0), rv = rv/vM;
%   else         rv = rv/vm;
%   end
% end
% 
% te = tic;
% for t = 1 : T
%   XX = bsxfun(@pro_x, X, mu);
% end
% % for t = 1 : T
% %   XX = bsxfun(@minus, X, mu);
% %   ix = (XX>0);
% %   XX(ix) = XX(ix) ./ vM;
% %   XX(~ix) = XX(~ix) ./ vm;
% % end
% te = toc(te);
% 
% at = te/T;
% at = at*(32*32*32)/(48*48*3);
% fprintf('avg time = %4.3f\n', at);

  
end
