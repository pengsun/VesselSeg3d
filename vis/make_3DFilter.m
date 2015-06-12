function FF = make_3DFilter(F)
%MAKE_3DFILTER Summary of this function goes here
%   F: [H,W,D, P,Q]
%   FF: [HP, WQ, D]
  [H,W,D,P,Q] = size(F);
  FF = reshape(F, [H*P, W*Q, D]);
end

