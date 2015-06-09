function err =  te_oneImgAcc(varargin)
%te_oneImgAcc test on one image pixelwise, save the prediction scores as mha


dir_mo = 'D:\CodeWork\git\VesselSeg3d\mo_zoo';
name_mo = 'net3d4_nh16';
cnt_mo = 'ep_2281';
fn_mo = fullfile(dir_mo, name_mo, [cnt_mo,'.mat']);
% handles
hgetx = @get_x_cubic12;
hgety = @get_y_g27s5;
haccy = @acc_y_g27s5;

% 
batch_sz = 768;
% testing image (instances), ground truth(labels)
name     = '01-001-MAP';
dir_name = fullfile('D:\data\defactoSeg2\', name);
fn_mha   = fullfile(dir_name, 't.mha');          % the CT volume
fn_fgbg  = fullfile(dir_name, 'maskfgbg.mha');   % the fg bg mask

% output file name
dir_out_s = fullfile('.\', name_mo, cnt_mo);
if (~exist(dir_out_s,'dir')), mkdir(dir_out_s); end 
fn_out_s  = fullfile(dir_out_s, [name,'_pre_s.mha']);

% load data 
function te_bdg = load_te_data()
  mha     = mha_read_volume(fn_mha);
  mk_fgbg = mha_read_volume(fn_fgbg);
  te_bdg  = bdg_mhaSampLazy(mha, mk_fgbg, batch_sz, hgetx, hgety);
end
fprintf('loading volume %s...', fn_mha);
te_bdg = load_te_data();
fprintf('data\n');

% load model
fprintf('loading model %s...', fn_mo);
st = load(fn_mo);
ob = st.ob;
clear st;
fprintf('done\n');

% statistics
fprintf('# mask pixels = %d\n', numel(te_bdg.ix_fgbg) );
fprintf('# foreground mask pixels = %d\n', numel(te_bdg.ix_fg) );
fprintf('# background mask pixels = %d\n', numel(te_bdg.ix_bg) );
  
% do the job: testing it
Ypre = test(ob, te_bdg);
Ypre = gather(Ypre);

% restore prediction to vesselness scores and write
out_s = get_pre_score(Ypre, te_bdg, haccy);
mhawrite(fn_out_s, out_s);

end % te_oneImg

function out = get_pre_score(Ypre, te_bdg, haccy)
  szout = size(te_bdg.mk_fgbg);
  ind   = te_bdg.ix_fgbg(:);
  
  out = haccy(szout, ind, Ypre);
end