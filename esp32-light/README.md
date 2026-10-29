# esp32-light — 10장 예제 (OnLevel 기반 켜짐 밝기, 속성 갱신 예시)

esp-matter `examples/light`(release/v1.4)를 해설서 10.6.2에 맞게 수정한 예제다.

| 파일 | 내용 | 해설서 |
|---|---|---|
| `main/app_main.cpp` | `level_control.on_level = MATTER_BRIGHTNESS` — 켜짐 = 최대 밝기 정책을 **OnLevel 속성**으로 지정 | 표 10-11 (권장안) |
| `main/app_driver.cpp` | 구동부는 켜짐 시 밝기를 정하지 않음. `[HW]` 로그로 구동부 지령을 출력 | 표 10-11 |
| `variants/v3_sync.diff` | (선택) 켜짐 시 `ScheduleWork`로 콜백 밖에서 `attribute::update(CurrentLevel)` | 표 10-12 |
| `device_hal/esp32_devkit_c_gpio33/` | esp-matter `esp32_devkit_c` 장치 프로필에서 LED 핀만 GPIO5 → **GPIO33** | 실습 보드 |
| `CMakeLists.txt` | ESP32 타깃의 기본 장치 프로필을 위 폴더로 지정 | — |

## 준비
- ESP-IDF **v5.4.1**, esp-matter **release/v1.4** 설치(esp-matter 설치 문서 참고)
- 보드: ESP32-DevKitC(ESP32-WROOM-32E 등). GPIO33 → 저항(330Ω 내외) → LED(+) → LED(−) → GND
- 컨트롤러: chip-tool, 2.4GHz WPA2 Wi-Fi

## 빌드 방법
이 폴더를 그대로 빌드해도 되고, esp-matter 예제 폴더에 복사해서 빌드해도 된다. 어느 쪽이든 `ESP_MATTER_PATH`만 설정돼 있으면 된다.

```bash
. $IDF_PATH/export.sh
. $ESP_MATTER_PATH/export.sh

# (방법 1) 이 폴더에서 바로
cd esp32-light
# (방법 2) esp-matter 예제 옆에 복사해서
cp -r esp32-light $ESP_MATTER_PATH/examples/light_guideline && cd $ESP_MATTER_PATH/examples/light_guideline

idf.py set-target esp32
idf.py build
idf.py -p <포트> erase-flash flash monitor     # 처음 또는 변형을 바꿀 때는 erase-flash로 NVS(커미셔닝 정보)까지 초기화
```

- `ESP_MATTER_DEVICE_PATH` 환경 변수가 이미 설정돼 있으면 그 값이 우선한다. GPIO33 프로필을 쓰려면 `unset ESP_MATTER_DEVICE_PATH` 후 빌드한다.
- 빌드 확인: `build/compile_commands.json`에 `device_hal/esp32_devkit_c_gpio33/device.c`가 있어야 GPIO33으로 출력된다.

### v3 속성 갱신 예시 적용 (선택)
```bash
cd esp32-light
patch -p1 < variants/v3_sync.diff      # 되돌리기: patch -R -p1 < variants/v3_sync.diff
idf.py build
```

## 확인 방법
```bash
chip-tool pairing ble-wifi 2 <SSID> <PASSWORD> 20202021 3840
../scripts/level_check.sh 2            # 레벨/OnLevel 연동, 기기 UART의 [HW] 로그와 비교
```
- UART 로그: `[HW] power=`, `[HW] brightness=%`(구동부 지령), `[SYNC]`(v3 적용 시 속성 갱신)
- 구동부 지령 0~100은 8비트 PWM duty에 그대로 쓰인다(100% 지령 = duty 100/255).

## 알려진 사항
- **esp-matter gpio LED 구동부 특성**: 밝기 0%(레벨 1 등)를 받으면 내부 마지막 밝기를 갱신하지 않고, 켤 때 그 값을 다시 적용한다. OnLevel이 null인 상태에서 128 → 1 → 끔 → 켬을 하면 CurrentLevel은 1인데 LED는 이전 밝기(50%)로 켜진다. SDK 컴포넌트의 동작이므로 이 예제에서는 수정하지 않았다(해설서 10.6.2 참고 문단).
- v3(속성 갱신 예시)는 OnLevel 기본값과 함께 동작한다. SDK의 On/Off–Level 연동이 레벨을 갱신하는 경우 SYNC 값(254)은 덮어써지므로, 켜짐 시 밝기 정책은 OnLevel로 구현한다(해설서 표 10-12 한계 문장).
