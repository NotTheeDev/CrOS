#include "screen.h"
#include "ports.h"
//#include "../kernel/util.h"

// Predefines the function so compiler would do bad stuff!
int get_cursor_offset();
void set_cursor_offset();
int print_char(char character, int col, int row, char attribute);
int get_offset(int col, int row);
int get_offset_row(int offset);
int get_offset_col(int offset);

/*
*********************************************
* Public screen functions                   *
*********************************************
*/

void print_at(const char* message, int col, int row) {
    int offset;
    if (col >= 0 && row >= 0)
        offset = get_offset(col, row);
    else {
        offset = get_cursor_offset();
        
        row = get_offset_row(offset);
        col = get_offset_col(offset);
    }

    int i = 0;
    while (*message != 0) {
        offset = print_char(*message++, col, row, WHITE_ON_BLACK);

        row = get_offset_row(offset);
        col = get_offset_col(offset);
    }
}

void print(char *message) {
    print_at(message, -1, -1);
}

void clear_screen() {
    int screen_size = MAX_COLS * MAX_ROWS;
    int i;

    char *screen = (char *)VIDEO_ADDRESS;

    for (i = 0; i < screen_size; i++) {
        screen[i * 2] = ' ';
        screen[i * 2 + 1] = WHITE_ON_BLACK;
    }

    set_cursor_offset(get_offset(0, 0));
}

/*
*********************************************
* Private screen functions                  *
*********************************************
*/

int print_char(char character, int col, int row, char attribute) {
    unsigned char *vidmem = (unsigned char*) VIDEO_ADDRESS;
    if (!attribute) { attribute = WHITE_ON_BLACK; }

    if (col >= MAX_COLS || row >= MAX_ROWS) {
        vidmem[2 * (MAX_COLS) * (MAX_ROWS) - 2] = 'E';
        vidmem[2 * (MAX_COLS) * (MAX_ROWS) - 1] = RED_ON_WHITE;
    }

    int offset;
    if (col >= 0 && row >= 0) {
        offset = get_offset(col, row);
    } else {
        offset = get_cursor_offset();
    }

    if (character == '\n') {
        row = get_offset_row(offset);
        offset = get_offset(0, row + 1);
    } else {
        vidmem[offset] = character;
        vidmem[offset + 1] = attribute;

        offset += 2;
    }

    set_cursor_offset(offset);
    return offset;
}

int get_cursor_offset() {
    port_byte_out(REG_SCREEN_CTRL, 14);
    int offset = port_word_in(REG_SCREEN_DATA) << 8;
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);
    return offset * 2;
}

void set_cursor_offset(int offset) {
    offset /= 2;

    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

int get_offset(int col, int row) { return 2 * (row * MAX_COLS + col); }
int get_offset_row(int offset) { return offset / (2 * MAX_COLS); }
int get_offset_col(int offset) { return (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2; }
