# LED Matrix Game

## Project Overview
This project was developed as part of a course focused on microcontroller programming and embedded systems at the technical university of vienna. The objective was to design an interactive game on an LED matrix, where the player controls a character to reach a randomly positioned target using a joystick. The game updates the score in real-time and transmits it via USART to a connected device.

## Game Description
- **Objective**: Move the character (a single pixel) across the LED matrix using the joystick to reach a randomly placed target (two adjacent pixels). Each time the target is reached, the score increases by +1, the target relocates to a new random position, and the updated score is transmitted to the PC.
- **Controls**: The joystick allows movement in the X and Y directions. The character moves continuously in the chosen direction until it reaches the boundary of the LED matrix.
- **Reset Function**: Pressing button B resets the game, placing the character back in the center, initializing a new target, and resetting the score to zero.

## Key Features and Code Structure

### 1. LED Matrix Display Control
   - **Functions**: `init_led_matrix`, `send_word_to_SPI`, `send_same_word_to_all_modules`, `send_current_matrix_to_modules`.
   - **Description**: Initializes and controls the LED matrix display. Functions in this section manage the display updates for the character and target positions using SPI communication.

### 2. Joystick Input Handling
   - **Functions**: `joy_stick_direction`.
   - **Description**: Reads analog joystick input to determine movement direction. The joystick’s X and Y positions are converted into movement commands, which are then used to adjust the character’s position on the LED matrix.

### 3. Random Target Generation
   - **Functions**: `new_rndm_goal_position`.
   - **Description**: Sets a new target position on the LED matrix after each successful target reach. The position is generated using ADC noise to ensure a random location.

### 4. USART Communication for Score Updates
   - **Functions**: `send_uart_data`.
   - **Description**: Sends the current score to a connected PC using USART each time the target is reached, allowing real-time score tracking.

### 5. Interrupt-Driven Logic
   - **Functions**: `TIM2_IRQHandler`.
   - **Description**: Manages game logic using timer interrupts. The interrupt handler checks if the game should be reset, verifies if the character reached the target, updates the score, and triggers character movement based on joystick input.

### 6. Game Logic and Movement
   - **Functions**: `player_movement`, `check_game_over`, `initialize_game`, `add_pos_matrix`, `remove_pos_matrix`.
   - **Description**: Core game logic for movement, collision detection, and initialization. The character moves based on joystick input, boundaries are checked, and positions are added or removed from the LED matrix as needed.

## Requirements
- **Hardware**: LED matrix, joystick, microcontroller, and button B for reset.
- **Development Environment**: STM32 IDE or equivalent, with necessary header files (`stm32f30x_conf.h`) for STM32 microcontrollers.

## Contents of the Project's Folder

- **main.c**: The core implementation code for the HOME-Station LED Matrix Game, handling character movement, joystick input, target generation, and score transmission.
- **stm32f30x_conf.h**: Configuration file for the STM32 microcontroller, setting up necessary parameters and configurations for the project.
- **demo_video.mov**: A demonstration video showing the gameplay of the HOME-Station LED Matrix Game. This video illustrates character movement, target reaching, and other key features in action.
