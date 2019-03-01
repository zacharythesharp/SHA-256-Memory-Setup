# SHA-256 Memory Setup

**Abstract**
SHA, or Secure Hash Algorithm, is part of a large family of cryptographic hash
functions. This hash function acts as a unique identification for pieces of data. No two
pieces of data will share the same hash. Hashing acts as a one way function, in that once
the data is encrypted, it cannot be returned to the original format. Such characteristics
allow these algorithms to be useful in many scenarios including but not limited to
authentication, password validation, and anti-tamper mechanisms.
There have been many iteration of the SHA algorithms. The scope of this project
revolves around the SHA-2 family, more specifically SHA-256. SHA-256 has a wide
variety of applications. Because it outputs data in 256 bit chunks, it is used in Debian
package authentication, cryptocurrency transaction validation, and many standardized
U.S. Government applications. The SHA-2 family is becoming a bit out-of-date, in that
with each passing year, it becomes more prone to data length attacks, and in the next few
years, the next family, SHA-3, will be adopted as the new standard.

**Introduction**
The scope of this project delves into creating into a simplified version of the
SHA-256 algorithm. In order to simplify the algorithm, constraints were given in order to
produce an output that was only 512 bits long. The message size was also limited
between 1 and 55 characters in order to not exceed this output size. In order to further
simplify the project, the purpose here was to read in and get data ready in order to
perform the hash algorithms; however, the scope of this project does not involve
performing the has itself.
This project was coded in Verilog and compiled with SystemVerilog. It was
simulated with test benches on Modelsim and synthesized with Synopsys 2015.

Inside the 'Projects' folder, you will find three subfolders.

1. results: contains the final cell reports and timiing constraints
2. synth: contains the synthesized design parameters and constraints
3. v: contains the source and reference files

**Source Files**
MyDesign.v - this file contains the majority of the source code
sram.v - verilog file used to simulate a memory module
ece_564_project_tb_top.v - test module used to simulate code
.dat files - message files imported in the simulation to test the system
