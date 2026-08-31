#pragma once

#include "CAN26.h"

void log_packet(const CANPacket_t* p);
void send_tests(CANDeviceUUID_t our_uuid);
