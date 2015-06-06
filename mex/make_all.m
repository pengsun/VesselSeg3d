% config
opt = {};
% opt{end+1} = '-g';
% opt{end+1} = '-DVB';
% opt{end+1} = '-v';
opt{end+1} = '-largeArrayDims';

str = computer('arch');
switch str(1:3)
  case 'win' 
    opt{end+1} = 'COMPFLAGS=/openmp $COMPFLAGS';
    opt{end+1} = 'LINKFLAGS=/openmp $LINKFLAGS';
  case 'gln'
    opt{end+1} = 'CXXFLAGS="\$CXXFLAGS -fopenmp -std=c++11"';
    opt{end+1} = 'LDFLAGS="\$LDFLAGS -fopenmp -std=c++11"';
  otherwise
    error('unsupported platform %s\n', str);
end
%% do it
mex(opt{:}, 'get_x_cubic12.cpp');
mex(opt{:}, 'get_x_cubic32.cpp');
mex(opt{:}, 'get_x_slice32c3.cpp');
mex(opt{:}, 'get_x_slice32c15.cpp');
mex(opt{:}, 'get_x_slice48c3.cpp');
mex(opt{:}, 'get_x_slice48c15.cpp');
mex(opt{:}, 'load_mhaAsync.cpp', 'mha_reader_mt.cpp');
