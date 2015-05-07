function yy = get_y_cen2(mk, ind)
%GET_Y_CEN2 Get labels Y at the cubic center as a vector (2 dims)
%   yy = get_y_cen2(mk, ind)
%   mk: [a,b,c]. 255: vessels, <255: background
%   ind: [M] linear index to the mk
%   yy: [2, M] each column is a 1-hot response. [1;0] for bg, [0;1] for fg
%

% values from the mask
v = mk(ind);
M = numel(ind);

% scalr to vector response
yy = zeros(2, M, 'single');
yy(1,v==128) = 1; % back ground
yy(2,v==255) = 1; % fore ground
 