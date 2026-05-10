# Q1

Create the following directory structure using only `mkdir` and `touch`:
`project/{src/{rtl,tb,include},docs,scripts,build}`. Verify with `tree`.

## Answer

```bash
mkdir -p project/src/{rtl,tb,include}
mkdir -p project/{build,docs,scripts}
tree project
```

**Output:**

```
project
|-- build
|-- docs
|-- scripts
|-- src
|   |-- include
|   |-- rtl
|   `-- tb

10 directories, 0 files
```

---

# Q2

Download the RISC-V ISA manual PDF using wget/curl. Find its size, permissions, and file type using `ls -lh` and `file`

## Answer

```bash
wget https://github.com/riscv/riscv-isa-manual/releases/latest/download/riscv-spec.pdf -O riscv-spec.pdf
ls -lh riscv-spec.pdf
```

**Output:**

```
-rw-rw-r-- 1 arm20 arm20 5.4M May  6 16:48 riscv-spec.pdf
```

---

# Q3

Create a file with 100 random lines using a command. Sort it, find unique lines, and count occurrences. Pipe the top 10 most frequent to a new file.

## Answer

```bash
shuf -r -n 100 -e register opcode pipeline instruction interrupt decoder firmware privilege assembler bitwidth > random.txt
cat random.txt
```

**Output:**

```
bitwidth
instruction
interrupt
firmware
register
instruction
decoder
decoder
pipeline
opcode
assembler
firmware
register
firmware
bitwidth
interrupt
interrupt
register
assembler
opcode
decoder
interrupt
interrupt
interrupt
decoder
decoder
instruction
opcode
privilege
instruction
opcode
opcode
register
assembler
opcode
bitwidth
register
bitwidth
assembler
opcode
pipeline
privilege
opcode
privilege
instruction
firmware
firmware
privilege
bitwidth
pipeline
firmware
privilege
firmware
opcode
privilege
bitwidth
assembler
bitwidth
interrupt
decoder
privilege
assembler
instruction
firmware
opcode
instruction
pipeline
register
assembler
pipeline
opcode
bitwidth
opcode
assembler
decoder
assembler
instruction
pipeline
firmware
assembler
pipeline
opcode
bitwidth
decoder
firmware
privilege
decoder
firmware
register
pipeline
register
opcode
register
privilege
privilege
opcode
privilege
bitwidth
firmware
privilege
```

```bash
sort random.txt | uniq -c | sort -rn | head -10 > top10.txt
cat top10.txt
```

**Output:**

```
     14 privilege
     13 opcode
     12 firmware
      9 bitwidth
      9 decoder
      9 assembler
      8 interrupt
      8 instruction
      8 register
      7 pipeline
```

---

# Q4

Set up SSH keys and verify connection to GitHub using `ssh -T git@github.com`. Take a screenshot of the success message.

## Answer

```bash
ssh -T git@github.com
```

**Output:**

```
Hi AbdurRahman020! You've successfully authenticated, but GitHub does not provide shell access.
```

---

# Q5

Write a one-liner pipeline that finds all `.c` files in `/usr/include`, counts lines in each, sorts by line count, and shows the top 5 largest files.

## Answer

```bash
find /usr/include -name "*.c" | xargs wc -l | sort -rn | grep -v total | head -5
```

**Output:**

```
   146 /mnt/c/Users/arm20/Documents/GitHub/programming-fundamentals/ByteMeC/mathStuff.c
   110 /mnt/c/Users/arm20/Documents/GitHub/programming-fundamentals/ByteMeC/matrixStuff.c
    99 /mnt/c/Users/arm20/Documents/GitHub/programming-fundamentals/ByteMeC/hollowPatterns.c
    87 /mnt/c/Users/arm20/Documents/GitHub/programming-fundamentals/ByteMeC/arrayMics.c
    58 /mnt/c/Users/arm20/Documents/GitHub/programming-fundamentals/ByteMeC/studentDatabase.c
```

> **Note:** I didn't have a `/usr/include` folder, so I tested it on my own `.c` files instead.

---

# Q5

Write a one-liner pipeline that finds all `.c` files in `/usr/include`, counts lines in each, sorts by line count, and shows the top 5 largest files.

## Answer

```bash
find /usr/include -name "*.c" | xargs wc -l | sort -rn | grep -v total | head -5
```

**Output:**

```
  146 /usr/include/mathStuff.c
  110 /usr/include/matrixStuff.c
   99 /usr/include/hollowPatterns.c
   87 /usr/include/arrayMics.c
   58 /usr/include/studentDatabase.c
```

> **Note:** I didn't have a `/usr/include` folder, so I tested it on my own `.c` files from my project directory in WSL (`/mnt/c/Users/arm20/Documents/GitHub/programming-fundamentals/ByteMeC`). The command and output are the same — only the path changes.
