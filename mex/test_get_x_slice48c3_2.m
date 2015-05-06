%% dim1, dim2
% image
sz   = 48;
img  = ones(sz,sz,sz);
% 
for i = 1 : sz
  img(:,:, i) = i*img(:,:,i);
end

img = int16(img);

% index
cen = [25,25,25];
ind = sub2ind( [sz,sz,sz], cen(1),cen(2),cen(3));

zz = get_x_slice48c3(img, [ind;ind;ind]);
xx = zz(:,:,:,2);
%% dim1, dim2
% % image
% sz   = 32;
% tmpl = ones(sz, sz);
% img  = zeros(sz,sz,sz);
% % 
% img(:,:, 2)  = tmpl;
% img(:,:, 9)  = tmpl;
% img(:,:, 16) = tmpl;
% img(:,:, 23) = tmpl;
% img(:,:, 30) = tmpl;
% 
% img = int16(img);
% 
% % index
% cen = [16,16,16];
% ind = sub2ind( [sz,sz,sz], cen(1),cen(2),cen(3));
% 
% xx = get_x_slice32c15(img, ind);
%% 
% % image
% sz = [34,34,34];
% img = reshape(1:prod(sz), sz);
% img = int16(img);
% % index
% cen = [17,17,17];
% ind = sub2ind(sz, cen(1),cen(2),cen(3));
% % read mha
% xx = get_x_slice32c15(img, ind);