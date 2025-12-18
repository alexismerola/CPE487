# 2048 in VHDL
### Jordan Doles and Alexis Merola

<br />

**Expected Behavior:**

The project implements the game 2048 entirely in hardware on the Nexys A7 FPGA and outputs the game visually through a VGA monitor.

When powered on, the system displays a 4x4 grid representing the 2048 game board. Once the game has begun (by clicking the BTNC) a box with a value of 2 will appear on the screen. The player interacts with the game using the on-board push buttons. Pressing BTNU for up, BTND for down, BTNL for left, or BTNR for right will cause all the tiles to slide in the corresponding direction

Tile movement follows the standard 2048 rules:
- Tiles slide as far as possible in the selected direction.
- Tiles of equal value merge into one tile with double the value.
- Each tile may merge only once per move, enforced using merge-tracking logic.
- If at least one tile moved or merged, a new tile with value 2 is spawned in an empty cell.

All the game state updates occur synchronously on the VGA vertical sync signal, effectively creating a frame-based update system. The system cycles through the states of waiting for input , processing moevement, merging tiles, spawning new tiles, and rendering output.

Pressing the reset button (BTNC) clears the board and starts a new game. The player wins by creating a 2048 tiles and loses if the board fills with no valid moves remaining.

<br />

**Project in Vivado and Nexys Board:**

To run the project in Vivado and on the Nexys board, the following steps are required:
1. Create a new Vivado project called 2048 targeting the Nexys A7 - 100T FPGA
2. Add all VHDL source files, including pong.vhd, bat_n_ball.vhd, clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd, leddec16.vhd, vga_sync.vhd.
3. Add pong.xdc constraints file to the project.
4. Synthesize, implement, and generate the bitstream.
5. Program the Nexys board and connect the VGA output to a monitor.
Once programed, the game runs automatically and responds to user input through the board buttons.

<br />

**Inputs and Outputs:**

- Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category)
- As part of this category, if using starter code of some kind (discussed below), you should add at least one input and at least one output appropriate to your project to demonstrate your understanding of modifying the ports of your various architectures and components in VHDL as well as the separate .xdc constraints file.
We used Lab 6, the pong game as starter code.
Inputs (from Nexys board)
- System clock (100 MHz)
- Push buttons:
  - BTNU: moves tiles up
  - BTND: move tiles down
  - BTNL: move tiles left
  - BTNR: move tiles right
  - Reset button: restart the game

Outputs (to Nexys board)
- VGA RGB signals (4 bits each for red, green, blue)
- VGA horizontal and vertical sync signals
- Optional 7-segment display output (connected in top-level module)
  

<br />

**Project in Action:**  

- Images and/or videos of the project in action interspersed throughout to provide context (10 points of the Submission category)
When running on hardware, the VGA monitor displays the 2048 grid with colored tiles representing different values. Pressing a direction button causes the tiles to slide and merge smoothly on the next screen refresh. Resetting the board visibly clears all tiles and spawns a new starting tile.

<br />

**Modifications:**

- “Modifications” (15 points of the Submission category)
- If building on an existing lab or expansive starter code of some kind, describe your “modifications” – the changes made to that starter code to improve the code, create entirely new functionalities, etc. Unless you were starting from one of the labs, please share any starter code used as well, including crediting the creator(s) of any code used. It is perfectly ok to start with a lab or other code you find as a baseline, but you will be judged on your contributions on top of that pre-existing code!
- If you truly created your code/project from scratch, summarize that process here in place of the above.

This project was built on top of the Pong Lab starter code. Major modifications include:
- Replacing ball and paddle logic with a 4×4 tile grid structure
- Adding full 2048 movement and merge logic in hardware
- Implementing merge tracking to prevent multiple merges per move
- Introducing a move-rate limiter to prevent repeated button presses
- Adding tile spawning logic after valid moves
- Replacing simple color output with value-based tile coloring
- Synchronizing all updates with the VGA vertical sync signal
These changes transformed a simple Pong display into a complete grid-based game with nontrivial state management.

<br />

**Process:**

- Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)

This project was completed as a team effort. Resoonisibilites were dirvided up between differnet pieces of the game. Both of us worked on creating the array and setting up the game board. Alexis implemented the movement logic and spawning of new tiles. Jordan added the colors to each different box value 2 through 2048. 

In order to implement our design we first began brainstorming how to create this project. We decided to use the Lab 6 pong game as our base code. We were able to turn the bat from the pong game into our game board by stopping it from moving, extending it across the entire screen, and dupublicating it in both horizontal and vertical directions using constants until 16 boxes were shown on the screen. This is done in the batdraw process.



Major challenges included implementing correct merge behavior and preventing unintended repeated movements from button presses. These issues were resolved by adding merge flags and a move counter synchronized with the frame update.

<br />
