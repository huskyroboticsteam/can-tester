#include "bridge.h"
#include "util.h"

// A ring buffer stores bytes read from UART
#define BUF_SIZE 50
static uint8_t buf[BUF_SIZE];
static uint8_t head = 0;
static uint8_t tail = 0;

// Track the index of frames that we receive so we can detect dropped frames
static uint8_t rx_frame_index = 0;

bridge_ret_t bridge_rx(CANPacket_t* packet) {
    return BR_NO_DATA;
}
