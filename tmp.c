#include <stdint.h>
#include <stdio.h>

int main() {
  char *s = "Hello World!";
  uint64_t low = 0x1F6C1F6C1F651F48;
  uint64_t high = 0x1F6C1F6C1F651F48;
  printf("%.*s  %.*s", 8, (char *)low, 8, (char *)high);
}
