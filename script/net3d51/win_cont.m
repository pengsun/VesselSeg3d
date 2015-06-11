function win_cont ()
%% use asynchronous mha loader
%% init dag: from scratch
beg_epoch = 36; 
dir_data  = 'D:\data\defactoSeg2';
dir_root  = rootdir();
dir_mo      = fullfile(dir_root,'mo_zoo','net3d51_nh16');
dir_mo_from = fullfile(dir_root,'mo_zoo','net3d51_nh16');

fn_mo = sprintf('ep_%d.mat', beg_epoch-1);
h = create_dag_from_file ( fullfile(dir_mo_from, fn_mo) );
%% config
h.beg_epoch = beg_epoch;
h.num_epoch = 200 * 30;
batch_sz    = 256;
ni_perMha   = 2e4;

%% CPU or GPU
% h.the_dag = to_cpu( h.the_dag );
h.the_dag = to_gpu( h.the_dag );
%% peek and do something (printing, plotting, saving, etc)
hpeek = peek();

% plot training loss
addlistener(h, 'end_ep', @hpeek.plot_loss);

% save model
hpeek.dir_mo = dir_mo;
addlistener(h, 'end_ep', @hpeek.save_mo);
%% initialize the batch data generator
tr_bdg = load_tr_data(dir_data, ni_perMha, batch_sz);
%% do the training
diary( [mfilename, '.txt'] );
diary on;

train(h, tr_bdg);

diary off;

function ob = create_dag_from_file (fn_mo)
load(fn_mo, 'ob');
% ob loaded and returned

function tr_bdg = load_tr_data(dir_data, ni_perMha, bs)
% load the info file and make the names list
st = load( fullfile(dir_data, 'info.mat') );
names = st.imgNames(st.imgSetId==1); % 1 indicates training data
names = cellfun( @(nm)(fullfile(dir_data, nm)), ...
  names, 'UniformOutput', false); 

tr_bdg = bdg_mhaDefacto2(...
  names, ni_perMha, bs, ...
  @get_x_cubic12, @get_y_cen1, @bdg_mhaSampBal);
