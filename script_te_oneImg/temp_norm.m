%%
fn_in = '.\net3d7_nh16\ep_4964\01-001-MAP_pre_s.mha';
fn_out = '.\net3d7_nh16\ep_4964\01-001-MAP_pre_norms.mha';
%%
I = mha_read_volume(fn_in);
m = min(I(:));
M = max(I(:));
II = (I - m)./(M-m);
%%
mhawrite(fn_out, II);