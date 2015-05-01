#ifndef util3d_h__
#define util3d_h__

#include "tmwtypes.h"

inline void ix_to_pnt3d (const mwSize sz[], mwSize ix, mwSize pnt[])
{
  pnt[2] = ix / (sz[0]*sz[1]);

  ix = ix % (sz[0]*sz[1]);
  pnt[1] = ix / sz[0];

  ix = ix % (sz[0]);
  pnt[0] = ix;
}

inline void pnt3d_to_ix(const mwSize sz[], mwSize pnt[], mwSize& ix)
{
  ix = pnt[0] + 
       pnt[1] * sz[0] + 
       pnt[2] * (sz[0]*sz[1]);
}

inline void cen_plus_offset(mwSize cen[], mwSize offset[], mwSize pnt[])
{
  pnt[0] = cen[0] + offset[0];
  pnt[1] = cen[1] + offset[1];
  pnt[2] = cen[2] + offset[2];
}

inline void clap (const mwSize sz_mk[], mwSize pnt[])
{
  for (mwSize i = 0; i < 3; ++i) {
    if (pnt[i] < 0)         pnt[i] = 0;
    if (pnt[i] >= sz_mk[i]) pnt[i] = sz_mk[i] - 1; 
  }
}

template<typename val_in_T, typename val_out_T>
inline void get_val_from_offset(val_in_T *p_mk, const mwSize sz_mk[], mwSize pntcen[], mwSize offset[],
                                val_out_T &val)
{
  mwSize pnt[3];
  cen_plus_offset(pntcen, offset, pnt);
  clap(sz_mk, pnt);

  mwSize ix;
  pnt3d_to_ix(sz_mk, pnt, ix);

  val =  val_out_T( *(p_mk + ix) );
}

#endif // util3d_h__