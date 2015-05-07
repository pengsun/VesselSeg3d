%%
mo_name = 'slice32c15';
dir_nameroot = 'D:\data\DefactoSeg2';
dir_ss = fullfile(rootdir(), 'rst_zoo', mo_name);
%% iterate
[ss,gtgt] = deal([]);
fns = dir( dir_ss );
for i = 1 : numel(fns)
  if (fns(i).isdir), continue; end
  fprintf('processing %s...\n', fns(i).name);
  
  % get score and gt
  ix = find(fns(i).name == '_');
  name = fns(i).name(1 : ix(1)-1);
  dir_name = fullfile(dir_nameroot, name);
  [s,gt] = roc_oneImg(dir_name, fullfile(dir_ss, fns(i).name));
  
  % cat
  ss   = [ss(:); s];
  gtgt = [gtgt(:); gt];
end
%% plot
figure;
[fpr, tpr] = perfcurve(gtgt(:), ss(:), 1);
set(gca,'xlim',[0,0.07],'ylim',[0.6,1]);
grid on;
title(mo_name);