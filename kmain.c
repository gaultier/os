#include <stdint.h>

void print_s(uint8_t *s, uint64_t len) {
  uint8_t *ptr = (uint8_t *)0x00b8000;
  for (uint64_t i = 0; i < len; i++) {
    *(ptr++) = *(s++);
    *(ptr++) = 0x1f;
  }
}
void kmain() { print_s((uint8_t *)"hello me", 8); }
