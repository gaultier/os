#include <stdbool.h>
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

__attribute__((interrupt)) void syscall_hook(void *p) {
  __asm__(".intel_syntax noprefix\n"
          "sysret\n");
}

void user_program() {
  __asm__(".intel_syntax noprefix\n"
          "mov eax, 1\n"
          "mov rdi, 2\n"
          "syscall");
}

void kmain() {
  print_s((uint8_t *)"hello me", 8);
  while (true) {
    // Run `user_program` in userspace.
    __asm__(".intel_syntax noprefix\n"
            "mov rcx, user_program        \n"
            "mov rsp, rsp        \n" // TODO: user space stack
            "mov r11, 0x0202     \n"
            "sysret;            \n");
  }
}
