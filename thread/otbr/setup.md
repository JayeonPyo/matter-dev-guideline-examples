# OTBR 설정 — otbr-agent 실행, ot-ctl 네트워크 형성

검증 호스트: Raspberry Pi 5 (Debian 13), ot-br-posix. RCP는 `../rcp/build.md`의 nRF52840 Dongle.

## 1. 설치
```bash
git clone https://github.com/openthread/ot-br-posix && cd ot-br-posix
./script/bootstrap
INFRA_IF_NAME=wlan0 ./script/setup        # infra 인터페이스: 가정/실험실 LAN의 wlan0 또는 eth0
sudo systemctl disable --now otbr-agent   # 실습에서는 아래처럼 수동 기동 (자동 기동을 원하면 생략)
```

## 2. otbr-agent 실행
```bash
RCP=$(ls /dev/serial/by-id/*Thread_Co-Processor*-if02)     # Spinel 포트 (if02)

# (A) 가정/실험실 LAN — infra = wlan0
sudo otbr-agent -I wpan0 -B wlan0 -v "spinel+hdlc+uart://$RCP?uart-baudrate=115200" &

# (B) 공용망(학교, 카페 등) — dummy infra: RA·mDNS가 호스트 밖으로 나가지 않음.
#     이 경우 chip-tool은 OTBR과 같은 호스트에서 실행해야 한다.
sudo ip link add otbr-dummy type dummy
sudo ip link set otbr-dummy multicast on up     # multicast 필수 (아래 주의 참고)
sudo otbr-agent -I wpan0 -B otbr-dummy -v "spinel+hdlc+uart://$RCP?uart-baudrate=115200" &
```

> **주의 — infra 인터페이스의 multicast 플래그**: 꺼져 있으면 SRP로 등록된 기기를 mDNS로 광고하지 못한다. 그러면 커미셔닝이 PASE까지 성공한 뒤 `operational discovery failed ... Timeout`으로 끝난다. dummy 인터페이스는 기본값이 꺼짐이므로 반드시 켠다.

## 3. Thread 네트워크 형성 (ot-ctl)
```bash
sudo ot-ctl dataset init new
sudo ot-ctl dataset commit active
sudo ot-ctl ifconfig up
sudo ot-ctl thread start

sudo ot-ctl state                  # leader 가 될 때까지 몇 초 대기
sudo ot-ctl dataset active -x      # 커미셔닝에 쓸 dataset (hex) — 네트워크 키가 들어 있으므로 외부에 공개하지 않는다
sudo ot-ctl br state               # running
sudo ot-ctl channel; sudo ot-ctl panid
```
dataset은 OTBR 설정에 저장된다. 재부팅 후에는 `ifconfig up` → `thread start`만 하면 같은 네트워크로 다시 시작한다.

## 4. 확인 명령
| 명령 | 용도 |
|---|---|
| `ot-ctl child table` | 붙은 Thread 기기(child) — `childtable`은 이 버전에서 Error 35 |
| `ot-ctl router table` | 라우터 목록 (재플래시 전 기기가 한동안 남아 있을 수 있음) |
| `ot-ctl srp server host` / `service` | 기기의 SRP 등록 (`_matter._tcp`) |
| `ot-ctl rcp version` | RCP 펌웨어 버전 |
