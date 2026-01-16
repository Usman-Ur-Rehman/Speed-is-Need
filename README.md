# Speed-is-Need
Speed-is-Need is a car racing game developed in x86 assembly for DOS as part of an academic project. It was built to gain hands-on experience with machine-level programming and direct hardware interaction. The game operates in text-mode video memory, with all logic and rendering implemented without using any high-level libraries.

## overview
The game runs in text-mode video memory and interacts directly with hardware using BIOS and interrupt routines.  
All game logic, rendering, and input handling are implemented without any high-level libraries.

## purpose
The main goal of this project is to practice:
- machine-level programming
- direct video memory manipulation
- keyboard and timer interrupt handling
- basic game logic in assembly language

## platform
- DOS environment  
- x86 (16-bit) assembly  
- built and tested using NASM in DOSBox / emu8086

## how to run
1. assemble the source code using NASM:  
   `nasm -f bin speed-is-need.asm -o speed-is-need.com`
2. run the generated executable inside DOSBox
3. use arrow keys to control the car

## controls
- left arrow: move car left  
- right arrow: move car right  
- p: pause game  
- r: resume game  
- esc: exit game

## license
This project is provided for educational purposes only. It is intended to demonstrate low-level programming and assembly game development in a DOS environment. You may freely use it for learning or reference, but not for commercial purposes.

## credits
Developed as part of a system-level programming assignment.
