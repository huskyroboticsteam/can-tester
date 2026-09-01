#include "bridge.h"

#include "util.h"

bridge_ret_t bridge_init(QueueHandle_t* queue) {
    // allocate UART drivers and event queue
    esp_err_t ret;
    ret = uart_driver_install(
        UART_NUM,    // controller
        (1024 * 2),  // RX buffer size
        (1024 * 2),  // TX buffer size
        10,          // event queue size
        queue,       // event queue
        0            // intr flags
    );
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "UART driver install err: %d", ret);
        return BR_ERR;
    }

    // config UART
    uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };
    ret = uart_param_config(UART_NUM, &uart_config);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "UART config err: %d", ret);
        ESP_ERROR_CHECK(uart_driver_delete(UART_NUM));
        return BR_ERR;
    }

    // set UART pins
    ret = uart_set_pin(
        UART_NUM,
        UART_TX_PIN,  // TX pin
        UART_RX_PIN,  // RX pin
        UART_PIN_NO_CHANGE,
        UART_PIN_NO_CHANGE,
        UART_PIN_NO_CHANGE,
        UART_PIN_NO_CHANGE);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "UART pin set err: %d", ret);
        ESP_ERROR_CHECK(uart_driver_delete(UART_NUM));
        return BR_ERR;
    }

    return BR_OK;
}
