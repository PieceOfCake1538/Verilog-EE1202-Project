# Verilog-EE1202-Project
This project implements a fully synchronous, parameterized N-bit Successive Approximation Register (SAR) logic controller in Verilog. The SAR logic is the core digital control unit used inside a SAR Analog-to-Digital Converter (ADC), performing a binary-search-based conversion of an analog input to an N-bit digital value.

The design resolves one bit per clock cycle, starting from the MSB and progressing to the LSB, using comparator feedback to decide each bit. A complete, self-checking testbench is provided to verify correctness.

This project was created as part of the Digital Circuits course project at IIT Hyderabad.
