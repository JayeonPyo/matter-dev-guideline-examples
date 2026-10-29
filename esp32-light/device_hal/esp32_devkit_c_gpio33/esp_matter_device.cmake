cmake_minimum_required(VERSION 3.5)
if (NOT ("${IDF_TARGET}" STREQUAL "esp32" ))
    message(FATAL_ERROR "please set esp32 as the IDF_TARGET using 'idf.py set-target esp32'")
endif()

# esp-matter의 esp32_devkit_c 프로필에서 LED 핀만 GPIO5 → GPIO33으로 바꾼 프로필.
# device 컴포넌트(esp-matter device_hal/device)는 SRC_DIRS "${device_type}"을 컴파일하므로,
# 이 폴더의 device.c가 빌드되도록 절대 경로를 넘긴다.
SET(device_type     "${CMAKE_CURRENT_LIST_DIR}")
SET(led_type        gpio)
SET(button_type     iot)

SET(extra_components_dirs_append    "$ENV{ESP_MATTER_PATH}/device_hal/led_driver"
                                    "$ENV{ESP_MATTER_PATH}/device_hal/button_driver/iot_button")
