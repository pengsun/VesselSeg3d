classdef tfw_Conv3dPool3d < tfw_i
  %tfw_Conv3Pool3d Conv3d + Max Pooling3d
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function ob = tfw_Conv3dPool3d()
      %%% internal connection
      % 1: conv, param
      ob.tfs{1}        = tf_conv3d();
      ob.tfs{1}.p(1).a = randn(0, 0, 'single'); % kernel
      ob.tfs{1}.p(2).a = zeros(0, 0, 'single'); % bias
      % 2: pool
      ob.tfs{2}   = tf_maxpool3d();
      ob.tfs{2}.i = ob.tfs{1}.o;
      
      %%% input/output data
      ob.i = n_data();
      ob.o = n_data();

      %%% set the parameters
      ob.p = dag_util.collect_params( ob.tfs );
      
    end % tfw_Conv3dPool3d
    
    function ob = fprop(ob)
      % outer -> inner
      ob.tfs{1}.i.a = ob.i.a; 
      % fprop all
      for i = 1 : numel( ob.tfs )
        ob.tfs{i} = fprop(ob.tfs{i});
        ob.ab.sync();
      end
      % inner -> outer
      ob.o.a = ob.tfs{end}.o.a; 
    end % fprop
    
    function ob = bprop(ob)
      % outer -> inner
      ob.tfs{end}.o.d = ob.o.d; 
      % bprop all
      for i = numel(ob.tfs) : -1 : 1
        ob.tfs{i} = bprop(ob.tfs{i});
        ob.ab.sync();
      end
      ob.i.d = ob.tfs{1}.i.d; 
    end % bprop
  end
  
end

