%% config
ni_perMha = 1e3; % #instances per mha
bs        = 512; % 
T         = 36;  % T epoches, T == #te

dir_data = 'D:\data\defactoSeg2';

% sz      = [32,32,15];
% fnout   = 'te_slice32c15.mat'; % te data file name
% h_get_x = @get_x_slice32c15;   % handle to how to get X 

sz      = [48,48,15];
fnout   = 'te_slice48c15.mat'; % te data file name
h_get_x = @get_x_slice48c15;   % handle to how to get X 

rng(42,'twister'); % ensure repeatability
%% init the batch data generator
st = load( fullfile(dir_data, 'info.mat') );
names = st.imgNames(st.imgSetId==3); % 1 indicates training data
names = cellfun( @(nm)(fullfile(dir_data, nm)), ...
  names, 'UniformOutput', false); 

te_bdg = bdg_mhaDefacto2(names, ni_perMha, bs, ...
  h_get_x, @get_y_cen1, @bdg_mhaSampBal);
%% collect data
X = zeros([sz(1),sz(2),sz(3),0], 'single');
Y = zeros([1, 0], 'single');

diary( [fnout,'.txt'] );
diary on;
for t = 1 : T
  te_bdg = reset_epoch(te_bdg);
  nbat = get_numbat(te_bdg);
  for i_bat = 1 : nbat
    
    data = get_bd_orig(te_bdg, i_bat);
    X = cat(4, X, data{1});
    Y = cat(2, Y, data{2});
    
    assert( size(X,4)==size(Y,2) );
    fprintf('t = %d, i_bat = %d, #instances = %d\n',...
      t, i_bat, size(Y,2) );
  end
end
diary off;
%% write
ffnout = fullfile(pwd, fnout);

fprintf('saving %s...', ffnout);
save(fnout, 'X','Y', '-v7.3');
fprintf('done\n');