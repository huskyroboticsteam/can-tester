#include "bridge.h"
#include "util.h"
#include "esp_rom_crc.h"

// Each frame is sent with a incrementing index so the receiver can detect dropped frames
static uint8_t tx_frame_index = 0;

bridge_ret_t bridge_tx(const CANPacket_t* packet) {
    if (!packet || packet->contentsLength > 6)
        return BR_BAD_PACKET;

    struct uart_frame u_frame;
    const uint8_t frame_size = sizeof(u_frame);

    u_frame.start = BR_FRAME_START;    // set the frame start code
    u_frame.index = tx_frame_index++;  // set the frame index, then increment it for next time

    const uint16_t can_id = serialize_id(packet);
    u_frame.id_lo_bits = (uint8_t)(can_id & 0xFF);  // set the lower 8 bits of the ID
    u_frame.id_hi_bits = (uint8_t)(can_id >> 8);    // set the higher 8 bits of the ID

    u_frame.content_len = packet->contentsLength;   // set the content length
    u_frame.command = packet->command;              // set the command ID
    u_frame.sender_uuid = packet->senderUUID;       // set the sender UUID
    memcpy(u_frame.contents, packet->contents, 6);  // copy the 6 bytes of content

    // calculate and set the CRC of the frame
    u_frame.crc = esp_rom_crc8_le(0, (uint8_t*)&u_frame, frame_size - 1);

    // send the frame over UART
    return uart_write_bytes(UART_NUM, &u_frame, frame_size) == frame_size ? BR_OK : BR_ERR;
}
