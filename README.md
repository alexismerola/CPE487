# 2048 in VHDL
### Jordan Doles and Alexis Merola

<br />

**Expected Behavior:**

The project implements the game 2048 entirely in hardware on the Nexys A7 FPGA and outputs the game visually through a VGA monitor.

When powered on, the system displays a 4x4 grid representing the 2048 game board. Once the game begins (by pressing BTNC) a tile with a value of 2 will appear on the board. The player interacts with the game using the on-board push buttons. Pressing BTNU for up, BTND for down, BTNL for left, or BTNR for right will cause all the tiles to slide in the corresponding direction.

Tile movement follows the standard 2048 rules:
- Tiles slide as far as possible in the selected direction.
- Tiles of equal value merge into one tile with double the value.
- Each tile may merge only once per move, enforced using merge-tracking logic.
- If at least one tile moved or merged, a new tile with value 2 is spawned in an empty cell.

All game-state updates occur synchronously on the VGA vertical sync signal, effectively creating a frame-based update system. The system cycles through the following states:
1. Waiting for user input
2. Processing moevement
3. Merging tiles
4. Spawning a new tile
5. Rendering output

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

IMAGES AND VIDEOS HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<br />

**Modifications:**
This project was built on top of the Pong Lab (Lab 6) starter code. Major modifications include:
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

This project was completed as a team effort. Resoonisibilites were divided up between different pieces of the game. Both team members collaborated on creating the tile array and setting up the game board structure. Alexis implemented the movement logic, merge behavior, and tile spawning. Jordan implemented the color mapping for each tile value 2 through 2048. 

Design Evolution:

The project bagan with brainstorming how to adapt the Lab 6 Pong code into a grid-based game. Initially, the Pong bat was repurposed to form the game board by stopping its movement, extending it across the screen, and duplicating it horizontally and vertically using constants until a 4x4 grid (16 boxes) was displayed. This logic was implemented in the batdraw process.

Early attempts at gameplay involved treating a tile as a moving square object. This approach led to issues with speed control, screen boundaries, and overall complexity. As a result, the design shifted to a grid-based array approach, which better matched the rules of 2048.

Array-Based Game Logic:

The core of the game is implemented using a 4x4 array, where each element represents the value stored in one tile location. Each array entry holds a numerical value (powers of 2 for active tiles). This structure allows the entire board state to be updated.

Movement is implemented using nested loops that traverse the array in a direction dependent order. For each move:
- Nonzero tiles are shifted toward the selected direction
- Adjacent tiles with equal values are merged by doubling one value and clearing the other
- A separate merge flag array ensures that each tile can merge only once per move

Tiles are prevented from merging with tiles of different values by explicitly checking equality before any merge operation occurs. If no movement or merge occurs during a button press, no new tile is spawned.

Once a valid move is detected, a new tile with value 2 is spawned in an empty array location. All of these updates occur synchronously on the vertical sync signal.

Value-Based Color Mapping:

To improve usability and visual feedback, the game implements value-based tile coloring using the VGA RGB outputs. Each tile's numberical value stored in the 4x4 array is mapped to a specific color during the VGA rednering process.

The colors given to each tile are:
INSERT IMAGE OF TILE COLORS

The color logic is implemented using conditional checks on each tile's stored value. Based on this value, the VGA red, green,  and blue signals are assigned appropriate intensity levels. Because this logic is driven directly from thegame-state array, tile colors update automatically whenever merges occur.

Challenges and Solutions:

Major challenges included implementing correct merge behavior and preventing unintended repeated movements due to button bounce or long presses. These issues were resolved by:
- Adding merge flags to enforce single merges per tile per move
- Introducing a frame-based move counter synchronized with the VGA refresh
By the end of the project, these solutions resulted in smooth gameplay and a fun game of 2048!

<br />
