#pragma once

#include "mex.h"
#include "tmwtypes.h"

#include <vector>
#include <string>

#include <thread>
#include <mutex>
#include <condition_variable>


typedef std::vector<std::string> VecStr;
typedef std::vector<char>        VecChar;


struct mha_meta {
  mwSize    sz[3]; // size along dim_1,...,dim_3
  mxClassID tp;    // element type: uin8, single, etc.
};

struct mha_reader_mt {
  void read (const VecStr& fns);

  int  get_numbuf ();
  void get_meta   (int i_buf, mha_meta &mm);
  void get_mem    (int i_buf, char* &buf);

private:
  void wait_tasks ();
  void kill_tasks ();
  void run_tasks  (const VecStr& fns);

  struct task {
    enum status {DONE, ERROR, UNSUPPORTED};

    std::string fn;
    mha_meta    mm;
    VecChar     buf;
    status      st;

    void run ();
  };

  std::vector<task> tasks; 
  std::mutex        mtx;
  std::thread       worker;
};