classdef tf_conv3d < tf_i
  %TF_CONV3D Convolution 3D 
  %   Detailed explanation goes here
  
  properties
    pad;
    stride;
  end
  
  methods
    function ob = tf_conv3d ()
      ob.pad = 0;
      ob.stride = 1;
      
      ob.i = n_data();
      ob.o = n_data();
      ob.p = [n_data(), n_data()];
    end % tf_conv3d
    
    function ob = fprop(ob)
      w = ob.p(1).a;
      b = ob.p(2).a;
      ob.o.a = mex_conv3d(ob.i.a, w,b, 'pad',ob.pad, 'stride',ob.stride);
    end % fprop
    
    function ob = bprop(ob)
      w = ob.p(1).a;
      b = ob.p(2).a;
      delta = ob.o.d;
      [ob.i.d, ob.p(1).d, ob.p(2).d] = mex_conv3d(...
        ob.i.a, w, b, delta, 'pad',ob.pad, 'stride',ob.stride);
    end % bprop
    
  end
  
end

