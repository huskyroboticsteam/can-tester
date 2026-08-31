#include <freertos/FreeRTOS.h>
#include <stdio.h>
#include <string.h>

#include "CAN26.h"
#include "esp_log.h"
#include "test.h"

#define TAG "MAIN"

// our own UUID and domains
static CANDevice_t this_device = {
    .peripheralDomain = 1,
    .motorDomain = 1,
    .powerDomain = 0,
    .deviceUUID = 0b1111110,
};

void app_main(void) {
    // initialize CAN
    if (CANInit(NULL, &this_device)) {
        ESP_LOGE(TAG, "Failed to initialize CAN");
        return;
    }

    // send test packets
    send_tests(this_device.deviceUUID);

    // listen for packets
    CANPacket_t rx_packet;
    while (1) {
        vTaskDelay(5);
        if (CANPollAndReceive(NULL, &rx_packet) == 1)
            log_packet(&rx_packet);
    }
}
