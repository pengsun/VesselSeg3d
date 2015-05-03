#include "mex.h"
#include "util3d.hpp"
#include <omp.h>

namespace {

const int SS = 16;   // half the size
const int S  = 2*S;  // slice size
const int CC = 5;    // #channels per plane
const int C  = 3*CC; // #channels in total (for the 3 perpendicular planes)
const int CHANNNEL_OFFSET_TMPL[CC] = {-14, -7, 0, 7, 14}; // channel position (offset) template
}

//  X = get_x_slice32c15(img, ind);
//  img: [a,b,c]. int16. the CT volume
//  ind: [M]. linear index to the image for the locations of sampling points
//  X: [32, 32, 15, M]. single. the slices data batch
void mexFunction(int no, mxArray       *vo[],
                 int ni, mxArray const *vi[])
{
  //// Input
  mxArray const *img = vi[0];
  mxArray const *ind = vi[1];
  

  ///// Create Output and set it
  mwSize M = mxGetM(ind) * mxGetN(ind);
  mwSize dims[4] = {S,S,C,0};
  dims[3] = M;
  mxArray *X = mxCreateNumericArray(4, dims, mxSINGLE_CLASS, mxREAL);
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
    mwSize ixcen = mwSize( *(p_ind + m) );
    ixcen -= 1; // Matlab 1 base -> C 0 base
    mwSize pntcen[3];
    ix_to_pnt3d(sz_img, ixcen, pntcen);
    
    // manually set the S x S x C planes
    { // dim_1, dim_2 planes, CC in total
      mwSize stride_X = 0 + S*S*C*m; 
      float *pp = p_X + stride_X;

      for (int i = (-SS); i < SS; ++i) { 
        for (int j = (-SS); j < SS; ++j) {
          for (int k = 0; k < CC; ++k) {
            // the working offset
            mwSize d[3]; 
            d[0] = i; d[1] = j; d[2] = CHANNNEL_OFFSET_TMPL[k];
            // value on the image
            float val; 
            get_val_from_offset(p_img, sz_img, pntcen, d,  val);
            // write back
            *pp = val; ++pp;
          } // for k
        } // for j
      } // for i
    }

    { // dim_2, dim_3
      mwSize stride_X = 1*S*S*CC + S*S*C*m; 
      float *pp = p_X + stride_X;

      for (int i = 0; i < CC; ++i) {
        for (int j = (-SS); j < SS; ++j) {
          for (int k = (-SS); k < SS; ++k) {
            // the working offset
            mwSize d[3];
            d[0] = CHANNNEL_OFFSET_TMPL[i]; d[1] = j; d[2] = k;
            // value on the image
            float val;
            get_val_from_offset(p_img, sz_img, pntcen, d, val);
            // write back
            *pp = val; ++pp;
          } // for k
        } // for j
      } // for i
    }

    { // dim_1, dim_3
      int stride = 2*S*S*CC + S*S*C*m;
      float *pp = p_X + stride;

      for (int i = (-SS); i < SS; ++i) {
        for (int j = 0; j < CC; ++j) {
          for (int k = (-SS); k < SS; ++k) {
            // the working offset
            mwSize d[3];
            d[0] = i; d[1] = CHANNNEL_OFFSET_TMPL[j]; d[2] = k;
            // value on the image
            float val;
            get_val_from_offset(p_img, sz_img, pntcen, d, val);
            // write back
            *pp = val; ++pp;
          } // for k
        } // for j
      } // for i
    }

  } // for m


  return;
}