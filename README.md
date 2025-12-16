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

Nexys A7 FPGA Board
![alt text](http://url/to/img.png)

INSERT IMAGE OF Monitor

<br />

**Project in Vivado and Nexys Board:**
- A summary of the steps to get the project to work in Vivado and on the Nexys board (5 points of the Submission category)

Inputs and Outputs:
- Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category)
- As part of this category, if using starter code of some kind (discussed below), you should add at least one input and at least one output appropriate to your project to demonstrate your understanding of modifying the ports of your various architectures and components in VHDL as well as the separate .xdc constraints file.

<br />

**Project in Action:**  
- Images and/or videos of the project in action interspersed throughout to provide context (10 points of the Submission category)

<br />

**Modifications:**
- “Modifications” (15 points of the Submission category)
- If building on an existing lab or expansive starter code of some kind, describe your “modifications” – the changes made to that starter code to improve the code, create entirely new functionalities, etc. Unless you were starting from one of the labs, please share any starter code used as well, including crediting the creator(s) of any code used. It is perfectly ok to start with a lab or other code you find as a baseline, but you will be judged on your contributions on top of that pre-existing code!
- If you truly created your code/project from scratch, summarize that process here in place of the above.

<br />

**Process:**
- Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)

<br />
