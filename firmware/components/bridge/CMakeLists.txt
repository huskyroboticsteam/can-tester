idf_component_register(SRCS "bridge.c" "bridge_rx.c" "bridge_tx.c" "util.c"
                    REQUIRES can26 esp_driver_uart
                    INCLUDE_DIRS ".")