#include "mex.h"
#include "util3d.hpp"

static const int TMPL[3] = {-5, 0, 5}; // the offset template
static const int num     = sizeof(TMPL)/sizeof(TMPL[0]);
static const int K       = num * num * num;

// acc_y_g27s5 Accumulate the 27 dim predictions. Stride 5.
//  img = acc_y_g27s5(sz_img, ind, yy)
//  Input:
//  sz_img: [3]. double. size
//  ind: [M]. double. linear index to the img
//  yy: [27, M]. single. each elem, a bg/fg response. The bigger, the more likely the fg.
//  Output:
//  img: [a,b,c]. single. the heat map, in place accumulation

void mexFunction(int no, mxArray       *vo[],
                 int ni, mxArray const *vi[])
{
  //// Create Output with all Zeros elements
  mwSize sz_img[3];
  for (int i = 0; i < 3; ++i) sz_img[i] = *( (double*)mxGetData(vi[0]) + i ); // sz_img = vi[0];
  vo[0] = mxCreateNumericArray(3, sz_img, mxSINGLE_CLASS, mxREAL);


  //// Do the job
  float  *p_img = (float*) mxGetData(vo[0]);  // img = vo[0]
  double *p_ind = (double*) mxGetData(vi[1]); // ind = vi[1]
  float  *p_yy  = (float*) mxGetData(vi[2]);  // yy = vi[2] 
  mwSize M = mxGetNumberOfElements(vi[1]); 

  // iterate over center points
  //#pragma omp parallel for
  for (int64_T m = 0; m < M; ++m) {
    // get the center point
    mwSize ixcen = mwSize( *(p_ind + m) );
    mwSize pntcen[3];
    ix_to_pnt3d(sz_img, ixcen, pntcen);

    // source starting point
    float* const p_yy_m = p_yy + m*K; 

    // manually set the K (=num*num*num) points
    int cnt = 0;
    for (int i = 0; i < num; ++i) {
      for (int j = 0; j < num; ++j) {
        for (int k = 0; k < num; ++k) {
          // the working offset
          int d[3]; 
          d[0] = TMPL[i]; d[1] = TMPL[j]; d[2] = TMPL[k];

          // value to be set
          float val = p_yy_m[cnt++]; 

          // accumulate! there can be overlapping ix!
          //#pragma omp atomic
          acc_val_from_offset(p_img, sz_img, pntcen, d,  val);
        } // for k
      } // for j
    } // for i

  } // for m

  return;
}