#pragma once

#include "stdint.h"
#include "driver/uart.h"
#include "CAN26.h"

#define TAG "BR"

#define UART_NUM UART_NUM_2
#define UART_TX_PIN 1
#define UART_RX_PIN 3

#define BR_FRAME_START 0xF0

uint16_t serialize_id(const CANPacket_t* packet);

struct uart_frame {
    uint8_t start;
    uint8_t index;
    uint8_t id_hi_bits;
    uint8_t id_lo_bits;
    uint8_t content_len;
    uint8_t command;
    uint8_t sender_uuid;
    uint8_t contents[6];
    uint8_t crc;
};
