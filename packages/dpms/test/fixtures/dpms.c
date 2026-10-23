// SPDX-License-Identifier: MIT
#include <stdbool.h>
#include <stdint.h>

static int32_t available = 1;
static int32_t mode = 1;
static int32_t get_error;
static int32_t set_error;

void dpms_test_configure(int32_t supported, int32_t read_error, int32_t write_error) {
    available = supported;
    get_error = read_error;
    set_error = write_error;
}

#ifndef DPMS_TEST_MISSING_SYMBOLS
int32_t flutterpi_dpms_is_available(void) {
    return available;
}

int32_t flutterpi_dpms_get(void) {
    return get_error == 0 ? mode : -get_error;
}

int32_t flutterpi_dpms_set(bool enabled) {
    if (set_error != 0) return set_error;
    mode = enabled ? 1 : 0;
    return 0;
}
#endif
