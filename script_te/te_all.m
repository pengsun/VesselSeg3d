%%
fn_mo = fullfile(rootdir(), 'mo_zoo', 'slice32c15', 'ep_5900.mat');
dir_nameroot = 'D:\data\defactoSeg2';
h_get_x  = @get_x_slice32c15;
h_get_y  = @get_y_cen1;

dir_out_s = fullfile(pwd, 'slice32c15'); 
%%
fns = dir( dir_nameroot );

for i = 1 : numel(fns)
  if (~fns(i).isdir), continue; end
  name = fns(i).name;
  if (strcmp(name,'.')), continue; end
  if (strcmp(name,'..')), continue; end
  
  dir_name = fullfile(dir_nameroot, name);
  te_oneImg(fn_mo, dir_name, h_get_x, h_get_y, dir_out_s);
  
end
