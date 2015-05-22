%% config
dir_matconvnet = 'D:\CodeWork\git\matconvnet';
dir_matconvdag = 'D:\CodeWork\git\MatConvDAG';
dir_mexconv3d = 'D:\CodeWork\git\MexConv3D';
%% matconvnet
run( fullfile(dir_matconvnet, 'matlab\vl_setupnn') );
%% mex_conv3d
run( fullfile(dir_mexconv3d, 'setup_path') );
%% matconvDAG
tmp = fileparts( mfilename('fullpath') );
cd( fullfile(dir_matconvdag, 'core') );
eval( 'dag_path.setup' );
cd(tmp);
%% this
% root
dir_this = fileparts( mfilename('fullpath') );
addpath( pwd );
% util
addpath( fullfile(pwd, 'util') );
% % cache
% addpath( fullfile(pwd, 'cache') );
% mex
addpath( fullfile(pwd, 'mex') );