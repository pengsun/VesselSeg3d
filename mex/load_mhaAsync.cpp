#include "mha_reader_mt.h"
#include "mex.h"
#include <algorithm>


using namespace std;


//// local functions
namespace {

// get fine name list
void get_fns (int ni, mxArray const *vi[],  VecStr& fns)
{
  char* str;
  for (int i = 0; i < ni; ++i) {
    str = mxArrayToString( vi[i] );
    if (str == 0) mexErrMsgTxt("load_mhaAsync: input must be string\n");
    fns[i] = string(str);
    mxFree(str);
  }
}

void copy_buf (char* buf, mxClassID tp, mwSize NElem,  float* to)
{
  switch (tp) {
    case mxUINT8_CLASS: {
      uint8_T* p_from = (uint8_T*) buf;
      copy(p_from, p_from+NElem, to);
      break;
    }
    case mxUINT16_CLASS: {
      uint16_T* p_from = (uint16_T*) buf;
      copy(p_from, p_from+NElem, to);
      break;
    }
    case mxSINGLE_CLASS: {
      float* p_from = (float*) buf;
      copy(p_from, p_from+NElem, to);
      break;
    }
    default:
      mexErrMsgTxt("load_mhaAsync: unsupported mha element type\n");
  }
}

} // namespace


//// the "singleton" reader
static mha_reader_mt the_reader;


// load_mhaAsync(fn1, fn2, ...);
// mha = load_mhaAsync();
//
// fn1, fn2, ...: string. file names
// mha: cell. Each elem: a 3D mha matrix
void mexFunction(int no, mxArray       *vo[],
                 int ni, mxArray const *vi[])
{
  // return the mha matrix cell
  if (ni == 0) {
    
    if (no != 1)
      mexErrMsgTxt("load_mhaAsync: #output arg must be 1");

    // create output: a cell with #mha file read
    mwSize N = the_reader.get_num();
    vo[0] = mxCreateCellMatrix(N, 1);

    // for each mha file set the cell
    for (int i_buf = 0; i_buf < N; ++i_buf) {
      // get the size and create an mxArray with the same size (always single)
      mha_meta mm;
      the_reader.get_meta(i_buf, mm);
      mxArray* p_mha = mxCreateNumericArray(3, mm.sz, mxSINGLE_CLASS, mxREAL);

      // get the buffer and copy data to the mxArray 
      char* buf;
      the_reader.get_mem(i_buf, buf);
      mwSize NElem = mm.sz[0] * mm.sz[1] * mm.sz[2]; 
      copy_buf(buf, mm.tp, NElem,  (float*)mxGetData(p_mha) );
      
      // write back to the cell
      mxSetCell(vo[0], i_buf, p_mha);
    }

    return;
  }

  // read the mha files
  VecStr fns;
  get_fns(ni, vi,  fns);
  the_reader.read(fns);
  
  return;
}