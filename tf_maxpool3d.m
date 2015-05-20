classdef tf_maxpool3d < tf_i
  %TF_MAXPOOL3d Max Pooling 3D
  %   Detailed explanation goes here
  
  properties
    pool;
    pad;
    stride;
    
    ind; % max index 
  end
  
  methods
    function ob = tf_maxpool3d ()
      ob.pool = [2,2,2];
      ob.pad = [0,0, 0,0, 0,0];
      ob.stride = [2,2,2];
      ob.ind = -1;
      
      ob.i = n_data();
      ob.o = n_data();
    end % tf_maxpool3d
    
    function ob = fprop(ob)
      [ob.o.a, ob.ind] = mex_maxpool3d(ob.i.a,...
        'pool',ob.pool, 'pad',ob.pad, 'stride',ob.stride);
    end % fprop
    
    function ob = bprop(ob)
      ob.i.d = mex_maxpool3d(ob.o.d, ob.ind,...
        'pool', ob.pool, 'pad',ob.pad, 'stride',ob.stride);
    end % bprop
    
  end % methods
  
end

