function save_5dfilter(F, dir_out, prefix)
%SAVE_5DFILTER Summary of this function goes here
%   F: [H,W,D, P,Q]

P = size(F, 4);
Q = size(F, 5);

for i = 1 : P
  for j = 1 : Q
    fn  = sprintf('_%d_%d.mha', i, j);
    ffn = fullfile(dir_out, [prefix, fn]);
    mhawrite(ffn, F(:,:,:, i,j), [1,1,1]);
  end
end

end