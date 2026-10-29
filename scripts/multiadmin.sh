#!/bin/bash
# 11장 멀티어드민 / 패브릭 검증 (Wi-Fi·Thread 노드 공통). 관리자 A가 이미 커미셔닝한 노드에 대해 실행한다.
#   (a) 패브릭 여유        SupportedFabrics / CommissionedFabrics
#   (b) 추가 패브릭 연동   OpenCommissioningWindow(ECM) → 관리자 B가 수동 페어링 코드로 커미셔닝
#       패브릭 조회        기본(fabric-filtered) vs --fabric-filtered 0          (표 11-4)
#       확장               NOCs, UpdateFabricLabel, 관리자별 ACL(fabric-scoped, 11.1), CurrentFabricIndex
#   (c) 타 생태계 제거     RevokeCommissioning → RemoveFabric → Revoke 재실행     (11.8.5 모범사례 #4)
#
# 사용법: ./multiadmin.sh <node-id> [fabric-label=AdminA-Home]
# 환경 변수: CHIP_TOOL(기본 chip-tool), STORAGE_A, STORAGE_B(관리자 A/B 저장소), NAME_B(기본 beta → FabricID 2)
set -u
CHIP_TOOL="${CHIP_TOOL:-chip-tool}"
STORAGE_A="${STORAGE_A:-$HOME/.matter-guideline/admin-a}"
STORAGE_B="${STORAGE_B:-$HOME/.matter-guideline/admin-b}"
NAME_B="${NAME_B:-beta}"
N=${1:?node-id}; LABEL=${2:-AdminA-Home}

mkdir -p "$STORAGE_A" "$STORAGE_B"
rm -rf "${STORAGE_B:?}"/*   # 관리자 B는 실행할 때마다 새 패브릭으로 시작
A="--storage-directory $STORAGE_A"
B="--storage-directory $STORAGE_B --commissioner-name $NAME_B"

run() {
    echo
    echo "### [$(date +%T)] chip-tool $*"
    "$CHIP_TOOL" "$@" 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
}

echo "===== (a) 패브릭 여유 ====="
run operationalcredentials read supported-fabrics $N 0 $A
run operationalcredentials read commissioned-fabrics $N 0 $A

echo "===== (b) 추가 패브릭 연동 (관리자 B = $NAME_B) ====="
OCW=$(run pairing open-commissioning-window $N 1 300 1000 3840 $A)
echo "$OCW"
CODE=$(echo "$OCW" | grep -oE "Manual pairing code: \[[0-9]+\]" | grep -oE "[0-9]{11,}" | head -1)
echo "### 수동 페어링 코드 = $CODE"
run pairing code $N "$CODE" $B
run operationalcredentials read commissioned-fabrics $N 0 $A

echo "===== 패브릭 조회: 기본(fabric-filtered) ====="
run operationalcredentials read fabrics $N 0 $A
echo "===== 패브릭 조회: --fabric-filtered 0 ====="
run operationalcredentials read fabrics $N 0 --fabric-filtered 0 $A

echo "===== 확장: NOCs, 패브릭 레이블, ACL, 현재 패브릭 인덱스 ====="
run operationalcredentials read nocs $N 0 --fabric-filtered 0 $A
run operationalcredentials update-fabric-label "$LABEL" $N 0 $A
run operationalcredentials read fabrics $N 0 --fabric-filtered 0 $A
run accesscontrol read acl $N 0 $A
run accesscontrol read acl $N 0 $B
run operationalcredentials read current-fabric-index $N 0 $B

echo "===== (c) 커미셔닝 창 닫기 → 관리자 B 패브릭 제거 ====="
run pairing open-commissioning-window $N 1 300 1000 3840 $A
run administratorcommissioning read window-status $N 0 $A
run administratorcommissioning revoke-commissioning $N 0 --timedInteractionTimeoutMs 10000 $A
run administratorcommissioning read window-status $N 0 $A
FI=$("$CHIP_TOOL" operationalcredentials read current-fabric-index $N 0 $B 2>&1 | grep -oE "CurrentFabricIndex: [0-9]+" | grep -oE "[0-9]+$")
run operationalcredentials remove-fabric "${FI:-2}" $N 0 $A
# 모범사례 #4: 제거 후 Revoke 재실행. 열린 창이 없으면 기기가 실패 상태를 돌려줄 수 있다(정상).
run administratorcommissioning revoke-commissioning $N 0 --timedInteractionTimeoutMs 10000 $A
run operationalcredentials read commissioned-fabrics $N 0 $A
run operationalcredentials read fabrics $N 0 --fabric-filtered 0 $A
