%% config
mo_dir = 'D:\CodeWork\git\VesselSeg3D\mo_zoo';
mo_nm  = 'net3d51_nh16';
mo_ep  = 'ep_807';

%% load model
mo_fn = fullfile(mo_dir,mo_nm, [mo_ep,'.mat']);
load(mo_fn);
ob.the_dag = to_cpu(ob.the_dag);
%% 
dir_out = fullfile('./', mo_nm, mo_ep);
if(~exist(dir_out,'dir')), mkdir(dir_out); end

prefix  = 'layer1';
save_5dfilter(ob.the_dag.p(1).a, dir_out, prefix);