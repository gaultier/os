#include <stdint.h>
#include <stdio.h>

int main() {
  uint16_t data[4] = {64512, 9, 0, 0};
  uint64_t n = *(uint64_t *)data;
  printf("%#lx", n);
}
