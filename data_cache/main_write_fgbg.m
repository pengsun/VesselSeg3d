%%
dir_data = 'D:\data\defactoSeg2';
%%
fns = dir( dir_data );

for i = 1 : numel(fns)
  if ( ~fns(i).isdir ), continue; end
  
  nm = fns(i).name;
  if (strcmp(nm, '.')), continue; end
  if (strcmp(nm, '..')), continue; end

  % do the job
  dir_mha = fullfile(dir_data, nm);
  fn_fg   = fullfile(dir_mha, 'maskv3.mha');
  fn_bg   = fullfile(dir_mha, 'maskb.mha');
  fn_out  = fullfile(dir_mha, 'maskfgbg.mha');
  
  fprintf('writing %s...', fn_out);
  try 
    write_fgbg(fn_fg, fn_bg, fn_out);
  catch
    fprintf('error occured, skip\n');
    continue;
  end
  
  fprintf('done\n');
end

