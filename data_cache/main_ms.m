%% mean and std for slice32c15
%% config
% dir_data = '/home/ubuntu/A/data/defactoSeg2';
dir_data = 'D:\data\defactoSeg2';

ni_perMha = 2e4;
bs        = 1024;
TT        = 200 * 1;

% fnout = 'slice48c3_ms.mat';
% sz      = [48,48,3];
% h_get_x = @get_x_slice48c3;

% fnout = 'cubic12_ms.mat';
% sz      = [12,12,12];
% h_get_x = @get_x_cubic12;

fnout = 'cubic24_ms.mat';
sz      = [24,24,24];
h_get_x = @get_x_cubic24;

%%
st = load( fullfile(dir_data, 'info.mat') );
names = st.imgNames(st.imgSetId==1); % 1 indicates training data
names = cellfun( @(nm)(fullfile(dir_data, nm)), ...
  names, 'UniformOutput', false); 

h = bdg_mhaDefacto2(names, ni_perMha, bs, ...
  h_get_x, @get_y_cen1, @bdg_mhaSampBal);

rng(624, 'twister');
%%

v_mean = zeros(sz, 'single' );
v_std  = zeros(sz, 'single' );
cnt = 0;

for t = 1 : TT
  
  h = reset_epoch(h);
  Nbat = get_numbat(h);
  
  for i = 1 : Nbat
    fprintf('ep %d, bat %d...\n', t, i);
    data = get_bd(h, i);
    X = data{1};
    
    cur_mean = mean(X, 4);
    cur_std  = std(X, 0, 4); % 0 means (n-1) normalization
    
    v_mean = (cnt*v_mean + cur_mean)/(cnt+1);
    v_std  = (cnt*v_std  + cur_std)/(cnt+1);
  end
end
%% 
save(fnout, 'v_mean','v_std');
