#include "subscriber.h"

int main(int argc, char** argv)
{
  init_sub();
  run_sub(argc, argv);
  fini_sub();
  return 0;
}