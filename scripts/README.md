# scripts — 11장(및 10.6.2) chip-tool 검증 스크립트

| 스크립트 | 검증 내용 | 해설서 |
|---|---|---|
| `multiadmin.sh <node-id>` | 패브릭 여유 → 추가 패브릭 연동 → 패브릭 조회(기본 / `--fabric-filtered 0`) → NOCs·레이블·ACL → Revoke → RemoveFabric → Revoke | 11.1, 11.5 표 11-4, 11.6, 11.8.5 |
| `level_check.sh <node-id>` | On/Off ↔ Level 연동, OnLevel 254 / null 동작 | 10.6.2 |

Wi-Fi 노드(esp32-light)와 Thread 노드(nRF light_bulb) 모두 쓸 수 있다. 관리자 A로 먼저 커미셔닝해 둬야 한다.

```bash
export CHIP_TOOL=chip-tool                                   # chip-tool 경로
export STORAGE_A=~/.matter-guideline/admin-a                 # 관리자 A 저장소 (기본값)
chip-tool pairing ble-wifi 2 <SSID> <PASSWORD> 20202021 3840 --storage-directory $STORAGE_A
./multiadmin.sh 2 | tee multiadmin.log
PAUSE=5 ./level_check.sh 2 | tee level.log
```

| 환경 변수 | 기본값 | 의미 |
|---|---|---|
| `CHIP_TOOL` | `chip-tool` | chip-tool 실행 파일 |
| `STORAGE_A` | `~/.matter-guideline/admin-a` | 관리자 A(1차 생태계) 저장소 |
| `STORAGE_B` | `~/.matter-guideline/admin-b` | 관리자 B(타 생태계 역할) 저장소. `multiadmin.sh`가 실행마다 비운다 |
| `NAME_B` | `beta` | 관리자 B의 commissioner name (FabricID 2) |
| `PAUSE` | `5` | `level_check.sh`의 LED 관찰 대기 시간(초) |

## 검증 결과 (참고)
| 항목 | 결과 |
|---|---|
| SupportedFabrics / CommissionedFabrics | 5 / 1 → 관리자 B 추가 후 2 → 제거 후 1 |
| `read fabrics` 기본 / `--fabric-filtered 0` | 1건 / 2건 |
| ACL (관리자 A / B) | 각자 자기 패브릭 항목 1건만 보임 (Privilege 5, AuthMode 2 = CASE) |
| RevokeCommissioning | WindowStatus 1 → 0 |
| level_check (OnLevel 254 예제) | 시험 1: 254, 시험 2: 254, 시험 3: 128, 시험 4: 1 |

## 참고
- `multiadmin.sh`의 마지막 Revoke 재실행은 Matter Multi-Admin Best Practices 모범사례 #4(해설서 11.8.5)에 따른 단계이며, 열린 창이 없으면 기기가 실패 상태를 반환할 수 있다(정상).
- 커미셔닝 로그의 `mbedTLS error: Generic error`는 시험용 인증서(PAA 미등록)에서 나오는 정상 메시지다.
- 같은 호스트에서 chip-tool을 동시에 두 개 이상 실행하면 BLE 연결이 `le-connection-abort-by-local`로 실패한다.
