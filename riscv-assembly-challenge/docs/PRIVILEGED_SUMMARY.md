# RISC-V Privileged Architecture — Summary

Based on RISC-V Privileged Spec (Volume 2), Sections 3.1–3.4.

## 1. Privilege Levels

RISC-V defines three privilege modes, but not every core needs to implement all of them.

- **Machine Mode (M-mode)** — the highest privilege level and the only one that is mandatory. Every RISC-V hardware implementation has M-mode, even the smallest microcontroller cores. It's where firmware and the bootloader run, and it has full access to all hardware.
- **Supervisor Mode (S-mode)** — an optional mode used by an OS kernel (like Linux). It can manage virtual memory (page tables) but doesn't have the same unrestricted access as M-mode.
- **User Mode (U-mode)** — also optional, this is where normal applications run. It has restricted access to hardware and memory, so a buggy or malicious program can't take down the whole system.

A minimal core, like the one we built earlier in this module, might only implement M-mode since there's no OS running on it. A full Linux system needs all three modes working together — U-mode for apps, S-mode for the kernel, and M-mode underneath for firmware.

The reason for having separate levels in the first place is protection. If every program ran with full hardware access, one buggy application could overwrite another program's memory or mess with I/O devices it has no business touching. By putting the OS kernel in S-mode and applications in U-mode, the hardware itself enforces a wall between them. A user program simply cannot execute the instructions that would let it, say, change the page table or disable interrupts — trying to do so causes a trap, which is discussed below. This is different from the base ISA we worked with earlier, which has no real concept of "who is allowed to do what"; privilege levels are what turn a bare processor core into something that can safely run an actual operating system with multiple untrusted programs on it at once.

It's also worth noting that these levels are hierarchical, not arbitrary categories — M-mode can do everything S-mode can do, and S-mode can do everything U-mode can do, but not the other way around. The `mstatus` register (below) keeps track of which mode the previous privilege level was, which matters when the CPU needs to return control after handling a trap.

## 2. Key CSRs (Control and Status Registers)

CSRs are special registers used to control and monitor the processor's behavior, especially during traps. The important ones for trap handling are:

| CSR | Purpose |
|---|---|
| `mstatus` | Holds global interrupt enable bit and tracks current privilege mode |
| `mtvec` | Address of the trap handler — the PC jumps here when a trap occurs |
| `mepc` | Saves the PC of the instruction that caused the trap, so execution can resume later |
| `mcause` | Encodes what actually caused the trap (illegal instruction, ecall, timer interrupt, etc.) |
| `mtval` | Extra info about the trap, like a faulting memory address |

Basically, `mtvec` tells the CPU where to go, `mepc` remembers where it came from, and `mcause`/`mtval` tell the handler what happened.

A couple of extra details worth mentioning:

- `mtvec` actually has a mode bit as well as a base address. In **direct mode**, every trap jumps to the same single handler address, and that handler is responsible for figuring out the cause itself by reading `mcause`. In **vectored mode**, the base address is really the start of a table, and the CPU jumps to `base + 4 × cause`, so different interrupt causes can each have their own small handler instead of all going through one big dispatcher.
- There are also delegation registers, `medeleg` and `mideleg`, which let M-mode hand off certain exceptions/interrupts to be handled directly in S-mode instead of always trapping to M-mode first. This matters for a full OS since it means the kernel can handle most traps itself without bouncing through machine mode every single time, which would be slower.

## 3. Trap Handling Flow

When a trap (an exception or interrupt) occurs, the hardware and software work together like this:

1. The processor detects a trap condition.
2. Hardware automatically saves the current PC into `mepc`, writes a cause code into `mcause`, and jumps the PC to whatever address is in `mtvec`.
3. The trap handler (software) runs. It reads `mcause` to figure out what happened and decides how to respond.
4. Once handled, the handler executes an `MRET` instruction, which restores the PC from `mepc` and returns to normal execution.

This is basically the same mechanism used for both interrupts (external events, like timers) and exceptions (something goes wrong during execution, like an illegal instruction or a system call). The CPU doesn't really care which one it is — it just uses `mcause` to distinguish and dispatch accordingly.

It's worth being clear on the distinction between the two, since they're both called "traps" but behave a little differently:

- **Exceptions** are synchronous — they happen because of the instruction currently being executed. Examples are an illegal opcode, a misaligned memory access, or an `ecall` (used deliberately by software to request something from a higher privilege level, like a system call).
- **Interrupts** are asynchronous — they can happen at basically any point, triggered by something outside the currently executing instruction stream, like a timer expiring or an external device signaling it needs attention.

Because both use the same `mepc`/`mcause`/`mtvec` mechanism, the hardware doesn't need two totally separate paths — it's really one general trap mechanism that both cases funnel into, with `mcause`'s top bit typically used to tell them apart (interrupt vs. exception) and the rest of the bits giving the specific cause code.

As a concrete example: if a user program executes `ecall` to request a service from the OS, the PC at the `ecall` instruction gets saved into `mepc`, `mcause` gets set to the "environment call" code, and the PC jumps to the handler in `mtvec`. The OS handler reads `mcause`, sees it's a system call, does whatever was requested, then runs `MRET` to hop back into the user program right where the `ecall` left off (well, technically one instruction later, since the OS increments the saved PC before returning, otherwise it would just `ecall` again in an infinite loop).

## 4. Why This Matters

Even for a minimal M-mode-only core, understanding this flow is useful because it's how the processor deals with errors and system calls without needing an OS. For a full system, this same trap mechanism is what lets the OS take control away from a user program (for example, on a timer interrupt) or handle a system call (`ecall`) safely.

## 5. Exceptions vs Interrupts

It's worth being a bit more precise about the two kinds of traps, since they're caused differently even though the hardware response is basically the same:

- **Exceptions** are caused by the currently executing instruction itself — things like an illegal instruction, a misaligned memory access, or an `ecall`/`ebreak` instruction. They happen synchronously, meaning they're tied directly to a specific instruction in the program.
- **Interrupts** come from outside the currently running instruction stream — a timer expiring, an external device signaling it needs attention, etc. These are asynchronous, so they can happen "between" instructions rather than because of one particular instruction.

`mcause` actually has a bit reserved just to say whether the trap was an interrupt or an exception, and then the rest of the code tells you which specific one it was. This is how a single trap handler entry point in `mtvec` can end up branching to completely different handling code depending on what caused the trap.

## 6. M-mode vs S-mode CSRs

One detail that's easy to miss at first is that S-mode has its own parallel set of CSRs (`sstatus`, `stvec`, `sepc`, `scause`, `stval`) that mirror the M-mode ones. This exists so that a supervisor-level OS kernel can handle most traps itself without needing to escalate to M-mode every time, which would defeat the purpose of having separate privilege levels in the first place. M-mode still sits above everything as the ultimate fallback, and can delegate certain traps/interrupts down to S-mode using delegation registers (`medeleg`, `mideleg`), so the CPU doesn't always have to bounce all the way up to M-mode for routine stuff like handling a user-mode syscall.

## References

- RISC-V International, *The RISC-V Instruction Set Manual, Volume II: Privileged Architecture*, Sections 3.1–3.4.
- Harris, S. L., & Harris, D. M. (2022). *Digital Design and Computer Architecture: RISC-V Edition*. Morgan Kaufmann.
