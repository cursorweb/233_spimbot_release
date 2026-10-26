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
    for (int i = 0; i < 10; ++i) {
        move_best();
        solve_puzzle(request_puzzle());
    }

    while (true) {
        // idle
    }
}

char dx[4] = {1, 0, -1, 0};
char dy[4] = {0, 1, 0, -1};
char dir = 0; // 0 1 2 3

void move_best() {
    int x = BOT_X / 10;
    int y = BOT_Y / 10;

    for (int k = 0; k < 4; k++) {
        int d = (dir + k) % 4; // forward (x % 4 == x & 3)
        int s = (d + 1) % 4; // sideways (clockwise)
        int b = (d + 2) % 4; // back

        int fx = dx[d], fy = dy[d];
        int sx = dx[s], sy = dy[s];

        /*
        M 1 2
        M   3
        M 5 4
        */
        if (!is_blocked(x + fx,          y + fy) &&
            !is_blocked(x + 2*fx,        y + 2*fy) &&
            !is_blocked(x + 2*fx + sx,   y + 2*fy + sy) &&
            !is_blocked(x + 2*fx + 2*sx, y + 2*fy + 2*sy) &&
            !is_blocked(x + fx + 2*sx,   y + fy + 2*sy)) {
            move_bot(d * 90, 2); 
            move_bot(s * 90, 2);
            move_bot(b * 90, 2);
            move_bot(((s + 2) % 4) * 90, 2);
            // ((s + 2) & 3) * 90
            dir = d;
            return;
        }
    }
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