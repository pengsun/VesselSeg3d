#include "mha_reader_mt.h"
#include <algorithm>
#include <iterator>
#include <fstream>
#include <cstring>


using namespace std;


namespace {

int get_elemsz(mxClassID cid) {
  switch (cid) {
  case mxUINT8_CLASS: return 1;
    break;
  case mxUINT16_CLASS: return 2;
    break;
  case mxSINGLE_CLASS: return 4;
    break;
  default:
    mexErrMsgTxt("mha_reader_mt: unsupported mha element type\n");
  }
}

mxClassID get_cidFromMhaStr (const char * str) {
  if ( 0 == strcmp(str,"MET_SHORT") ) 
    return mxINT16_CLASS;

  if ( 0 == strcmp(str,"MET_UCHAR") ) 
    return mxUINT8_CLASS;

  if ( 0 == strcmp(str,"MET_FLOAT") ) 
    return mxSINGLE_CLASS;

  return mxUNKNOWN_CLASS;

}

void mha_read_meta (ifstream& is,  
                    mha_meta &mm, mwSize &byte_offset) 
{
  // start at file beginning
  is.clear();
  is.seekg(0, ios::beg);

  // init output
  byte_offset = 0;

  // parse line by line
  string line;
  while (std::getline(is, line)) {
    // get string like "left = right"
    char left[512], right[512];
    sscanf(line.c_str(), "%s = %s", left, right);

    // check and set

    if ( 0 == strcmp(left, "ObjectType") ) { // must be an image
      if ( 0 == strcmp(right, "Image") )
        break; // unsupported
    }

    if ( 0 == strcmp(left, "NDims") ) { // must be 3 dimensional
      if ( 0 == strcmp(right, "3") )
        break; // unsupported
    }

    if ( 0 == strcmp(left, "CompressedData") ) {
      if ( 0 == strcmp(right, "True") )
        break; // unsupported
    }  

    if ( 0 == strcmp(left, "DimSize") ) { // e.g., DimSize = 512 512 368
      int xdim, ydim, zdim;
      sscanf(right, "%d %d %d", xdim,ydim,zdim);
      mm.sz[0] = xdim;
      mm.sz[1] = ydim;
      mm.sz[2] = zdim;
      continue;
    }  

    if ( 0 == strcmp(left, "ElementType") ) { // e.g., ElementType = MET_SHORT
      mm.tp = get_cidFromMhaStr(right);
      continue;
    }  

    if ( 0 == strcmp(left, "ElementDataFile") ) { // end of header!
      byte_offset = (mwSize)is.tellg();
      break;
    }

  } // while not end of file


}

void mha_read_data (ifstream& is, mha_meta mm, mwSize bytes_offset,
                    VecChar &buf)
{
  // create the output
  mwSize numel = mm.sz[0] * mm.sz[1] * mm.sz[2];
  int elemsz = get_elemsz(mm.tp);
  mwSize numbytes = numel*elemsz;
  buf.resize( numbytes );

  // copy bytes
  is.seekg(bytes_offset, ios::beg);
  istreambuf_iterator<char> isbeg(is);
  istreambuf_iterator<char> isend;
  copy(isbeg, isend,  &buf[0]);

  // TODO: check if bytes copied matches the file size
}

} // namespace


//// Impl of mha_reader_mt
void mha_reader_mt::read(const VecStr& fns)
{
  kill_tasks();
  
  thread td{&mha_reader_mt::run_tasks, fns};
  worker = std::move(td);
}

int mha_reader_mt::get_numbuf()
{
  wait_tasks();
  lock_guard lock(mtx);

  return tasks.size();
}

void mha_reader_mt::get_meta(int i_buf, mha_meta& mm)
{
  wait_tasks();
  lock_guard lock(mtx);
  mm = tasks[i_buf].mm;
}

void mha_reader_mt::get_mem(int i_buf, char* &buf)
{
  wait_tasks();
  lock_guard lock(mtx);
  buf = &(tasks[i_buf].buf[0]);
}


//// Impl of mha_reader_mt private
void mha_reader_mt::wait_tasks()
{
  if (worker.joinable())
    worker.join();
}

void mha_reader_mt::kill_tasks()
{
  // TODO: termination immediately
  if (worker.joinable())
    worker.join();

  tasks.resize(0); // OK that the memory is not really released
}

void mha_reader_mt::run_tasks( const VecStr& fns )
{
  lock_guard lock(mtx);

  tasks.resize(fns.size());
  for (int i = 0; i < tasks.size(); ++i) {
    tasks[i].fn = fns[i];
    tasks[i].run();
  }
}


//// Impl of mha_reader_mt::task
void mha_reader_mt::task::run()
{
  // open as text: parse header text
  ifstream is(this->fn);
  if (!is.is_open()) {
    this->st = ERROR;
    return;
  }
  // get raw data offset, return if error occurred
  mwSize byte_offset;
  mha_read_meta(is, this->mm, byte_offset);
  if (byte_offset == 0 || mm.tp == mxUNKNOWN_CLASS) {
    st = UNSUPPORTED;
    mm.tp = mxUNKNOWN_CLASS;
    buf.resize(0);
    return;
  }
  is.close();
 
  // read raw data
  is.open(this->fn, ios::binary);
  mha_read_data(is, this->mm, byte_offset,  this->buf);
  is.close();
}
