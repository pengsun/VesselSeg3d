%get_y_g27s5 Get 27 dim labels. Each elem: 0/1 bg/fg response. Stride 5.
%   yy = get_y_g27s5(mk, ind)
%   mk: [a,b,c]. uint8. 255: vessels, 128: background, 0: not interested
%   ind: [M]. double. linear index to the mk
%   yy: [27, M]. single. each elem, 0/1 bg/fg response
