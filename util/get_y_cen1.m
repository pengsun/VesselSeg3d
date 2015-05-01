function yy = get_y_cen1(mk, ind)
%GET_Y_CEN1 Get labels Y at the cubic center as a scalar (1 dim)
%   yy = get_y_cen1(mk, ind)
%   mk: [a,b,c]. 255: vessels, <255: background
%   ind: [M] linear index to the mk
%   yy: [1, M] each elem, 0/1 bg/fg response
%

  % values from the mask
  v = mk(ind);
  M = numel(ind);
  
  % scalr to vector response
  yy = zeros(1, M, 'single');
  yy(2, v==255) = 1; % fore ground
  %yy(1, v==128) = 0; % back ground