classdef bdg_mhaDefacto2Async < bdg_i
  %bdg_mhaDefacto2 Generate data asynchronously from mha files in 
  %directory. A wrapper 
  %   Call mex file load_mhaAsync for internal asynchronous mha reading
  
  properties
    dir_names; % 
    M;         % #instances per mha 
    bs;        % batch size
    h_get_x;   % handle to getting x
    h_get_y;   % handle to getting y
    class_bdg; % handle to bdg (class name)
    
    i_cnt;  % current mha count
    mha_id; % mha order
    h_bdg;  % working mha bdg
  end
  
  methods % implement the bdg_i interfaces
    function ob = bdg_mhaDefacto2Async(dir_names, M, bs,...
                                       h_getx, h_gety, class_bdg)
      % check
      assert(M >= bs);
      
      % record
      ob.dir_names = dir_names;
      ob.M       = M;
      ob.bs      = bs;
      ob.h_get_x = h_getx;
      ob.h_get_y = h_gety;
      ob.class_bdg = class_bdg; % set internal bdg class name
      
      % initial params 
      ob.i_cnt  = numel(ob.dir_names);
      ob.mha_id = 1 : numel(ob.dir_names);
    end % bdg_mhaInDir
    
    function ob = reset_epoch(ob)
      ob       = switch_toCurrentMha(ob);
      ob.h_bdg = reset_epoch(ob.h_bdg);
    end
    
    function data = get_bd(ob, i_bat)
      data = get_bd( ob.h_bdg, i_bat );
    end % get_bd
    
    function data = get_bd_orig (ob, i_bat)
      data = get_bd_orig( ob.h_bdg, i_bat );
    end % get_bd_orig
    
    function N = get_bdsz (ob, i_bat)
      N = get_bdsz(ob.h_bdg, i_bat);
    end % get_bdsz
    
    function nb = get_numbat (ob)
      nb = get_numbat( ob.h_bdg ) ;
    end % get_numbat
    
    function ni = get_numinst (ob)
      ni = get_numinst( ob.h_bdg );
    end % get_numinst
    
  end % methods
  
  methods % auxiliary
    function ob = switch_toCurrentMha (ob)
      
      while (true)
        try
          % set current mha
          ob.i_cnt = ob.i_cnt + 1;
          if (ob.i_cnt > numel(ob.dir_names) )% have seen all mha files,
            ob = init_superEpoch (ob);        % begin another "super" epoch
          end
          
          % fetch data
          if (ob.i_cnt == 1) % begining of super epoch, prefetch mannually
            ob = prefetch(ob, ob.i_cnt);
          end        
          [mha, mk_fgbg] = fetch(ob);
          
          % prefetch data
          if (ob.i_cnt <= numel(ob.dir_names) ) % don't need it if the last
            i_next = ob.i_cnt + 1;
            ob = prefetch(ob, i_next);
          end
 
        catch
          etmpl = 'error while processing mha count %d: %s, skip this\n'; 
          i_mha = ob.mha_id(ob.i_cnt);
          fprintf(etmpl,  i_mha, ob.dir_names{i_mha} );
          continue;
        end
        
        % leave if no error
        break; 
      end % while true
      
      % set the bdg
      clear ob.h_bdg;
      MM = floor( ob.M/2 );
      ob.h_bdg = ob.class_bdg(mha, mk_fgbg, MM, ob.bs,...
         ob.h_get_x, ob.h_get_y);
    end
    
    function ob = init_superEpoch (ob)
      ob.i_cnt = 1;
      ob.mha_id = randperm( numel(ob.dir_names) );
      fprintf('new mha order: %d\n', ob.mha_id);
    end
    
    function ob = prefetch(ob, cnt) 
      i_mha  = ob.mha_id( cnt ); % let it raise an error if too big cnt
      cur_nm = ob.dir_names{i_mha};
      fprintf('begin prefetching mha count %d: %s...\n',...
        i_mha, cur_nm );
      
      fn_mha      = fullfile(cur_nm, 't.mha');
      fn_maskfgbg = fullfile(cur_nm, 'maskfgbg.mha');
      load_mhaAsync(fn_mha, fn_maskfgbg);
    end
    
    function [mha,mk_fgbg] = fetch(ob)
      t_elap = tic; %------------------------------------------------------
      [mha, mk_fgbg] = load_mhaAsync();
      t_elap = toc(t_elap); %----------------------------------------------
      
      % done, print fetched mha info
      i_mha  = ob.mha_id( ob.i_cnt ); 
      cur_nm = ob.dir_names{i_mha};
      fprintf('fetching mha count %d: %s...', i_mha, cur_nm);
      fprintf('Done. Time spent %4.3f\n', t_elap);
    end
    
  end % methods 
  
end % bdg_mhaDefacto2