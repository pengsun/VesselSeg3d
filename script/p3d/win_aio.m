function win_aio ()
%% use asynchronous mha loader
%% init dag: from scratch
beg_epoch = 1; 
dir_data  = 'D:\data\defactoSeg2';
dir_root  = rootdir();
dir_mo    = fullfile(dir_root,'mo_zoo','tmp_p3d_aio');

h = create_dag_from_scratch ();
h = set_dataNormLayer (h, dir_root);
%% config
h.beg_epoch = beg_epoch;
h.num_epoch = 1000;
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

function h = create_dag_from_scratch ()
h = dag_mb();
h.the_dag = tfw_p3d();
h = init_params(h);
h = init_opt(h);

function h = init_params(h)
KK = 32; % cubic size
NH = 16; % #hidden units
no = 1;  % output size
f = 0.01;
% parameter layer I, conv
h.the_dag.p(1).a = f*randn(3,3,KK,NH, 'single') ; % kernel
h.the_dag.p(2).a = zeros(1, NH, 'single');        % bias
% parameter layer II, conv
h.the_dag.p(3).a = f*randn(2,2,NH,NH, 'single'); 
h.the_dag.p(4).a = zeros(1,NH,'single');        
% parameter layer III, conv
h.the_dag.p(5).a = f*randn(2,2,NH,NH, 'single'); 
h.the_dag.p(6).a = zeros(1,NH,'single');        
% parameter layer IV, output
h.the_dag.p(7).a = f*randn(3,3,NH,no, 'single'); 
h.the_dag.p(8).a = zeros(1,no,'single'); 

function h = init_opt(h)
num_params = numel(h.the_dag.p);
h.opt_arr = opt_1storder();
h.opt_arr(num_params) = opt_1storder();

nr = floor(num_params/2);
assert( nr == ceil(num_params/2) );
% rr = [0.01, 0.005, 0.001, 0.001];
rr = 0.001 * ones(1, nr);
for i = 1 : numel(rr)
  h.opt_arr( 2*(i-1) + 1 ).eta = rr(i);
  h.opt_arr( 2*(i-1) + 2 ).eta = rr(i);
end

function h = set_dataNormLayer(h, dir_root)
st = load( fullfile(dir_root, 'data_cache', 'cubic32_ms.mat') );
h.the_dag.tfs{1}.v_mean = st.v_mean;
h.the_dag.tfs{1}.v_std  = st.v_std;


function tr_bdg = load_tr_data(dir_data, ni_perMha, bs)
% load the info file and make the names list
st = load( fullfile(dir_data, 'info_small.mat') );
names = st.imgNames(st.imgSetId==1); % 1 indicates training data
names = cellfun( @(nm)(fullfile(dir_data, nm)), ...
  names, 'UniformOutput', false); 

tr_bdg = bdg_mhaDefacto2Async(...
  names, ni_perMha, bs, ...
  @get_x_cubic32, @get_y_cen1, @bdg_mhaSampBal);
