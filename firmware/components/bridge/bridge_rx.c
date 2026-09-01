#include "bridge.h"
#include "esp_log.h"
#include "esp_rom_crc.h"
#include "util.h"

// Track the index of frames that we receive so we can detect dropped frames
static uint8_t rx_frame_index = 0;

// Hold partially-received UART frames
static uart_frame_t u_frame;                     // continuous memory region that can be parsed as a UART frame
static uint8_t* buf = (uint8_t*)(&u_frame);      // a pointer that treats this as a 14-byte buffer
static uint8_t buf_size = sizeof(uart_frame_t);  // size of a full UART frame
static uint8_t head = 0;                         // new bytes should be written at this index

// If the first byte doesn't match the UART frame start code, search the rest of
// the frame for a match. If a match is found, shift the remaining bytes left so
// that index 0 holds a start byte. If a match isn't found, reset the buffer. This
// only happens when data is corrupted, so the byte-shifting cost is negligible.
// TODO: consider using a circular buffer
static void buf_find_start() {
    uint8_t start_idx = 1;

    while (buf[start_idx] != BR_FRAME_START && start_idx < head)
        start_idx++;

    if (start_idx >= head) {
        head = 0;  // frame start code not found; reset buffer
    }

    if (start_idx > 0) {
        // frame start code found; move it to index 0 and shift the remaining bytes left
        int i = 0;
        while ((start_idx + i) < buf_size) {
            buf[i] = buf[start_idx + i];
            i++;
        }

        head = i;
    }
}

bridge_ret_t bridge_rx(CANPacket_t* packet) {
    int bytes_read = uart_read_bytes(UART_NUM, buf + head, buf_size - head, 0);
    if (bytes_read < 0)
        return BR_ERR;

    // check if we have a full UART frame
    head += bytes_read;
    if (head < buf_size)
        return BR_NO_DATA;

    // check for the UART frame start code and for a passing CRC
    uint8_t crc = esp_rom_crc8_le(0, buf, buf_size - 1);
    if (buf[0] != BR_FRAME_START || crc != buf[buf_size - 1]) {
        buf_find_start();
        return BR_DATA_CORRUPTED;
    }

    // assemble a CAN packet
    uint16_t id = (uint16_t)u_frame.id_lo_bits;
    id |= ((uint16_t)(u_frame.id_hi_bits)) << 8;

    packet->device.peripheralDomain = u_frame.id_lo_bits & 0x1;
    packet->device.motorDomain = u_frame.id_lo_bits & 0x2;
    packet->device.powerDomain = u_frame.id_lo_bits & 0x4;
    packet->device.deviceUUID = id & 0x3F8;

    packet->priority = (id >> 10) & 0x1;
    packet->contentsLength = u_frame.content_len;
    packet->command = u_frame.command;
    packet->senderUUID = u_frame.sender_uuid;

    memcpy(packet->contents, u_frame.contents, 6);

    return BR_OK;
}
