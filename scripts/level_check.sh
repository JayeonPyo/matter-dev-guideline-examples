#!/bin/bash
# 10.6.2 검증: On/Off ↔ Level Control 연동과 OnLevel 속성.
# 여기서 읽은 CurrentLevel을 기기 UART의 "[HW] brightness=%" 로그와 LED 상태에 비교한다.
#   시험 1  level 1 → 끔 → 켬                    (펌웨어의 OnLevel 기본값 적용)
#   시험 2  write on-level 254 → 끔 → 켬         (CurrentLevel 254 기대)
#   시험 3  on-level null, level 128 → 끔 → 켬   (이전 레벨 128 기대)
#   시험 4  on-level null, level 1 → 끔 → 켬     (CurrentLevel 1 기대)
#
# 사용법: PAUSE=5 ./level_check.sh <node-id> [endpoint=1]      (PAUSE = LED 관찰 대기 초)
# 환경 변수: CHIP_TOOL(기본 chip-tool), STORAGE_A(관리자 A 저장소)
set -u
CHIP_TOOL="${CHIP_TOOL:-chip-tool}"
STORAGE_A="${STORAGE_A:-$HOME/.matter-guideline/admin-a}"
N=${1:?node-id}; EP=${2:-1}
A="--storage-directory $STORAGE_A"

run() {
    echo
    echo "### [$(date +%T)] chip-tool $*"
    "$CHIP_TOOL" "$@" 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
}
see() {
    echo "### [$(date +%T)] >>> LED 관찰: $1"
    sleep "${PAUSE:-5}"
}

echo "===== 초기 상태 ====="
run levelcontrol read on-level $N $EP $A
run levelcontrol read current-level $N $EP $A
run levelcontrol read options $N $EP $A

echo "===== 시험 1: level 1 → 끔 → 켬 ====="
run onoff on $N $EP $A
run levelcontrol move-to-level 1 0 0 0 $N $EP $A
see "level 1"
run onoff off $N $EP $A
run onoff on $N $EP $A
see "끔 → 켬 후 (시험 1)"
run levelcontrol read current-level $N $EP $A

echo "===== 시험 2: write on-level 254 → 끔 → 켬 ====="
run levelcontrol write on-level 254 $N $EP $A
run onoff off $N $EP $A
run onoff on $N $EP $A
see "on-level 254, 끔 → 켬 후 (시험 2)"
run levelcontrol read current-level $N $EP $A

echo "===== 시험 3: on-level null, level 128 → 끔 → 켬 ====="
run levelcontrol write on-level null $N $EP $A
run levelcontrol move-to-level 128 0 0 0 $N $EP $A
run onoff off $N $EP $A
run onoff on $N $EP $A
see "level 128, 끔 → 켬 후 (시험 3)"
run levelcontrol read current-level $N $EP $A

echo "===== 시험 4: on-level null, level 1 → 끔 → 켬 ====="
run levelcontrol move-to-level 1 0 0 0 $N $EP $A
run onoff off $N $EP $A
run onoff on $N $EP $A
see "on-level null, level 1, 끔 → 켬 후 (시험 4)"
run levelcontrol read current-level $N $EP $A
