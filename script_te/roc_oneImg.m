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
elseif (nargin == 2)
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