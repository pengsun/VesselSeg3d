function [err_ep, err] =  te_eps(varargin)

% config 
dir_root = fileparts( fileparts( mfilename('fullpath') ) );
if ( nargin==0 )
%   ep = 1 : 200 : 10000;
%   batch_sz = 512;
%   dir_mo = fullfile(dir_root, 'mo_zoo', 'slice48c3_cen2');
  ep = 173;
  batch_sz = 384;
  dir_mo = fullfile(dir_root, 'mo_zoo', 'win_net3d2_nh16');
  
  %fn_data = fullfile('C:\Temp\slices2.mat');
  %fn_data = fullfile(dir_root, 'data_cache','te_slice48c3_cen2.mat');
  fn_data = fullfile(dir_root, 'data_cache','te_cubic32.mat');
  fn_mo_tmpl = 'ep_%d.mat';
elseif ( nargin==5 )
  ep = varargin{1};
  batch_sz = varargin{2};
  dir_mo = varargin{3};
  fn_data = varargin{4};
  fn_mo_tmpl = varargin{5};  
else
  error('Invalid arguments.');
end
   
% load data
fprintf('loading %s...', fn_data);
te_bdg = load_te_data_all(fn_data, batch_sz);
fprintf('done\n');

% plot
err_ep = 0;
[err, err_bg, err_fg] = deal(1);
figure;
hax = axes;
% plot_err(hax, err_ep, err, 'ro-');
% plot_err(hax, err_ep, err_fg, 'bx-');

for i = 1 : numel(ep)
  % init dag: from file 
  fn_mo = sprintf(fn_mo_tmpl, ep(i));
  ffn_mo = fullfile(dir_mo, fn_mo);
  if ( ~exist(ffn_mo,'file') )
    fprintf('%s not found, break and stop.\n', ffn_mo);
    break; 
  end
  load(ffn_mo, 'ob');
  % get ob from here
 
  Ypre = test(ob, te_bdg);
  Ypre = gather(Ypre);
  
  % show the error
  [err(1+i), err_bg(1+i), err_fg(1+i)] = get_bin_cls_err(Ypre, te_bdg.Y);
  %
  err_ep = [err_ep, ep(i)];
  plot_err(hax, err_ep(2:end), err(2:end), 'ro-');
  hold on;
  plot_err(hax, err_ep(2:end), err_bg(2:end), 'm*-');
  plot_err(hax, err_ep(2:end), err_fg(2:end), 'bx-');
  hold off;
  
  % print the error
  fprintf('model: %s\n', fn_mo);
  fprintf('classification error = %d\n', err(end) );
  fprintf('background misclassification rate = %d\n', err_bg(end) );
  fprintf('foreground misclassification rate = %d\n', err_fg(end) );
end
legend( {'err', 'fg err', 'bg err'}, 'Interpreter','none' );
title(fn_data, 'Interpreter','none');


% function te_bdg = load_te_data(fn_data, bs)
% load(fn_data, 'X','Y','setId');
% ind_te = find( setId == 3 );
% 
% xx = X(:,:,:, ind_te);
% yy = Y(:, ind_te);
% 
% te_bdg = bdg_memXd4Yd2(xx,yy, bs);


function te_bdg = load_te_data_all(fn_data, bs)
load(fn_data, 'X','Y');
te_bdg = bdg_memXd4Yd2(X,Y, bs);

function plot_err(hax, err_ep, err, sty)
plot(err_ep, err, sty, 'linewidth', 2, 'parent', hax);
xlabel('epoches');
ylabel('testing classification error');
% set(hax, 'yscale','log');
grid on;
drawnow;