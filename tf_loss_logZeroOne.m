classdef tf_loss_logZeroOne < tf_i
  %TF_LOSS_LOGZEROONE Log loss for binary classification, zero-one label
  %   Detailed explanation goes here
  
  properties
    prob; % [1,N] estimated probability
    sz;   % [d1,...,dM]. size for the data at input 1
  end
  
  methods
    function ob = tf_loss_logZeroOne ()
      ob.i = [n_data(), n_data()];
      ob.o = n_data();
    end
    
    function ob = fprop (ob)
      F = ob.i(1).a; % [d1,...,dM, N]
      y = ob.i(2).a; % [1, N], 0 or 1
      
      % book the input size
      ob.sz = size(F);
      
      % logistic link: F --> prob
      F = reshape(F, size(y));    % [1, N]
      ob.prob = 1./( 1 + exp(-2*F) ); % [1, N]
      
      % loss
      ob.o.a = -log( y.*ob.prob + (1-y).*(1-ob.prob) );
    end
    
    function ob = bprop (ob)
      % w.r.t. prediction 
      y = ob.i(2).a; % [1, N], 0 or 1
      ob.i(1).d = reshape( 2*(ob.prob - y), ob.sz);
      
      % w.r.t. label: ignore it
    end
    
  end
  
end

