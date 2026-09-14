.syntax unified
.arm
.global _start
.section .text

/*
 * Minimal ARM EABI run-as replacement for Fire OS 5 / Bueller.
 * argv[3] must be /proc/self/task/$$/attr/current. The caller uses exec so
 * the shell-expanded TID remains this process's TID after replacement.
 */
_start:
    ldr     r8, [sp]              /* argc */
    add     r5, sp, #4            /* argv */
    cmp     r8, #4
    blt     fail

    mov     r0, #0
    mov     r1, #0
    mov     r2, #0
    mov     r7, #210              /* setresgid32 */
    svc     #0
    cmp     r0, #0
    blt     fail

    mov     r0, #0
    mov     r1, #0
    mov     r2, #0
    mov     r7, #208              /* setresuid32 */
    svc     #0
    cmp     r0, #0
    blt     fail

    ldr     r0, [r5, #12]         /* argv[3] */
    mov     r1, #2                /* O_RDWR */
    mov     r2, #0
    mov     r7, #5                /* open */
    svc     #0
    cmp     r0, #0
    blt     fail
    mov     r4, r0

    mov     r0, r4
    adr     r1, shell_context
    mov     r2, #13               /* context plus newline, never the NUL */
    mov     r7, #4                /* write */
    svc     #0
    cmp     r0, #13
    bne     fail

    mov     r0, r4
    mov     r7, #6                /* close */
    svc     #0

    adr     r0, shell_path
    mov     r1, r5                /* preserve run-as argv: sh sees -c command */
    add     r2, r5, r8, lsl #2
    add     r2, r2, #4            /* envp follows argv NULL */
    mov     r7, #11               /* execve */
    svc     #0

fail:
    mov     r0, #127
    mov     r7, #1                /* exit */
    svc     #0

.align 2
shell_path:
    .asciz  "/system/bin/sh"
shell_context:
    .ascii  "u:r:shell:s0\n"

