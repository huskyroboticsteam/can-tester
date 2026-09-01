#include "util.h"

// Combine the CAN device UUID, domains, and priority into 2 bytes
uint16_t serialize_id(const CANPacket_t* packet) {
    uint16_t id = packet->device.peripheralDomain;  // perip domain
    id |= packet->device.motorDomain << 1;          // motor domain
    id |= packet->device.powerDomain << 2;          // power domain
    id |= packet->device.deviceUUID << 3;           // UUID
    id |= packet->priority << 10;                   // priority

    return id;
}
