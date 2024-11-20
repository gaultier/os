#include <stdint.h>
#include <stdio.h>

int main() {
  uint16_t data[4] = {64512, 9, 0, 0};
  uint64_t n = *(uint64_t *)data;
  printf("%#lx", n);
  /* char *s = "Hello World!"; */
  /* uint64_t low = 0x1F6C1F6C1F651F48; */
  /* uint64_t high = 0x1F6C1F6C1F651F48; */
  /* printf("%.*s  %.*s", 8, (char *)low, 8, (char *)high); */
}
