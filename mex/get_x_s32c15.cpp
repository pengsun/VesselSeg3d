#include "mex.h"
#include "util3d.hpp"
#include <omp.h>

static const int K  = 48;
static const int KK = 24;

//  X = get_x_s32c15(img, ind);
//  img: [a,b,c]. the CT volume
//  ind: [M]. linear index to the image for the locations of sampling points
//  X: [32, 32, 15, M]. the slices data batch
void mexFunction(int no, mxArray       *vo[],
                 int ni, mxArray const *vi[])
{
  //// Input
  mxArray const *img  = vi[0];
  mxArray const *ind = vi[1];
  

  ///// Create Output
  int M = mxGetM(ind) * mxGetN(ind);
  mwSize dims[4] = {K,K,3,0};
  dims[3] = M;
  mxArray *X = mxCreateNumericArray(4, dims, mxSINGLE_CLASS, mxREAL);


  //// do the job
  int16_T *p_img = (int16_T*) mxGetData(img);
  const mwSize *sz_img;
  sz_img = mxGetDimensions(img);

  double *p_ind = (double*) mxGetData(ind);
  float  *p_X  = (float*) mxGetData(X); 

  // iterate over center points
  #pragma omp parallel for
  for (int m = 0; m < M; ++m) {
    // center index --> center point
    int ixcen = int( *(p_ind + m) );
    ixcen -= 1; // Matlab 1 base -> C 0 base
    int pntcen[3];
    ix2pnt(sz_img, ixcen, pntcen);
    
    // manually set the 48 x 48 x 3 planes

    { // dim_1, dim_2 plane
      int stride = 0 + K*K*3*m; 
      float *pp = p_X + stride;

      for (int i = (-KK); i < KK; ++i) { 
        for (int j = (-KK); j < KK; ++j) {
          // the working offset
          int d[3]; 
          d[0] = i; d[1] = j; d[2] = 0;
          // value on the image
          float val; 
          get_val_from_offset(p_img, sz_img, pntcen, d,  val);
          // write back
          *pp = val; ++pp;
        } // for j
      } // for i
    }

    { // dim_2, dim_3
      int stride = K*K + K*K*3*m; 
      float *pp = p_X + stride;

      for (int j = (-KK); j < KK; ++j) {
        for (int k = (-KK); k < KK; ++k) {
          // the working offset
          int d[3];
          d[0] = 0; d[1] = j; d[2] = k;
          // value on the image
          float val;
          get_val_from_offset(p_img, sz_img, pntcen, d, val);
          // write back
          *pp = val; ++pp;
        } // for k
      } // for j
    }

    { // dim_1, dim_3
      int stride = 2*K*K + K*K*3*m;
      float *pp = p_X + stride;

      for (int i = (-KK); i < KK; ++i) {
        for (int k = (-KK); k < KK; ++k) {
          // the working offset
          int d[3];
          d[0] = i; d[1] = 0; d[2] = k;
          // value on the image
          float val;
          get_val_from_offset(p_img, sz_img, pntcen, d, val);
          // write back
          *pp = val; ++pp;
        } // for k
      } // for i
    }

  } // for m


  //// Set output
  vo[0] = X;

  return;
}