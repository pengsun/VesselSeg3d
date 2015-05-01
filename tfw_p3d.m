classdef tfw_p3d < tfw_i
  %TFW_P3D pseudo 3D ConvNet for segmentation
  %   Taking volume patch as input, outputing the foreground score at the
  %   center.
  
  properties
  end
  
  methods 
    
    function ob = tfw_p3d()
    % Initialize the DAG net connection
    
      %%% set the connection structure
      % -- layer 0
      % the value normalization by mean and std
      ell = 1;
      tfs{ell} = tf_norm_ms();
      
      % -- layer I
      ell = ell + 1;
      tfs{ell}   = tfw_ConvReluPoolDrop();
      tfs{ell}.i = tfs{ell-1}.o;

      % -- layer II
      ell = ell + 1;
      tfs{ell}   = tfw_ConvReluPoolDrop();
      tfs{ell}.i = tfs{ell-1}.o;
      
      % -- layer III
      ell = ell + 1;
      tfs{ell}   = tfw_ConvReluPoolDrop();
      tfs{ell}.i = tfs{ell-1}.o;
      
      % -- layer IV, output
      ell = ell + 1;
      tfs{ell}   = tf_conv();
      tfs{ell}.i = tfs{ell-1}.o;
      % loss
      ell = ell + 1;
      tfs{ell}      = tf_loss_lse();
      tfs{ell}.i(1) = tfs{ell-1}.o;
      
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
       ob.tfs{1}.i.a      = ob.ab.cvt_data( ob.i(1).a ); % bat_X
       ob.tfs{end}.i(2).a = ob.ab.cvt_data( ob.i(2).a ); % bat_Y
       
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
      for i = numel(ob.tfs) : -1 : 2
        ob.tfs{i} = bprop(ob.tfs{i});
        ob.ab.sync();
      end
      % tfs{1} is the normalization tf, skip it
      
      % %%% Internal Input --> Outer Input: just the input 1, the image
      % ob.i(1).d = ob.tfs{1}.i.d; % bat_X
    end % bprop
    
    % helper
    function Ypre = get_Ypre(ob)
      Ypre = ob.tfs{end-1}.o.a;
    end % get_Ypre
  end % methods
  
end % tfw_p3d

