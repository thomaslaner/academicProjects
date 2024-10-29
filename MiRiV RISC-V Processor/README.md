# MiRiV RISC-V Processor

## Project Overview
This project was developed as part of a course at the Technical University of Vienna on digital design and computer architecture. The focus was on creating a minimal RISC-V processor, **MiRiV**, using VHDL. The project demonstrates competencies in processor design, pipeline architecture, memory management, and hazard resolution.

**Note**: As a university project, MiRiV is a learning exercise and is not a production-ready implementation. Users are encouraged to explore the code, identify bugs, and make improvements as they see fit!

## Key Features

- **RISC-V Instruction Set Implementation**: The processor supports a subset of the RISC-V instruction set, demonstrating knowledge in ISA implementation and adherence to industry standards.
- **Pipeline Architecture**: Implements a multi-stage pipeline, including fetch, decode, execute, memory, and write-back stages, illustrating an understanding of data flow within modern processor architectures.
- **Cache and Memory Management**: Integrated a memory system with caching to improve processing efficiency, utilizing direct-mapped and associative caching.
- **Hazard Resolution**: Developed hazard detection and resolution mechanisms, including data forwarding and branch handling, to maintain pipeline efficiency and prevent data hazards.
- **Simulation and Verification**: Verified each module with comprehensive testbenches and simulations, ensuring reliable performance and accurate functionality.

## Contents of the MiRiV Folder

- **quartus/**: Contains the project files needed to synthesize and configure the MiRiV processor on an FPGA, demonstrating proficiency in FPGA-based development workflows.
- **sim/**: Includes simulation files, testbenches, and scripts used to verify the functionality of the processor components, showcasing skills in testing and validation of digital designs.
- **software/**: Assembly and C programs written to test and demonstrate the capabilities of the MiRiV processor, reflecting practical experience with software-hardware integration.
- **test/**: Contains files for verifying the functionality of individual modules in the processor, ensuring reliability and modular testing.
- **vhdl/**: The primary VHDL source files for the MiRiV processor, covering various modules and demonstrating a strong foundation in VHDL and digital design principles.

## Running Tests
   - Tests are located in the `test` folder. Each test folder includes a Makefile with targets for compilation and simulation (`compile`, `clean`, and `sim`).
   - Tests cover functionality for each component and end-to-end operations.

## Tools
   - **Quartus**: Used for synthesizing and configuring the processor on an FPGA.
   - **ModelSim**: Used for simulation and verification of the processor modules.

## Contributors
- [Thomas Laner](https://github.com/thomaslaner)
- [Manuel Oberbacher](https://github.com/mnlbrb)