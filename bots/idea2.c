int main() {
    // start moving bot
    *VELOCITY      = 10;    // set velocity to 10
    *ANGLE         = 90;    // set angle to 90
    *ANGLE_CONTROL = 1;     // set control to absolute (meaning angle of 90 will point down)

    // request timer
    int current_time = *TIMER;               // check current value of timer
    int time_to_stop = current_time + 20000; // time we desire to stop moving at (20000 cycles will move 20 pixels if at velocity 10)
    *TIMER = time_to_stop;                   // timer will interrupt when elapsed cycles == write value
    
    // wait until timer interrupt
    while (has_timer != 0) {
        // We will be interrupted when we have reached [time_to_stop] cycles,
        // so until then, we wait. 
        // (During Lab Spimbot, you may want to do something useful during this time!)
    }

    has_timer = 0;  // reset timer flag to 0  
    *VELOCITY = 0;  // stop moving bot
}

struct LightsOuts {
    int num_rows;
    int num_cols;
    int num_colors;
    unsigned char board[MAX_GRIDSIZE*MAX_GRIDSIZE];
};

int request_puzzle() {
    puzzle_received = false;
    *REQUEST_PUZZLE = &puzzle;
    int puzzle_num = num_puzzles_requested;
    num_puzzles_requested++;

    while (!puzzle_received) {
      // The interrupt handler sets puzzle_received.
    }
    return puzzle_num;
}

bool solve_puzzle(int puzzle_num) {
  zero_board(puzzle.num_rows, puzzle.num_cols, solution);
  bool got_sol = solve(&puzzle, solution, 0, 0); // the greedy solver from Lab 7
  *CURRENT_PUZZLE = puzzle_num;
  *SUBMIT_SOLUTION = solution;
  bool correct = *MMIO_STATUS == 0; // 0 means correct: +4 paint
  return got_sol && correct;
}