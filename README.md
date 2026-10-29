# matter-dev-guideline-examples

「매터 제품 개발 가이드라인(한글 해설서)」의 예제 코드와 검증 스크립트 라이브러리.
해설서 본문의 실습을 그대로 재현할 수 있도록 장별로 나누었다.

본 저장소는 한국정보통신기술협회(TTA) 「매터 제품 개발 가이드라인 개발 및 TTA 표준화」 사업의 산출물로서 세종대학교 SESLab이 개발하였다.

## 구성과 해설서 대응

| 해설서 | 폴더 | 내용 |
|---|---|---|
| **10장** (10.6.2, 표 10-11·10-12) | [`esp32-light/`](esp32-light/README.md) | esp-matter `examples/light` 수정본. `main/app_driver.cpp`·`app_main.cpp` = OnLevel 적용본(**권장안**), `variants/v3_sync.diff` = 속성 갱신 예시(선택), `device_hal/esp32_devkit_c_gpio33/` = GPIO33 LED 장치 프로필 |
| **11장** (11.1, 11.5 표 11-4, 11.6, 11.8.5) | [`scripts/`](scripts/README.md) | `multiadmin.sh` 멀티어드민·패브릭 조회, `level_check.sh` OnLevel/레벨 연동 검증 (chip-tool) |
| **12장** (12.8~12.10) | [`thread/`](thread/) | `rcp/build.md` 동글 RCP 빌드·DFU, `otbr/setup.md` otbr-agent 실행·네트워크 형성, `light_bulb/build.md` DK 빌드·플래시, `commission.sh` BLE-Thread 커미셔닝 + On/Off 확인 |

```
matter-dev-guideline-examples/
├── README.md
├── LICENSE
├── esp32-light/                         10장
│   ├── main/app_driver.cpp              OnLevel 적용본 (권장안)
│   ├── main/app_main.cpp
│   ├── device_hal/esp32_devkit_c_gpio33/   GPIO33 장치 프로필
│   ├── variants/v3_sync.diff            속성 갱신 예시 (선택)
│   └── README.md                        빌드 방법
├── scripts/                             11장
│   ├── multiadmin.sh
│   ├── level_check.sh
│   └── README.md
└── thread/                              12장
    ├── rcp/build.md
    ├── otbr/setup.md
    ├── light_bulb/build.md
    └── commission.sh
```

## 검증 환경

| 항목 | 버전 |
|---|---|
| Wi-Fi 기기 | ESP32-DevKitC V4 (ESP32-WROOM-32E, ESP32-D0WD-V3), GPIO33에 저항 직렬 LED (High = 켜짐) |
| ESP SDK | ESP-IDF **v5.4.1**, esp-matter **release/v1.4** (abdb759) |
| Thread | nRF Connect SDK **v2.9.0**, nRF52840 DK + nRF52840 Dongle(RCP), ot-br-posix on Raspberry Pi 5 |
| 컨트롤러 | chip-tool (Nordic 배포 NCS v2.9.0 빌드, **Matter 1.4**) |

## 빠른 시작

```bash
# 10장 — ESP32 예제 빌드
. $IDF_PATH/export.sh && . $ESP_MATTER_PATH/export.sh
cd esp32-light && idf.py set-target esp32 && idf.py build flash monitor

# 11장 — 커미셔닝 후 검증
chip-tool pairing ble-wifi 2 <SSID> <PASSWORD> 20202021 3840 --storage-directory ~/.matter-guideline/admin-a
scripts/multiadmin.sh 2
scripts/level_check.sh 2

# 12장 — OTBR 구성 후 (thread/otbr/setup.md)
thread/commission.sh 0x1234
scripts/multiadmin.sh 0x1234
```

자세한 내용은 각 폴더의 문서를 본다.

## 검증 상태
- `esp32-light`: 기본(OnLevel 적용) 구성과 `v3_sync.diff` 적용 구성 모두 빌드를 확인하였으며, 기본 구성은 해설서 10.6.2의 검증에 사용한 펌웨어와 동일하다.
- `scripts/`, `thread/commission.sh`: 해설서 11장·12장의 검증에 사용한 명령을 재사용 가능한 형태로 정리한 것이다.
- 알려진 사항(esp-matter gpio LED 구동부 특성 등)은 `esp32-light/README.md`를 본다.

## 라이선스
Apache License 2.0 (`LICENSE`). esp-matter(Apache-2.0)의 `examples/light`(Public Domain/CC0)와 `device_hal`(Apache-2.0), nRF Connect SDK 예제(명령만 인용)를 기반으로 한다.
