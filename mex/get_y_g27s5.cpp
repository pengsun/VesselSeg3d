#include "mex.h"
#include "util3d.hpp"

static const int TMPL[3] = {-5, 0, 5}; // the offset template
static const int num     = sizeof(TMPL)/sizeof(TMPL[0]);
static const int K       = num * num * num;

// yy = get_y_g27s5(mk, ind)
//   mask: [a,b,c]. UINT8. 255: vessels, 128: background, 0: not interested
//   ind: [M]. Double. linear index to the mk
//   yy: [27, M]. Single. each elem, 0/1 bg/fg response
void mexFunction(int no, mxArray       *vo[],
                 int ni, mxArray const *vi[])
{
  //// Input
  mxArray const *mk  = vi[0];
  mxArray const *ind = vi[1];
  

  ///// Create Output
  int M = mxGetM(ind) * mxGetN(ind);
  mwSize dims[2];
  dims[0] = K;
  dims[1] = M;
  mxArray *yy = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, mxREAL);


  //// do the job
  uint8_T *p_mk = (uint8_T*) mxGetData(mk);
  const mwSize *sz_mk;
  sz_mk = mxGetDimensions(mk);

  double *p_ind = (double*) mxGetData(ind);
  float  *p_yy  = (float*) mxGetData(yy); 

  // iterate over center points
  #pragma omp parallel for
  for (int64_T m = 0; m < M; ++m) {
    // get the center point
    mwSize ixcen = int( *(p_ind + m) );
    mwSize pntcen[3];
    ix_to_pnt3d(sz_mk, ixcen, pntcen);

    // destination starting point
    float *pp = p_yy + m*K; 

    // manually set the K (=27) points
    for (int i = 0; i < 2; ++i) {
      for (int j = 0; j < 2; ++j) {
        for (int k = 0; k < 2; ++k) {
          // the working offset
          int d[3]; 
          d[0] = TMPL[i]; d[1] = TMPL[j]; d[2] = TMPL[k];
          // value on mask
          uint8_T val; 
          get_val_from_offset(p_mk, sz_mk, pntcen, d,  val);
          // the 
          *pp = (val==255)? 1.0 : 0.0; // 255: fore ground, set 1; otherwise: set 0
          ++pp;
        } // for k
      } // for j
    } // for i

  } // for m


  //// Set output
  vo[0] = yy;

  return;
}