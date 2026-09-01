#include "test.h"

#include "esp_log.h"

#define TAG "TEST"

// Log a CAN packet in a human-readable format
void log_packet(const CANPacket_t* p) {
    if (!p) {
        ESP_LOGI(TAG, "<NULL>");
        return;
    }

    ESP_LOGI(
        TAG,
        "[CAN]\n  per: %u\n  mot: %u\n  pow: %u\n  uuid: 0x%02X\ncmd: %d\nsender: 0x%02X\ndata(%d): { %02d %02d %02d %02d %02d %02d }",
        (unsigned)p->device.peripheralDomain,
        (unsigned)p->device.motorDomain,
        (unsigned)p->device.powerDomain,
        (unsigned)p->device.deviceUUID,
        (unsigned)p->command,
        (unsigned)p->senderUUID,
        (unsigned)p->contentsLength,
        p->contents[0], p->contents[1], p->contents[2],
        p->contents[3], p->contents[4], p->contents[5]);
}

// Send 4 CAN packets that should be accepted (in loopback mode),
// and send 2 CAN packets that should be filtered out.
void send_tests(CANDeviceUUID_t our_uuid) {
    const uint8_t num_test_packets = 6;
    CANPacket_t packets[num_test_packets];

    // populate test packets array with default values
    for (uint8_t i = 0; i < num_test_packets; i++) {
        packets[i] = (CANPacket_t){
            .device = {
                .peripheralDomain = 0,
                .motorDomain = 0,
                .powerDomain = 0,
                .deviceUUID = 0,
            },
            .priority = 0,
            .contentsLength = 6,
            .command = i,  // set unique command
            .senderUUID = our_uuid,
        };
        // set unique contents
        for (uint8_t j = 0; j < packets[i].contentsLength; j++)
            packets[i].contents[j] = (i * 10) + j;
    }

    // ACCEPT: test UUID addressing
    packets[0].device.deviceUUID = our_uuid;

    // ACCEPT: test broadcast
    packets[1].device.peripheralDomain = 1;
    packets[1].device.motorDomain = 1;
    packets[1].device.powerDomain = 1;

    // ACCEPT: test peripheral domain
    packets[2].device.peripheralDomain = 1;

    // ACCEPT: test peripheral and motor domains
    packets[3].device.peripheralDomain = 1;
    packets[3].device.motorDomain = 1;

    // IGNORE: test different UUID
    packets[4].device.deviceUUID = 0b0000001;

    // IGNORE: test different domain
    packets[5].device.powerDomain = 1;

    // send test packets
    for (uint8_t i = 0; i < num_test_packets; i++){
        if(CANSend(NULL, packets + i))
            ESP_LOGE(TAG, "Failed to send packet");
    }
}
