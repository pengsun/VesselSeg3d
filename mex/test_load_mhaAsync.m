%%
fn1 = 'D:\data\defactoSeg2\01-005-FSM\t.mha';
fn2 = 'D:\data\defactoSeg2\01-005-FSM\maskfgbg.mha';

fn3 = 'D:\data\defactoSeg2\02-001-C-O\t.mha';
fn4 = 'D:\data\defactoSeg2\02-001-C-O\maskfgbg.mha';
%%
% fn1 = 'zz.mha';
% fn2 = 'zz.mha';
%%
load_mhaAsync(fn1,fn2, fn3);
%%
[x, y] = load_mhaAsync();
size(x)
size(y)

%%

%%
load_mhaAsync(fn3,fn4, fn2);
%%
[x, y, z] = load_mhaAsync();
size(x)
size(y)
size(z)