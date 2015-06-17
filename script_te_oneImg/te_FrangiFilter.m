%%
name = '01-001-MAP';
dir_data = 'D:\data\defactoSeg2\';
ffn = fullfile(dir_data, name, 't.mha');
I = mha_read_volume(ffn);
%% Frangi Filter 
options.BlackWhite       = false;
options.FrangiScaleRange = [1 1];
R = FrangiFilter3D(I,options);
%% apply the fgbg mask (ROI)
fn_mk = fullfile(dir_data, name, 'maskfgbg.mha');
mk = mha_read_volume(fn_mk);
RR = R;
RR(mk==0) = 0.0;
%% save
mhawrite([name,'_ff.mha'], RR./max(RR(:)));