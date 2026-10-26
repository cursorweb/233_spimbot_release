/*
printf:
move $a0, xy
move $a1, xy
jal print_xy
*/

int main() {
    enable_interrupts();

    // Initialize bot
    *ANGLE = -90;
    *ANGLE_CONTROL = 1;
    *VELOCITY = 0;

    // YOUR CODE GOES HERE
    map = load_map();
    int num = request_puzzle();
    solve_puzzle(num);
    move_best();

    while (true) {
        // idle
    }
}

void move_best() {
    int loc = *BASE_LOCATION;
    // convert to tile coordinates
    int x = (loc >> 16) / 10;
    int y = (loc & 0xFFFF) / 10;

    int bestA = 0, bestW = 0, bestH = 0, bestdx = 1, bestdy = 1;

    for (int dir = 0; dir < 4; ++dir) {
        // 10 means up = 1, right = 0
        int dx = (dir & 1) ? -1 : 1; // 1 - 2 * (dir & 1)
        int dy = (dir & 2) ? -1 : 1; // 1 - 2 * ((dir >> 1) & 1);
        
        int minh = 1000;

        // go left to right, and then go down, and see how far you can go before hit a wall
        // find the minumum how far you can go
        for (int i = 0; i < 30; ++i) {
            // currx
            if (is_blocked(x + i * dx, y)) break;

            int h = 0;
            while (!is_blocked(x + i * dx, y + h * dy)) h++;
            if (h < minh) minh = h;

            // W is inclusive (steps to take)
            int W = i;
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

    // assume bestA != 0
    // if (bestA == 0) return;

    move_bot(bestdx, 0, bestW);
    move_bot(0, bestdy, bestH - 1);
    move_bot(-bestdx, 0, bestW);
    move_bot(0, -bestdy, bestH - 2); // avoid trying to go too far up
}

bool is_blocked(int x, int y) {
    if (x < 0 || x >= 30 || y < 0 || y >= 30) return true;
    // 4th bit is wall checker
    return (map[y * 30 + x] & 0x10) != 0;
}

void move_bot(int dx, int dy, int n) {
    int angle;
    if (dx != 0) {
        // horizontal (0 or 180)
        angle = (dx > 0) ? 0 : 180;
        // angle = (dx < 0) * 180;
    } else {
        // vertical (-90 or 90)
        angle = (dy > 0) ? 90 : -90;
        // angle = 90 - 180 * (dy < 0);
    }

    *ANGLE = angle;
    *ANGLE_CONTROL = 1; // absolute

    (char)has_timer = 0;
    // 1 tile every 10,000 cycles at vel=10
    *TIMER = *TIMER + n * 10'000;

    *VELOCITY = 10;

    while (has_timer == 0) {
        // get paint
        // int num = request_puzzle();
        // solve_puzzle(num);
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