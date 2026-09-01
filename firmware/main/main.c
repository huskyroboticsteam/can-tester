#include <freertos/FreeRTOS.h>
#include <stdio.h>
#include <string.h>

#include "CAN26.h"
#include "bridge.h"
#include "esp_log.h"
#include "test.h"

#define TAG "MAIN"

// this device's UUID and domains
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

    // initialize bridge
    QueueHandle_t uart_q;  // not used or now
    if (bridge_init(&uart_q) != BR_OK) {
        ESP_LOGE(TAG, "Bridge init failed");
        return;
    }

    // send test CAN packets
    send_tests(this_device.deviceUUID);
    vTaskDelay(5000 / portTICK_PERIOD_MS);  // delay to allow time to start serial monitor

    bridge_ret_t ret;
    CANPacket_t packet;
    while (1) {
        // forward CAN packets to UART
        if (CANPollAndReceive(NULL, &packet) == 1) {
            ret = bridge_tx(&packet);
            if (ret != BR_OK)
                ESP_LOGE(TAG, "Bridge TX err");
        }

        // forward UART frames to CAN bus
        ret = bridge_rx(&packet);
        if (ret == BR_ERR || ret == BR_DATA_CORRUPTED)
            ESP_LOGE(TAG, "Bridge RX err: %d", ret);
        else if (ret == BR_OK)
            CANSend(NULL, &packet);

        vTaskDelay(5);
    }
}
