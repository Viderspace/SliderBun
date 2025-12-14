#include QMK_KEYBOARD_H
#include "slider_bun.h"

// -----------------------------------------------------------------------------
// Keymap
// -----------------------------------------------------------------------------
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
[0] = LAYOUT(
                    KC_0,
        
        KC_1, KC_2, KC_3,
        KC_4, KC_5, KC_6, KC_7
)
};

// -----------------------------------------------------------------------------
// QMK Hooks
// -----------------------------------------------------------------------------
void matrix_init_user(void) {
    slider_init();
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case KC_0:
            if (record->event.pressed) {
                slider_cycle_mode();
            }
            return false;
        
        default:
            return true;
    }
}

void matrix_scan_user(void) {
    slider_update();
}