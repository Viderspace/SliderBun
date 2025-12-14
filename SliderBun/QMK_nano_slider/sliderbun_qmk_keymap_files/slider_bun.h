//
// Created by Jonatan Vider on 14/12/2025.
//

#pragma once

#include "smooth_axis.h"
#include "analog.h"
#include "raw_hid.h"
#include "timer.h"

// -----------------------------------------------------------------------------
// Slider Mode Configuration
// -----------------------------------------------------------------------------
typedef enum {
  SLIDER_MODE_VOLUME = 0,
  SLIDER_MODE_BRIGHTNESS,
  SLIDER_MODE_SHORTCUT1,
  SLIDER_MODE_SHORTCUT2,
  SLIDER_MODE_SHORTCUT3,
  SLIDER_MODE_SHORTCUT4,
  SLIDER_MODE_COUNT
} slider_mode_t;

// Command bytes for RAW HID protocol
#define CMD_SET_VOLUME      0x01
#define CMD_SET_BRIGHTNESS  0x02
#define CMD_SHORTCUT1       0x10
#define CMD_SHORTCUT2       0x11
#define CMD_SHORTCUT3       0x12
#define CMD_SHORTCUT4       0x13

// -----------------------------------------------------------------------------
// Internal State
// -----------------------------------------------------------------------------
static smooth_axis_t slider_axis;
static smooth_axis_config_t slider_cfg;
static slider_mode_t slider_mode = SLIDER_MODE_VOLUME;

static const float SLIDER_RESPONSE_TIME_SEC = 1.0f;

// -----------------------------------------------------------------------------
// Helper Functions
// -----------------------------------------------------------------------------
static inline uint32_t slider_now_func(void) {
    return timer_read32();
}

static inline float slider_scale_to_u16(float tenbit) {
    float t = tenbit / 1023.0f;
    return t * 65535.0f;
}

static inline uint8_t slider_mode_to_command(slider_mode_t mode) {
    switch (mode) {
        case SLIDER_MODE_VOLUME:     return CMD_SET_VOLUME;
        case SLIDER_MODE_BRIGHTNESS: return CMD_SET_BRIGHTNESS;
        case SLIDER_MODE_SHORTCUT1:  return CMD_SHORTCUT1;
        case SLIDER_MODE_SHORTCUT2:  return CMD_SHORTCUT2;
        case SLIDER_MODE_SHORTCUT3:  return CMD_SHORTCUT3;
        case SLIDER_MODE_SHORTCUT4:  return CMD_SHORTCUT4;
        default:                     return CMD_SET_VOLUME;
    }
}

static inline void slider_send_packet(uint16_t value_16) {
    uint8_t buf[32] = {0};
    
    buf[0] = slider_mode_to_command(slider_mode);
    buf[1] = 0x00;
    buf[2] = (uint8_t)(value_16 & 0xFF);
    buf[3] = (uint8_t)(value_16 >> 8);
    
    raw_hid_send(buf, sizeof(buf));
}

// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------
static inline void slider_init(void) {
    smooth_axis_config_auto_dt(&slider_cfg, 1023, SLIDER_RESPONSE_TIME_SEC, slider_now_func);
    smooth_axis_init(&slider_axis, &slider_cfg);
}

static inline void slider_update(void) {
    uint16_t raw = 1023 - analogReadPin(SLIDER_PIN);
    
    smooth_axis_update_auto_dt(&slider_axis, raw);
    
    if (smooth_axis_has_new_value(&slider_axis)) {
        uint16_t value_16 = smooth_axis_get_u16(&slider_axis);
        slider_send_packet(slider_scale_to_u16(value_16));
    }
}

static inline void slider_cycle_mode(void) {
    slider_mode = (slider_mode + 1) % SLIDER_MODE_COUNT;
    // Immediately send current value in new mode
    uint16_t value_16 = smooth_axis_get_u16(&slider_axis);
    slider_send_packet(value_16);
}