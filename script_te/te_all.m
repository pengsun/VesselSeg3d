%% config
dir_out_s = fullfile(pwd, 'slice32c15'); 

fn_mo = fullfile(rootdir(), 'mo_zoo', 'slice32c15', 'ep_6000.mat');
dir_nameroot = 'D:\data\defactoSeg2';
h_get_x  = @get_x_slice32c15;
h_get_y  = @get_y_cen1;
%% testing data
st = load( fullfile(dir_nameroot,'info.mat') );
fns = st.imgNames( st.imgSetId == 3 ); % 3 for testing data
ffns = cellfun(@(f)(fullfile(dir_nameroot, f)), fns,...
  'UniformOutput',false);
for i = 1 : numel(ffns)
  dir_name = ffns{i};
  te_oneImg(fn_mo, dir_name, h_get_x, h_get_y, dir_out_s);
end
