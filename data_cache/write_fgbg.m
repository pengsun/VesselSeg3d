function write_fgbg( fn_fg, fn_bg, fn_out )

mk_fg = mha_read_volume(fn_fg);
mk_bg = mha_read_volume(fn_bg);

% construct the internal mask
mk_fgbg = mk_fg;
itmp = (mk_bg==255);
mk_fgbg(itmp) = 128;

% write to mha
mhawrite(fn_out, mk_fgbg, [1,1,1]);
end