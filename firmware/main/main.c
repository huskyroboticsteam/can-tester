#include <freertos/FreeRTOS.h>
#include <stdio.h>
#include <string.h>

#include "CAN26.h"
#include "bridge.h"
#include "esp_log.h"
#include "test.h"

#define TAG "MAIN"

// our own UUID and domains
static CANDevice_t this_device = {
    .peripheralDomain = 1,
    .motorDomain = 1,
    .powerDomain = 0,
    .deviceUUID = CAN_UUID_DEBUG1,
};

void app_main(void) {
    // initialize CAN
    if (CANInit(NULL, &this_device)) {
        ESP_LOGE(TAG, "CAN init failed");
        return;
    }

    QueueHandle_t uart_q;
    if (bridge_init(&uart_q) != BR_OK) {
        ESP_LOGE(TAG, "Bridge init failed");
        return;
    }

    send_tests(this_device.deviceUUID);

    CANPacket_t rx_packet;
    while (1) {
        // forward CAN packets to computer
        if (CANPollAndReceive(NULL, &rx_packet) == 1) {
            log_packet(&rx_packet);
            if (bridge_tx(&rx_packet) != BR_OK)
                ESP_LOGE(TAG, "Bridge TX error");
        }

        // TODO: forward CAN packets to CAN bus

        vTaskDelay(5);
    }
}
