classdef bdg_mhaSamp < bdg_i
  %BDG_MHASAMP bdg_mhaSamp, producing mini-batch by in-place sampling 
  %   Pass the handle to get_x and get_y
  %   Set function handles for how to get instances x and labels y
  %
  %   A typical senario:
  %   ------------------
  %   The instatces are 3 perpendicular planes:
  %   X: [32,32,32,N], ndims(X) = 4
  %   The lables are 0/1 mask for the pre-specified points in the cube
  %   Y: [K,N], each clumn is 1-hot response for the fg; Or 0/1 bg/fg 
  %      coding when K = 1
  %
  
  properties
    mha;     % [a,b,c] the 3d CT volume
    mk_fgbg; % [a,b,c] the mask:
             % 255: vessels, 128: background, 0: not interested
    ix_fgbg; % [M] # fg+bg pixels index
    
    h_get_x; % handle to how to get instances x
    h_get_y; % handle to how to get labels y

    hb; % handle to a  bat_gentor
  end
  
  properties % to restore
    xMean; % [48, 48, 3] int16 mean image
    vmax;  % [1] int16 max value
    vmin;  % [1] int16 min value
  end
  
  methods % implement the bdg_i interfaces
    function ob = bdg_mhaSamp (mha, mk_fg, mk_bg, bs, h_get_x, h_get_y)
      % checking
      assert( all(size(mha)==size(mk_fg)) );
      assert( all(size(mk_fg)==size(mk_bg)) );
      
      % restore the main CT volume
      ob.mha = mha;
      
      % construct the internal mask
      ob.mk_fgbg = mk_fg;
      itmp = (mk_bg==255);
      ob.mk_fgbg(itmp) = 128;
      
      % create internal batch generator
      ob.ix_fgbg = find(ob.mk_fgbg > 0);
      N = numel(ob.ix_fgbg);
      ob.hb = bat_gentor();
      ob.hb = reset(ob.hb, N,bs);
      
      % how to get instances x and labels y
      ob.h_get_x = h_get_x;
      ob.h_get_y = h_get_y;
    end % bdg_mha2
    
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
      % the fg, bg mask index: should never be out of boundary
      ind_fgbg = ob.ix_fgbg(idx);
      
      % the instaces: X
      X = ob.h_get_x(ob.mha, ind_fgbg);
      data{1} = restore_X(ob, X);
      % the labels: Y
      data{2} = ob.h_get_y(ob.mk_fgbg, ind_fgbg);
    end
    
    function Ygt = get_all_Ygt (ob)
      Ygt = ob.h_get_y(ob.mk_fgbg, ob.ix_fgbg);
    end
    
    function xx = restore_X (ob, x)
      % uint8 to float
      xx = single(x);
      
      % do nothing further if unset
      if ( isempty(ob.xMean) || isempty(ob.vmin) || isempty(ob.vmax) )
        return;
      end
      
      % to 0 mean, approximately [-1, +1]
      xx = bsxfun(@minus, xx, ob.xMean);
      ix = (xx > 0);
      xx(ix)  = xx(ix) ./ abs(ob.vmax);
      xx(~ix) = xx(~ix) ./ abs(ob.vmin); 
    end % restore_X
    
  end % auxiliary 
  
end % bdg_mha2
