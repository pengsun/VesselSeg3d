classdef tfw_net3d8_te < tfw_net3d8
  %TFW_NET3D8_te tfw_net3d8 specilized in testing
  
  properties
  end
  
  methods 
    
    function ob = tfw_net3d8_te(the_dag)
      % copy
      ob.tfs = the_dag.tfs;
      
      % remove the loss layer
      ob.tfs(end) = [];
      
      ob.i = n_data(); % X_bat, 
      ob.o = n_data();             % the loss
    end % tfw_net3d8_te
    
    function ob = fprop(ob)
       %%% Outer Input --> Internal Input
       ob.tfs{1}.i.a  = ob.ab.cvt_data( ob.i(1).a ); % bat_X
       ob.tfs{1}.i.a  = reshapeInput3d(ob.tfs{1}.i.a );
       
       %%% fprop for all
       for i = 1 : numel( ob.tfs )
         ob.tfs{i} = fprop(ob.tfs{i});
         ob.ab.sync();
       end
       
       %%% Internal Output --> Outer Output: set the loss
       ob.o.a = ob.tfs{end}.o.a;
    end % fprop
    
    function ob = bprop(ob)
    end
    
    % helper
    function Ypre = get_Ypre(ob)
      Ypre = ob.tfs{end}.o.a;
    end % get_Ypre
  end % methods
  
end % 

function X = reshapeInput3d (X)
sz1 = size(X,1);
sz2 = size(X,2);
sz3 = size(X,3);
sz4 = size(X,4);

X = reshape(X, [sz1,sz2,sz3, 1, sz4]);

end