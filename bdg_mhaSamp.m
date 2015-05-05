classdef bdg_mhaSamp < bdg_i
  %bdg_mhaSamp producing mini-batch by sampling 
  %   Sample all data and put them in RAM. 
  %   Pass the handle to get_x and get_y
  %   Set function handles for how to get instances x and labels y
  %
  %   A typical senario:
  %   ------------------
  %   The instatces are a cube:
  %   X: [32,32,32,N], ndims(X) = 4
  %   The lables are 0/1 mask for the pre-specified points in the cube
  %   Y: [K,N], each clumn is 1-hot response for the fg; Or 0/1 bg/fg 
  %      coding when K = 1; bg, fg are balanced
  %
  
  properties
    X;
    Y;
    ix_fgbg; % [M] # fg+bg pixels index
    
    h_get_x; % handle to how to get instances x
    h_get_y; % handle to how to get labels y

    hb; % handle to a  bat_gentor
  end
   
  methods % implement the bdg_i interfaces
    function ob = bdg_mhaSamp (mha, mk_fgbg, bs, h_get_x, h_get_y)
    % ob = bdg_mhaSamp (mha, mk_fgbg, bs, h_get_x, h_get_y)
    
      % checking
      assert( all( size(mha)==size(mk_fgbg) ) );
      
      fprintf('bdg_mhaSamp: sampling for current mha...');
      t_elap = tic; %------------------------------------------------------
      
      % sampling
      ix_fg  = find(mk_fgbg == 255);
      ix_bg  = find(mk_fgbg == 128);
      ix_all = [ix_fg(:); ix_bg(:)]; 
      
      % create internal batch generator
      ob.ix_fgbg = ix_all;
      N = numel(ob.ix_fgbg);
      ob.hb = bat_gentor();
      ob.hb = reset(ob.hb, N,bs);
      
      % function handles: how to get instances x and labels y?
      ob.h_get_x = h_get_x;
      ob.h_get_y = h_get_y;
      % 
      ob.X = ob.h_get_x(mha,     ob.ix_fgbg);
      ob.Y = ob.h_get_y(mk_fgbg, ob.ix_fgbg);
      
      t_elap = toc(t_elap); %----------------------------------------------
      fprintf('done. Time spent %4.3f\n', t_elap);
    end % bdg_mhaSamp
    
    function ob = reset_epoch(ob)
    % reset for a new epoch
      N = numel(ob.ix_fgbg);
      bs = get_bdsz(ob, 1);
      ob.hb = reset(ob.hb, N,bs);
    end
    
    function [data, idx] = get_bd (ob, i_bat)
    % get the i_bat-th batch data
      % the instance index
      idx = get_idx(ob.hb, i_bat);
      data = get_bd_from_idx(ob, idx);
    end
    
    function [data, idx] = get_bd_orig (ob, i_bat)
    % get the i_bat-th batch data
      % the instance index
      idx = get_idx_orig(ob.hb, i_bat);
      data = get_bd_from_idx(ob, idx);
    end
    
    function N = get_bdsz (ob, i_bat)
    % get the size of the i_bat-th batch data
      N = numel( get_idx_orig(ob.hb, i_bat) );
    end
    
    function nb = get_numbat (ob)
    % get number of batchs in an epoch
      nb = ob.hb.num_bat;
    end
    
    function ni = get_numinst (ob)
    % get number of the total instances
      ni = numel(ob.ix_fgbg);
    end
  end % methods
  
  methods % auxiliary, extra interfaces
    function data = get_bd_from_idx (ob, idx)
      % the instaces: X
      data{1} = ob.X(:,:,:, idx);
      % the labels: Y
      data{2} = ob.Y(:, idx);
    end
        
    function Ygt = get_all_Ygt (ob)
      Ygt = ob.h_get_y(ob.mk_fgbg, ob.ix_fgbg);
    end
    
  end % auxiliary 
  
end % bdg_mhaSampBal
