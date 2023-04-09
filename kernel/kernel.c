// Fix this peace of retardnes i am going to sleep ;)
#include "../drivers/screen.h"

void kmain() {
    const char* msg = "X";
    clear_screen(); // This wants to work
    print_char('X', 1, 1, WHITE_ON_BLACK); // This doesnt want to work
    print_at(msg, 1, 3);
    // Why it doesnt work? Having no idea, and yes I can't use print debug
    // WHEN I DONT HAVE It :)
}
