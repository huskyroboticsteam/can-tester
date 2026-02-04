// TODO: comment

#include "app.h"
#include "stm32f1xx_hal.h"
#include "usbd_cdc_if.h"
#include <stdint.h>
#include <string.h>


void RunApp() {
  // setup
  char* tx_buf = "Hello, world!\r\n";
  
  // loop
  while (1) {
    CDC_Transmit_FS(tx_buf, strlen(tx_buf));
    HAL_Delay(1000);
  }
}
