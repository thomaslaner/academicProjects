# FPGA Retro Ball Game

## Project Overview
This project implements a classic arcade-style game on an FPGA, where the player navigates a falling ball through obstacles to avoid collisions and score points. The game leverages VHDL to manage game logic, control inputs, video output, and scoring, delivering a retro gaming experience on a black-and-white display.

## Game Mechanics
- **Objective**: The player guides a falling ball to avoid hitting randomly placed bricks. Points are scored for each avoided brick, and the score is displayed on a seven-segment display.
- **Controls**: An NES controller is used to move the ball left or right.
- **Display**: The game output is rendered on a black-and-white display through a video baseband signal (VBS) generator, creating a classic arcade look.

## Key Features
1. **Game Logic**: The core VHDL modules handle the ball's movement, brick generation, collision detection, and scoring system.
2. **NES Controller Integration**: An interface with an NES controller allows the player to control the ball's movement.
3. **Video Signal Generation**: The VBS controller produces an analog signal compatible with a black-and-white display, showcasing the game’s elements (ball, bricks, background).
4. **Real-Time Scoring**: The player's score is continuously updated on a seven-segment display, providing immediate feedback.

## Project Structure
- **vhdl/**: Contains all VHDL source files, organized by functionality, including:
  - **audio_cntrl/**: Audio control for sound effects.
  - **ball_game/**: Main game logic for ball movement, brick generation, and collision detection.
  - **dbg_port/**: Debugging interface for testing and monitoring signals.
  - **display_switch/**: Manages display states and visual transitions.
  - **lcd_grap_controller/**: Controls graphical output to an LCD.
  - **nes_controller/**: NES controller interface for player input.
  - **ssd_controller/**: Seven-segment display controller for real-time score display.
  - **vbs_grap_controller/**: Video baseband signal generator for analog display output.
  - Additional folders for supporting modules like `math`, `ram`, `prng` (pseudo-random number generator for brick placement), `synchronizer`, and `top` (top-level design integration).

## Setup Instructions
1. **Hardware Requirements**:
   - **FPGA Board**: Ensure compatibility with VHDL and sufficient I/O ports for the NES controller, display, and seven-segment display.
   - **NES Controller**: Connect to the FPGA for player movement.
   - **Display**: A black-and-white display compatible with an analog video input for the VBS output.
   - **Seven-Segment Display**: Connected to show the player’s score.

2. **Compilation and Synthesis**:
   - Use the provided Makefile or your FPGA toolchain (such as Quartus) to compile and synthesize the VHDL code.
   - Ensure that all modules are correctly configured in the toolchain for proper interfacing with the NES controller and display peripherals.

3. **Running the Game**:
   - Load the synthesized bitstream onto the FPGA.
   - Connect the NES controller and display peripherals to the appropriate FPGA I/O ports.
   - Power on the setup and use the NES controller to move the ball, avoid bricks, and accumulate points.

## Design Details
### Game Logic
The game logic is designed to track the position of the ball, generate bricks at random positions, detect collisions, and update the score accordingly. The ball's movement is controlled via the NES controller, allowing the player to dodge incoming bricks in real-time.

### NES Controller Integration
The NES controller interface decodes player input, translating left and right movements into corresponding ball movements on the screen. This integration enables an interactive and responsive gaming experience.

### Video Signal Generation
The VBS graphics controller outputs a video baseband signal, compatible with analog black-and-white displays, to visualize the game. It renders the ball, bricks, and background elements, achieving a retro arcade aesthetic.

### Scoring System
The scoring system increments each time a brick is successfully avoided. The score is displayed on a seven-segment display, providing immediate feedback and enhancing the retro arcade feel.

## Feedback and Improvements
During the evaluation of this project, the following feedback was provided:

1. **Design Modularity**: For better organization and easier testing, it was suggested to break down the design into more submodules.
2. **Deadlock Issue**: The game was found to have a potential deadlock issue under specific conditions.
3. **SignalTap Measurement**: SignalTap measurement was conducted to verify correct behavior of signals and timing within the design.

Based on this feedback, possible future improvements could include modularizing the VHDL code further, and resolving the deadlock issue to improve the robustness of the gameplay experience.