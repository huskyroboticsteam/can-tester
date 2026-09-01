#pragma once

#include "CAN26.h"
#include "driver/uart.h"
#include "stdint.h"

#define TAG "BR"

// UART parameters
#define UART_NUM UART_NUM_0
#define UART_TX_PIN 1
#define UART_RX_PIN 3

// UART frame start code / delimeter
#define BR_FRAME_START 0xF0

// Convert a CAN packet device ID into an 11-bit representation
uint16_t serialize_id(const CANPacket_t* packet);

// Data frame that carries a CAN packet over UART.
// This should form a continuous array of 14 bytes.
typedef struct uart_frame {
    uint8_t start;        // frame delimeter (code: BR_FRAME_START)
    uint8_t index;        // index for receiver to use to detect dropped frames
    uint8_t id_hi_bits;   // device ID higher-order bits
    uint8_t id_lo_bits;   // device ID lower-order bits
    uint8_t content_len;  // content length (DLC - 2)
    uint8_t command;      // command ID
    uint8_t sender_uuid;  // sender UUID
    uint8_t contents[6];  // contents
    uint8_t crc;          // CRC8 hash
} uart_frame_t;
