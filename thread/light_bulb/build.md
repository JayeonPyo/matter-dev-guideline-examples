# Matter 기기 (nRF52840 DK) — light_bulb 빌드·플래시

nRF Connect SDK v2.9.0의 `nrf/samples/matter/light_bulb`을 **수정 없이** 쓴다.

## 빌드·플래시
```bash
# NCS v2.9.0 toolchain 환경에서 (한글 Windows: PYTHONUTF8=1)
west build -p -b nrf52840dk/nrf52840 nrf/samples/matter/light_bulb
west flash                 # DK의 디버그 USB(J-Link, 짧은 변 쪽 포트)에 연결, 전원 스위치 ON
```
- 빌드 결과(참고, debug 기본값): FLASH 824,648 B / 982,528 B (83.9%), RAM 187,336 B / 256 KB (71.5%), MCUboot 포함(sysbuild)
- `west flash`가 nrfjprog를 못 찾으면 J-Link Commander로 `build/merged.hex`를 기록해도 된다
  (`connect` → `erase` → `loadfile build/merged.hex` → `r` → `g`).
- Windows에서 J-Link가 연결되지 않으면(장치 관리자 "BULK interface" 오류 코드 28) SEGGER `USBDriver/InstDrivers.exe`를 실행한다.

## 부팅 로그 (UART 115200, J-Link VCOM)
```
*** Booting My Application v2.9.0-... ***
[DL]  Setup Pin Code (0 for UNKNOWN/ERROR): 20202021
[DL]  Setup Discriminator (0xFFFF for UNKNOWN/ERROR): 3840 (0xF00)
[SVR]SetupQRCode: [MT:6FCJ142C00KA0648G00]
[SVR]Manual pairing code: [34970112332]
[DL]CHIPoBLE advertising started
```
- passcode 20202021 / discriminator 3840은 SDK 시험용 기본값이다(제품에서는 기기별 고유값).
- Thread에 붙기 전에는 `Failed to advertise commissionable node: 3`이 찍힐 수 있다(정상).
- BLE 커미셔닝 광고는 부팅 후 **15분**만 열린다. 지나면 기기를 리셋한다.
- 팩토리 리셋: 칩 전체 지우기 후 다시 플래시(`west flash --erase` 또는 J-Link `erase`).
