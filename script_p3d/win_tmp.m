function win_tmp ()
%% init dag: from scratch
beg_epoch = 1; 
dir_root  = 'D:\data\defactoSeg2';
dir_mo    = fullfile(dir_root,'mo_zoo','tmp_p3d');

h = create_dag_from_scratch ();
%% config
h.beg_epoch = beg_epoch;
h.num_epoch = 10;
batch_sz    = 256;
dir_data    = fullfile(dir_root, 'data', '20M');

%% CPU or GPU
% h.the_dag = to_cpu( h.the_dag );
h.the_dag = to_gpu( h.the_dag );
%% peek and do something (printing, plotting, saving, etc)
hpeek = peek();
% plot training loss
% addlistener(h, 'end_ep', @hpeek.plot_loss);
% save model
hpeek.dir_mo = dir_mo;
addlistener(h, 'end_ep', @hpeek.save_mo);
%% initialize the batch data generator
tr_bdg = load_tr_data(dir_data, batch_sz);
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
NH = 16; % # hidden units
f = 0.1;
% parameter layer I, conv
h.the_dag.p(1).a = f*randn(3,3,3,NH, 'single') ; % kernel
h.the_dag.p(2).a = zeros(1, NH, 'single');       % bias
% parameter layer II, conv
h.the_dag.p(3).a = f*randn(2,2,NH,NH, 'single'); 
h.the_dag.p(4).a = zeros(1,NH,'single');        
% parameter layer III, conv
h.the_dag.p(5).a = f*randn(2,2,NH,NH, 'single'); 
h.the_dag.p(6).a = zeros(1,NH,'single');        
% parameter layer IV, conv 1x1
h.the_dag.p(7).a = f*randn(1,1,NH,NH, 'single'); 
h.the_dag.p(8).a = zeros(1,NH,'single');     
% parameter layer V, output
h.the_dag.p(9).a  = f*randn(5,5,NH,2, 'single'); 
h.the_dag.p(10).a = zeros(1,2,'single');   

function h = init_opt(h)
num_params = numel(h.the_dag.p);
h.opt_arr = opt_1storder();
h.opt_arr(num_params) = opt_1storder();

% rr = [0.01, 0.005, 0.001, 0.001];
rr = 0.001 * ones(1, 5);
for i = 1 : numel(rr)
  h.opt_arr( 2*(i-1) + 1 ).eta = rr(i);
  h.opt_arr( 2*(i-1) + 2 ).eta = rr(i);
end

function tr_bdg = load_tr_data(dir_data, bs)
nm = '01-001-MAP';
mha = mha_read_volume(...
  fullfile(dir_data, nm, 't.mha') );
mk_fgbg = mha_read_volume(...
  fullfile(dir_data, nm, 'maskfgbg.mha') );

tr_bdg = bdg_matInDir(mha, mk_fgbg, bs,  @get_x_cubic32, @get_y_cen1 );