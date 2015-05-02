#pragma once

#include "mex.h"
#include "tmwtypes.h"
#include <vector>
#include <string>

typedef std::vector<std::string> VecStr;

struct mha_meta {
  mwSize    sz[3]; // size along dim_1,...,dim_3
  mxClassID tp;    // element type: uin8, single, etc.
};

struct mha_reader_mt {
  void read (const VecStr& fns);

  int  get_num  ();
  void get_meta (int i_buf, mha_meta &ma);
  void get_mem  (int i_buf, char* &buf);
};