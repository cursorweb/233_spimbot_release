int main() {
    enable_interrupts();
    map = load_map();

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
            int num = request_puzzle();
            solve_puzzle(num);
        }

        has_timer = 0;
    }

    *VELOCITY = 0;

    while (true) {
        // idle
    }
}

void move_best() {
    int loc = *BASE_LOCATION;
    int x = (loc >> 16) / 10;
    int y = (loc & 0xFFFF) / 10;

    int bestA = 0, bestW = 0, bestH = 0, bestdx = 1, bestdy = 1;

    for (int dir = 0; dir < 4; ++dir) {
        // 10 means up = 1, right = 0
        int dx = (dir & 1) ? -1 : 1;
        int dy = (dir & 2) ? -1 : 1;
        int minh = 1000;

        // go left to right, and then go down, and see how far you can go before hit a wall
        // find the minumum how far you can go
        for (int i = 1; i < 30; ++i) {
            // currx
            if (blocked(x + i * dx, y)) break;

            int h = 0;
            while (!blocked(x + i * dx, y + h * y)) h++;
            if (h < minh) minh = h;

            int W + i;
            int H = minh;

            if (W * H > bestA) {
                bestA = W * H;
                bestW = W;
                bestH = H;
                bestdx = dx;
                bestdy = dy;
            }
        }
    }

    if (bestA == 0) return;

    move(bestdx, 0, bestW - 1);
    move(0, bestdy, bestH - 1);
    move(-bestdx, 0, bestW - 1);
    move(0, -bestdy, bestH - 2);
}

bool is_blocked(int x, int y) {
    if (x < 0 || x >= 30 || y < 0 || y >= 30) return true;
    // 4th bit is wall checker
    return (map[y * 30 + x] & 0x10) != 0;
}

void move_bot(int angle, int n) {
    *ANGLE = angle;
    *ANGLE_CONTROL = 1; // absolute

    (char)has_timer = 0;
    // 1 tile every 10,000 cycles at vel=10
    *TIMER = *TIMER + n * 10'000;

    *VELOCITY = 10;

    while (has_timer == 0) {
        // get paint
        int num = request_puzzle();
        solve_puzzle(num);
    }
    *VELOCITY = 0;
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