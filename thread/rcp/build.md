# RCP (nRF52840 Dongle) 빌드·DFU

OTBR이 Thread 무선을 쓰려면 nRF52840 Dongle에 OpenThread RCP 펌웨어를 올린다.

| 항목 | 값 |
|---|---|
| SDK | nRF Connect SDK **v2.9.0** (NCS 3.x의 coprocessor 샘플은 nRF52840 Dongle을 지원하지 않는다) |
| 샘플 | `nrf/samples/openthread/coprocessor` (RCP 기본 활성) |
| 보드 타깃 | `nrf52840dongle/nrf52840` |
| 전송 | USB CDC ACM — 스니펫 `usb` |

## 빌드
```bash
# NCS v2.9.0 toolchain 환경에서 (nRF Connect for VS Code 터미널 또는 nrfutil toolchain-manager)
# 한글 Windows: 먼저 PYTHONUTF8=1 설정 (cp949 UnicodeDecodeError 방지)
west build -p -b nrf52840dongle/nrf52840 nrf/samples/openthread/coprocessor -- -Dcoprocessor_SNIPPET=usb
```
빌드 결과(참고): FLASH 150,044 B / 988 KB (14.8%), RAM 48,000 B / 256 KB (18.3%)

## DFU (동글 내장 부트로더)
동글에는 온보드 디버거가 없으므로 `west flash` 대신 부트로더 DFU를 쓴다.
```bash
nrfutil install nrf5sdk-tools
nrfutil nrf5sdk-tools pkg generate --hw-version 52 --sd-req=0x00 \
    --application build/zephyr/zephyr.hex --application-version 1 rcp.zip
# RESET 버튼(USB 커넥터 반대쪽 측면)을 커넥터 방향으로 밀어 누름 → 빨간 LED가 서서히 깜빡이면 부트로더 진입
nrfutil nrf5sdk-tools dfu usb-serial -pkg rcp.zip -p <동글 포트>
```
`Device programmed.`가 나오면 성공이다.

## 포트 확인 (Linux 호스트)
```bash
ls /dev/serial/by-id/
# usb-Nordic_Semiconductor_ASA_Thread_Co-Processor_<SN>-if00  ← 콘솔
# usb-Nordic_Semiconductor_ASA_Thread_Co-Processor_<SN>-if02  ← Spinel (OTBR에 지정)
```
if00을 지정하면 otbr-agent가 `Init() at spinel_driver.cpp: Failure`로 실패한다.
