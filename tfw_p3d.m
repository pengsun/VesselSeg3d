classdef tfw_p3d < tfw_i
  %TFW_P3D pseudo 3D ConvNet for segmentation
  %   Taking volume patch as input, outputing the foreground score at the
  %   center.
  
  properties
  end
  
  methods 
    
    function ob = tfw_p3d()
    % Initialize the DAG net
    
      %%% set the connection structure
      % -- layer I
      % 1: conv, param
      tfs{1}      = tf_conv();
      tfs{1}.p(2) = n_data();
      % 2: pool
      tfs{2}   = tf_pool();
      tfs{2}.i = tfs{1}.o;
      
      % -- layer II
      % 3: conv, param
      tfs{3}      = tf_conv();
      tfs{3}.i    = tfs{2}.o;
      tfs{3}.p(2) = n_data();
      % 4: pool
      tfs{4}   = tf_pool();
      tfs{4}.i = tfs{3}.o;
      
      % -- layer III
      % 5: conv, param
      tfs{5}      = tf_conv();
      tfs{5}.i    = tfs{4}.o;
      tfs{5}.p(2) = n_data();
      % 6: pool
      tfs{6}   = tf_pool();
      tfs{6}.i = tfs{5}.o;
      
      % -- layer IV, 1x1 conv
      % 7: conv, param
      tfs{7}      = tf_conv();
      tfs{7}.i    = tfs{6}.o;
      tfs{7}.p(2) = n_data();
      % 8: relu
      tfs{8}   = tf_relu();
      tfs{8}.i = tfs{7}.o;
      % 9: dropout
      tfs{9}   = tf_dropout();
      tfs{9}.i = tfs{8}.o;
      
      % -- layer V, output
      % 10: full connection, param
      tfs{10}      = tf_conv();
      tfs{10}.i    = tfs{9}.o;
      tfs{10}.p(2) = n_data();
      % 11: loss
      tfs{11}      = tf_loss_lse();
      tfs{11}.i(1) = tfs{10}.o;
      
      % write back
      ob.tfs = tfs;      
      
      
      %%% input/output data
      ob.i = [n_data(), n_data()]; % X_bat, Y_bat, respectively
      ob.o = n_data();             % the loss
      
      
      %%% associate the parameters
      ob.p = dag_util.collect_params( ob.tfs );
      
    end % tfw_lenetDropout
    
    function ob = fprop(ob)
       %%% Outer Input --> Internal Input
       ob.tfs{1}.i.a     = ob.ab.cvt_data( ob.i(1).a ); % bat_X
       ob.tfs{11}.i(2).a = ob.ab.cvt_data( ob.i(2).a ); % bat_Y
       
       %%% fprop for all
       for i = 1 : numel( ob.tfs )
         ob.tfs{i} = fprop(ob.tfs{i});
         ob.ab.sync();
       end
       
       %%% Internal Output --> Outer Output: set the loss
       ob.o.a = ob.tfs{end}.o.a;
    end % fprop
    
    function ob = bprop(ob)
      %%% Outer output --> Internal output: unnecessary here
      
      %%% bprop for all
      for i = numel(ob.tfs) : -1 : 1
        ob.tfs{i} = bprop(ob.tfs{i});
        ob.ab.sync();
      end
      
      %%% Internal Input --> Outer Input: just the input 1, the image
      ob.i(1).d = ob.tfs{1}.i.d; % bat_X
    end % bprop
    
    % helper
    function Ypre = get_Ypre(ob)
      Ypre = ob.tfs{end-1}.o.a;
    end % get_pre
  end % methods
  
end % tfw_p3d

