function varargout = roc_oneImg(dir_name, fn_pre)
% get roc from the prediction score (a mha)
% roc_oneImg()
% [ss,gt] = roc_oneImg(dir_name, fn_pre)
%

if (nargin == 0)
  name     = '01-001-MAP';
  dir_name = fullfile('D:\data\defactoSeg2\', name);
  fn_fg    = fullfile(dir_name, 'maskv3.mha');   % the fore-ground
  fn_bg    = fullfile(dir_name, 'maskb.mha');    % the back-ground
  fn_pre   = [name,'_pre_s.mha'];                % prediction score
  
%   dir_pre  = './';
%   name_mo  = 'net3d31_nh16';
%   cnt_mo   = 'ep_2281';
  
%   dir_pre  = './';
%   name_mo  = 'net3d4_nh16';
%   cnt_mo   = 'ep_2281';
  
  dir_pre  = './';
  name_mo  = 'net3d51_nh16';
  cnt_mo   = 'ep_559';
  
  fn_pre = fullfile(dir_pre, name_mo, cnt_mo, fn_pre);
elseif (nargin == 2) % TODO: fixing
  fn_fg    = fullfile(dir_name, 'maskv3.mha');   % the fore-ground
  fn_bg    = fullfile(dir_name, 'maskb.mha');    % the back-ground
else
  error('wrong arguments.');
end

% 
pre_s = mha_read_volume(fn_pre);
fg    = mha_read_volume(fn_fg);
bg    = mha_read_volume(fn_bg);

%
[ss, gt] = get_ss_and_gt(pre_s, fg,bg);
[fpr, tpr] = perfcurve(gt, ss, 1);

if (nargin==2)
  varargout{1} = ss;
  varargout{2} = gt;
  return; 
end

%
figure;
plot(fpr, tpr);
set(gca, 'xlim',[0,0.07], 'ylim',[0.6,1])
grid on;
title([name_mo, '-', cnt_mo], 'Interpreter','none');

function [ss, gt] = get_ss_and_gt(pre_s, fg,bg)
% ss: [M]. prediction scores
% gt: [M]. 0/1 ground truth

ifg = find(fg==255);
ibg = find(bg==255);
ii  = [ifg(:); ibg(:)];
ss  = pre_s(ii);
ss  = ss(:);

gt = zeros( size(ss), 'like',ss);
gt( 1 : numel(ifg) ) = 1;