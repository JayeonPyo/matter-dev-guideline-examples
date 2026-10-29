#!/bin/bash
# 12장: nRF52840 DK(light_bulb)를 BLE로 OTBR Thread 네트워크에 커미셔닝하고 On/Off 제어를 확인한다.
# OTBR과 같은 호스트에서 실행한다(dataset을 로컬 ot-ctl에서 읽음, sudo 필요).
#
# 사용법: ./commission.sh [node-id=0x1234] [passcode=20202021] [discriminator=3840]
# 환경 변수: CHIP_TOOL(기본 chip-tool), STORAGE_A(관리자 A 저장소)
# 이어서 멀티어드민: ../scripts/multiadmin.sh <node-id>
set -u
CHIP_TOOL="${CHIP_TOOL:-chip-tool}"
STORAGE_A="${STORAGE_A:-$HOME/.matter-guideline/admin-a}"
NODE=${1:-0x1234}; PASSCODE=${2:-20202021}; DISC=${3:-3840}
mkdir -p "$STORAGE_A"
A="--storage-directory $STORAGE_A"

run() {
    echo
    echo "### [$(date +%T)] chip-tool $*"
    "$CHIP_TOOL" "$@" 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
}

[ "$(sudo ot-ctl state | head -1)" = leader ] || { echo "OTBR이 leader가 아님 (otbr/setup.md 참고)"; exit 1; }

# 끝의 CR/LF 제거: 남아 있으면 chip-tool이 "Odd number of characters"로 실패한다.
DATASET=$(sudo ot-ctl dataset active -x | head -1 | tr -d '\r\n ')

echo "### [$(date +%T)] chip-tool pairing ble-thread $NODE hex:<dataset> $PASSCODE $DISC"
"$CHIP_TOOL" pairing ble-thread "$NODE" "hex:$DATASET" "$PASSCODE" "$DISC" $A 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | tee /tmp/commission.log
grep -q "commissioning completed with success" /tmp/commission.log || { echo "커미셔닝 실패 — 기기 리셋(BLE 광고 15분) 후 재시도"; exit 1; }

run onoff on $NODE 1 $A
run onoff read on-off $NODE 1 $A
run onoff toggle $NODE 1 $A
run onoff read on-off $NODE 1 $A

echo; echo "### ot-ctl child table"
sudo ot-ctl child table
