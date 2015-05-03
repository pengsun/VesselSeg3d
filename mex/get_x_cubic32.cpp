#include "mex.h"
#include "util3d.hpp"
#include <omp.h>

static const int S  = 32;
static const int SS = S/2;

//  X = get_x_cubic32(img, ind);
//  img: [a,b,c]. int16. The CT volume
//  ind: [M]. double. Linear index to the image for the locations of sampling points
//  X: [K,K,K, M]. single. The cubic data batch
void mexFunction(int no, mxArray       *vo[],
                 int ni, mxArray const *vi[])
{
  //// Get Input
  mxArray const *img  = vi[0];
  mxArray const *ind = vi[1];
  

  ///// Create Output
  mwSize M = mxGetM(ind) * mxGetN(ind);
  mwSize dims[4] = {S,S,S,0};
  dims[3] = M;
  mxArray *X = mxCreateNumericArray(4, dims, mxSINGLE_CLASS, mxREAL);
  // set the output
  vo[0] = X;


  //// do the job
  int16_T *p_img = (int16_T*) mxGetData(img);
  const mwSize *sz_img;
  sz_img = mxGetDimensions(img);

  double *p_ind = (double*) mxGetData(ind);
  float  *p_X  = (float*) mxGetData(X); 

  // iterate over center points
  #pragma omp parallel for
  for (int64_T m = 0; m < M; ++m) {
    // center index --> center point
    mwSize ixcen = int( *(p_ind + m) );
    ixcen -= 1; // Matlab 1 base -> C 0 base
    mwSize pntcen[3];
    ix_to_pnt3d(sz_img, ixcen, pntcen);
    
    // set the K x K x K cubic: iterate over dim_1, dim_2, dim_3
    mwSize stride_x = S*S*S*m;
    float *pp = p_X + stride_x; // stride

    for (int i = (-SS); i < SS; ++i) {
      for (int j = (-SS); j < SS; ++j) {
        for (int k = (-SS); k < SS; ++k) {
          // the working offset
          mwSize d[3]; 
          d[0] = i; d[1] = j; d[2] = k;
          // value on the image
          float val; 
          get_val_from_offset(p_img, sz_img, pntcen, d,  val);
          // write back
          *pp = val; ++pp;
        } // for i
      } // for j
    } // for k

  } // for m

  return;
}