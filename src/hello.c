#include <rp6502.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include "controller.h"
#include "sprite.h"

typedef struct Sprite Sprite;
struct Sprite {
    int16_t xpos_px;
    int16_t ypos_py;
    uint16_t xram_img_ptr;
    uint8_t log_size; // always square
    bool has_opacity_metadata;
};

struct {
    uint16_t pixels[8];
} *rows[8];

void main() {    
    Sprite sprite_config;
    uint16_t i;
    uint8_t *bytearray = (uint8_t *) &sprite_config;

    sprite_config.xpos_px = 30;
    sprite_config.ypos_py = 30;
    sprite_config.xram_img_ptr = 0xF000;
    sprite_config.log_size = 3;
    sprite_config.has_opacity_metadata = true;

    RIA_ADDR0 = sprite_config.xram_img_ptr;
    RIA_STEP0 = 1;
    for (i = 0; i < sizeof(sprite_8x8); ++i) {
        RIA_RW0 = sprite_8x8[i];
    }
    RIA_ADDR0 = 0xE000;

    for (i = 0; i < sizeof(sprite_config); ++i) {
        RIA_RW0 = * bytearray++;
    }
    xreg(1, 0, 1);
    xreg(4, 1, 1);
    xreg(0, 2, 1);
    xreg(0, 6, 1);
    xreg(1, 7, 1);
    xreg(0xE000, 8, 1);
    while (true){
        RIA_ADDR0 = 0xE000;
        sprite_config.xpos_px += 1;
        RIA_RW0 = sprite_config.xpos_px & 0x00FF;
        RIA_RW0 = sprite_config.xpos_px >> 8;
        delay();
        delay();
        delay();
        delay();
    }

}