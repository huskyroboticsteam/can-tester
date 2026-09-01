#pragma once

#include <freertos/FreeRTOS.h>

#include "CAN26.h"

typedef enum bridge_ret_codes_ {
    BR_ERR = 0,
    BR_OK = 1,
    BR_NO_DATA,
    BR_BAD_PACKET,
    BR_DATA_CORRUPTED,
} bridge_ret_t;

// Initialize the bridge (UART-only currently)
bridge_ret_t bridge_init(QueueHandle_t* queue);

// Send a packet to the computer
bridge_ret_t bridge_tx(const CANPacket_t* packet);

// Read in bytes until a full frame is received from the computer
bridge_ret_t bridge_rx(CANPacket_t* packet);
