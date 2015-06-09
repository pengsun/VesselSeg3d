%acc_y_g27s5 Accumulate the 27 dim predictions. Stride 5.
%   img = acc_y_g27s5(sz_img, ind, y)
%   Input:
%   sz_img: [3]. double. size
%   ind: [M]. double. linear index to the img
%   y: [27, M]. single. each elem, a bg/fg response. The bigger, the more likely
%   fg.
%   Output:
%   img: single. the heat map, in place accumulation
