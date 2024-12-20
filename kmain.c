#include <stdint.h>

void kmain();
void entrypoint() { kmain(); }

static void print_s(uint8_t *s, uint64_t len) {
  uint8_t *ptr = (uint8_t *)0x00b8000;
  for (uint64_t i = 0; i < len; i++) {
    *(ptr++) = *(s++);
    *(ptr++) = 0x1f;
  }
}

void syscall_hook() { __asm__("sysret\n"); }

void kmain() {
  print_s((uint8_t *)"hello me", 8);

#if 0
  __asm__(".intel_syntax noprefix\n"
          "mov ecx, 0xC0000082 \n" // LSTAR
          "xor edx, edx\n"
          "mov eax, syscall_hook\n"
          "wrmsr\n");
#endif
}
