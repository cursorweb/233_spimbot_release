int main() {
    // Initialize bot
    *ANGLE = -90;
    *ANGLE_CONTROL = 1;
    *VELOCITY = 0;

    // YOUR CODE GOES HERE
    int turns_remaining = 8;
    *VELOCITY = 10;

    while (turns_remaining > 0) {
        turns_remaining--;

        *ANGLE = 90;
        *ANGLE_CONTROL = 0;

        if (turns_remaining != 3) {
            // Continue at 90 degrees
        } else {
            *ANGLE = -90;
            *ANGLE_CONTROL = 0;
        }

        // cover 10 tiles
        int stop_time = *TIMER + 10000 * 8;
        *TIMER = stop_time;

        // while (has_timer == 0)
        while (has_timer == 0) {
            // wait for timer interrupt
        }

        has_timer = 0;
    }

    *VELOCITY = 0;

    while (true) {
        // idle
    }
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