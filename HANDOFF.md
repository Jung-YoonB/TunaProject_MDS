# TunaProject_MDS 작업 인수인계 문서

Claude Code와 함께 진행한 작업을 시간순으로 쌓아온 **누적 작업 로그**. 새 세션/새 환경에서 이어받을 때 이 문서와 `PROJECT_AUDIT.md` 두 개만 읽으면 지금까지의 맥락을 그대로 이어받을 수 있게 하는 것이 목적이다.

**이 문서를 읽는 법**
- `HANDOFF.md`(작업 로그) / `PROJECT_AUDIT.md`(버그·정책·위험 목록) / `HANDOFF_NEXT_SESSION_PROMPT.txt`(다음 세션 시작 프롬프트) + `메종드사조_스타일가이드.pdf` 4개는 **사용자가 직접 관리하는 문서**이고, 커밋도 항상 사용자가 직접 한다(Claude가 먼저 커밋하지 않는 것이 이 프로젝트의 규칙).
  - **2026-09-01 경위**: 원래 "git commit 대상이 아님"이었는데 `a9bdcfa` 커밋에 4개가 함께 포함돼 `origin/frontfix`까지 올라갔다(`.gitignore`엔 등록된 적이 없어 그동안은 단지 스테이징을 안 했을 뿐이었음). → **`main`으로 올라가기 전에 다시 추적에서 빼고 로컬에서만 관리하기로 최종 결정**(3-43/3-44).
  - **2026-09-03 아침 갱신**: 집↔회사 두 PC를 오가며 이어서 작업하려고 **다시 일부러 4개를 같이 커밋해서 GitHub에 올리는 중이다.** 현재 4개 모두 tracked 상태(의도한 것, 사고 아님). **`main`으로 병합하기 직전에만** 다시 추적에서 빼고 커밋할 것 — 그 전까지는 이 방식(GitHub로 동기화)이 맞다.

> ## ⛔ 이 문서들의 편집 권한 (2026-09-01 확정)
>
> **`HANDOFF.md` / `PROJECT_AUDIT.md` / `HANDOFF_NEXT_SESSION_PROMPT.txt` 3개 문서를 갱신·최신화하는 것은 팀장(BJY) 한 사람만 한다.**
>
> - 팀원(및 팀원이 쓰는 Claude)은 이 문서들을 **읽기 전용 참고 자료로만** 쓸 것. **내용을 고치거나, 새 섹션을 추가하거나, 잘못된 내용을 발견해서 정정하는 것도 하지 말 것.**
> - 이 문서들은 git 추적 대상이 아니라 팀장 로컬에만 있고, 여러 사람이 동시에 손대면 이력이 갈라져서 "지금까지의 맥락을 그대로 이어받는다"는 이 문서의 목적 자체가 깨진다.
> - 문서 내용에 **오류를 발견하거나 추가할 내용이 생기면 직접 고치지 말고 팀장에게 전달**할 것. 반영은 팀장이 한다.
> - 팀원 쪽 작업 기록이 필요하면 **별도 파일**을 만들어 쓸 것(이 3개 문서에 끼워 넣지 말 것).
- 아래 `1.`~`3.` 세 섹션은 **최초 스냅샷(2026-08-28)** 이고, 그 이후의 모든 작업은 `3-1`부터 `3-N`까지 시간순으로 이어 붙인 구조다.
- **섹션 번호는 "작성 순서"이지 날짜순이 아님** — 예를 들어 3-29(08-31) 다음에 3-30(08-30)이 온다. 각 섹션 제목에 날짜가 붙어 있으니 날짜 기준으로 읽을 것.
- 세부 수정이 이어진 구간은 `3-38-1`, `3-38-2`처럼 하위 번호(`###`)로 붙어 있다.

---

## 지금 상태 요약 (2026-09-02 기준)

| 항목 | 상태 |
|---|---|
| 브랜치 상황 | `BJY_works`. **`JWC_works`(`3e4d83f`) 병합 중 — 충돌 2건 해결 완료, 미커밋**(3-57). 병합 회귀 확인 결과 직전 작업물 전부 생존 |
| DB 상태 | **최신화 완료(3-53, 사용자 직접 실행).** `REVIEW_STATUS` 생성 / `LIKE_COUNT`·`REVIEWHISTORY`·`SEQ_REVIEW_RHIST_ID` 제거 / **CATEGORY 15 · TAG 58** / **`PRODUCT` 130건 등록 완료**(60건 예정 → 실제 130건) |
| ✅ 과도기 해소 | **product 전달 목록(3-47) 7건이 이번 병합으로 들어왔다.** 누락됐던 1건(상세 평균별점·리뷰수 `REVIEW_STATUS` 필터)은 3-57에서 보완. `ORA-00904`로 상세가 깨지던 문제 해소 — 상품 상세 200 확인 |
| 아직 다른 브랜치 | `JJY_Work` / `JWC_works` / `KGH_works` / `product_images` / `origin/KCH_works` — 팀원 개인 작업 브랜치라 각자 `main`을 받아가면 해소됨(3-43 매퍼 수정도 그때 따라감) |
| 테스트 서버 | **`http://192.168.30.24:8797/`** — 가동 중, 3-42/3-43 결과물 배포 반영 확인 완료. **로컬 개발 서버와 포트가 같으니 헷갈리지 말 것**(`localhost:8797` = devtools 로컬) |
| 진행 중인 작업 | **3-60 대규모 라운드 완료**(상품 상세/장바구니·찜 선택모드+페이징/결제 PRG+405/리뷰 이미지·좋아요/드롭다운 화살표, AUDIT 27·29~48 전부 조치) — `PROJECT_AUDIT.md` 버그 항목 **48개 전부 조치 완료, 미해결 0** |
| 미커밋 변경 | **약 45개 파일**(3-60) + 이전 라운드분 누적(3-56 결제/`JWC_works` 병합/3-57~59). **관리 문서 4종(`HANDOFF.md`/`PROJECT_AUDIT.md`/`HANDOFF_NEXT_SESSION_PROMPT.txt`/스타일가이드 PDF)은 현재 git 추적 중**(2026-09-03 아침부터 의도적 — 집↔회사 두 PC를 GitHub로 동기화하려는 목적. **`main` 병합 직전에만** 다시 추적 제거 후 재커밋 예정). `docs/ADMIN_BINDING_HANDOVER.md`는 삭제 예정 문서라 무시 |
| 다음 단계 | AUDIT "버그" 섹션은 전부 닫혔음. 남은 것은 다른 섹션 — **정책적 고려가 필요한 부분**(product 영역 집계 3곳 필터 미반영) / **잠재적 위험 요소**(20번 `style_user.css` 최상위 `#id` 102개, 24번 추가 이미지 표시/검증 불일치). 좋아요(`REVIEWLIKE`) 더미 데이터가 여전히 0행이면 3-60에서 새로 단 좋아요 버튼도 화면상 항상 0으로 보일 수 있음 — 확인 필요 |
| ✅ 로컬 이미지 있음 | 이번 병합(`JWC_works`)으로 `uploads/product`(701개)가 git 추적에 포함돼 로컬(`localhost:8797`)에서도 상품 썸네일이 정상 표시된다(3-58에서 실제 200 확인). 위 "로컬 이미지 없음"은 병합 전 상태였음 — 더는 유효하지 않음 |
| ✅ cart/wish 연결됨 | 4경로 전부 404였던 것이 **`JWC_works` 병합으로 해소** — `wish/my-wish`·`cart/my-cart` 로그인 상태 200 확인(AUDIT 버그 16번 닫힘) |
| CSS 구성 | `default.css` / `style.css` / `style_user.css` / `style_admin.css` 4개, `header.jsp`가 전 페이지에 전부 로드 |
| JS 컨벤션 | 인터랙션 → `static/js/views/<페이지>.js`, 비즈니스·데이터 → `static/js/<도메인>/<기능>Service.js` |
| 서버 | 포트 8797, `./mvnw spring-boot:run`(devtools 자동 재시작), admin 계정 `admin`/`1234` |

---

## 목차

| 구간 | 시기 | 내용 |
|---|---|---|
| `1` ~ `3` | 2026-08-28 | 최초 스냅샷 — 관리자 기능 3종(상품 등록 / 쿠폰 등록·삭제 / 주문·배송 상태 변경) 백엔드 구현, 검증 방법, 남은 과제 |
| `3-1` ~ `3-19` | 2026-08-28~29 | 관리자 3종을 실사용 수준으로 다듬기(배송 택배정보 모달, 상태 전이 로직, 상품/쿠폰 등록 검증) + **CSS 전역 leak 대형 버그(3-5/3-6)** + JS 분리 컨벤션 최초 확립(3-1) |
| `3-20` ~ `3-26` | 2026-08-29 | 로그인 후 원래 페이지 복귀, 관리자 마이페이지 정리, 쿠폰 화면 UI/필터/페이지네이션 마무리 |
| `3-27` ~ `3-29` | 2026-08-30~31 | 전체 리팩토링(`/simplify`), admin DTO 통합, **프로젝트 전체 감사 → `PROJECT_AUDIT.md` 생성** |
| `3-30` ~ `3-31` | 2026-08-30~31 | 유저 주문/배송 확인 기능 구현(가장 큰 단일 섹션, 마이페이지·리뷰·쿠폰 화면 포함) + 새 환경에서 전체 재검증 |
| `3-32` ~ `3-36` | 2026-08-31 | 팀 브랜치 병합(`KGH_works`, `JWC_works`) 검토·검증 + 쿠폰/wish/cart 패키지 중복 정리 |
| `3-37` ~ `3-40` | 2026-08-31~09-01 | **`frontfix` 인수 — 프론트 CSS/JS 규격화 검증**(3-37) + 홈페이지 마무리(3-38), 더보기/무한스크롤(3-39), 배경 이미지 시도 후 단색 원복(3-40) |
| `3-41` | 2026-09-01 | 문서 정리 + **다음 단계(다른 페이지 규격화) 계획** |
| `3-42` | 2026-09-01 | **나머지 페이지 CSS/JS 규격화 실행** — JS 분리 5개 페이지(인라인 script 0개 달성) + `userWithdraw` 독립 페이지 통합 + **삭제됐던 `userUpdateInfo.js` 복구**(회원정보 수정 화면이 통째로 죽어 있었음) + **아이콘 유니코드 글리프 → SVG 전면 전환** |
| `3-43` | 2026-09-01 | **`BJY_works`에서 쿠폰 페이징 매퍼 문 복구** + 병합 전 다이버전스 조사(**cart/wish 도달 경로 문제 발견**) + 관리 문서 4종 git 추적 제외 결정 |
| `3-44` | 2026-09-01 | **전 브랜치 병합·최신화 + `main` 배포 + 테스트 서버 가동**(`192.168.30.24:8797`) |
| `3-45` | 2026-09-01 | **리뷰 삭제 후 재작성 차단 구현** — 정책 확정 → `REVIEWHISTORY` 신설 → 매퍼/서비스 반영·검증. 후속으로 **다품목 주문 리뷰 경로 버그 수정(3-45-1)** + **전체 죽은 코드/주석 정리(3-45-2)** + 낡은 빌드 산출물 문제 해결(`clean` 필요) |
| `3-46` | 2026-09-01 | **카테고리/태그 확정본 반영 SQL 작성** — 임시 데이터 + 샘플 상품·연계 데이터 전부 정리 후 카테고리 15 / 태그 58 등록. 실행은 사용자 |
| `3-47` | 2026-09-01 | **리뷰 스키마 재설계(`REVIEWHISTORY` 폐기 → `REVIEW_STATUS` 컬럼, `LIKE_COUNT` → `REVIEWLIKE` 일원화)** — 스키마 검토 + 리뷰/멤버 영역 코드 선반영 + product 영역 전달 목록 |
| `3-48` | 2026-09-01 | **상품 등록 옵션 1개 고정 → 개수 제한 없이 추가** — JSP/JS/CSS + 컨트롤러/서비스까지, `optionsJson` 전송 방식으로 변경 |
| `3-49` | 2026-09-01 | **리뷰 작성 페이지 규격 통일** — wrapper 없이 `#review-form`(ID)이 컨테이너라 "고쳐도 안 바뀌던" 원인 해소 + 블록 419줄 전면 스코프(전역 leak `*`/`h2`/`.product-price` 등 제거) |
| `3-50` | 2026-09-01 | **전 페이지 공통 - 짧은 콘텐츠에서 생기던 카드 아래 빈 띠 제거** — `main` 세로 flex + wrapper/카드 높이 이어받기, 중복 `min-height:100vh` 10곳 제거 |
| `3-51` | 2026-09-01 | **뒤로가기 시 클릭 잔상 제거** — hover 같은 `:focus` 강조 7곳을 `:focus-visible`로 전환(앵커는 밑줄 차단 규칙 별도) |
| `3-52` | 2026-09-01 | **문서·주석 최신화** — 낡은 주석 3건 정정, 과한 주석 7곳 축약(HANDOFF 번호 참조로 대체), 문서 3종 갱신 |
| `3-53` | 2026-09-02 | **DB 최신화 실행 완료 + 상품 60건 일괄 등록 사전 점검** — DB 검증(카테고리 15·태그 58), product 미병합 과도기 확인, **product 병합 후 실행할 검증 체크리스트 A~D** |
| `3-54` | 2026-09-02 | **뷰 수정 묶음 + 주문 다품목 표시 + 테스트 더미 데이터** — `ReviewMapper.xml` 병합 회귀 복구, **마이페이지 리뷰 타일(AUDIT 18) 해소**, 관리자 상품등록 4건 + 서버 길이 검증, 태그 글자색 명암비 계산, 주문/배송 **총수량 + 품목 드롭다운**, `dummy_order_review.sql` 신규 |
| `3-55` | 2026-09-02 | **헤더 닉네임 노출(#TB006_TC-12) + 품목별 리뷰 상태** — 세션 DTO에 닉네임 추가(변경 시 세션 갱신 포함), 배송완료 카드 기본 펼침 + `리뷰 작성 완료/미작성`, **`hasReview` 이름 충돌을 `allReviewed`로 분리**, 주석 정리 |
| `3-56` | 2026-09-02 | **결제 화면 금액 안내(#TB019_TC-29) + 결제 재개 + 배송비 정돈** — **화면·서버 계산 불일치(67%·최대 2원) 해소**, 포인트 최소/상한 안내, 배송비·포인트 매직넘버 단일 출처화, **헤더 영수증 아이콘 = 진행 중인 결제 재개**(세션 30분), 깨진 경로 3건 수정 |
| `3-57` | 2026-09-02 밤 | **`JWC_works` 병합 충돌 해결 + product 전달 목록 검수 + AUDIT 버그 1번 조치** — `productdetail.js` 중복 선언 사고 차단, 누락된 `REVIEW_STATUS` 필터 보완, 세션 키 3곳 정정으로 좋아요·쿠폰 500 해소, 체크리스트 A~D 전부 통과 |
| `3-58` | 2026-09-03 | **메인페이지(`home.jsp`) 서버 연동** — 정적 목업(카테고리/상품 하드코딩) → `ProductService` 실데이터 SSR 전환, 죽은 `/mds/list` 라우트 정리, 카테고리 아이콘 이름 매칭 재배치 |
| `3-59` | 2026-09-03 | **화면 확인 3건 조치** — 상품 상세 장바구니를 실제 `POST /cart/add-cart`로 연결(비로그인 시 로그인 요구), 홈 "더보기"를 진짜 추가 노출(8→16)+페이지네이션으로 재설계("전체 상품 보기"와 겹치던 기능 분리), 이미지 호버 태그 팝업(`.sp-tag-popup`) 마크업 누락 보완 |
| `3-60` | 2026-09-03 | **대규모 라운드 — AUDIT 27, 29~48 전부 조치** 상품 상세(옵션가격/카테고리/설명/등급할인/대표이미지 500), 검색·찜 카드 리뷰 링크, 장바구니·찜 선택모드+페이지네이션 전면 개편, 장바구니 개별삭제·재담기 수량증가·헤더뱃지 즉시반영, 찜 로그아웃 후 상태 동기화, 결제 PRG(취소/뒤로가기 재제출 확인)+`/checkout` 405 우회+포인트 안내/레이아웃, 리뷰 이미지 경로 누락+좋아요 버튼 신설, 드롭다운 화살표 위치. **버그 섹션 48개 전부 조치 완료 ← 최신** |
| 부록 A | — | 참고 메모리(환경/함정 메모) |

---

## 1. 완료된 것 (2026-08-28 최초 스냅샷)

> 관리자 기능 3개(상품 등록 / 쿠폰 등록·삭제 / 주문·배송 상태 변경)의 백엔드를 처음부터 구현하고, Postman + 실제 DB 조회로 전부 검증까지 끝낸 시점의 기록. (이 시점 기준으로 아직 커밋 전이었음)

### 상품 등록 (CRUD 중 등록)
- `admin.controller.AdminProductController` — `GET/POST /admin/product/add`
- 대표 이미지(1장, 필수) / 추가 이미지(개수 제한 없이 동적 추가) / 설명 이미지(신규 추가, 개수 제한 없음) 3종 업로드 → `PRODUCTIMAGE.PRODUCT_TITLE_IMAGE` 0/1/2로 저장
- 가격/재고는 PRODUCT 테이블에 컬럼이 없어서, 등록할 때마다 "기본 옵션" 1개(PRODUCTOPTION+OPTIONDETAIL)를 자동 생성해서 담음
- 카테고리 1개 선택 → CATEGORYDETAIL, 태그는 여러 개 선택/생성 → TAG(find-or-create)+TAGDETAIL
- `addProduct.jsp`: 카테고리/태그 옵션을 DB에서 JSTL로 렌더링, 재고 입력 필드·설명 이미지 영역은 **임시 주석 달아서 신규 추가**(원래 화면엔 없었음), 추가 이미지 업로드를 고정 6칸 → 무제한 동적 추가 UI로 교체

### 쿠폰 등록/삭제
- `admin.controller.AdminCouponController` — `GET /admin/coupon`(목록 화면), `GET /admin/coupon/list`(JSON), `GET/POST /admin/coupon/add`, `POST /admin/coupon/delete`
- 삭제 시 `COUPONHISTORY`에 발급 이력이 있으면 FK 제약 때문에 차단하고 안내 메시지 반환 (스키마 변경 없이 애플리케이션 레벨에서 방어)
- 할인율은 관리자가 정수 퍼센트(예: 15)로 입력 → 서버에서 `/100`으로 변환해 저장, **1~100 범위 서버 검증 있음**
- `admincouponView.jsp`: 원래 스크립트가 아예 없던 정적 목업이었음 → 목록 조회/검색/전체선택/선택삭제 전부 새로 구현. 수정(✎) 버튼은 이번 범위(등록/삭제) 밖이라 미구현 상태로 둠

### 주문/배송 상태 변경
- `admin.controller.AdminOrderController` — `GET /admin/order`(페이지), `GET /admin/order/list`(JSON: 주문목록+요약카운트), `POST /admin/order/delivery/{orderId}`(상태/송장번호 저장)
- `adminOrderDelivery.jsp`에 원래 있던 상세한 `TODO(data binding)` 주석 스펙을 그대로 따라 구현 → 하드코딩된 목업 배열을 실제 fetch 호출로 교체, 저장 버튼도 실제 API 연동
- **자세한 설계 결정/알려진 한계는 3번 섹션 참고** (이 부분이 다음에 이어서 다룰 영역)

### 그 외 수정
- `MemberController.java`: ADMIN 역할일 때 리턴하던 view 이름이 실제 파일 위치(`admin/` 폴더)와 안 맞아서 404 나던 것 5곳 수정
- `WebConfig.java`: 로그인 인터셉터가 보호하는 경로 이름에 오타(`usercouponView`/`userOrderDelivery`)가 있어서 `/member/couponView`, `/member/orderDelivery`가 비로그인 상태로도 뚫려 있던 것 수정 (→ NPE 위험도 같이 해소됨)
- `adminPage.jsp`: 관리자 마이페이지의 빠른메뉴/아코디언 링크가 죽은 정적 프로토타입(`resources/static/temp/*.html`)을 가리키고 있던 것을 실제 라우트(`/admin/product/add`, `/admin/order`, `/admin/coupon`)로 수정
- 신규 공용 유틸: `util.AdminAuthUtil.isAdmin(session)` — admin 컨트롤러 3개에 중복돼 있던 권한 체크 로직 통합
- 코드리뷰로 찾아서 고친 것: `adminOrderDelivery.jsp`의 회원명/상품명 XSS(이스케이프 없이 innerHTML에 삽입), 상품 등록 시 설명/상품명을 비워두면 Oracle이 빈 문자열을 NULL로 취급해서 500 나던 것(서버 검증 추가), 쿠폰 삭제 N+1 쿼리 → 배치 쿼리로 정리, 이미지 미리보기 blob URL 메모리 누수

### 변경 파일 목록
```
신규:
  src/main/java/com/kh/sajotuna/mds/admin/                          (controller 3, service 3+Impl, mapper 3, dto 13)
  src/main/java/com/kh/sajotuna/mds/util/AdminAuthUtil.java
  src/main/resources/mappers/admin/*.xml                            (3개)

수정:
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java
  src/main/java/com/kh/sajotuna/mds/util/config/WebConfig.java
  src/main/webapp/WEB-INF/views/admin/addProduct.jsp
  src/main/webapp/WEB-INF/views/admin/addCoupon.jsp
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp
  src/main/webapp/WEB-INF/views/admin/adminPage.jsp
```
(`header.jsp`가 수정 상태로 뜨는 건 이번 작업과 무관한 기존 미커밋 변경분 — 손대지 않음)

---

## 2. 검증 방법 (다시 이어서 할 때)

- 로컬 개발 서버: `./mvnw spring-boot:run`, 포트 **8797** (devtools 붙어있어서 `mvn compile`만 해도 자동 재시작됨). **재시작될 때마다 세션이 날아가서 재로그인 필요.**
- **팀 테스트 서버: `http://192.168.30.24:8797/`** (3-44에서 구축). ⚠️ **로컬과 포트가 같으니 주소를 반드시 확인할 것** — `localhost:8797`은 내 로컬, `192.168.30.24:8797`은 팀 공용이다.
- 로그인: `POST /member/login` body `loginId=admin&loginPw=1234`
- **유저 화면은 반드시 USER 계정으로 확인할 것.** `/member/myPage`, `/member/couponView`, `/member/cart`, `/member/wish`는 컨트롤러가 `role`로 분기해 ADMIN이면 admin 화면으로 빠지므로, admin 계정으로는 유저 쪽 버그가 아예 안 보인다.
- 이번 세션에서 만들어 드린 Postman 컬렉션 파일(`TunaProject_Admin.postman_collection.json`) 그대로 써도 되고, 직접 만든 요청으로 계속 진행해도 됨
- DB 직접 확인은 jshell + ojdbc11 드라이버로 (python 없어도 됨):
  ```bash
  OJDBC=$(find ~/.m2/repository/com/oracle/database/jdbc/ojdbc11 -iname 'ojdbc11-*.jar' ! -iname '*sources*' | sort -V | tail -1)
  jshell --class-path "$OJDBC"
  # import java.sql.*; Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@112.221.47.69:10000:xe", "C##MDS_ADMIN", "MDS"); ...
  ```

---

## 3. 다음: 주문/배송 부분에서 더 다뤄볼 것 (사용자 담당)

지금 구현은 **동작은 하지만 설계상 임의로 정한 부분들**이 있어서, 이어서 작업할 때 재검토가 필요함:

1. ~~**대시보드 요약 카운트 정의가 임의적**~~ **(2026-08-28 저녁 세션에서 관련 버그 수정 완료)**: `PRODUCTORDER.ORDER_STATUS`도 `PREPARING`/`SHIPPED`/`DELIVERED`/`CANCELED` 값을 갖는 필드인데(시드 데이터상 원래 `DELIVERY_STATUS`와 동기화되도록 설계된 것으로 보임), 관리자가 배송상태를 바꿔도 `ORDER_STATUS`는 갱신 안 되고 있던 걸 발견 → `AdminOrderServiceImpl.updateDeliveryStatus()`가 `DELIVERY.DELIVERY_STATUS` 저장 후 `PRODUCTORDER.ORDER_STATUS`도 동기화하도록 수정(`AdminOrderMapper.updateOrderStatus` 추가, `OUT_FOR_DELIVERY`는 `ORDER_STATUS`엔 없는 값이라 `SHIPPED`로 매핑). 이와 함께 `adminOrderDelivery.jsp`의 "주문 상태" 필터가 배송 진행 단계(배송준비중/배송중/배송완료/취소)인데도 `orderStatus`로 비교하던 버그도 `deliveryStatus` 기준으로 고침. 대시보드 카운트 정의(신규주문=`ORDER_STATUS` 결제단계, 나머지=`DELIVERY_STATUS`) 자체는 재검토 결과 그대로 유지가 맞다고 판단 — 결제 직후 아직 관리자가 안 건드린 신규 주문을 "신규"로 계속 잡아내려면 필요한 구조.
2. **대표 상품 선정 방식**: 한 주문에 상품이 여러 개면 `ORDERDETAIL` 중 `OD_ID`가 가장 작은(가장 먼저 담긴) 1건만 대표로 보여주고 나머지는 "외 N건"으로 표시. 다른 기준(예: 최고가 상품)이 필요하면 `resources/mappers/admin/AdminOrderMapper.xml`의 `selectOrderList` 서브쿼리 수정 필요.
3. ~~**DELIVERY 행이 항상 있다고 가정함**~~ **(2026-08-28 밤 세션 5회차에서 해결)**: 실제로 결제완료 후 DELIVERY 행이 없는 주문에서 "해당 주문의 배송 정보를 찾을 수 없습니다" 에러가 재현됨(테스트용으로 SQL로 직접 넣은 주문이었지만, 체크아웃 미구현 상태에서 실제로 벌어질 수 있는 상황이 그대로 드러난 것). 해결 방식은 "배송준비중으로 처음 바꿀 때 DELIVERY 행을 INSERT, 그 이후(배송중 등)부터는 UPDATE만" — 그리고 **DELIVERY 행이 없는 주문은 배송준비중을 반드시 거쳐야만 그 다음 단계로 갈 수 있게 서버에서 강제**(건너뛰고 바로 배송중 등으로 못 감). 자세한 내용은 3-7 섹션 참고. 체크아웃 플로우를 나중에 만들 때, 주문 생성 시점에 DELIVERY 행을 미리 만들지 말지는 이제 자유롭게 선택 가능 — 안 만들어도 admin 화면에서 알아서 처리됨.
4. **orderId 표시가 그냥 PK 숫자**: 목업엔 `20260915-001` 같은 포맷이 있었는데, 실제로는 `PRODUCTORDER.ORDER_ID`(순수 숫자)를 그대로 보여줌. 원래 JSP 주석에도 "실제 바인딩 시 별도 포맷팅 로직 필요"라고 적혀있던 부분이라 필요하면 포맷팅 추가.
5. **페이지네이션 버튼(1~5)이 아직 정적 목업**: 실제 페이징 쿼리 연동 안 돼있음. 지금은 전체 목록을 한 번에 불러와서 클라이언트에서 필터링하는 방식이라 데이터 많아지면 페이징이 필요해짐.
6. **필터(기간/검색어/상태)는 서버 왕복 없이 클라이언트에서 처리**: 지금 데이터 규모에선 괜찮지만, 주문이 많아지면 서버 사이드 필터링(쿼리 파라미터로 WHERE 절 추가)으로 바꾸는 게 나을 수 있음.
7. ~~**deliveryStatus 대소문자 변환**~~ **(2026-08-28 저녁 세션에서 위치 이동)**: JS는 소문자(`preparing` 등), DB/Java는 대문자(`PREPARING`)를 씀 — 변환 로직 자체는 그대로지만, 이제 `normalizeOrder()`/`.toUpperCase()` 둘 다 `static/js/admin/adminOrderService.js`(비즈니스 로직 파일)로 옮겨감. 체크아웃 플로우 등 다른 곳에서 이 값을 다룰 때 대소문자 헷갈리지 않게 주의.

---

## 3-1. 2026-08-28 저녁 세션 추가 작업 (배송 시작 시 택배 정보 입력)

사용자님이 "이 프로젝트는 실습 팀프로젝트라 유저 커머스 쪽에 집중하고 관리자는 최소 구현"이라는 방향을 제시 → 위 1번에서 발견한 "배송 시작 로직이 비어있음"(결제완료 → 배송중 전환 시 택배사/송장번호를 받을 방법이 없었음, DELIVERY.COMPANY 컬럼 자체가 지금까지 어디서도 안 쓰이고 있었음) 문제를, 페이지 분리(주문 관리/배송 관리) 대신 **기존 통합 페이지 안에서 모달로 최소 구현**하기로 결정.

### 구현
- 배송 상태를 `배송중`/`배송출발`/`배송완료`(택배사에 실제로 넘어간 이후 상태, `AdminOrderServiceImpl.COURIER_INFO_REQUIRED_STATUSES`)로 바꿀 때만 모달이 뜨고, 택배사+송장번호를 입력해야 저장됨. `배송준비중`/`취소`는 기존처럼 바로 저장.
- 서버 검증도 추가: 저 상태들로 바꾸는데 택배사/송장번호가 비어있으면 `IllegalStateException`으로 막음 (Postman으로 직접 호출해도 우회 불가).
- `DELIVERY.COMPANY` 컬럼을 처음으로 실제 사용하게 됨 — `AdminOrderListItemDTO`/`DeliveryUpdateRequestDTO`에 `company` 필드 추가, `AdminOrderMapper.xml`의 `selectOrderList`/`updateDeliveryStatus`에 반영.
- 실제 서버 띄워서 로그인 → 배송중 전환 시 택배사/송장번호 없이 호출하면 거부되는 것, 값 채워서 호출하면 DB까지 정상 저장되는 것(한글 택배사명 포함) 확인 완료. **모달을 브라우저에서 직접 클릭해보는 테스트는 못 함 — 브라우저 도구가 없어서 코드 리뷰로만 확인.** 화면에서 한 번 확인 필요.

### JS 구조 변경 (사용자님 요청)
인터랙션(DOM 조작/이벤트) JS와 비즈니스 로직(서버 통신/데이터 가공) JS를 파일로 분리하는 컨벤션을 이번에 새로 만듦:
- 인터랙션 JS → `static/js/views/<jsp파일명>.js` (예: `static/js/views/adminOrderDelivery.js`)
- 비즈니스 로직 JS → Java 패키지처럼 기능별 폴더로 → `static/js/admin/adminOrderService.js` (전역 `window.AdminOrderService` 네임스페이스로 노출, fetch 호출/정규화/필터링/상태 매핑 담당)
- JSP는 두 `<script src>`를 순서대로 로드(business 먼저, interaction 나중), context-path가 필요한 URL은 `<c:url>`로 만들어서 `<body data-*>` 속성에 심어두고 외부 JS에서 `document.body.dataset`로 읽음 (외부 .js 파일은 JSP EL/taglib을 못 쓰므로).
- **이번엔 주문/배송 페이지에만 적용함.** `addProduct.jsp`/`admincouponView.jsp` 등 다른 admin 페이지는 아직 인라인 `<script>`로 남아있음 — 같은 패턴으로 나중에 정리하면 됨.

### 변경/신규 파일
```
신규:
  src/main/resources/static/js/admin/adminOrderService.js   (비즈니스 로직)
  src/main/resources/static/js/views/adminOrderDelivery.js  (인터랙션)

수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/AdminOrderListItemDTO.java       (company 필드)
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/DeliveryUpdateRequestDTO.java    (company 필드)
  src/main/java/com/kh/sajotuna/mds/admin/model/mapper/AdminOrderMapper.java         (updateOrderStatus 추가, company 파라미터)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderService.java       (시그니처 변경)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderServiceImpl.java   (동기화+검증 로직)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminOrderController.java       (company 전달)
  src/main/resources/mappers/admin/AdminOrderMapper.xml                              (company 컬럼, updateOrderStatus)
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp                         (모달 마크업, 인라인 스크립트 제거)
  src/main/resources/static/css/style_admin_order.css                                (모달 스타일, tracking-input 스타일 제거)
```

## 3-2. 사용자님이 직접 header/review/product의 js를 views/로 옮긴 것 검증 + 수정

3-1에서 만든 컨벤션을 보고 사용자님이 `common/header.js`, `review/addreview.js`, `product/productdetail.js`를 `views/`로 직접 옮김. 검증해보니:

- **`addreview.js`, `productdetail.js`는 문제없음** — 순수 인터랙션(DOM 조작)만 있고 서버 통신/데이터 가공 로직이 안 섞여있어서 그대로 둬도 됨. JSP의 `<script src>` 경로만 새 위치(`/js/views/...`)에 맞게 수정.
- **`header.js`는 심각한 버그가 있었음**: 원래 JSP에 인라인으로 박혀있던 스크립트를 그대로 옮겨서, `${not empty sessionScope.loginMemberId}` (EL), `<c:url value="/"/>` (JSTL 태그), `<%-- --%>` (JSP 주석) 같은 **JSP 전용 문법이 그대로 남아있었음**. 정적 .js 파일은 Tomcat이 JSP처럼 처리해주지 않기 때문에, 이 상태로는 브라우저에서 파싱 에러가 나서 스크립트 전체가 죽는 상태였음(거기다 `<script src="/js/common/header.js">` 경로도 파일을 옮기면서 안 바꿔서 애초에 404였음).
- 이 파일이 깨지면 `window.addToCart`/`window.toggleWish`/`window.isWished`/`window.refreshCartBadge` 전역 함수가 전부 안 만들어져서, 이 함수들을 호출하는 **`cart.jsp`, `wish.jsp`, `searchProduct.jsp`의 장바구니/찜 버튼도 같이 먹통**이 되는 상황이었음(다행히 각 페이지가 `typeof window.addToCart === 'function'` 가드를 이미 해놔서 에러로 죽진 않고 조용히 무반응이었을 뿐).

### 수정
- `header.js`의 장바구니/찜 **데이터 로직**(localStorage 읽기/쓰기, `addToCart`/`toggleWish`/`isWished`)을 `static/js/common/cartWishService.js`(비즈니스 로직)로 분리 → `window.CartWishService` 네임스페이스로 노출하되, `cart.jsp`/`wish.jsp`/`searchProduct.jsp`가 이미 쓰던 `window.addToCart` 등 기존 전역 함수 이름도 하위 호환으로 그대로 유지(저 3개 JSP는 안 건드림).
- `header.js`는 뱃지 렌더링(DOM 조작)만 남기고, EL/JSTL 의존 부분은 `header.jsp`의 `<body data-logged-in="..." data-home-url="...">` 속성으로 옮겨서 `document.body.dataset`로 읽게 고침(외부 .js는 EL을 못 쓰므로 — 3-1의 adminOrderDelivery와 같은 패턴).
- `header.jsp`/`addReview.jsp`/`productDetail.jsp`의 `<script src>` 경로를 새 위치로 수정.
- 홈페이지(`/`) 기준으로 `data-logged-in`/스크립트 로드까지는 실제로 띄워서 확인함. `productDetail`/`addReview` 페이지는 사용자님이 브라우저로 직접 테스트 중인 것 같아서(서버 로그에 `/mds/detail/1` 접근 기록 보임) 겹치지 않게 서버 호출로는 추가 확인 안 함 — 화면에서 한 번 봐주면 좋겠음.

### 신규/수정 파일
```
신규:
  src/main/resources/static/js/common/cartWishService.js

수정:
  src/main/resources/static/js/views/header.js        (EL/JSTL 제거, 뱃지 렌더링만 남김)
  src/main/webapp/WEB-INF/views/common/header.jsp      (body data-* 속성, script src 경로 2개로 분리)
  src/main/webapp/WEB-INF/views/review/addReview.jsp   (script src 경로만 수정)
  src/main/webapp/WEB-INF/views/product/productDetail.jsp (script src 경로만 수정)
```

---

## 3-3. 2026-08-28 밤 세션: adminOrderDelivery.jsp 헤더/푸터 + 상태 전이 로직 정비

사용자님이 화면 확인하다가 3가지 지적: (1) 헤더/푸터 미연결 (2) 결제대기→결제완료 처리 로직이 없음 (3) 배송완료/취소된 주문도 이전 단계로 되돌릴 수 있는 버그. 검증 후 전부 확인되어 수정함.

### 1) 헤더/푸터 연결
- `addProduct.jsp`/`addCoupon.jsp`/`admincouponView.jsp`는 전부 `<jsp:include header.jsp/>`...`<jsp:include footer.jsp/>` 패턴을 쓰는데, `adminOrderDelivery.jsp`만 독립된 `<html>` 페이지로 만들었던 게 원인(제작 당시 실수). `adminPage.jsp`(관리자 마이페이지)도 동일한 문제가 있으나 이번 범위 밖이라 **손대지 않음** — 다음에 필요하면 같은 방식으로 고치면 됨.
- `header.jsp`가 `<body>`와 `<main>`을 열고, `footer.jsp`가 `</main>`과 `<footer>...</footer></body></html>`을 닫는 구조. 페이지 콘텐츠는 그 사이에 들어가야 함. `header.jsp`가 이미 모든 CSS를 전역으로 로드하므로 페이지별 `<link>`/`<head>`는 불필요.
- 기존에 `<body class="admin-order-delivery-page" data-*>`에 있던 클래스/데이터 속성은 `<body>`를 더 이상 못 쓰므로(공용이라) 콘텐츠를 감싸는 `<div class="admin-order-delivery-page" data-*>`로 옮김 — CSS 선택자(`.admin-order-delivery-page ...`)는 그대로 재사용 가능, JS만 `document.body.dataset` 대신 `document.querySelector('.admin-order-delivery-page').dataset`로 변경.

### 2) 결제대기 → 결제완료 처리
- `PRODUCTORDER.ORDER_STATUS`가 `PAYMENT_WAITING`인 주문은 "진행 현황"/"배송 정보" 칸이 전부 `-`로 표시되고, "관리" 칸엔 배송 드롭다운 대신 **"결제 완료 처리" 버튼만** 뜸.
- 신규 엔드포인트 `POST /admin/order/payment/{orderId}` (`AdminOrderMapper.confirmPayment`가 `WHERE ORDER_STATUS='PAYMENT_WAITING'` 조건으로 UPDATE, 0건이면 이미 처리된 것으로 보고 거부).
- 결제대기 주문에 배송 상태 변경(`/admin/order/delivery/{orderId}`)을 시도하면 서버에서 거부함 ("결제가 완료되지 않은 주문은 배송 상태를 변경할 수 없습니다").
- **테스트 방법**: 시드 데이터엔 `PAYMENT_WAITING` 주문이 하나도 없어서, jshell로 직접 INSERT해서 검증 후 삭제함 (아래 5번 참고).

### 3) 상태 역행 방지 + 종료 상태 잠금
- `AdminOrderServiceImpl`에 `DELIVERY_STATUS_RANK`(preparing=0, shipped/out_for_delivery=1, delivered/canceled=2)와 `TERMINAL_DELIVERY_STATUSES`(delivered, canceled) 추가.
- 서버: 새 상태의 rank가 현재보다 낮으면 거부, 현재 상태가 이미 terminal이면 아예 거부. `updateDeliveryStatus` 호출 시 `selectStatusSnapshot`으로 현재 상태를 먼저 조회.
- 프론트: 드롭다운 자체를 `Service.allowedNextStatuses(current)`로 필터링해서 역행 옵션이 아예 안 보이게 하고, terminal 상태는 드롭다운 대신 읽기 전용 배지(`delivery-status-badge`)로 표시("관리" 칸은 빈 `-`).
- **Postman으로 직접 호출해도 우회 불가** — 실제로 SHIPPED 주문을 PREPARING으로 되돌리는 시도, DELIVERED 주문 상태 변경 시도 둘 다 서버에서 거부되는 것 확인함.

### 4) 추가로 발견/수정
- `normalizeOrder()`: 결제대기 주문은 DB에 DELIVERY 행이 있어도(혹은 없어도) `deliveryStatus`를 무조건 `null`로 취급하도록 수정 — 안 그러면 "배송준비중" 필터에 결제 전 주문이 잘못 걸림.
- 저장/결제완료 처리 성공 후 UI 갱신 방식을 "해당 행만 수동 패치" → **`loadOrders()`로 전체 재조회**로 단순화(정확성 우선, 코드 중복 감소). "저장완료" 텍스트 깜빡임 같은 소소한 연출은 빠짐.

### 5) 실제 검증 내역 (전부 서버 띄워서 API로 직접 확인)
- 역행 시도(SHIPPED→PREPARING) 거부, terminal 상태(DELIVERED) 변경 시도 거부, 정상 전진(PREPARING→SHIPPED, 택배정보 포함) 성공.
- `PAYMENT_WAITING` 테스트 주문을 jshell + ojdbc11로 직접 INSERT(시드엔 이 상태가 없어서) → 배송상태 변경 거부 확인 → 결제완료 처리 성공 확인 → 중복 처리 시도 거부 확인 → 테스트 데이터 삭제까지 전부 완료.
  - (참고) `Get-Content script.jsh | jshell -` 로 파이프하면 PowerShell이 BOM을 섞어 넣어서 jshell이 파싱 에러를 냄. `cmd /c "jshell ... < script.jsh"`처럼 cmd 리다이렉션을 쓰면 됨.
- 브라우저에서 직접 헤더/푸터 렌더링, 결제완료 버튼 클릭, 드롭다운 옵션 제한을 눈으로 확인하는 것은 못 함(브라우저 도구 없음) — 화면에서 한 번 확인 필요.

### 신규/수정 파일
```
신규:
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/OrderStatusSnapshotDTO.java

수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/mapper/AdminOrderMapper.java        (selectStatusSnapshot, confirmPayment 추가)
  src/main/resources/mappers/admin/AdminOrderMapper.xml                             (동일)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderService.java      (confirmPayment 추가)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderServiceImpl.java  (역행/terminal/결제대기 검증)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminOrderController.java      (POST /admin/order/payment/{orderId})
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp                        (header/footer include로 재구성)
  src/main/resources/static/js/admin/adminOrderService.js                           (STATUS_RANK, isTerminal, allowedNextStatuses, confirmPayment)
  src/main/resources/static/js/views/adminOrderDelivery.js                          (3가지 행 상태 분기 렌더링, loadOrders 기반 갱신)
  src/main/resources/static/css/style_admin_order.css                               (delivery-status-badge, btn-confirm-payment)
```

---

## 3-4. 2026-08-28 밤 세션 2회차: 화면 깨짐 전체 원인 + admin 전 페이지 감사

사용자님이 `adminOrderDelivery.jsp` 화면 스크린샷을 보내주심 — 리스트가 불릿(•)으로 시작하고, 페이지네이션 숫자가 겹쳐 보이고, 전반적으로 CSS가 거의 안 먹은 것처럼 깨져 보임. 여기서 시작해서 **사이트 전체에 영향을 주는 근본 원인**을 찾음.

### 근본 원인: `header.jsp`가 존재하지 않는 CSS 파일을 링크하고 있었음
`header.jsp` 12번째 줄이 `<link rel="stylesheet" href="/css/common.css">`였는데, **`common.css`라는 파일 자체가 프로젝트에 없음**(`static/temp/*.html` 죽은 프로토타입 2개만 참조하던 이름). 반면 실제 전역 리셋 CSS인 `default.css`(margin/padding/border 0, box-sizing:border-box, `ul/ol` list-style:none 등 표준 리셋)는 파일로 존재하지만 `header.jsp`가 로드를 안 하고 있었음.

- 원래 `adminOrderDelivery.jsp`는 독립 페이지라 자체적으로 `default.css`를 직접 링크했었는데, 이번 세션 초반에 헤더/푸터 include 방식으로 바꾸면서 그 직접 링크를 없앴음(→ "header.jsp가 이미 다 로드해준다"고 잘못 가정) — 그 결과 리셋이 통째로 빠지면서 화면이 깨짐. **즉 이번에 새로 만든 버그가 아니라, header.jsp에 원래 있던 잠재 버그가 이번에 표면화된 것.**
- **사이트 전체(admin뿐 아니라 header.jsp를 쓰는 모든 페이지)에 영향 있었을 가능성이 높음.** `href="/css/common.css"` → `href="/css/default.css"`로 수정해서 근본적으로 해결함.

### admin 관련 JSP 5개 전수 검사 결과
1. **`adminOrderDelivery.jsp`** — 위 근본 원인 수정으로 해결. (헤더/푸터 자체는 직전 세션에서 이미 연결함)
2. **`adminPage.jsp`(관리자 마이페이지)** — 사용자님이 지적한 대로 헤더/푸터 미연결 확인 → `admincouponView.jsp`와 동일한 `<jsp:include header.jsp/>...<jsp:include footer.jsp/>` 패턴으로 재구성.
3. **`addProduct.jsp`(상품 등록)** — "모달이 뜬 채로 고장남" 원인 파악: 이 페이지가 `header.jsp`/`footer.jsp` include 방식으로 이미 전환은 되어 있었는데, **전환 전에 쓰던 구버전 커스텀 헤더(아이콘/로그인/nav)와 푸터 마크업이 지워지지 않고 그대로 남아있었음**(`</header>`처럼 이 파일 안에서 짝이 안 맞는 stray 종료 태그까지 포함). `<main class="product-register">`도 header.jsp가 이미 연 `<main>` 안에 중첩되어 있었음. 태그 모달 자체 CSS(`display:none` 기본값)는 정상이었음 — 화면이 깨져 보인 건 이 중복/orphaned 마크업과 위의 근본 원인(default.css 누락)이 겹친 결과로 추정. 중복 헤더/푸터 마크업 삭제, `<main>` → `<div class="product-register">`로 정리.
4. **`addCoupon.jsp`(쿠폰 등록)** — 짝이 안 맞는 stray `</main>`이 있었음(header.jsp가 연 `<main>`을 여기서 조기에 닫아버림 — 화면상 문제를 안 일으키고 있었지만 구조적으로 잘못됨). 제거해서 footer.jsp의 `</main>`이 정상적으로 닫도록 정리.
5. **`admincouponView.jsp`(쿠폰 목록)** — 헤더/푸터 자체는 정상. (당시엔 놓쳤던 CSS 스코프 문제가 3-5에서 추가로 발견됨 — 아래 참고)

### 검증
서버 띄워서 관리자 페이지 5개(`/admin/product/add`, `/admin/coupon/add`, `/admin/coupon`, `/admin/order`, `/member/myPage`) 전부 `curl`로 응답 받아서: `default.css` 링크 존재, `site-footer` 정확히 1번만 등장(중복 없음), 헤더 아이콘 마크업 존재 — 확인 완료. **브라우저에서 실제 눈으로 보는 확인은 여전히 못 했음** — 특히 addProduct.jsp 모달이 이제 정상적으로 열고 닫히는지, adminOrderDelivery.jsp가 이제 깨지지 않고 제대로 보이는지는 화면에서 확인 필요.

### 신규/수정 파일
```
수정:
  src/main/webapp/WEB-INF/views/common/header.jsp     (common.css -> default.css)
  src/main/webapp/WEB-INF/views/admin/adminPage.jsp   (header/footer include로 재구성)
  src/main/webapp/WEB-INF/views/admin/addProduct.jsp  (중복 헤더/푸터 마크업 삭제, main->div)
  src/main/webapp/WEB-INF/views/admin/addCoupon.jsp   (stray </main> 제거)
```

---

## 3-5. 2026-08-28 밤 세션 3회차: 진짜 원인은 "범용 선택자(body/main) 사이트 전역 충돌"

사용자님이 STS로 서버 직접 띄워서 확인 → 여전히 3가지 문제 보고: (1) addProduct.jsp 모달이 여전히 뜬 채로 고장 (2) adminOrderDelivery.jsp 중앙 영역 폭이 좁아지고 겹쳐 보임 (3) 쿠폰 목록에서 발급 이력 있는/없는 쿠폰 구분이 안 됨. 앞의 두 개를 파고들다가 **훨씬 크고 근본적인 사이트 전역 CSS 설계 문제**를 발견함.

### 진짜 근본 원인: `header.jsp`가 CSS 전부를 모든 페이지에 무차별 로드하는데, 각 페이지 CSS가 `body`/`main` 같은 범용 태그 선택자를 스코프 없이 그대로 쓰고 있었음
프로젝트의 페이지별 CSS 파일들(`style_addCoupon.css`, `style_admincouponView.css` 등)은 원래 "내 페이지만 로드되는" 걸 전제로, `body { ... }` / `main { ... }`처럼 스코프 없는 태그 선택자로 배경색·폭·카드 스타일을 잡아놨음. 그런데 `header.jsp`가 **모든 CSS 파일을 모든 페이지에 순서대로 로드**하기 때문에, 여러 페이지가 똑같이 `body`/`main`을 놓고 경쟁하고, **CSS 로드 순서상 가장 나중에 로드되는 파일이 사실상 사이트 전체의 `<body>`/`<main>` 스타일을 정함**. 실제로 확인해보니 `main {}` 스코프 없는 선택자를 쓰는 CSS 파일이 **10개**, `body {}`도 **15개**나 있었음 (admin 외 페이지 다수 포함 — `style.css`, `style_member.css`, `style_login.css` 등).

- `adminOrderDelivery.jsp` 폭이 좁아진 직접 원인: `style_admincouponView.css`가 header.jsp CSS 목록에서 가장 마지막에 로드되는데, 거기 있던 스코프 없는 `main { width: 800px; background:white; border-radius:12px; ... }`가 **모든 페이지의 실제 `<main>`을 800px 흰 카드로 강제로 덮어씀** — 그 안에서 `adminOrderDelivery.jsp`가 자체적으로 잡으려던 1100px 폭(`.page-content`)이 800px 부모 안에 끼여서 겹치고 깨져 보인 것.
- `addProduct.jsp` 모달이 계속 고장난 진짜 원인(제가 이번 세션 초반에 만든 버그): 제가 추가한 `style_admin_order.css`의 배송정보 모달 CSS가 `.modal-overlay`, `.modal-box`, `.modal-actions` 같은 **스코프 없는 범용 클래스명**을 그대로 썼는데, `addProduct.jsp`의 태그 모달도 똑같이 `.modal-overlay`/`.modal-actions` 클래스를 씀. `style_admin_order.css`가 `style_addProduct.css`보다 CSS 로드 순서상 나중이라, 제 `.modal-overlay { display:flex; ... }`가 addProduct의 `.modal-overlay { display:none; ... }`를 덮어써서 **태그 모달이 페이지 로드 시점부터 항상 열려있는 상태**가 됐던 것. (지난 라운드에서 고쳤다고 생각했던 "중복 헤더/푸터 마크업" 문제는 실제로 있던 별개의 문제가 맞지만, 모달이 안 닫히는 핵심 원인은 이거였음.)

### 수정 (전부 "스코프 없는 태그/범용 클래스 선택자를 페이지 전용 wrapper 클래스로 감싸기" 패턴)
- `style_admin_order.css`: 배송정보 모달 CSS 전체(`.modal-overlay`, `.modal-box`, `.modal-field`, `.modal-actions` 등)를 `.admin-order-delivery-page .modal-overlay`처럼 전부 스코프. 모달 `<div>`도 JSP에서 `.admin-order-delivery-page` 안쪽으로 이동(원래는 형제 요소였음 — 스코프가 통하려면 후손이어야 함).
- `adminOrderDelivery.jsp` / `style_admin_order.css`: `.admin-order-delivery-page main { width:1100px; ... }`처럼 원래 "header.jsp가 연 `<main>`이 내 페이지 안에 있다"고 가정한 선택자가, 페이지를 `<div>` 하나로 감싸는 구조로 바뀌면서 더 이상 안 맞게 됨(이제 `<main>`이 조상이지 후손이 아님) → 내부에 `.page-content` wrapper를 새로 두고 그쪽으로 폭 규칙 이동.
- `adminPage.jsp` / `style_admin_mypage.css` — 위와 동일한 패턴(`main` → `.page-content`)으로 수정.
- `addCoupon.jsp` / `style_addCoupon.css`, `admincouponView.jsp` / `style_admincouponView.css` — 스코프 없는 `body`(페이지 배경)/`main`(흰 카드) 2단 구조를, 각각 `.add-coupon-page`/`.admin-coupon-view-page`(바깥 배경) + `.add-coupon-page-card`/`.admin-coupon-view-page-card`(안쪽 흰 카드) 2단 wrapper로 교체.
- **admin 외 페이지(예: `style.css`, `style_member.css`, `style_login.css`, `style_home.css` 등)에도 스코프 없는 `body`/`main`이 남아있음 — 이번엔 admin 범위만 고쳤고, 나머지는 손 안 댐.** 지금 당장 눈에 띄는 문제를 안 일으키는 건 우연히 로드 순서상 다른 페이지가 이기고 있어서일 뿐, 근본적으로 같은 종류의 잠재 버그가 남아있는 상태. 나중에 다른 페이지에서 "갑자기 폭/배경이 이상해졌다"가 나오면 이 문서 참고.

### 쿠폰 발급 이력 UI 구분 (3번째 요청)
`COUPON` 목록 조회 쿼리에 `EXISTS (SELECT 1 FROM COUPONHISTORY WHERE COUPON_ID = ...)` 서브쿼리로 `hasHistory` 필드 추가 → 카드 UI에 "발급 이력 있음" 배지 + 카드 왼쪽 색 띠로 시각적 구분. 삭제 자체를 막지는 않음(기존 배치 삭제 시도 시 서버가 이미 막고 메시지 보여줌) — 그냥 목록에서 미리 알아볼 수 있게만 함. **지금 시드 데이터는 쿠폰 5개 전부 발급 이력이 있어서, 화면에 "구분"이 실제로 보이려면 발급 이력 없는 새 쿠폰을 하나 등록해봐야 함.**

### 검증
사용자님이 STS로 띄운 서버(포트 8797)에 직접 GET 요청으로 확인: 5개 CSS 파일에서 스코프 없는 `body`/`main` 사라짐, `.admin-order-delivery-page .modal-overlay` 등 스코프된 선택자로 정상 교체됨, `/admin/coupon/list` 응답에 `hasHistory` 필드 정상 포함, 5개 admin 페이지 전부 200 응답 확인. **JSP/정적 리소스는 STS가 자동으로 즉시 반영했고, Java(DTO/매퍼) 변경도 STS가 자동 컴파일해서 반영된 것까지 확인함.** 그래도 브라우저 화면으로 직접 보는 확인은 못 했으니 이번에도 화면에서 확인 필요.

### 신규/수정 파일
```
수정:
  src/main/resources/static/css/style_admin_order.css        (모달 CSS 스코프, .page-content로 폭 규칙 이동)
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp (모달을 wrapper 안으로 이동, .page-content 추가)
  src/main/resources/static/css/style_admin_mypage.css       (.page-content로 폭 규칙 이동)
  src/main/webapp/WEB-INF/views/admin/adminPage.jsp          (.page-content 추가)
  src/main/resources/static/css/style_addCoupon.css          (body/main -> .add-coupon-page(-card) 2단 스코프)
  src/main/webapp/WEB-INF/views/admin/addCoupon.jsp          (wrapper div 2단 추가)
  src/main/resources/static/css/style_admincouponView.css    (body/main -> .admin-coupon-view-page(-card) 2단 스코프, hasHistory 배지 스타일)
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp    (wrapper div 2단 추가, hasHistory 배지 렌더링)
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/AdminCouponDTO.java        (hasHistory 필드)
  src/main/resources/mappers/admin/AdminCouponMapper.xml                       (hasHistory 서브쿼리)
```

---

## 3-6. 2026-08-28 밤 세션 4회차: "뒷 배경 박스가 더 커야 함" — main{} 화이트 카드 leak 잔당 정리

3-5에서 `.admin-order-delivery-page`의 배경(cream, min-height:100vh)이 화면 일부에서만 보이고 그 아래(필터/테이블)는 흰 배경처럼 보인다는 스크린샷 지적 → 재추적한 결과, **3-5에서 스코프 안 한 다른 페이지들의 스코프 없는 `main{}`이 여전히 남아있어서 그 중 하나가 실제 `<main>`을 흰색 카드로 계속 덮어쓰고 있었음**(whack-a-mole: 하나 고치면 로드 순서상 그다음 파일이 다시 이김).

### 확인된 연쇄
1. `style_admincouponView.css`의 `main{}`을 3-5에서 스코프하고 나니, 그다음으로 로드 순서가 늦은 `style_productdetail.css`의 스코프 없는 `main{ width:1100px; margin:40px auto; padding:30px; background:white; }`(상품 상세 페이지용)가 이겨서 **모든 페이지의 `<main>`을 1100px 흰 카드로 만들고 있었음** — `adminOrderDelivery.jsp`가 그 안에 갇혀서 "폭은 우연히 비슷한데 흰 배경에 눌린" 것처럼 보였던 것.
2. `style_productdetail.css`를 스코프하면, 그다음은 `style_myPage.css`(회원 마이페이지, admin 아님, `main{width:900px;margin:50px auto}`)가 이김.
3. `style_home.css`(`main{width:1200px;margin:0 auto}`)도 로드 순서상 `style_myPage.css`보다 앞이라 당장은 안 이기지만, `style_myPage.css`를 고치면 다음 차례라 같이 정리함.
4. `style.css`의 `main{flex:1 0 auto}`는 header.jsp/footer.jsp와 세트로 만들어진 **의도된 정상 코드**(sticky-footer 플렉스 레이아웃, width/background를 안 건드림) — 이건 안 건드림.

### 수정
`style_productdetail.css`(+ `productDetail.jsp`), `style_home.css`(+ `home.jsp`), `style_myPage.css`(+ `member/myPage.jsp`) — 전부 3-5와 동일한 패턴(스코프 없는 `body`/`main` → 페이지 전용 wrapper 클래스)으로 정리. `productDetail.jsp`/`home.jsp`/`member/myPage.jsp`는 **admin이 아니지만**, 이걸 안 고치면 admin 페이지 배경이 계속 임의의 다른 페이지에 의해 좌우되는 상태라 같이 고침.

**아직 안 고친 것(의도적으로 범위 밖으로 둠)**: `style_member.css`/`style_addreview.css`/`style_addProduct.css`의 스코프 없는 `body{}` — `main{}`과 달리 폭 문제를 직접 일으키진 않아서(각 admin/페이지가 이미 자기 영역에 `min-height:100vh` 배경을 자체적으로 깔고 있어 body 배경은 안 보임) 남겨둠. `style_member.css`/`style_login.css`/`style_order.css`는 이미 `.login-page main`처럼 스코프된 선택자를 쓰고 있는데, 실제로 그 페이지들에 `<main class="login-page">`처럼 진짜 중첩 `<main>`이 있는지는 확인 안 함 — 나중에 그 페이지들에서 레이아웃이 이상하면 여기부터 볼 것.

### 검증
STS 서버에 admin 5개 페이지 + 홈(`/`) 재확인 — 전부 200, `home-page` 클래스 정상 렌더링 확인. **`productDetail.jsp`는 검증 못 함** — `ProductController.detailPage()`가 `Model`도 안 받고 `return "redirect:home/home"`으로 리다이렉트만 해서 실제 렌더링 경로를 못 탐(이건 원래부터 있던 별개의 미완성 버그, 이번에 안 건드림). `member/myPage.jsp`도 admin 계정으로는 `admin/adminPage.jsp`로 분기돼서 못 봤음(일반 회원 계정 필요) — 둘 다 화면에서 직접 확인 필요.

### 신규/수정 파일
```
수정:
  src/main/resources/static/css/style_productdetail.css     (body/main -> .product-detail-page(-card) 2단 스코프)
  src/main/webapp/WEB-INF/views/product/productDetail.jsp   (wrapper div 2단 추가)
  src/main/resources/static/css/style_home.css               (body/main -> .home-page 단일 스코프)
  src/main/webapp/WEB-INF/views/home/home.jsp                (wrapper div 추가)
  src/main/resources/static/css/style_myPage.css              (body/main -> .member-mypage-page(-content) 2단 스코프)
  src/main/webapp/WEB-INF/views/member/myPage.jsp             (wrapper div 2단 추가)
```

---

## 3-7. 2026-08-28 밤 세션 5회차: 배송준비중 전환 시 DELIVERY 행 INSERT + 건너뛰기 방지

바로 앞(3-6에서 테스트용으로 넣은 결제대기 주문 42번)에서 결제완료 처리 후 "배송 정보를 찾을 수 없습니다" 에러가 실제로 재현됨 — 3번 항목(위 "다음: 주문/배송 부분" 목록)에서 우려했던 상황이 실제로 벌어진 것. 사용자님과 논의 후 다음으로 정리:

- **DELIVERY 행이 없는 주문은 "배송준비중"으로 상태를 바꿀 때만 그 행을 새로 INSERT**한다. 그 이후(배송중/배송출발/배송완료/취소)는 이제 행이 있는 게 보장되므로 기존처럼 UPDATE만 하면 됨 — 상태별로 INSERT/UPDATE를 분기하지 않고 "배송준비중 딱 한 곳"에서만 INSERT가 일어나는 구조.
- **위 구조가 성립하려면 "배송준비중을 건너뛰고 바로 배송중 등으로 못 가게" 막아야 함** — 그래서 `AdminOrderServiceImpl.updateDeliveryStatus()`에서 `currentDeliveryStatus`(DB 값)가 `null`이면 무조건 `deliveryStatus == "PREPARING"`인지 확인하고, 아니면 거부("배송 정보가 없는 주문은 먼저 '배송준비중'으로 상태를 변경해야 합니다").
- 프론트(`adminOrderService.js`)의 `allowedNextStatuses(currentStatus)`도 `currentStatus`가 없으면(=DELIVERY 행 없음) `['preparing']`만 반환하도록 수정 — 드롭다운 자체에 배송준비중 외의 옵션이 아예 안 뜸(서버 검증과 이중 방어).
- `normalizeOrder()`의 `deliveryStatus`를 예전엔 DB 값이 없으면 `'preparing'`으로 기본값 처리했는데, 그러면 "실제로 배송준비중 처리된 주문"과 "아직 아무것도 안 된 주문"이 구분이 안 돼서 이번 버그의 원인이 됐음 — 이제는 DB 값이 없으면 `null` 그대로 유지, 화면 표시(드롭다운 색상 등)에만 `'preparing'`으로 fallback해서 보여줌.

### 검증
STS 서버에 직접 API로: (1) DELIVERY 행 없는 주문(42번)에 바로 `SHIPPED` 시도 → 거부 확인, (2) `PREPARING`으로 변경 → INSERT 성공 확인(`ORDER_STATUS`도 같이 동기화됨), (3) 그 다음 `SHIPPED`로 변경(택배정보 포함) → UPDATE 성공 확인. 이후 42번 주문은 사용자님이 화면에서 처음부터 직접 눌러보실 수 있도록 DELIVERY 행 다시 삭제하고 `PAYMENT_COMPLETED` 상태로 되돌려놓음.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/mapper/AdminOrderMapper.java        (insertDelivery 추가)
  src/main/resources/mappers/admin/AdminOrderMapper.xml                             (insertDelivery INSERT문)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderServiceImpl.java  (배송준비중 INSERT 분기 + 건너뛰기 방지)
  src/main/resources/static/js/admin/adminOrderService.js                          (allowedNextStatuses null 처리, normalizeOrder deliveryStatus null 유지)
  src/main/resources/static/js/views/adminOrderDelivery.js                         (드롭다운 표시/옵션 분리, revert 시 null 방어)
```

### 3-7-1. 추가 수정: 택배정보 이미 있으면 모달 다시 안 띄우게

사용자님이 실제로 43번 주문으로 배송준비중→배송중→배송출발까지 테스트하다가 발견: 배송중에서 이미 택배사/송장번호를 입력했는데, 배송출발로 한 단계 더 옮길 때도 모달이 또 떴음 — 같은 배송 건의 정보가 이미 있는데 다시 물어볼 필요가 없다는 지적. `adminOrderDelivery.jsp`의 저장 버튼 클릭 핸들러에서 모달을 띄우는 조건을 `Service.requiresCourierInfo(newStatus)` 단독 → `requiresCourierInfo(newStatus) && 아직 택배사/송장번호가 없을 때`로 수정(`static/js/views/adminOrderDelivery.js`). 서버 검증 로직은 안 건드림 — 어차피 "값이 비어있으면 거부"만 확인하는 거라 이미 있는 값을 그대로 보내면 통과함.

### 3-7-2. 추가 수정: 현재 상태를 드롭다운에서 다시 선택 못 하게

이어서 발견: "진행 현황" 드롭다운에 현재 상태 자체도 옵션으로 남아있어서, 바뀐 것 없이 "저장"을 눌러도 `confirm()` 창이 뜨고 그대로 다시 저장을 시도했음(예: 이미 배송중인데 배송중으로 "변경"). 두 군데 방어:
- `buildDeliveryStatusOptions()`: 현재 상태와 같은 `<option>`은 `disabled`로 표시 — 목록엔 남아서 "지금 이 상태"라는 걸 보여주지만 클릭해서 다시 고를 순 없음.
- 저장 버튼 클릭 핸들러: `newStatus === originalStatus`면 아무 요청도 안 보내고 그냥 종료 — 드롭다운 조작 없이 바로 저장을 눌러버리는 경우까지 이중으로 방어.

## 3-8. 2026-08-29: 드롭다운 방식 → "다음 단계로" 버튼 방식으로 전면 교체

3-7-1/3-7-2에서 드러났듯, 드롭다운으로 아무 배송 상태나 고를 수 있게 해둔 게 근본 문제였음 — 역행 금지/건너뛰기 금지/자기자신 재선택 금지/종료상태 잠금을 전부 프론트에서 하나하나 막아야 했고, 막을 때마다 새로운 구멍이 나왔음. **사용자님이 원래 기획 의도(진행 현황=읽기전용 표시, 관리=순차적 액션 버튼, "결제 완료 처리" 버튼과 동일한 패턴)를 지금이라도 따라가는 게 사이드 이슈 없이 제일 깔끔하다고 판단** → 드롭다운을 완전히 제거하고 버튼 방식으로 재구현.

### 설계
- "진행 현황" 칸: 이제 순수 읽기 전용 배지만 표시("결제 상태" 칸과 동일한 패턴). DELIVERY 행이 없으면 `-`.
- "관리" 칸: **"다음 단계로" 버튼 하나 + "주문 취소" 버튼**. 배송준비중→배송중→배송출발→배송완료 순서를 `STATUS_SEQUENCE`(고정 배열)로 못박아두고, 현재 상태에서 배열상 바로 다음 하나만 버튼으로 노출 — 애초에 잘못된 선택지 자체가 안 보이니 역행/건너뛰기/재선택 문제가 전부 사라짐.
- **"주문 취소" 버튼은 배송완료 전이면 모든 단계(심지어 DELIVERY 행이 아직 없는 상태)에서 노출**. 취소 자체는 원래 있던 로직(`updateDeliveryStatus`에 `CANCELED` 넘기기) 그대로 재사용 — 취소 관련 새 비즈니스 로직은 추가 안 함(사용자님 확인: admin 축소 구현 범위상 취소 후처리는 어차피 구현 안 할 거라, 버튼만 정상적으로 노출해두는 선에서 정리). 다만 DELIVERY 행이 없는 상태에서 취소가 막혀있던 것(배송준비중만 허용하던 기존 예외 처리)을 CANCELED도 같이 허용하도록 백엔드 수정 필요했음.
- 서버의 `DELIVERY_STATUS_RANK`도 맞춰서 변경: SHIPPED/OUT_FOR_DELIVERY를 동률(1)로 뒀던 걸 배송준비중(0)→배송중(1)→배송출발(2)→배송완료(3) 완전 선형 순서로 바꿈(취소는 항상 도달 가능하도록 3). 드롭다운이 없어지면서 "동시에 여러 옵션 중 고르기"가 필요 없어졌기 때문.
- 택배정보 모달 트리거 조건(3-7-1에서 고친 것)과 회귀/종료상태 서버 검증은 그대로 재사용 — 버튼이든 드롭다운이든 결국 같은 `updateDeliveryStatus` 엔드포인트를 호출하는 거라 백엔드 로직 대부분 안 건드림.

### 검증
STS 서버에 API로 전체 시퀀스 확인: (1) 배송준비중→배송중(신규 택배정보), (2) 배송중→배송출발(기존 택배정보 재사용, 모달 없이), (3) 배송출발→배송완료, (4) 배송완료 이후 아무 상태 변경 시도 거부(종료상태 잠금), (5) 배송중에서 배송준비중으로 역행 시도 거부, (6) 배송중에서 취소 성공, (7) **DELIVERY 행이 아예 없는 새 주문에서 바로 취소 성공**(이번에 새로 허용한 경로) — 전부 확인 완료. 브라우저 클릭 테스트는 여전히 못 했음 — 46번 주문(결제완료, DELIVERY 행 없음, 코코도르 그란데 디퓨저 18,800원)을 처음부터 눌러볼 수 있게 남겨둠.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderServiceImpl.java  (RANK 선형화, null-행 분기에 CANCELED 허용)
  src/main/resources/static/js/admin/adminOrderService.js                          (allowedNextStatuses -> nextStatus, NEXT_ACTION_LABEL 추가)
  src/main/resources/static/js/views/adminOrderDelivery.js                         (드롭다운 전체 제거, 배지+버튼 방식으로 재작성)
  src/main/resources/static/css/style_admin_order.css                              (.delivery-status-select 관련 스타일 제거, .btn-next-status/.btn-cancel-order/.action-cell 추가)
```

### 3-8-1. 추가 수정: "취소" → "취소/환불", 배송완료 후에도 취소/환불 가능하게

사용자님 피드백: "취소"에는 환불 의미도 있으니 문구를 "취소/환불"로 통일하고(대시보드 카드 라벨은 원래부터 "취소/환불"이었음 — 이제 나머지도 거기 맞춤), 배송완료된 주문도 취소/환불은 가능해야 한다는 지적. 반품/환불이 배송완료 이후에 일어나는 게 정상이니까 당연한 요구.

- **서버**: "종료 상태" 개념을 취소/환불에만 적용. 배송완료(`DELIVERED`)는 "정상적인 다음 단계는 없지만 취소/환불만은 가능한 상태"로 별도 취급 — `updateDeliveryStatus()`에서 `CANCELED`를 완전 종료로 막고, `DELIVERED`는 목표 상태가 `CANCELED`가 아닐 때만 막도록 분기. `DELIVERY_STATUS_RANK`는 그대로 둬도 됨(`CANCELED`가 `DELIVERED`와 동률(3)이라 역행 체크에 안 걸림).
- **프론트**: `TERMINAL_STATUSES`를 `['delivered','canceled']` → `['canceled']`로 축소 → 배송완료 행도 이제 `buildEditableCells()`를 타는데, `nextStatus('delivered')`가 `null`이라 "다음 단계로" 버튼 없이 "주문 취소/환불" 버튼만 자연스럽게 남음(코드 추가 없이 기존 분기 재사용).
- 문구 전부 통일: `STATUS_LABEL.canceled`, 버튼 텍스트, confirm() 문구, 필터 드롭다운 옵션 전부 "취소/환불"로. (배송정보 모달의 "취소" 버튼은 주문 취소가 아니라 "이 모달 닫기" 의미라 그대로 둠 — 헷갈리지 않게 구분.)

### 검증
API로: 배송완료 상태 주문(43번)에 취소/환불 시도 → 성공 확인, 그 후 다시 배송완료로 되돌리기 시도 → 거부 확인(취소/환불 자체는 여전히 진짜 종료 상태). 라벨 변경도 서버 응답 바이트 직접 디코딩해서 확인.

### 3-8-2. 추가 수정: 배지 텍스트 줄바꿈, 상품정보 null 표시

사용자님이 화면에서 발견: "결제완료"/"취소/환불" 배지 텍스트가 중간에서 줄바꿈되면서 깨져 보임, 45번 샘플 주문은 "상품 정보" 칸에 "(null개)"라고 나옴.

- **배지 줄바꿈**: `.payment-badge`/`.delivery-status-badge`/버튼들에 `white-space: nowrap` 없었음 — "관리" 칸이 버튼 2개(다음 단계로/취소·환불)로 넓어지면서 다른 칸들이 눌리자 배지 텍스트가 중간에서 줄바꿈됨. 관련 요소 전부에 `white-space: nowrap` 추가.
- **"(null개)"**: 45번 주문은 테스트용으로 SQL로 넣을 때 ORDERDETAIL을 안 넣어서 실제로 productName/qty가 null로 옴(진짜 버그 아니라 테스트 데이터 문제였음) — 다만 화면이 null을 그대로 문자열로 이어붙여서 보여준 건 방어 코드가 없었던 실제 허점이라, `productName`이 없으면 `-`로 표시하도록 `adminOrderDelivery.js`에 방어 코드 추가.

### 3-8-3. 추가 수정: 테스트 데이터 다양화 + 헤더 줄바꿈 + 기본 정렬

사용자님 요청 3가지:
1. **테스트용으로 다양한 상태 필요**: 42/43/45번이 전부 취소/환불 상태라 다양하게 못 눌러봄 → 45번을 다시 `PAYMENT_WAITING`(결제대기)으로 초기화하고, 이번엔 ORDERDETAIL도 제대로 넣어서 상품정보도 정상 표시되게 함. 지금 상태: 42/43=취소·환불, 45=결제대기, 46=결제완료(DELIVERY 행 없음) — 네 가지 다른 시작점에서 교차 검증 가능.
2. **"주문번호" 헤더도 줄바꿈됨**: `.admin-table thead th`에도 `white-space: nowrap` 없었음 → 추가.
3. **기본 정렬 + 정렬 토글**: 기존엔 `ORDER BY ORDER_DATE DESC, ORDER_ID DESC`(최신순)였는데 오름차순(주문번호 순)으로 기본 정렬되길 원함 → `AdminOrderMapper.xml`의 `selectOrderList`를 `ORDER BY ORDER_ID ASC`로 변경. 겸사겸사 "주문번호" 헤더를 클릭하면 오름차순/내림차순 토글되는 기능도 추가함(서버 재조회 없이 이미 불러온 목록을 클라이언트에서 재정렬 — 지금 데이터 규모에선 이 정도로 충분).

### 검증
API로 `/admin/order/list` 응답이 실제로 주문번호 오름차순(1,2,3,4,5...)으로 오는 것 확인. JSP/JS/CSS 변경사항도 서버 응답에서 직접 바이트 디코딩해서 전부 반영 확인.

### 신규/수정 파일
```
수정:
  src/main/resources/mappers/admin/AdminOrderMapper.xml       (ORDER BY ORDER_ID ASC로 변경)
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp  (주문번호 헤더를 정렬 토글 버튼으로)
  src/main/resources/static/js/views/adminOrderDelivery.js    (클라이언트 정렬 토글, 상품정보 null 방어)
  src/main/resources/static/css/style_admin_order.css         (배지/버튼/헤더 white-space:nowrap, .th-sort-btn 스타일)
```

### 3-8-4. 추가 수정: 택배사 자유 입력 → 드롭다운

사용자님이 화면에서 발견: 택배사 칸에 "우체국"처럼 아무 텍스트나 그대로 저장됨. `PAYMENT_NAME`(결제수단)처럼 DB에 CHECK 제약이 걸려있을 거라 예상했는데, 확인해보니 **`DELIVERY.COMPANY`엔 실제로 CHECK 제약이 없음**(스키마에 PK/DELIVERY_STATUS 체크/FK만 있고 COMPANY는 자유 `VARCHAR2(50)`) — 자유 입력이 그대로 저장된 게 맞았음. 드롭다운으로 바꿔서 값 자체를 제한하는 쪽으로 처리(DB 스키마는 안 건드림 — 이미 있는 자유 텍스트 컬럼에 지금 와서 CHECK 제약을 추가하는 건 더 큰 스키마 변경이라, 사용자님이 제안한 대로 애플리케이션 레벨에서 제한).

- 모달의 택배사 `<input type="text">` → `<select>`로 교체, 옵션 5개(CJ대한통운/한진택배/롯데택배/로젠택배/우체국택배).
- 서버(`AdminOrderServiceImpl`)에도 `VALID_COMPANIES` 목록을 두고 이 5개 중 하나가 아니면 거부하도록 검증 추가(프론트와 동일 목록 유지 — 목록 바꿀 땐 두 군데 다 고쳐야 함).
- **부수 효과 처리**: 드롭다운 도입 전에 자유 입력으로 저장된 기존 값(예: 46번 주문의 "우체국")은 이제 유효 목록에 없어서, "이미 택배정보 있으니 모달 없이 바로 저장" 조건에 `Service.isValidCompany(order.company)` 체크를 추가함 — 값이 유효 목록 밖이면 다음 단계로 넘어갈 때 모달을 다시 띄워서 정상 값으로 고르게 만듦(자연스러운 데이터 정정).

### 검증
API로 잘못된 값("우체국")으로 저장 시도 → 거부, 목록에 있는 값("우체국택배")으로 재시도 → 성공 확인. 페이지 HTML에서 `<select id="modal-company">`와 옵션 5개 렌더링도 확인.

## 3-9. 2026-08-29: 취소/환불 2단계(대기중 → 처리완료) + 결제 상태 칸에도 반영

사용자님 지적: 취소/환불 처리된 주문인데 "결제 상태" 칸이 그대로 "결제완료"로 나오는 게 이상함. `PRODUCTORDER.ORDER_STATUS`에 이미 `CANCELED` 타입이 있으니 그걸로 표시하는 게 맞지 않냐는 의견 + "취소/환불 누르면 대기중 → 처리완료 버튼 누르면 완료, 그때가 진짜 종료"라는 2단계 플로우 요청. **DB는 절대 alter하지 말 것**이라는 제약 하에 구현 가능한지 확인 후 진행.

### 가능했던 이유
스키마가 원래 `PRODUCTORDER.ORDER_STATUS`와 `DELIVERY.DELIVERY_STATUS` 두 컬럼으로 나뉘어 있다는 걸 이용함 — 새 컬럼도 새 CHECK 값도 필요 없이, **두 컬럼이 서로 다른 시점에 CANCELED가 되도록 순서를 쪼갬**:
- **대기중**: "주문 취소/환불" 버튼 → `DELIVERY_STATUS`만 `CANCELED`로 바뀌고, `ORDER_STATUS`는 이전 값(DELIVERED든 SHIPPED든) 그대로 둠(`updateDeliveryStatus`에서 `deliveryStatus`가 `CANCELED`일 때만 `updateOrderStatus` 동기화를 건너뛰도록 수정).
- **처리완료**: 새 버튼 "처리 완료" → 새 엔드포인트 `POST /admin/order/cancel-complete/{orderId}`(`AdminOrderServiceImpl.completeCancel()`) → 이때 비로소 `ORDER_STATUS`도 `CANCELED`로 맞춤. `DELIVERY_STATUS`가 이미 `CANCELED`가 아니면 거부, `ORDER_STATUS`가 이미 `CANCELED`면(중복 처리) 거부.
- 프론트(`normalizeOrder`)는 두 값을 조합해 `cancelStage`(`null`/`'pending'`/`'complete'`)를 계산 → "진행 현황"과 "결제 상태" 칸 둘 다 이 값을 보고 "취소/환불 대기중"/"취소/환불 완료"로 표시. "대기중"일 때만 "처리 완료" 버튼이 뜨고, "완료"가 돼야 진짜 종료(더 이상 아무 버튼 없음).

### 검증
API로 전체 플로우 확인: 배송완료 상태 주문 취소/환불 → `ORDER_STATUS`는 `DELIVERED` 그대로, `DELIVERY_STATUS`만 `CANCELED`(대기중) 확인 → 대기중 상태에서 배송상태 변경 재시도 → 거부 확인(기존 로직 그대로 재사용됨) → "처리 완료" 호출 → `ORDER_STATUS`도 `CANCELED`로 바뀜 확인 → 중복 처리 완료 시도 → 거부 확인. 45번 주문을 "대기중" 상태로 남겨둬서 화면에서 "처리 완료" 버튼 직접 눌러볼 수 있게 함.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderService.java      (completeCancel 추가)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminOrderServiceImpl.java  (취소시 ORDER_STATUS 동기화 보류 + completeCancel 구현)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminOrderController.java      (POST /admin/order/cancel-complete/{orderId})
  src/main/resources/static/js/admin/adminOrderService.js                          (cancelStage 계산, completeCancel 함수, 라벨 추가)
  src/main/resources/static/js/views/adminOrderDelivery.js                         (대기중/완료 분기 렌더링, 처리완료 버튼 핸들러)
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp                       (cancel-complete URL data 속성)
  src/main/resources/static/css/style_admin_order.css                              (cancel-pending/cancel-complete 배지, .btn-complete-cancel)
```

## 3-10. 2026-08-29: 전체 마무리 점검 (사용자 요청)

주문/배송 기능을 일단락하기 전에 사용자님 요청으로 전체 코드를 다시 훑어봄. 실제로 몇 가지 발견해서 고침:

1. **대시보드 "신규 주문"/"취소·환불" 중복 집계**: 배송 시작 전(DELIVERY 행이 없던 시점)에 바로 취소/환불하면 `ORDER_STATUS`가 `PAYMENT_COMPLETED`에 머물러 있는 "대기중" 상태가 되는데, `selectSummary` 쿼리가 이걸 신규주문 조건(`ORDER_STATUS IN (...)`)에서 걸러내지 않아서 신규주문과 취소/환불 카드에 동시에 잡히고 있었음. 실제로 재현 확인(테스트 주문으로 `newOrders:1`, `canceled:6` 동시 증가) → `selectSummary`의 신규주문 조건에 `DELIVERY_STATUS != 'CANCELED'`(또는 NULL) 조건 추가해서 해결.
2. **택배정보 모달의 택배사 `<select>`가 스타일 안 먹음**: 이전 세션에서 `<input type="text">`를 `<select>`로 바꿨는데, 모달 필드 CSS가 `input[type="text"]`에만 스코프돼 있어서 드롭다운이 브라우저 기본 스타일(송장번호 입력칸이랑 안 어울림)로 나오고 있었음 → CSS 선택자에 `select`도 포함시켜서 해결.
3. 그 외엔 코드 전체(백엔드 검증 로직, 프론트 상태 분기, 모달/버튼 이벤트 핸들러, dead code 잔존 여부)를 다시 훑었는데 추가로 걸리는 건 없었음.

### 검증
API로 새 버그(1번) 재현 후 수정 확인(수정 전 후 summary 값 비교), 서버 응답 바이트 디코딩으로 두 파일 변경사항 반영 확인.

### 원래 HANDOFF 3번 섹션에서 아직 안 끝난 항목 (참고용 재정리)
1, 3, 7번은 이번 세션들에서 다 해결됨. **아직 안 건드린 것**:
- **2번 (대표 상품 선정 방식)**: `ORDERDETAIL` 중 가장 먼저 담긴 1건 기준 그대로 유지 중 — 재검토 결과 바꿀 이유를 못 찾음, 필요해지면 그때 기준 다시 논의.
- **4번 (orderId 포맷)**: `PRODUCTORDER.ORDER_ID` 숫자 그대로 노출 중, 목업의 `YYYYMMDD-NNN` 포맷은 미적용 — 순수 화면 표시 문제라 우선순위 낮음.
- **5번 (페이지네이션 미연동)**: 여전히 정적 목업(1~5 버튼), 실제 페이징 쿼리 연동 안 됨.
- **6번 (필터 클라이언트 처리)**: 여전히 프론트에서 전체 목록 불러온 뒤 필터링, 서버사이드 필터링 안 됨.

그리고 이번 세션들에서 새로 발견했지만 **의도적으로 범위 밖으로 남겨둔 것들**:
- ~~`adminPage.jsp` 헤더/푸터 미연결~~ **정정**: 이 목록 자체가 stale했음 — 실제로는 3-4 섹션에서 이미 고쳐져 있었음(사용자님이 그때 "adminPage.jsp도 같이 고쳐달라"고 요청했었고, 그때 바로 처리됨). 3-9 요약에서 "안 고침"이라고 잘못 재보고했던 것 — 이 파일(HANDOFF.md) 스스로도 상태가 낡을 수 있으니 다음에 참고할 때 실제 파일을 다시 확인할 것.
- `style_member.css`/`style_addreview.css`/`style_addProduct.css`엔 여전히 스코프 없는 `body{}`가 남아있음 — 3-11 섹션에서 재검토(범위가 admin보다 커서 이번엔 보류).
- `ProductController.detailPage()`가 `Model`도 안 받고 `redirect:home/home`으로만 리다이렉트해서 상품 상세 페이지가 실제로 렌더링이 안 됨 (3-6 섹션에서 발견, 원래부터 있던 별개 버그, 사용자님이 이번엔 손대지 말라고 확인함).

## 3-11. 2026-08-29: 간단히 끝낼 수 있는 것들 마무리

사용자님이 "간단한 것들 끝내버리자"고 해서 원래 목록(5번 페이지네이션) + 발견했던 항목(adminPage.jsp) 처리:

- **`adminPage.jsp` 헤더/푸터**: 확인해보니 이미 3-4에서 고쳐져 있었음 — 새로 할 일 없음(위 정정 참고).
- **페이지네이션(5번)**: 서버 페이징 없이, 이미 클라이언트가 들고 있는 필터링/정렬된 전체 목록을 `PAGE_SIZE=10`으로 잘라서 보여주는 방식으로 구현. 페이지 번호 버튼은 현재 페이지 중심으로 최대 5개까지만 보임(목업 폭과 동일). 검색/필터/정렬이 바뀌면 1페이지로 리셋되지만, 저장/취소 등 액션 후 `loadOrders()`로 새로고침될 땐 보던 페이지 유지됨. 테스트용으로 주문 하나 더 추가해서(총 11개) 2페이지로 나뉘는 것 확인.
- **필터 클라이언트 처리(6번)**: 원래 "지금은 이대로 두자"고 확정했던 사항이라 할 일 없음.
- **orderId 포맷(4번)**: 목업 포맷을 억지로 흉내내면 실제 PK가 아닌데 그렇게 보이는 시각적 왜곡이 생겨서 스킵.

**보류한 것**: `style_member.css`/`style_addreview.css`/`style_addProduct.css`의 스코프 없는 `body{}` — 처음엔 "이것도 같은 패턴이라 간단하다"고 생각했는데, 다시 보니 `style_member.css`엔 이미 `.login-page main`처럼 스코프된 선택자가 있어서(로그인/회원가입 등 여러 페이지가 이 파일 하나를 공유) 최상단 `body{}`만 고치려 해도 그 페이지들(login.jsp/signUp.jsp/userWithdraw.jsp/userUpdateInfo.jsp/usercouponView.jsp/userOderDelivery.jsp 등, 전부 안 열어본 상태)이 실제로 `.xxx-page main`이 통하는 구조인지 하나하나 확인해야 함 — admin 페이지들처럼 이미 다 파악하고 있는 영역이 아니라 회원/유저 커머스 쪽이라 더 조심스러움. 이번엔 손 안 댐.

### 신규/수정 파일
```
수정:
  src/main/webapp/WEB-INF/views/admin/adminOrderDelivery.jsp  (정적 페이지네이션 마크업 -> JS가 채우는 빈 마크업)
  src/main/resources/static/js/views/adminOrderDelivery.js    (paginate/renderPagination, 필터/정렬 변경 시 1페이지 리셋)
  src/main/resources/static/css/style_admin_order.css         (pagination button:disabled 스타일)
```

---

## 3-12. 2026-08-29: 상품 등록(addProduct.jsp) 정비

주문/배송을 일단락하고 다음 날 상품 등록 쪽으로 넘어와서 사용자님이 지적한 5가지 처리:

1. **`style_addProduct.css`의 스코프 없는 `body{}` 제거**: 사이트 전체 폰트가 Arial로 보이던 원인(3-6에서 유일하게 남겨뒀던 파일). `body{background/color/font-family}`를 `.product-register` 선택자에 병합(다른 페이지들과 동일한 "단일 wrapper에 병합" 패턴, `min-height:100vh` 추가). `html,body{margin:0;padding:0}`은 `default.css`가 이미 동일하게 처리하고 있어 제거.
2. **재고/설명이미지 필드는 기획 확정**(사용자님 확인: 필수 사항) → 설명 이미지 영역에 `*` 필수 표시 추가 + JS에 "최소 1장 이상" 검증 추가(재고는 이미 필수 처리돼 있었음).
3. **JS 분리 컨벤션 적용**: 인라인 `<script>` 전체를 `static/js/admin/adminProductService.js`(비즈니스 로직 — `registerProduct()` fetch 호출만, `window.AdminProductService`)와 `static/js/views/addProduct.js`(태그/이미지 UI, 모달, 폼 검증 등 인터랙션)로 분리. `<c:url>`로 만든 등록 URL은 `.product-register` wrapper의 `data-register-url` 속성에 심어서 외부 JS가 읽음(3-1에서 만든 패턴 그대로).
4. **태그 UI 정리**: "기존 태그"(DB에서 불러온 선택 팔레트) 칩에 있던 X(삭제) 버튼 제거 — 클릭하면 어차피 선택 해제만 하고 실제 삭제는 안 하는데, X 아이콘이 "삭제"처럼 보여서 혼란스럽다는 지적. 클릭 토글만 남기고, X 버튼은 "현재 상품 태그"(적용될 태그) 목록에만 남김(여기선 실제로 선택에서 제거하는 의미라 X가 맞음).
5. **누락된 필수 필드 추가**: `PRODUCT.PRODUCT_TITLE`(상품 게시글 제목 - 목록/검색 카드에 노출)와 `PRODUCTOPTION.OPTION_NAME`(옵션명)이 폼에 아예 없어서 지금까지 전부 `productName` 값 하나가 세 컬럼(PRODUCT_TITLE/PRODUCT_NAME/OPTION_NAME)에 동일하게 들어가고 있었음 → 폼에 "상품 게시글 제목", "옵션명" 입력 필드 신규 추가, `ProductInsertDTO`에 `productTitle` 필드 추가, 컨트롤러/서비스/매퍼 시그니처 전부 3개 값을 독립적으로 받아 전달하도록 수정.

### 검증
STS 서버(8797)에 관리자 로그인 후 실제로 상품 등록 API를 호출해서 대표이미지+설명이미지 포함 전체 플로우 확인 — DB에 `PRODUCT_TITLE`/`PRODUCT_NAME`/`OPTION_NAME`이 각각 다른 값으로 정상 저장됨을 jshell로 직접 조회해 확인(테스트 데이터는 확인 후 삭제함). 페이지 HTML도 직접 받아서 새 필드 2개, 필수 표시, 태그 목록에 X 버튼 없음, 새 JS 파일 2개 정상 로드(200) 전부 확인. **브라우저 클릭 테스트(태그 모달, 이미지 업로드 미리보기 등 시각적 요소)는 못 함** — 화면에서 한 번 확인 필요.

### 신규/수정 파일
```
신규:
  src/main/resources/static/js/admin/adminProductService.js
  src/main/resources/static/js/views/addProduct.js

수정:
  src/main/resources/static/css/style_addProduct.css                              (body{} 제거, .product-register로 병합)
  src/main/webapp/WEB-INF/views/admin/addProduct.jsp                              (필드 2개 추가, 태그 X버튼 제거, data-register-url, 인라인 script -> src 2개)
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/ProductInsertDTO.java         (productTitle 필드)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminProductController.java  (productTitle/optionName 파라미터)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductService.java  (시그니처 변경)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductServiceImpl.java (검증 + DTO 매핑)
  src/main/resources/mappers/admin/AdminProductMapper.xml                         (insertProduct에 productTitle 바인딩)
```

## 3-13. 2026-08-29: 상품 등록 화면 실사용 버그 수정 + 최종 검증

사용자님이 실제로 화면에서 눌러보며 발견한 문제들 + 마지막 전체 재검토:

1. **`.product-register`에 `min-height:100vh` 넣은 것 제거** — 3-12에서 body{} 병합하며 추가했었는데, 다시 보니 이 페이지 콘텐츠 자체가 이미 한 화면(100vh)보다 훨씬 길어서 사실상 아무 효과가 없는 속성이었음(제거해도 안 해도 시각적으로 동일) → "잘려 보이는" 문제의 진짜 원인은 아래 2번(죽은 헤더/푸터 CSS)과 3번(패딩 누락)이었음, 이 항목은 원인이 아니었던 걸로 정정. (참고: `.add-coupon-page`처럼 콘텐츠가 짧은 페이지에서는 `min-height:100vh`가 배경을 화면 끝까지 채우기 위해 실제로 필요하니, "무조건 빼야 한다"는 규칙은 아님 — 콘텐츠가 이미 100vh를 넘는지 먼저 확인할 것.)
2. **`style_addProduct.css`에 죽은 헤더/카테고리/푸터 CSS가 통째로 남아있던 것 발견 + 제거** — addProduct.jsp가 독립 페이지였을 때 쓰던 구버전 CSS(`#site-header`, `#logo_img`, `#search_box`, `#search_input`, `.icon`, `.sign`, `.category-nav`, `.site-footer`, `.footer-top` 등)가 안 지워지고 남아있었는데, 하필 지금 공용 `header.jsp`/`footer.jsp`가 실제로 쓰는 것과 **완전히 같은 id/class명**이라 사이트 전체의 진짜 헤더/푸터 스타일(`style.css`, 세이지그린 그리드 레이아웃)을 덮어쓰고 있었음. 특히 `#search_input`은 ID 선택자라 로드 순서와 무관하게 항상 이겼음. 통째로 삭제.
3. **`.product-register`에 좌우 패딩이 원래 없었음**(`padding:70px 0 100px` — 위아래만) → 내부 콘텐츠가 바깥 배경 박스 가장자리에 그대로 붙어 "잘린 것처럼" 보임. 쿠폰 등록 카드(`.add-coupon-page-card{padding:40px}`)와 동일 기준으로 `padding:70px 40px 100px`로 수정. (이건 이번 세션에서 새로 생긴 버그가 아니라 addProduct.jsp가 원래부터 갖고 있던 문제 — 쿠폰 페이지와 비교해보고서야 발견됨.)
4. **대표 이미지에 미리보기가 아예 없었음** — 추가/설명 이미지는 파일 선택 시 썸네일이 뜨는데 대표 이미지만 안 뜸(기존 로직 자체가 없었음). 레이블 내용을 실제 이미지로 바꿔치기 + 다른 썸네일과 동일한 스타일의 × 제거 버튼 추가.
5. **여러 장 업로드 시 순서를 못 바꿈** — 한 번에 여러 파일 선택하면 브라우저가 넘겨주는 순서가 뒤죽박죽인데 고정할 방법이 없었음 → 추가/설명 이미지 썸네일에 HTML5 드래그 앤 드롭으로 순서 변경 기능 추가(드래그 중 반투명, 드롭 대상에 테두리 표시).
6. **파일 업로드 크기 제한이 주석 처리된 채 방치돼 있었음** — `application.properties`에 `spring.servlet.multipart.max-file-size`/`max-request-size`가 값까지 적혀있는데 주석(`#`) 처리라 Spring 기본값(1MB/10MB)이 적용되고 있었음 → 실사진 여러 장 업로드 시 "Failed to fetch"(서버가 연결을 끊어서 브라우저가 네트워크 에러로 인식)로 나타남. 주석 해제해서 파일당 10MB/요청 전체 50MB로 활성화.
7. **최종 검증 라운드에서 서버 검증 3종 추가**: (a) 가격/재고 음수 값 서버 거부(`price < 0`/`stock < 0`) — 재고는 DB CHECK로 막히긴 했지만 처리 안 된 예외(500)로 나타났었음, 가격은 DB 제약조차 없어 그냥 저장되고 있었음. (b) 카테고리 미선택 시 서버 거부 — 원래 optional 파라미터라 API로 우회하면 카테고리 없이 등록 가능했음. (c) 업로드 파일의 `Content-Type`이 image/jpeg·png·webp가 아니면 거부(디스크에 쓰기 전에 전부 미리 검사 — 트랜잭션 롤백은 DB에만 적용되고 파일엔 적용 안 되므로, 뒤쪽 파일이 걸렸을 때 앞쪽 파일만 남는 것도 방지). Content-Type 헤더만 보는 수준이라 완벽한 방어는 아님(헤더 자체를 위조하면 우회 가능) — 학교 프로젝트 스코프에 맞춘 선.
8. **설명 이미지 "필수" 규칙이 서버엔 없었음**(3-12에서 만든 갭) — JS만 검증하고 `AdminProductServiceImpl`엔 대표 이미지만 필수 체크가 있었음 → 동일하게 서버 검증 추가.

**의도적으로 보류한 것**:
- 태그 등록 시 태그 개수만큼 개별 쿼리(find-or-create): 상품 하나당 한 번만 도는 관리자 액션이라 지금 규모(태그 10~20개)에서는 성능 문제 없다고 판단, 배치로 안 바꿈. 나중에 상품 상세/목록 화면에서 태그를 얼마나 노출할지 정해지면 그때 필요성 재검토하기로 함.
- 재고 0일 때 STATUS 자동 SOLD_OUT 전환: `product`/`productDetail` 쪽 노출 로직과 얽혀있어 범위 밖으로 보류.

### 검증
STS 서버(8797)에 API로: 음수 가격/재고/카테고리 누락/잘못된 파일타입 4가지 케이스 전부 거부 확인, 정상 케이스는 여전히 성공 확인, 거부된 케이스들이 DB에 고아 데이터를 안 남기는 것도 jshell로 확인. 사용자님이 실제 화면에서 대표+추가1장+설명4장 포함해서 실제 상품(하겐다즈 케이크) 하나를 처음부터 끝까지 등록 성공 → PRODUCT_TITLE/PRODUCT_NAME/OPTION_NAME/카테고리/태그3개/이미지6장 전부 DB에 정확히 저장된 것 jshell로 대조 확인 완료.

### 신규/수정 파일
```
수정:
  src/main/resources/static/css/style_addProduct.css        (min-height:100vh 제거, 죽은 헤더/카테고리/푸터 CSS 삭제, 좌우 패딩 추가, 태그 패딩 대칭화, 드래그 스타일, 대표이미지 remove 버튼 스타일)
  src/main/resources/static/js/views/addProduct.js          (대표 이미지 미리보기, 드래그 순서 변경)
  src/main/resources/application.properties                 (multipart 크기 제한 주석 해제)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductServiceImpl.java  (가격/재고/카테고리/파일타입 검증, 설명이미지 필수 검증)
```

### 남은 것 (다음에 이어서 할 것)
- 쿠폰 등록/삭제(addCoupon.jsp/admincouponView.jsp) — 아직 인라인 `<script>` 그대로, JS 분리 컨벤션 미적용
- `style_member.css`/`style_addreview.css`의 스코프 없는 `body{}` — 여전히 보류 중(3-11 참고, 회원 페이지 쪽이라 조심스럽게 남겨둠)
- `ProductController.detailPage()` 리다이렉트 버그 — 여전히 손대지 말 것

## 3-14. 2026-08-29: 쿠폰 등록 서버 검증 보강

상품 등록 최종 검토(3-13)와 같은 관점으로 쿠폰 등록도 훑어봤고, 발견한 4가지를 전부 수정:

1. **쿠폰명 빈 문자열 서버 검증 없었음**: `COUPON_NAME VARCHAR2(50) NOT NULL`인데 서버는 빈 문자열을 안 막아서 Oracle이 NULL 취급 → 처리 안 된 예외(500) 노출 가능(화면은 JS가 막지만 API 직접 호출로 우회 가능). `couponName == null || isBlank()` 체크 추가.
2. **쿠폰명 50자 길이 제한 서버 검증 없었음**: 초과 시 마찬가지로 처리 안 된 예외. 길이 체크 추가 + 화면 입력창에도 `maxlength="50"` 추가(원래 빠져있었음 — 태그 모달 입력창엔 있었는데 여기는 없었음).
3. **발급일보다 종료일이 빠른 경우 검증 없었음**: 서버에 `endDate.isBefore(effectiveStart)` 체크 추가(발급일 미입력 시 오늘 기준). 화면에도 동일 조건으로 alert 추가(기존엔 `min` 속성만 있어서 강제력 없었음).
4. **종료일이 과거인 경우 검증 없었음**(사용자님 확인: 정책 위반이라 막아야 함) — 서버에 `endDate.isBefore(today)` 체크 추가, 화면에도 `endDate.min = today` 기본값 설정 + alert 추가.

### 검증
API로 5가지 케이스 확인: 빈 이름 거부, 51자 이름 거부, 과거 종료일 거부, 발급일보다 빠른 종료일 거부, 정상 케이스는 성공 — 전부 의도대로 동작 확인, 테스트로 만든 쿠폰은 삭제함.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java  (이름 필수/길이, 날짜 검증 추가)
  src/main/webapp/WEB-INF/views/admin/addCoupon.jsp                                  (maxlength 추가, 날짜 검증 alert 추가)
```

### 남은 것 (다음에 이어서 할 것)
- `style_member.css`/`style_addreview.css`의 스코프 없는 `body{}` — 여전히 보류 중
- `ProductController.detailPage()` 리다이렉트 버그 — 여전히 손대지 말 것

## 3-15. 2026-08-29: 쿠폰 두 화면 JS 분리 컨벤션 적용

addCoupon.jsp/admincouponView.jsp 둘 다 인라인 `<script>`로 남아있던 것을 3-1에서 만든 컨벤션대로 분리:

- `static/js/admin/adminCouponService.js`(신규) — 비즈니스 로직. `registerCoupon`/`fetchCoupons`/`deleteCoupons`(fetch 호출) + `formatDeadline`/`formatPercent`(표시용 데이터 가공), `window.AdminCouponService`로 노출.
- `static/js/views/addCoupon.js`(신규) — 발급일/종료일 min 제약, 폼 검증(3-14에서 추가한 날짜 검증 포함), 등록 버튼 클릭 핸들러. `.add-coupon-page`의 `data-register-url`/`data-list-url` 속성에서 URL을 읽음.
- `static/js/views/admincouponView.js`(신규) — 카드 렌더링/검색/전체선택/삭제 버튼 등 인터랙션. `.admin-coupon-view-page`의 `data-list-url`/`data-add-url`/`data-delete-url` 속성에서 URL을 읽음.
- 두 JSP 다 인라인 `<script>` 블록을 `<script src>` 2개(business 먼저, interaction 나중)로 교체. (주문/배송 페이지의 `var`+IIFE 스타일을 따름 — addProduct.js는 top-level `const`를 썼는데, 나중에 통일하고 싶으면 그것도 손볼 것)

### 검증
API로 쿠폰 등록→목록조회→삭제 전체 흐름을 실제 JS가 호출하는 것과 동일한 엔드포인트로 재현해서 5→6→5개로 정상 증감하는 것 확인, 두 페이지 다 200 응답 + 새 JS 파일 3개 전부 200 로드 확인, `data-*` 속성도 정상 렌더링 확인.

### 신규/수정 파일
```
신규:
  src/main/resources/static/js/admin/adminCouponService.js
  src/main/resources/static/js/views/addCoupon.js
  src/main/resources/static/js/views/admincouponView.js

수정:
  src/main/webapp/WEB-INF/views/admin/addCoupon.jsp        (data-* 속성, 인라인 script -> src 2개)
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp  (data-* 속성, 인라인 script -> src 2개)
```

### 남은 것
- `style_member.css`/`style_addreview.css`의 스코프 없는 `body{}` — 여전히 보류 중
- `ProductController.detailPage()` 리다이렉트 버그 — 여전히 손대지 말 것
- addProduct.js가 다른 interaction 파일들과 스타일이 다름(top-level const vs var+IIFE) — 원하면 통일

## 3-16. 2026-08-29: 쿠폰 목록/등록 화면 UI 개선 2건 + 날짜 검증 강화

사용자님이 화면 써보다가 요청한 것들:

1. **"발급 이력 있는 쿠폰은 수정/삭제 불가" 안내 문구 추가**: 기존엔 카드의 "발급 이력 있음" 배지에 마우스 올려야만 보이는 `title` 툴팁으로만 설명돼있어서 놓치기 쉬웠음 → "등록된 쿠폰" 제목 바로 아래에 상시 노출되는 문구(`<p class="coupon-notice">`) 추가.
2. **날짜 입력창이 달력 아이콘을 눌러야만 열림**: `input[type=date]`의 기본 동작 — 박스 전체를 클릭해도 달력이 뜨도록 `click` 이벤트에서 `showPicker()` 호출(지원 안 하는 브라우저는 그냥 기존 아이콘 클릭 동작으로 자연스럽게 폴백).
3. **(3-14 보강) 종료일에 "오늘"도 허용하면 안 됨** — DEADLINE이 날짜만 저장하고 시/분 정보가 없어서, 종료일을 오늘(또는 발급일과 같은 날)로 고르면 사실상 발급되자마자 만료되는 것과 동일한 문제. 사용자님 확인 후 검증을 `endDate >= today` → `endDate > today`로, `endDate >= 발급일` → `endDate > 발급일`로 강화(서버+화면 양쪽, `min` 속성도 발급일 다음날부터로 조정).

### 검증
API로 "종료일=오늘"/"발급일=종료일(같은 날)" 둘 다 거부되는 것, "종료일=내일"/"발급일 다음날" 둘 다 성공하는 것 확인 — 테스트 쿠폰은 삭제함. 안내 문구/날짜 클릭 오픈은 페이지 HTML·JS 서버 응답으로 반영 확인.

### 신규/수정 파일
```
수정:
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp                          (안내 문구 추가)
  src/main/resources/static/css/style_admincouponView.css                          (.coupon-notice 스타일)
  src/main/resources/static/js/views/addCoupon.js                                  (showPicker 클릭 오픈, 날짜 검증 강화)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java (날짜 검증 강화)
```

## 3-17. 2026-08-29: 만료 배지 문구 다듬기 + 만료 배지 기능 연결 + 만료 테스트 데이터

사용자님이 3-16의 alert 문구가 어색하다고 지적 + 만료된 쿠폰이 DB에 있는지 확인 요청(있는데 안 보이는 건지 확인용) + 만료 배지 기능 요청 3가지 처리:

1. **alert 문구 자연스럽게 수정**: "종료일에는 시간을 따로 지정할 수 없어서..." 같은 장황한 문구를 사용자님이 제안한 "종료일을 발급일과 동일하게 설정할 수 없습니다.\n내일 이후를 선택해 주세요."로 교체(줄바꿈 포함, `alert()`는 `\n`을 그대로 줄바꿈으로 표시함). 겸사겸사 "오늘=종료일" 체크와 "발급일=종료일" 체크 두 개로 나뉘어 있던 걸 `effectiveStart`(발급일 미입력 시 오늘) 기준 하나로 합쳐서 단순화.
2. **UI 단에서 아예 못 고르게**: 사실 3-16에서 이미 `endDate.min`을 발급일(또는 오늘) 다음날로 맞춰놔서, 네이티브 달력에서 해당 날짜들이 회색으로 비활성화되어 있음 — alert는 수동 타이핑 등으로 우회했을 때를 위한 이중 방어일 뿐, 정상적인 달력 클릭 흐름에서는 애초에 선택이 안 됨.
3. **만료 쿠폰 DB 조회 결과**: 등록된 쿠폰 5개 전부 종료일이 미래라 만료 0건 — "있는데 안 보이는" 게 아니라 "애초에 없어서" 안 보이는 상황이었음.
4. **만료 배지 기능 연결**: 확인 과정에서 `style_admincouponView.css`에 `.coupon-status`/`.active`/`.expired` 스타일이 이미 정의돼 있는데 `admincouponView.js`에서 전혀 안 쓰고 있는 걸 발견 — 원래 정적 목업 단계부터 마커만 있고 내용은 비어있던 미완성 자리(`static/temp/admincouponView.html`에서도 확인, 카드 마크업에 빈 자리만 있음). `AdminCouponService.isExpired(deadline)` 추가(문자열 날짜 비교, ISO 형식이라 사전식 비교로 충분) + `admincouponView.js`의 `buildCard()`에 `.coupon-status.active`("진행중")/`.coupon-status.expired`("만료") 배지 렌더링 연결.
5. **만료 테스트 데이터 추가**: "여름 시즌 할인 쿠폰(만료)" (20%, DEADLINE 2026-08-01, 발급 이력 없음) 하나를 jshell로 직접 INSERT — 화면에서 만료 배지가 실제로 뜨는지 확인할 수 있게. 발급 이력이 없어서 삭제도 자유롭게 가능(테스트 끝나면 지워도 되고, 그냥 둬도 됨).

### 검증
API로 `/admin/coupon/list` 응답에 ID 46(여름 시즌 할인 쿠폰(만료)) 포함 확인, `admincouponView.js`/`adminCouponService.js`에 배지 로직 반영 확인, `addCoupon.js`에 새 alert 문구 반영 확인. 브라우저에서 실제 배지 색상/문구 확인은 못 함 — 화면에서 확인 필요.

### 신규/수정 파일
```
수정:
  src/main/resources/static/js/views/addCoupon.js         (alert 문구 통합/수정)
  src/main/resources/static/js/admin/adminCouponService.js (isExpired 추가)
  src/main/resources/static/js/views/admincouponView.js    (만료/진행중 배지 렌더링)
```

## 3-18. 2026-08-29: 날짜 min 계산에 타임존 버그 발견 + 수정

사용자님이 화면에서 종료일 캘린더를 직접 열어보다가 발견: 종료일 선택창을 열면 "오늘" 날짜가 비활성화 안 돼있고 실제로 클릭하면 선택까지 됨(3-17에서 "발급일/오늘과 같은 날은 막았다"고 했던 것과 모순). 원인 추적 결과 진짜 버그였음:

- `addCoupon.js`가 "내일 날짜"를 구할 때 `new Date(dateStr+'T00:00:00'); d.setDate(d.getDate()+1); d.toISOString().split('T')[0]` 방식을 썼는데, **`toISOString()`은 항상 UTC로 변환**해서 반환함. 서버/사용자 환경이 한국(UTC+9)이라, 로컬 자정 기준으로 하루를 더한 뒤 UTC로 변환하면 시간대 차이(9시간)에 의해 날짜가 도로 원래 날짜로 계산되는 경우가 생김(직접 재현: `nextDay('2026-08-29')`가 `'2026-08-30'`이 아니라 `'2026-08-29'`를 반환) → `endDate.min`이 "오늘"로 설정되면서 오늘 날짜가 비활성화 안 됨. `adminCouponService.js`의 `isExpired()`도 같은 패턴(`new Date().toISOString()`으로 "오늘"을 구함)이라 자정~오전 9시 사이엔 "오늘"이 하루 전으로 잘못 계산되는 잠재 버그가 있었음(이건 화면에서 직접 재현되진 않았지만 코드 검토로 발견).
- **수정**: `toISOString()`을 아예 쓰지 않고, `getFullYear()`/`getMonth()`/`getDate()`로 로컬 날짜 문자열을 직접 조립하는 `toDateString()`/`getTodayString()`/`getNextDayString()`을 `adminCouponService.js`(비즈니스 로직 파일)에 추가하고 `window.AdminCouponService`로 노출 → `addCoupon.js`와 `isExpired()` 둘 다 이 공유 함수를 쓰도록 교체. `static/js` 전체에서 `toISOString()` 쓰는 다른 곳 없는지 grep으로 재확인함(없음).

### 검증
서버(jshell 아님, Get-Date로 확인) 로컬 시각이 KST인 것 확인, 코드 리뷰로 버그 재현 경로 검증(수동 계산: 기존 코드가 8/29 → 8/29를 반환하던 것을 새 코드는 8/29 → 8/30으로 정확히 계산함). 서버에 새 JS 반영 확인. **브라우저에서 실제 캘린더 UI로 재확인은 필요** — 화면에서 오늘 날짜가 이제 진짜 비활성화되는지 봐줘야 함.

### 신규/수정 파일
```
수정:
  src/main/resources/static/js/admin/adminCouponService.js (toDateString/getTodayString/getNextDayString 추가, isExpired 수정)
  src/main/resources/static/js/views/addCoupon.js          (nextDay 로컬 함수 제거, 공유 함수 사용)
```

## 3-19. 2026-08-29: 쿠폰 삭제를 "전부 삭제 또는 전부 미삭제"로 변경

사용자님이 발급 이력 있는 쿠폰이 섞인 채로 여러 개 선택해서 삭제 눌렀을 때 지적: (1) 어떤 게 삭제됐는지 화면에서 알기 어려운데 에러 메시지가 "미삭제: [1, 2, 3]" 식으로 **쿠폰 ID를 그대로 노출**해서 이상함(일반 판매자가 쿠폰 ID를 알 방법이 없음), (2) 그냥 발급 이력 있는 쿠폰이 선택에 하나라도 포함되면 나머지도 전부 삭제하지 말라는 요청(부분 삭제가 오히려 헷갈림, 만료 여부는 이번 삭제 차단 기준과 무관 — 발급 이력만 기준).

- `AdminCouponServiceImpl.deleteCoupons()`: 이력 있는 게 하나라도 있으면 `mapper.deleteCoupons()` 자체를 호출하지 않고 즉시 반환(전부 미삭제) — 기존엔 이력 없는 것만 걸러서 부분 삭제했음.
- `AdminCouponController.delete()`: 차단됐을 때 `ApiResponse.success(부분삭제메시지, result)`가 아니라 `ApiResponse.fail("선택한 쿠폰 중 발급 이력이 있어 삭제할 수 없는 쿠폰이 포함되어 있습니다. 해당 쿠폰을 선택에서 제외한 뒤 다시 시도해 주세요.")`로 변경 — ID 목록 없이 그냥 "섞여있다"는 것만 안내. 프론트(`admincouponView.js`)는 이미 `.then`/`.catch`로 성공/실패를 나누고 있어서 코드 변경 없이 그대로 맞물림(실패 시 `loadCoupons()` 재호출도 자연스럽게 안 함 — 어차피 아무것도 안 바뀌었으므로).

### 검증
API로 (1) 이력 있는 것만 선택 → 거부, (2) 이력 있는 것 + 이력 없는 것 섞어서 선택 → 전체 거부(이력 없는 것도 안 지워지는 것까지 재확인 — 처음 확인할 때 검증 스크립트 실수로 "지워진 것처럼" 잘못 나왔었는데, 새 테스트 쿠폰으로 다시 깨끗하게 재현해서 실제로는 안 지워지는 것 확인함), (3) 이력 없는 것만 선택 → 정상 삭제. 테스트용 만료 쿠폰(3-17에서 만든 것)이 이 과정에서 같이 지워져서, 화면 확인용으로 동일한 쿠폰을 다시 만들어둠(COUPON_ID=48, "여름 시즌 할인 쿠폰(만료)").

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java (전부-삭제-or-전부-미삭제로 변경)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminCouponController.java     (실패 메시지에서 ID 노출 제거, fail()로 변경)
```

## 3-20. 2026-08-29: 로그인 후 원래 요청했던 페이지로 복귀

사용자님 지적: 로그인 필요한 페이지 접속 시도 → 로그인 화면 뜨는 것까진 맞는데, 로그인 성공 후 원래 가려던 페이지가 아니라 항상 메인으로 보내져서 불편함.

### 원인
`LoginInterceptor`(비로그인 시 리다이렉트)와 `MemberController.login()`(POST) 둘 다 이미 `redirectURL` 파라미터를 절반은 다루고 있었는데, **중간 연결고리 두 개가 빠져있었음**:
1. `MemberController.loginForm()`(GET)이 `redirectURL` 쿼리 파라미터를 아예 안 읽고 모델에도 안 담았음.
2. `login.jsp`의 `<form>`에 `redirectURL`을 담아 넘길 hidden 필드가 없었음.
→ 결과: 인터셉터가 `/member/login?redirectURL=...`로 보내도, 로그인 폼 제출 시점엔 이 값이 통째로 유실되어 POST 핸들러가 항상 기본값(`redirect:/`)으로 빠짐.

추가로 확인한 것: **admin 3개 컨트롤러(`AdminProductController`/`AdminOrderController`/`AdminCouponController`)의 로그인 필요 페이지는 애초에 `redirectURL` 자체를 전혀 안 붙이고 있었음**(그냥 `"redirect:/member/login"` 고정 문자열) — 관리자 페이지 접근 시도는 이번 기능 대상에서 원래 빠져있던 부분이라 같이 처리함.

### 수정
- `MemberController.loginForm()`: `redirectURL` 파라미터를 받아 모델에 담음(안전성 검증 통과 시에만).
- `login.jsp`: `<form>` 안에 `<input type="hidden" name="redirectURL" value="${fn:escapeXml(redirectURL)}">` 추가(`fn:escapeXml`로 이스케이프 — 안 하면 반사형 XSS 가능했음).
- `MemberController.login()`(POST): 로그인 실패 시에도 `redirectURL`을 들고 로그인 페이지로 되돌아가게(기존엔 실패 시 이 값을 버렸음).
- **오픈 리다이렉트 방지**: `isSafeRedirect()` 헬퍼 추가 — `redirectURL`이 `/`로 시작하고 `//`로는 시작하지 않는 내부 상대경로일 때만 신뢰(`http://evil.com`, `//evil.com` 같은 외부 주소는 무시하고 그냥 메인으로 감). GET/POST 양쪽 다 이 검증을 거침.
- `LoginInterceptor`: 원래 요청 URI만 담았는데, 쿼리스트링도 있으면 같이 붙여서 보존(`?tab=x` 같은 파라미터도 로그인 후 살아남게).
- admin 3개 컨트롤러의 `checkAdminPage()`: `HttpServletRequest`를 받아 인터셉터와 동일한 방식으로 `redirectURL`을 붙여서 로그인 페이지로 보내도록 변경.

### 검증
API로: (1) 비로그인 상태로 `/member/myPage`, `/admin/order` 접근 → 둘 다 `redirectURL` 붙어서 로그인 페이지로 리다이렉트 확인, (2) 로그인 페이지 GET 응답에 hidden 필드가 정확한 값으로 렌더링되는 것 확인, (3) 그 값으로 로그인 POST → 실제로 원래 페이지(`/admin/order`)로 리다이렉트되는 것 확인, (4) 오픈 리다이렉트 방어: `http://evil.com`, `//evil.com`을 `redirectURL`로 넣어도 전부 무시되고 메인(`/`)으로 감 확인, (5) XSS 방어: `redirectURL`에 `"><script>...` 주입 시도 → 렌더링된 HTML에 이스케이프된 형태(`&lt;script&gt;`)로만 나오는 것 확인, (6) 회귀: `redirectURL` 없는 평범한 로그인은 여전히 메인으로 감, 로그인 상태에서 admin 페이지 정상 접근 확인.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/util/interceptor/LoginInterceptor.java     (쿼리스트링 보존)
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java   (GET에서 redirectURL 수신, POST 실패 시에도 보존, isSafeRedirect)
  src/main/webapp/WEB-INF/views/member/login.jsp                              (hidden 필드 추가, fn 태그리브 추가)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminProductController.java (checkAdminPage에 redirectURL 추가)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminOrderController.java   (동일)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminCouponController.java  (동일)
```

## 3-21. 2026-08-29: 관리자 마이페이지 "일반 메뉴" 아코디언 → 상시 노출로 변경

사용자님 지적: `adminPage.jsp`의 "일반 메뉴" 아코디언이 기본적으로 닫힌 상태라 클릭해야 하위 메뉴가 보이는데, 그냥 항상 펼쳐진 채로 보이면 좋겠음.

- `<button aria-expanded="false">` + `<ul class="accordion-panel" hidden>` 구조를, 클릭 이벤트가 없는 `<div class="accordion-header">` + `hidden` 속성 없는 패널로 변경 — 펼침/접힘 자체가 사라짐.
- 상위 그룹 제목 옆의 접힘 화살표(chevron SVG)도 함께 제거(더 이상 토글 아님을 시각적으로도 명확히 함).
- JS의 아코디언 토글 클릭 핸들러, CSS의 `.accordion-chevron`/`[aria-expanded]`/`[hidden]` 관련 규칙 전부 죽은 코드가 되어 함께 삭제.

### 검증
로그인 후 `/member/myPage`(관리자 계정) 응답에서 하위 메뉴 항목이 `hidden` 없이 바로 렌더링되는 것, chevron/aria-expanded 마크업이 사라진 것, 관련 CSS도 같이 정리된 것 확인.

### 신규/수정 파일
```
수정:
  src/main/webapp/WEB-INF/views/admin/adminPage.jsp   (버튼->div, hidden 제거, chevron 제거, 토글 JS 삭제)
  src/main/resources/static/css/style_admin_mypage.css (accordion-chevron 등 죽은 규칙 삭제)
```

## 3-22. 2026-08-29: 쿠폰 목록 삭제 UI 개편

사용자님이 화면 캡처 보내며 요청: (1) "전체선택"/"전체선택취소" 버튼 2개를 하나로 합치기, (2) 선택 체크박스는 평소엔 숨기고, "선택 삭제" 자리에 있던 버튼을 "삭제할 쿠폰 선택"으로 바꿔서 이걸 눌러야 체크박스(+전체선택 버튼)가 나타나게, (3) 카드마다 있는 수정(✎) 버튼 옆에 개별 삭제 버튼도 추가.

- **선택 모드 토글**: `#toggleSelectModeButton`("삭제할 쿠폰 선택" ↔ "취소") 하나로 선택 모드 진입/이탈을 관리. 진입 시 `#couponCardList`에 `.selecting` 클래스 추가 → CSS가 그때만 체크박스(`display:none`이 기본)를 보여줌, `#selectionControls`(전체선택 버튼)과 `#deleteSelectedButton`(선택 삭제 실행 버튼)도 같이 나타남.
- **전체선택 통합**: `#toggleSelectAllButton` 하나가 현재 전부 체크돼 있으면 전체 해제, 아니면 전체 선택으로 동작(기존 두 버튼의 로직을 한 클릭 핸들러로 통합).
- **개별 삭제 버튼**: 카드마다 `.delete-icon-button`(🗑) 추가, `edit-button`과 동일한 스타일 계열이되 빨간 톤. 발급 이력 있는 쿠폰은 `disabled` 처리(클릭 자체가 안 됨 — 브라우저가 disabled 버튼의 클릭 이벤트를 아예 안 보냄). 클릭 시 확인창 → 해당 쿠폰 1개만 담아 기존 삭제 API 호출(3-19의 전부-삭제-or-전부-미삭제 로직을 그대로 재사용, 단일 항목이라 로직 변화는 없음).
- 삭제 성공 시(개별/일괄 공통) 선택 모드를 자동으로 빠져나오도록(`exitSelectionMode()`) 정리.
- 겸사겸사 발견: `style_admincouponView.css`의 `.active`/`.expired`(진행중/만료 배지 색상)가 스코프 없는 범용 클래스명이었음 — 흔한 이름이라 다른 페이지 CSS와 부딪힐 수 있어서 `.admin-coupon-view-page .active`/`.expired`로 스코프함(지금 당장 충돌은 없었지만 예방 차원).

### 검증
API 응답/서버 정적 파일로 새 버튼 ID·CSS·JS 로직 전부 반영된 것 확인(선택 모드 마크업이 기본적으로 `hidden`인 것 포함). 실제 클릭 인터랙션(선택 모드 진입/전체선택 토글/개별 삭제 확인창)은 브라우저에서 확인 필요.

### 신규/수정 파일
```
수정:
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp   (선택 모드 마크업 구조 변경)
  src/main/resources/static/css/style_admincouponView.css   (체크박스 기본 숨김, 선택모드 버튼/개별삭제 버튼 스타일, .active/.expired 스코프)
  src/main/resources/static/js/views/admincouponView.js     (선택모드 토글, 전체선택 통합, 개별 삭제, requestDelete 공통화)
```

### 3-22-1. 추가 수정: "전체선택"이 hidden인데도 계속 보이던 버그

사용자님이 화면에서 발견: 선택 모드가 아닐 때(체크박스 숨김 상태)도 "전체선택" 링크가 계속 보임. 원인은 `#selectionControls`에 `class="select-menu"`가 붙어있는데, `.select-menu{display:flex}` 규칙이 있어서 — **브라우저 기본 `[hidden]{display:none}` 규칙은 User-Agent 출처라, author(우리가 작성한) CSS 규칙이 같은 속성(`display`)을 지정하면 specificity와 무관하게 항상 author 규칙이 이김**. 그래서 `hidden` 속성이 DOM에 있어도 시각적으로 안 먹힘.

수정: `#selectionControls[hidden]{display:none}`을 명시적으로 추가해서 강제로 숨김 처리. 이 패턴(class가 display를 지정하는 요소에 hidden 속성만 믿고 쓰는 것)이 다른 페이지에도 있을 수 있어 메모리에 기록해둠(이번엔 이 파일만 고침, 전체 감사는 안 함).

### 신규/수정 파일
```
수정:
  src/main/resources/static/css/style_admincouponView.css  (#selectionControls[hidden] 규칙 추가)
```

## 3-23. 2026-08-29: 쿠폰 카드 색상 4단계 구분(만료 x 발급이력)

사용자님 요청: 만료 여부와 발급 이력 여부를 조합한 4가지 경우를 카드 색으로 구분하고 싶은데, 노란색은 애매해서 색 선택은 맡김.

**선정한 색상** (왼쪽 색 띠 + 은은한 배경, 기존 "발급 이력 있음" 빨간 띠 스타일 확장):
- **회색** — 만료 + 이력 없음: 완전히 죽은 쿠폰, 삭제해도 아무 문제 없음
- **빨강** — 만료 + 이력 있음: 삭제 안 되는 게 골칫거리라서가 아니라, 유저가 언제 어떻게 할인받았는지 기록을 남기려고 **의도적으로** 안 지우는 것(사용자님이 3-24에서 정정) — 기존 "발급 이력 있음" 표시와 동일 색 유지
- **초록** — 진행중 + 이력 있음: 정상적으로 쓰이고 있는 건강한 쿠폰
- **파랑** — 진행중 + 이력 있음 아님(신규): 아직 아무도 안 쓴 신규 쿠폰

`admincouponView.js`가 `state-active-history`/`state-active-no-history`/`state-expired-history`/`state-expired-no-history` 중 하나를 카드에 클래스로 부여, CSS에서 각각 다른 `border-left`+`background-color`로 스타일링(기존 `.has-history` 단일 클래스를 이 4개로 대체).

### 테스트 데이터
4가지 조합을 전부 화면에서 확인할 수 있게 세팅:
- ID 1~5(기존 시드): 진행중 + 이력 있음 → 초록
- ID 48("여름 시즌 할인 쿠폰(만료)", 3-17에서 생성): 만료 + 이력 없음 → 회색
- ID 49("테스트 쿠폰"): 진행중 + 이력 없음 → 파랑
- ID 50(신규 생성, "만료+이력있음 테스트 쿠폰"): 만료 + 이력 있음 → 빨강. `COUPON`에 과거 종료일로 직접 INSERT하고 `COUPONHISTORY`에도 발급 이력 1건(MEMBER_ID=2, TYPE='ISSUE') 같이 넣어서 두 조건을 동시에 만족시킴.

### 검증
API로 4개 쿠폰(1, 48, 49, 50)의 deadline/hasHistory 조합이 각각 (미래,Y)/(과거,N)/(미래,N)/(과거,Y)인 것 확인 — 4가지 색상 케이스가 전부 실제 데이터로 준비됨. CSS/JS에 4개 상태 클래스 전부 반영된 것도 확인. **실제 화면에서 4가지 색이 의도대로 보이는지는 확인 필요.**

### 신규/수정 파일
```
수정:
  src/main/resources/static/css/style_admincouponView.css  (.has-history -> state-* 4종 색상 규칙)
  src/main/resources/static/js/views/admincouponView.js    (stateClass 계산 로직)
```

## 3-24. 2026-08-29: 쿠폰 상태별 필터 + 기본 정렬 순서

3-23에서 색으로 구분한 4가지 상태(만료 x 발급이력)를 실제로 필터링할 수 있게 해달라는 요청 + 기본 노출 순서 지정(진행중·미사용 > 진행중·사용이력 > 만료·미사용 > 만료·사용이력). 겸사겸사 사용자님이 "만료+이력있음(빨강)"의 의미를 정정: 삭제 안 되는 게 골칫거리라서가 아니라, 할인 이력을 기록으로 남기기 위해 일부러 안 지우는 것 — 3-23 문서 문구도 같이 고침.

- `adminCouponService.js`에 상태/우선순위 계산을 공용 함수로 뽑음: `getCouponState(coupon)`(4가지 문자열 중 하나 반환, 카드 색 클래스 계산과 동일 로직 재사용), `getStatePriority(coupon)`(진행중·미사용=0, 진행중·사용이력=1, 만료·미사용=2, 만료·사용이력=3).
- `admincouponView.jsp`의 검색창 옆에 상태 필터 `<select id="coupon-state-filter">` 추가(전체/4가지 상태).
- `admincouponView.js`: 기존 `applySearch()`를 `applyFilters()`로 확장 — 검색어 AND 상태필터를 함께 적용한 뒤, `getStatePriority` 기준으로 정렬(같은 상태 안에서는 원래 서버 응답 순서 유지 - JS 배열 정렬은 안정 정렬이라 보장됨). 상태 필터 select의 `change` 이벤트도 이 함수를 다시 호출하도록 연결.
- `buildCard()`의 카드 색 클래스 계산도 새로 만든 `getCouponState()`를 재사용하도록 정리(기존엔 이 로직이 카드 렌더링 함수 안에 따로 있었음).

### 검증
서버 응답으로 필터 select 마크업, `getCouponState`/`getStatePriority` 함수, `admincouponView.js`의 `applyFilters`/`stateFilter` 연결까지 전부 반영 확인. 로직상 현재 DB 데이터(파랑 1개/초록 5개/회색 1개/빨강 1개) 기준 기본 정렬 결과가 요청한 순서와 일치하는 것도 확인. **실제 화면에서 필터 선택 시 정상 동작하는지, 기본 정렬 순서가 눈으로 봤을 때 맞는지는 확인 필요.**

### 신규/수정 파일
```
수정:
  src/main/resources/static/js/admin/adminCouponService.js  (getCouponState/getStatePriority 추가)
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp   (상태 필터 select 추가)
  src/main/resources/static/css/style_admincouponView.css   (#coupon-state-filter 스타일)
  src/main/resources/static/js/views/admincouponView.js     (applyFilters로 확장, buildCard가 getCouponState 재사용)
```

## 3-25. 2026-08-29: 쿠폰 목록 페이지네이션

사용자님 요청: 쿠폰 개수가 늘어나면 계속 스크롤하고 있을 수 없으니 페이지네이션 필요. `adminOrderDelivery.js`(3-11에서 구현)와 완전히 동일한 패턴으로 이식.

- `admincouponView.jsp`: `#couponCardList` 아래에 `<nav class="pagination">` + `#pagination-prev`/`#pagination-list`/`#pagination-next` 추가(주문/배송 페이지와 동일한 마크업 구조, id는 페이지가 달라 겹쳐도 무관).
- `style_admincouponView.css`: `.admin-coupon-view-page .pagination` 스코프로 스타일 추가(주문 페이지 디자인을 차용하되, 강조색은 이 페이지에서 이미 쓰던 `#f0dfc0`/`#5c4a2f`/`#b59b7b`로 맞춤 — 굳이 새 색 안 만듦).
- `admincouponView.js`: `PAGE_SIZE=10`, `paginate()`, `renderPagination()`(현재 페이지 중심 최대 5개 버튼) 추가. `render()`가 필터링+정렬된 전체 목록을 받아서 카운트는 전체 기준으로 보여주되 카드는 현재 페이지 것만 그림. 검색/상태필터 변경 시엔 `applyFiltersFromFirstPage()`(1페이지로 리셋)를, prev/next/페이지번호 클릭이나 삭제 후 새로고침 시엔 `applyFilters()`(현재 페이지 유지, 범위 벗어나면 자동으로 마지막 페이지로 당겨짐)를 호출 — 전부 3-11의 주문/배송 페이지네이션과 동일한 설계.

### 검증
서버 응답으로 마크업/CSS/JS 함수(`PAGE_SIZE`, `renderPagination`, `applyFiltersFromFirstPage`) 전부 반영 확인. 처음엔 쿠폰이 7개뿐이라(PAGE_SIZE=10 미만) 여러 페이지 동작을 라이브로 못 봤는데, 사용자님 요청으로 "페이지네이션 테스트 1~5"(진행중·미사용, 종료일 2026-12-31) 5개를 jshell로 추가해서 총 13개로 늘림 → `/admin/coupon/list` 응답으로 13개 확인, PAGE_SIZE=10 기준 2페이지가 되는 것 확인. (색상 분포: 파랑 6개(기존 1 + 신규 5)/초록 5개/회색 1개/빨강 1개 = 13개, 정렬 순서상 1페이지에 파랑 6+초록 4, 2페이지에 초록 1+회색 1+빨강 1.)

### 테스트 데이터
```
신규 (사용자 확인용으로 남겨둠, 필요 없어지면 화면에서 직접 삭제 가능 - 전부 발급 이력 없음):
  COUPON_ID 54~58: "페이지네이션 테스트 1"~"5" (5%, 진행중·미사용, 종료일 2026-12-31)
```

### 신규/수정 파일
```
수정:
  src/main/webapp/WEB-INF/views/admin/admincouponView.jsp  (pagination nav 마크업 추가)
  src/main/resources/static/css/style_admincouponView.css  (.pagination 스타일)
  src/main/resources/static/js/views/admincouponView.js    (PAGE_SIZE/paginate/renderPagination/applyFiltersFromFirstPage)
```

## 3-26. 2026-08-29: 쿠폰 기능 최종 재검토

사용자님이 페이지네이션 확인 끝내고 "더 없나 검증해줘" 요청 → 다시 훑어보다가 실제로 2가지 발견해서 고침:

1. **선택 상태가 페이지 이동 시 사라짐(3-22/3-25가 서로 안 맞물리던 버그)**: 3-22에서 만든 선택 모드(체크박스)와 3-25에서 나중에 추가한 페이지네이션이 서로 고려 없이 합쳐지면서 생긴 문제. `render()`가 페이지를 넘길 때마다 카드를 통째로 새로 그리는데, 체크박스의 checked 상태를 어디에도 저장 안 해서 — 1페이지에서 몇 개 체크하고 2페이지로 넘어가면 그 체크 상태가 사라지고, 그 상태로 "선택 삭제"를 누르면 **현재 화면에 보이는 페이지에서 체크된 것만** 삭제되고 이전 페이지에서 체크했던 건 조용히 무시됨(에러도 없이). "전체선택"도 마찬가지로 현재 페이지에 보이는 것만 선택하고 있었음("전체"라는 이름과 실제 동작이 안 맞음).
   - `selectedIds`(Set)로 체크된 쿠폰 id를 페이지 전환과 무관하게 별도 보관 → `buildCard()`가 카드를 새로 그릴 때마다 이 Set을 보고 checked 여부를 되살림.
   - "전체선택"은 이제 현재 페이지가 아니라 **검색/필터를 통과한 전체 목록** 기준으로 동작.
   - "선택 삭제"도 이제 화면에 보이는 체크박스가 아니라 `selectedIds`를 그대로 씀.
   - 검색어/상태필터를 바꾸면 이전 선택은 더 이상 의미가 없으므로 `selectedIds`를 비움(선택 모드 취소 시에도 동일).
2. **쿠폰설명(`COUPON_TEXT`) 길이 제한이 빠져있었음**: `VARCHAR2(300)`인데 쿠폰명(50자)엔 3-14에서 이미 넣어둔 길이 제한을 쿠폰설명엔 안 넣었었음(누락) → 301자 이상 입력 시 처리 안 된 예외(500) 노출 가능했음. 화면 `<textarea>`에 `maxlength="300"` 추가 + 서버(`registerCoupon`)에도 동일 검증 추가(쿠폰명과 동일 패턴).

### 검증
API로: 301자 쿠폰설명 거부, 정확히 300자는 성공 확인(테스트 쿠폰은 삭제함). 선택 상태 유지 로직은 코드 리뷰로 검증(페이지 전환 시 `selectedIds` 기준으로 checked가 복원되는 것, "전체선택"이 `currentFilteredList` 전체를 대상으로 하는 것, 필터 변경 시 선택 초기화되는 것) — **실제 여러 페이지를 오가며 체크 후 삭제하는 흐름은 화면에서 확인 필요**.

### 신규/수정 파일
```
수정:
  src/main/resources/static/js/views/admincouponView.js                          (selectedIds로 선택 상태 페이지 간 유지)
  src/main/webapp/WEB-INF/views/admin/addCoupon.jsp                              (couponText maxlength="300")
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java (couponText 길이 검증 추가)
```

## 3-27. 2026-08-30: 전체 리팩토링 (`/simplify`)

사용자님 요청("리팩토링의 시간이야. 덜어낼 수 있는것 덜어내고, 고쳐야할 거 고치고!")으로 이번 세션에서 손댄 3개 관리자 기능 + 로그인 리다이렉트 + adminPage.jsp 전체를 대상으로 재사용/단순화/효율/설계 4개 관점 병렬 리뷰 후 발견한 것 적용.

### 적용한 것
1. **관리자 권한 체크 3중 중복 제거**: `AdminProductController`/`AdminOrderController`/`AdminCouponController`가 각자 들고 있던 `checkAdminPage`/`checkAdminApi` private 메서드(내용은 동일)를 삭제하고, `AdminAuthUtil`에 새로 추가한 공용 정적 메서드 `pageGuard(request, session)`/`apiGuard(session)`로 통일.
2. **로그인 리다이렉트 URL 생성 중복 제거**: `LoginInterceptor`(인터셉터)와 `AdminAuthUtil.loginRedirect()`가 각자 URL 인코딩 로직을 들고 있던 것을 `util.RedirectUtil.buildLoginRedirectPath(request)`로 통합.
3. **쿠폰 삭제 결과 DTO 제거**: `CouponDeleteResultDTO`(deletedIds/blockedIds)가 실제로는 화면에서 한 번도 안 읽히는 죽은 반환값이었음(3-19에서 "전부 삭제 or 전부 미삭제"로 바뀌면서 이미 불필요해졌는데 안 지워져 있었음). `AdminCouponService.deleteCoupons()`를 `void`로 바꾸고, 막힐 때는 `IllegalStateException`을 던지는 방식(다른 관리자 API들과 동일한 패턴)으로 통일. DTO 파일 자체도 삭제.
4. **addProduct.js를 다른 화면 스크립트와 같은 IIFE 컨벤션으로 통일**: `addCoupon.js`/`admincouponView.js`/`adminOrderDelivery.js`는 전부 `(function(){...})()`로 감싸 전역 오염을 막는데 `addProduct.js`만 최상위 변수/함수 선언이었음(당장 충돌은 없었지만 새 파일이 기존 컨벤션과 다르게 작성된 것) → 전체를 IIFE로 감쌈.
5. **상품 등록 필수값 검사 중복 제거**: `AdminProductServiceImpl`에 복붙돼 있던 4개의 "null 또는 blank면 예외" 블록(제목/상품명/옵션명/설명)을 `requireNonBlank(value, message)` 헬퍼 하나로 축약.
6. **쿠폰 목록 화면 성능 개선 2건**:
   - 페이지 번호만 바꿀 때(`onPageChange`) 매번 검색어/필터/정렬을 처음부터 다시 계산하고 있었음 → 페이지 전환은 이미 계산된 `currentFilteredList`로 다시 그리기만 하면 되므로 `render(currentFilteredList)`만 호출하도록 변경.
   - `isExpired`/`getCouponState`/`getStatePriority`가 각자 내부에서 매번 `new Date()`로 "오늘"을 새로 계산하고 있어서, 목록 필터링(`O(n)`)·정렬(`O(n log n)`) 중에 같은 계산이 쿠폰 수만큼 반복됐음 → 세 함수 모두 `today`를 선택적으로 받도록 바꾸고, `applyFilters()`/`render()`가 한 번만 계산해서 넘겨주도록 수정. 또한 `buildCard()`가 `isExpired()`와 `getCouponState()`를 각각 불러 만료 여부를 두 번 계산하던 것도 `stateFromParts(expired, hasHistory)` 헬퍼를 추가해 한 번만 계산하도록 정리.
7. **자잘한 정리**: `style_admin_mypage.css`의 "일반 메뉴 (아코디언)" 주석이 3-21에서 아코디언을 없앤 뒤에도 그대로 남아있던 것 → "일반 메뉴"로 수정.

### 검증
`mvnw compile`로 컴파일 확인 후, 실행 중인 STS 서버(포트 8797)에 대해 API로 재검증:
- 쿠폰 삭제: 발급 이력만 있는 쿠폰 단독 삭제 시도 → 거부, 이력 있는/없는 쿠폰 섞어서 삭제 시도 → 전부 거부(이력 없는 쿠폰도 살아있음 확인), 이력 없는 쿠폰만 삭제 → 성공.
- `admin/product/add`(페이지), `admin/order/list`(API), `admin/coupon/list`(API) 모두 정상 응답 확인.
- 비로그인 상태로 `admin/coupon/list` 호출 시 `AdminAuthUtil.apiGuard`가 정상적으로 차단하는 것 확인.

쿠폰 목록의 필터/페이지네이션 성능 개선과 `addProduct.js` IIFE 변경은 코드 리뷰로 검증(동작 자체는 바뀌지 않고 계산 방식/스코프만 정리한 리팩토링) — 화면에서 직접 확인은 필요시 사용자가.

### 신규/수정/삭제 파일
```
신규:
  src/main/java/com/kh/sajotuna/mds/util/RedirectUtil.java

수정:
  src/main/java/com/kh/sajotuna/mds/util/AdminAuthUtil.java                        (pageGuard/apiGuard 추가, loginRedirect가 RedirectUtil 사용)
  src/main/java/com/kh/sajotuna/mds/util/interceptor/LoginInterceptor.java         (RedirectUtil 사용)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminProductController.java   (pageGuard/apiGuard로 교체, private 메서드 삭제)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminOrderController.java     (〃)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminCouponController.java    (〃, /delete가 ApiResponse<Void> 반환)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponService.java    (deleteCoupons 시그니처 void로 변경)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java (〃, 막히면 IllegalStateException)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductServiceImpl.java (requireNonBlank 헬퍼로 중복 제거)
  src/main/resources/static/js/views/addProduct.js                                (IIFE로 감쌈)
  src/main/resources/static/js/admin/adminCouponService.js                        (isExpired/getCouponState/getStatePriority가 today 파라미터를 받음, stateFromParts 추가)
  src/main/resources/static/js/views/admincouponView.js                          (onPageChange가 재필터 대신 재렌더링만, today를 한 번만 계산해서 전달)
  src/main/resources/static/css/style_admin_mypage.css                           (주석 문구 정리)

삭제:
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/CouponDeleteResultDTO.java
```

## 3-28. 2026-08-30: admin DTO를 테이블별 공용 DTO로 병합

사용자님이 admin 쪽 DTO가 불필요하게 세분화된 것처럼 보인다며, `review.model.dto.ReviewDTO`(여러 곳에 흩어져 있던 리뷰 관련 DTO를 하나로 합친 선례)처럼 **같은 테이블을 참조하는 DTO가 다른 패키지에 이미 있으면 admin 것을 그쪽으로 편입**하는 방향으로 리팩토링 요청.

### 조사 결과
- admin의 `ProductInsertDTO`/`ProductOptionInsertDTO`/`ProductImageInsertDTO`/`CategoryOptionDTO`/`TagOptionDTO`는 각각 테이블 하나에 정확히 대응(정규화가 이미 잘 되어 있음) — 진짜 중복은 아니었음
- 다만 그중 3개는 **다른 패키지에 이미 같은 테이블을 가리키는 DTO가 있었음**:
  - `product.model.dto.detail.OptionDTO` (PRODUCTOPTION) — 상품 상세페이지에서 이미 씀
  - `product.model.dto.detail.ProductDetailDTO` (PRODUCT) — 상품 상세페이지에서 이미 씀
  - `product.model.dto.mainPage.CategoryDTO` (CATEGORY) — `categoryName`만 있고 실제로는 어느 쿼리도 채우지 않는 고아 클래스였음(`searchProduct.jsp`에 "CategoryDTO에 categoryId가 없어서 연결 불가"라는 TODO까지 있었음)
  - `TagOptionDTO`/`ProductImageInsertDTO`(TAG/PRODUCTIMAGE)는 다른 패키지에 대응 DTO가 없어서 그대로 둠
- **주의**: `CategoryDTO`/`CouponDTO`라는 이름은 이미 다른 패키지에서 MyBatis 전역 별칭(`@Alias`)으로 선점되어 있어서, admin DTO를 그 이름으로 새로 만들면 서버 시작 시 별칭 충돌이 남 → 새로 만드는 대신 기존 클래스에 편입하는 방식으로 처리
- 쿠폰은 더 복잡했음: COUPON 테이블을 가리키는 DTO가 이미 3개(`admin.AdminCouponDTO`, `product.model.dto.coupon.CouponDTO`, `coupon.model.dto.MypageCouponDTO`) 있었고, 그중 마이페이지 경로(`MemberMapper.selectCouponsByMemberId`)는 인터페이스가 `List<MypageCouponDTO>`라고 선언해놓고 매퍼 XML은 `resultType="CouponDTO"`로 결과를 만드는 **기존 버그**가 있었음(화면에서 이 데이터를 렌더링하는 곳이 없어서 지금까지 안 터졌을 뿐). 사용자님 지시로 **마이페이지 쪽(MypageCouponDTO)은 이번엔 건드리지 않고, admin만 `product.model.dto.coupon.CouponDTO`로 편입**, 발급 이력 개념은 별도 `CouponHistoryDTO`로 분리.

### 적용한 것
1. **`OptionDTO`에 admin 등록 흐름을 위한 주석 추가** 후 admin이 이걸 그대로 사용하도록 변경, `admin.ProductOptionInsertDTO` 삭제
2. **`ProductDetailDTO`에 admin 등록 흐름을 위한 주석 추가** 후 admin이 이걸 그대로 사용하도록 변경(등록 시엔 productId/productTitle/productName/productContent 4개만 채움), `admin.ProductInsertDTO` 삭제
3. **`CategoryDTO`에 `categoryId` 필드 추가**(원래 없어서 스토어프론트 검색 페이지 TODO에도 걸려있던 부분 — 이번에 admin 재사용을 위해 추가하면서 그 갭도 같이 채워짐) 후 admin이 이걸 그대로 사용, `admin.CategoryOptionDTO` 삭제
4. **`CouponDTO`에 admin 전용 필드 4개(`couponValue`, `createdAt`/`deadline` LocalDate, `hasHistory`) 추가** 후 admin이 이걸 그대로 사용, `admin.AdminCouponDTO` 삭제. 처음엔 기존 `createdAt`/`deadline`(String)의 타입을 LocalDate로 바꿔치기했었는데, 사용자님이 "기존 필드를 변경하지 말고 문자열 버전은 `createdAtStr`/`deadlineStr`로 남긴 채 admin용 LocalDate 필드를 새로 추가하는 방향이어야 한다"고 정정 — 기존 필드명을 `createdAtStr`/`deadlineStr`로 바꾸고(스토어프론트 상세페이지 표시용, 그대로 유지), admin 전용으로 `createdAt`/`deadline`(LocalDate)을 별도로 추가하는 방식으로 수정. 스토어프론트의 `getCoupons` 쿼리(`detailPage.xml`)도 이 이름에 맞춰 `to_char(...) as created_at_str`/`as deadline_str`로 되돌림(원래 동작 그대로 유지, 필드명만 정리).
5. **`CouponHistoryDTO` 신규 생성**(COUPONHISTORY 테이블 매핑, product.model.dto.coupon 패키지) — 아직 이걸 통째로 채우는 쿼리는 없음(현재는 존재 여부만 필요해서 boolean/List<Long>으로 충분), 나중에 "이 쿠폰을 누가 언제 썼는지" 같은 실제 이력 조회 기능이 생기면 사용할 수 있게 미리 준비해둔 것.

### 검증
`mvnw compile` 통과 확인 후 실행 중인 서버에 대해:
- `admin/product/add` 페이지의 카테고리 드롭다운이 이제 `categoryId`를 값으로 정상 렌더링하는 것 확인
- 실제 상품 등록 API 호출(대표+설명 이미지 포함) 후 DB에서 PRODUCT/PRODUCTOPTION/PRODUCTIMAGE 행이 정상 생성된 것 직접 조회로 확인, 테스트 데이터는 삭제
- `admin/coupon/list`/`admin/coupon/add`가 병합된 `CouponDTO`로 정상 동작하는 것 확인(등록 후 목록에 couponValue/deadline이 LocalDate 필드 기준으로 정상 노출), 테스트 쿠폰은 삭제(처음엔 한글 문자열로 `-like` 필터링해서 지우려다 PowerShell에서 매칭이 안 돼 조용히 실패한 걸 뒤늦게 발견 — 이후엔 쿠폰 ID로 직접 지움)
- 스토어프론트의 `getCoupons` 쿼리(필드명을 `createdAtStr`/`deadlineStr`로 정리한 뒤 재확인)가 `/mds/detail/{productId}` 컨트롤러를 통해 500 에러 없이(302로) 처리되는 것 확인 — 이 컨트롤러는 애초에 조회 결과를 화면에 렌더링하지 않고 리다이렉트만 하는 미완성 상태라 그 이상은 검증 불가/불필요

### 신규/수정/삭제 파일
```
신규:
  src/main/java/com/kh/sajotuna/mds/product/model/dto/coupon/CouponHistoryDTO.java

수정:
  src/main/java/com/kh/sajotuna/mds/product/model/dto/detail/OptionDTO.java          (주석만 추가)
  src/main/java/com/kh/sajotuna/mds/product/model/dto/detail/ProductDetailDTO.java   (주석만 추가)
  src/main/java/com/kh/sajotuna/mds/product/model/dto/mainPage/CategoryDTO.java      (categoryId 필드 추가)
  src/main/java/com/kh/sajotuna/mds/product/model/dto/coupon/CouponDTO.java          (couponValue/hasHistory 추가, createdAt/deadline을 LocalDate로 변경)
  src/main/resources/mappers/admin/AdminProductMapper.xml                           (resultType/parameterType을 공용 DTO로 교체)
  src/main/resources/mappers/admin/AdminCouponMapper.xml                            (〃)
  src/main/resources/mappers/product/detailPage.xml                                 (getCoupons에서 to_char 제거)
  src/main/java/com/kh/sajotuna/mds/admin/model/mapper/AdminProductMapper.java       (타입 교체)
  src/main/java/com/kh/sajotuna/mds/admin/model/mapper/AdminCouponMapper.java        (〃)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductService.java     (〃)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductServiceImpl.java (〃)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponService.java      (〃)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java  (〃)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminCouponController.java      (〃)

삭제:
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/ProductInsertDTO.java
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/ProductOptionInsertDTO.java
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/CategoryOptionDTO.java
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/AdminCouponDTO.java
```

## 3-29. 2026-08-31: 프로젝트 전체 감사(`PROJECT_AUDIT.md`) + 후속 조치

3-28 직후 사용자님이 "프로젝트 전체를 훑어서 버그/정책 검토/잠재적 위험을 리스트업만 해달라(수정 X)"고 요청 → member/coupon, product/review, 전체 보안·설정 3개 영역을 병렬 조사 에이전트로 감사하고 admin 3종은 직접 재검토. 결과를 별도 문서 **`PROJECT_AUDIT.md`**(레포 루트, HANDOFF.md처럼 커밋 대상 아님)로 저장 — 팀 공유 및 지속 업데이트용. **이 세션에서 발견된 버그(회원가입 폼 깨짐, ProductController 세션 키 오류, 리뷰 이미지 뒤섞임, `/member/orderDelivery` INNER JOIN 문제 등 다수)는 전부 review/product/member 담당 영역이라 이번엔 고치지 않음 — 자세한 내용은 `PROJECT_AUDIT.md` 참고.**

사용자님이 자기 담당 영역(리뷰/일부 admin) 및 명시적으로 지시한 것만 다음처럼 실제로 적용:

1. **리뷰 텍스트 500자 서버 검증** — `ReviewServiceImpl.writeReview()`. `REVIEW_TEXT VARCHAR2(1500 BYTE)`가 한글 500자(3바이트×500)까지만 안전한데 서버 검증이 없었음.
2. **리뷰 이미지 업로드 파일종류 검증 + 관리자 상품 등록의 Content-Type 스푸핑 대응** — 신규 `util.ImageValidationUtil`(JPG/PNG/WEBP 매직 바이트 직접 확인, Content-Type 헤더 대체)을 만들어 `AdminProductServiceImpl`/`ReviewServiceImpl` 양쪽에서 공용으로 사용.
3. **쿠폰 `couponValue`를 `double` → `BigDecimal`로 변경** — `discountPercent/100.0` 나눗셈 대신 `BigDecimal.valueOf(discountPercent, 2)`로 스케일 직접 지정(부동소수점 오차 원천 차단). 처음엔 기존 `createdAt`/`deadline`(String) 필드의 타입을 LocalDate로 바꿔치기했었는데, 사용자님이 "기존 필드는 그대로 두고 admin용 LocalDate 필드를 새로 추가하는 방향이어야 한다"고 정정 — `createdAtStr`/`deadlineStr`(String, 기존 용도 유지)와 `createdAt`/`deadline`(LocalDate, admin 신규)을 나란히 두는 구조로 수정.
4. **업로드 파일 orphan 완전 차단 + 파일 정합성 검사 기능 신설** — `util.FileUploadUtil`을 "UUID 파일명 즉시 생성"과 "실제 디스크 쓰기"로 분리하고, 디스크 쓰기를 `TransactionSynchronizationManager`의 `afterCommit()` 콜백으로 미룸(`AdminProductServiceImpl`, `ReviewServiceImpl` 양쪽 적용) — 등록 도중 실패해도 파일이 애초에 안 써져서 orphan이 원천 차단됨. 추가로 `/admin/maintenance` 화면(관리자 대시보드 퀵메뉴에 5번째 타일로 노출) 신설 — `uploads/product`↔`PRODUCTIMAGE`, `uploads/review`↔`REVIEWIMAGE`를 대조해서 "파일만 있음(삭제 가능)"/"DB만 있음(재업로드 필요)"을 리스트로 보여줌. 스케줄러 없이 관리자가 직접 누르는 온디맨드 방식(포트폴리오 성격상 눈에 보이는 게 낫다고 판단). 자동 삭제 없이 목록 확인 후 사람이 버튼을 눌러야 삭제되고, 삭제 API는 클릭 시점에 DB를 재확인 + 경로 순회 문자 차단하는 안전장치 포함.
5. **전체 프로젝트 낡은/오해 소지 있는 주석 정리** — Java/JSP/매퍼 XML 전수 스캔 후 실제 코드와 대조해서 9곳 수정(이미 해결된 TODO가 안 지워진 것, 옛 리다이렉트 문자열을 가리키는 것, 복붙하다 타입명 안 고친 것 등). 상세 내역은 `PROJECT_AUDIT.md` 참고.
6. **매퍼가 이름으로 참조 중인 DTO 4개에 `@Alias` 명시적으로 추가** — `SearchDTO`, `MyPageWishDTO`, `MyPageCartDTO`, `MyPageDeliveryDTO`. `application.properties`의 `mybatis.type-aliases-package=com.kh.sajotuna.mds`가 패키지 전체를 자동 스캔해서 `@Alias` 없이도 클래스명으로 resolve되고 있었지만(그래서 지금까지 문제없이 동작), 매퍼가 클래스명에 의존한다는 걸 코드에서 바로 보이게 하려고 명시함. **참고: 이 자동 스캔 때문에 프로젝트 전체(`com.kh.sajotuna.mds` 하위)에서 클래스명이 유일해야 함 — 새 DTO 만들 때 이름 겹침 주의.**
7. **최종 점검**: `/code-review high`로 이번 세션 diff(39개 파일) 재검증 → `FileUploadUtil.saveFile()`이 4번 리팩토링 이후 호출부 0건인 죽은 메서드로 남아있던 것 발견, 삭제. 그 외 문제 없음. 컴파일 + 서버 기동 후 admin/member 주요 엔드포인트 스모크 테스트 전부 통과, 파일 정합성 검사 기능으로 이번 세션 테스트 흔적이 DB/디스크에 하나도 안 남은 것까지 확인.

### 신규/수정/삭제 파일
```
신규:
  PROJECT_AUDIT.md
  src/main/java/com/kh/sajotuna/mds/util/ImageValidationUtil.java
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/FileIntegrityIssueDTO.java
  src/main/java/com/kh/sajotuna/mds/admin/model/dto/DeleteOrphanFileRequestDTO.java
  src/main/java/com/kh/sajotuna/mds/admin/model/mapper/AdminMaintenanceMapper.java (+xml)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminMaintenanceService.java (+Impl)
  src/main/java/com/kh/sajotuna/mds/admin/controller/AdminMaintenanceController.java
  src/main/webapp/WEB-INF/views/admin/adminMaintenance.jsp
  src/main/resources/static/css/style_adminMaintenance.css
  src/main/resources/static/js/admin/adminMaintenanceService.js
  src/main/resources/static/js/views/adminMaintenance.js

수정:
  src/main/java/com/kh/sajotuna/mds/review/model/service/ReviewServiceImpl.java   (텍스트 길이/이미지 검증, AFTER_COMMIT)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminProductServiceImpl.java (이미지 검증 교체, AFTER_COMMIT)
  src/main/java/com/kh/sajotuna/mds/util/FileUploadUtil.java                      (파일명 생성/디스크 쓰기 분리 + saveOnCommit)
  src/main/java/com/kh/sajotuna/mds/product/model/dto/coupon/CouponDTO.java       (couponValue BigDecimal, createdAtStr/deadlineStr + createdAt/deadline 분리)
  src/main/java/com/kh/sajotuna/mds/admin/model/service/AdminCouponServiceImpl.java (BigDecimal 반영)
  src/main/java/com/kh/sajotuna/mds/product/model/dto/mainPage/SearchDTO.java     (@Alias 추가)
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MyPageWishDTO.java           (〃)
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MyPageCartDTO.java           (〃)
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MyPageDeliveryDTO.java       (〃)
  src/main/webapp/WEB-INF/views/admin/adminPage.jsp                              (퀵메뉴 5번째 타일)
  src/main/resources/static/css/style_admin_mypage.css                          (퀵메뉴 그리드 4→5열)
  src/main/webapp/WEB-INF/views/common/header.jsp                                (신규 CSS 링크)
  src/main/webapp/WEB-INF/views/product/productDetail.jsp                       (낡은 주석 정리 2건)
  src/main/webapp/WEB-INF/views/product/searchProduct.jsp                       (낡은 주석 정리 4건)
  src/main/webapp/WEB-INF/views/product/wish.jsp                                 (오해 소지 있는 주석 정리)
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java     (복붙 오류 주석 5곳 수정)
```

---

## 3-30. 2026-08-30: 유저 주문 배송 확인 기능 구현

PROJECT_AUDIT.md에 이미 기록돼있던 `/member/orderDelivery` 관련 버그 3개(뷰 이름 불일치, DELIVERY INNER JOIN, N+1 쿼리)를 실제로 고치면서 "유저 주문/배송내역 확인" 기능을 처음부터 완성. admin의 주문/배송 관리 기능(이미 완성됨)을 참고해서 ORDER_STATUS/DELIVERY_STATUS 값과 흐름은 새로 정의하지 않고 그대로 읽기 전용으로 재사용.

### 구현
1. **뷰 이름 버그 수정** — `MemberController.userOrderDeliveryForm()`이 반환하던 `"member/orderDelivery"`를 실제 파일 위치인 `"order/userOderDelivery"`로 수정(파일을 옮기는 대신 뷰 이름을 맞춤).
2. **`userOderDelivery.jsp`를 독립 HTML 목업 → header/footer include 패턴으로 전면 재작성** — `wish.jsp`/`cart.jsp`와 같은 구조로 전환하고, `deliveryList` 모델을 JSTL(`<c:forEach>`)로 직접 렌더링하는 SSR 방식 채택. 이 페이지는 컨트롤러가 애초에 `Model`에 데이터를 채워서 뷰만 리턴하는 구조(admin처럼 JSON API+fetch가 아님)라, 서버 통신 로직이 필요 없어서 `static/js/views/userOrderDelivery.js`는 상태 필터 탭 인터랙션(이미 렌더링된 `.order-card`를 `data-status`로 보이기/숨기기)만 담당하는 순수 DOM 스크립트로 작성 — 별도 `xxxService.js`(비즈니스 로직) 파일은 만들지 않음(addReview.js/productDetail.js와 같은 "인터랙션만 있는 경우" 패턴).
3. **`selectDeliveriesByMemberId` 쿼리 재작성** (`MemberMapper.xml`):
   - DELIVERY를 LEFT JOIN으로 변경(버그 7 수정) — 체크아웃 미구현으로 아직 DELIVERY 행이 없는 결제완료 주문도 이제 목록에 나타남. `AdminOrderMapper.selectSummary`와 동일 패턴.
   - `WHERE PO.ORDER_STATUS != 'CART'` 추가 — LEFT JOIN으로 바꾸면서 자칫 장바구니에 담겨있기만 한(아직 주문 아닌) 항목까지 새로 노출될 뻔한 것을 admin 쿼리와 동일한 조건으로 막음.
   - 대표 상품(가장 먼저 담긴 ORDERDETAIL) 1건 + 상품 건수를 `ROW_NUMBER() OVER (PARTITION BY od.ORDER_ID ORDER BY od.OD_ID)` + `COUNT(*) OVER (PARTITION BY od.ORDER_ID)`로 서브쿼리 하나에서 함께 조회 — `AdminOrderMapper.selectOrderList`와 같은 패턴이지만, admin은 대표상품/건수를 서브쿼리 2개로 나눠서 조인하는 반면 이번엔 윈도우 함수 하나로 합쳐서 더 단순화함. `MemberServiceImpl.listDelivery()`의 N+1 반복 조회 루프(`selectProductByOrderId`를 주문마다 호출) 제거(버그 9 수정), 이제 안 쓰는 `selectProductByOrderId`는 Mapper 인터페이스/XML에서 삭제.
   - 대표 상품의 이미지도 `PRODUCTIMAGE`를 서브쿼리 안에서 조회하는데, 찜/장바구니 쿼리가 겪고 있는 것과 같은 INNER JOIN 함정(대표이미지 미등록 상품이면 통째로 안 보임)을 새로 만들지 않도록 스칼라 서브쿼리로 작성(이미지 없으면 그냥 NULL, ROW_NUMBER 매칭에 영향 안 줌).
   - 대표 상품/이미지가 없는 경우(주문 상세 데이터 누락 등) 대비 `NVL`로 기본값 처리 — 이 과정에서 `MemberServiceImpl.java:134`에 있던 `/upload/product/`(s 빠진 오타) 하드코딩 기본값도 자연스럽게 제거하고 SQL의 `NVL(..., '/uploads/product/')`로 옮기면서 오타 수정(버그 12의 이 부분만 수정, `productDetail.jsp` 3곳은 범위 밖이라 안 건드림).
4. **`MyPageDeliveryDTO`에 `qty`/`productCount` 필드 추가** — "상품명 외 N건" 표시용(admin의 `AdminOrderListItemDTO`와 동일한 필드 이름/역할).
5. **화면 설계**: 필터 탭(전체/배송준비중/배송중/배송완료/취소환불), 주문 카드(대표 상품 이미지+이름+"외 N건", 결제금액, 상태 배지, 4단계 진행바, 택배사/송장번호(있을 때만), 배송지). admin의 `STATUS_SEQUENCE`(배송준비중→배송중→배송출발→배송완료, 취소는 배송완료 전이면 언제든 도달 가능한 별도 종료 상태)와 `cancelStage`(취소/환불 대기중 vs 완료, `DELIVERY_STATUS`/`ORDER_STATUS` 두 컬럼으로 구분) 개념을 그대로 읽기 전용으로 재사용. DELIVERY 행이 아직 없는(결제완료, 배송준비중 전) 주문은 "배송준비중" 필터 버킷에 넣되 배지는 "결제완료"로 구분 표시, 진행바는 전부 미도달 상태로 표시.
   - **원래 목업에 있던 배송조회/주문취소/리뷰작성 버튼은 전부 제거함** — 이번 기능은 "확인"(읽기 전용) 범위이고, 세 버튼 모두 대응하는 실제 백엔드 흐름이 없어서(배송조회는 외부 택배사 연동 미구현, 주문취소는 유저용 취소 API 없음, 리뷰작성은 임시 html로 링크된 상태) 동작 안 하는 버튼을 그대로 두는 대신 범위에 맞게 제거하는 쪽을 택함.
6. **CSS 스코프 수정** (`style_order.css`) — `.order-delivery-page main { width:800px; ... }`가 이 페이지를 header/footer include 방식으로 바꾸면서 더 이상 안 맞게 됨(이제 `<main>`이 조상이지 후손이 아님, 3-5/3-6에서 admin 페이지들에 적용했던 것과 동일한 문제) → `.order-delivery-page .page-content`로 이동. 배송출발(`OUT_FOR_DELIVERY`) 단계의 진행바 강조색이 원래 목업엔 없어서(4단계 중 배송중/배송완료만 있었음) 새로 추가. 상품 썸네일에 실제 `<img>`를 넣기 위한 스타일, 택배사/송장번호·배송지 텍스트 스타일 추가. 더 이상 렌더링하지 않는 버튼(배송조회/주문취소/리뷰작성)용 CSS는 제거.

### 실제 검증 (서버 8797 + 라이브 DB, jshell+ojdbc11)
회원가입 API로 신규 테스트 유저 생성(`delvtest`) → 로그인 → 테스트 주문 7건을 상태별로 직접 INSERT(① CART, ② 결제완료+DELIVERY행 없음, ③ PREPARING, ④ SHIPPED+택배정보+2개 품목, ⑤ DELIVERED, ⑥ 취소대기, ⑦ 취소완료) → `/member/orderDelivery` 실제 호출해서 렌더링된 HTML 확인:
- CART 주문은 목록에서 정상적으로 빠짐(장바구니 항목이 주문으로 새는 것 방지 확인).
- DELIVERY 행 없는 결제완료 주문이 이제 목록에 정상적으로 나타남(버그 7 재현 후 수정 확인 — 이게 이번 작업의 핵심 검증 포인트).
- SHIPPED 다품목 주문의 "외 1건" 텍스트, 택배사/송장번호 표시 정상.
- 취소대기("취소/환불 대기중")와 취소완료("취소/환불 완료") 배지가 `DELIVERY_STATUS`/`ORDER_STATUS` 조합으로 정확히 구분됨.
- 4단계 진행바가 각 상태에서 정확한 단계까지 체크(✓) 표시됨(DELIVERED는 4단계 전부 체크).
- 응답에 `page-content` 클래스, `site-footer` 정상 1회 등장 확인(헤더/푸터 정상 연결).
- 검증 후 테스트 주문 7건 + ORDERDETAIL/DELIVERY(CASCADE) + 테스트 유저 1명 전부 ID 기준으로 삭제, 잔존 0건 확인 완료.
- **브라우저에서 필터 탭 클릭 등 실제 인터랙션 테스트는 못 함**(브라우저 도구 없음) — 로직 자체는 기존에 검증된 `wish.jsp` 필터 패턴과 동일해서 위험은 낮지만, 화면에서 한 번 클릭해서 확인 필요.

### 3-30-1. 추가 수정: 마이페이지에서 진입 경로가 없던 것 연결

사용자님이 화면 확인 중 `/member/myPage`에서 "주문·배송 조회"를 눌러도 아무 반응이 없다고 지적 — `myPage.jsp`가 원래 완전 정적 목업이라 "주문·배송 조회" 타일 2곳(빠른 메뉴, 내 선물 관리)이 `<div>`로만 되어있고 링크가 아예 없었음(다른 타일들도 마찬가지지만, 이번에 완성한 기능으로 가는 경로이므로 이 2곳만 범위 내로 판단해 연결). `<div class="quick-menu-item">`/`<div class="menu-item">`를 `<a href="<c:url value='/member/orderDelivery'/>">`로 교체 — `default.css`에 이미 `a { text-decoration:none; color:#333 }` 전역 리셋이 있어서 스타일 변화 없이 그대로 링크만 추가됨. 로그인 세션으로 직접 클릭 경로 재현해서 정상 이동 확인. 나머지 타일(리뷰작성/문의사항/장바구니/찜 등)은 이번 기능과 무관해서 그대로 둠.

### 3-30-2. 추가 수정: 화면 확인 피드백 3건 반영

사용자님이 화면(배송중 카드) 스크린샷 보내면서 3가지 요청: (1) 필터 탭에 "배송출발" 없음 (2) 배송완료 주문에 리뷰 작성 버튼 필요 (3) 상품 이미지 없을 때 조그맣게 안내 문구 표시.

1. **필터 탭에 "배송출발" 추가** — 기존엔 `SHIPPED`/`OUT_FOR_DELIVERY`를 필터 단계에서 "배송중" 하나로 묶었었는데(대시보드 요약 카운트 기준을 그대로 따랐던 것), 사용자 화면에서는 진행바에 이미 배송출발이 별도 단계로 보이는데 필터에서만 못 고르는 게 어색해서 별도 탭(`data-status="out_for_delivery"`)으로 분리. 상태 배지 CSS(`.status-badge.status-out_for_delivery`)도 새로 추가.
2. **배송완료 주문에 리뷰 작성 버튼 연결** — 실제 리뷰 작성 라우트(`GET /review/write?odId=`)가 `OD_ID`(ORDERDETAIL PK) 기준으로 동작하고(`ReviewServiceImpl.getWriteInfo`가 배송완료 여부/중복작성 여부를 서버에서 재검증), 대표 상품의 `OD_ID`가 기존 쿼리엔 없었어서 `MyPageDeliveryDTO.odId` 필드와 `selectDeliveriesByMemberId`의 대표상품 서브쿼리에 `od.OD_ID`를 추가로 노출. `deliveryStatus == 'DELIVERED'`인 카드에만 "리뷰 작성" 버튼 노출, 클릭 시 `/review/write?odId={대표 od_id}`로 이동. (이미 리뷰를 작성한 경우 등은 `ReviewController`가 자체적으로 홈으로 리다이렉트 + 에러 메시지 처리하므로 이 페이지에서 별도 방어 안 함 — 기존 프로젝트 관례 그대로 재사용.) 주문에 상품이 여러 개("외 N건")면 대표 상품 1건만 리뷰 작성 대상이 됨 — 이번 범위에선 그 이상은 다루지 않음.
3. **상품 이미지 없을 때 안내 문구 표시** — 대표 상품 이미지가 없으면(대표 상품 자체가 없거나, 있어도 대표이미지 미등록) `<img>` 대신 "상품 이미지가 없습니다" 작은 텍스트(9px)를 썸네일 박스 안에 표시. 실제로는 시드 데이터의 모든 상품에 대표이미지가 있어서 이 케이스가 잘 안 나오길래, 검증할 때 `ORDERDETAIL` 없는 주문을 하나 추가로 만들어서(대표 상품 자체가 없는 극단 케이스) 렌더링 확인함.

### 3-30-3. 추가 수정: 1차 UI 개선 (썸네일 크기, 배송정보 라벨링)

3-30-2 반영 후 사용자님이 스크린샷으로 이어서 지적: (1) 배송출발 상태 확인할 테스트 데이터가 없음 (2) 썸네일이 작아서 "상품 이미지가 없습니다" 텍스트가 밀림 (3) 택배사/송장번호/배송지 정보가 너무 축약돼서 나옴.

1. **`.item-thumb` 56px → 80px로 확대**, no-image 텍스트도 9px → 11px로 같이 키움.
2. **택배/배송지 정보를 라벨 붙인 줄 단위로 재구성** — 기존 `CJ Logistics / 123456789012`, `Home - Test Address 4` 한 줄짜리 표기를 `.delivery-info` 안에 `.info-row` 두 줄로 분리: "택배사 : CJ Logistics | 송장번호 : 123456789012", "배송지 : Home - Test Address 4". 라벨(`.info-label`)만 굵게, 구분자(`.info-divider`)는 연한 회색으로 톤다운.
3. 검증용으로 `OUT_FOR_DELIVERY` 상태 테스트 주문(78번)을 추가로 넣어서 배송출발 배지/진행바가 정상 표시되는 것 확인.

### 3-30-4. 서버 사이드 페이징 추가

사용자님이 "지금은 괜찮지만 나중에 주문이 쌓이면 문제될 것 같다"며 페이징 요청 → 지금까지는 `listDelivery(memberId)`가 회원의 전체 주문을 한 번에 불러온 뒤 상태 필터도 클라이언트 JS(`userOrderDelivery.js`)에서 `data-status` 보이기/숨기기로 처리하고 있었음(admin 쪽 문서에도 "나중에 서버사이드로 바꿀 필요" 라고 이미 적혀있던 것과 동일한 종류의 부채). 이번엔 처음부터 페이지+상태필터 둘 다 서버에서 처리하도록 다시 설계함.

- **API 시그니처 변경**: `GET /member/orderDelivery`가 `status`(기본값 `all`)/`page`(기본값 `1`) 쿼리 파라미터를 받음. `MemberService.listDelivery(memberId, status, page)` / 신규 `totalDeliveryPages(memberId, status)` 추가.
- **`MemberMapper.xml`**: 상태 필터 조건을 `<sql id="deliveryStatusFilter">` 공용 조각으로 빼서 `selectDeliveriesByMemberId`(페이지 조회, `OFFSET #{offset} ROWS FETCH NEXT #{pageSize} ROWS ONLY`)와 신규 `countDeliveriesByMemberId`(총 건수) 양쪽에서 재사용. 페이지 크기는 `MemberServiceImpl.DELIVERY_PAGE_SIZE = 10`으로 고정.
- **필터 탭이 클라이언트 JS 토글 버튼 → 서버 왕복 링크로 전환**: `<button data-status>` → `<a href="?status=xxx&page=1">`로 교체(필터 바꾸면 1페이지로 리셋). 이제 필터링 자체가 SQL WHERE에서 일어나므로, 페이지네이션과 필터가 항상 정확하게 맞물림(전에 클라이언트 필터 방식이었다면 페이징 도입 시 "이 페이지엔 없지만 다른 페이지엔 있는" 상태 카운트 불일치 문제가 생겼을 것).
- **페이지네이션 위젯 추가** — 이전/다음 + 현재 페이지 기준 5개 창(window) 숫자 링크. 윈도우 계산(`pageWindowStart/End`)은 컨트롤러에서 계산해서 모델로 넘김(EL엔 Math 함수가 없어서 JSTL로 직접 계산하기 애매함 — 순수 화면 표시용 계산이라 서비스 레이어 아니라 컨트롤러에 둠). `totalPages <= 1`이면 위젯 자체를 안 보여줌.
- **`static/js/views/userOrderDelivery.js` 삭제** — 필터링이 서버로 넘어가면서 이 페이지에 남은 JS 인터랙션이 없어짐(더 이상 쓸모없는 파일이라 제거, JSP의 `<script>` 참조도 같이 제거).
- CSS: 필터 탭 선택자를 `button` → `a`로 교체, 신규 `.pagination`/`.page-link` 스타일 추가.

### 검증
서버에 테스트 주문을 12건까지 늘려서(페이지당 10건 기준으로 2페이지 발생) 확인: 1페이지 10건+"다음" 링크, 2페이지 2건+"이전" 링크 정상 동작. `status=preparing` 필터 단독으로도 정확한 건수만 나오는 것, 필터+페이지 조합(`?status=xxx&page=N`)이 함께 정상 동작하는 것, `totalPages=1`일 때 페이지네이션 위젯이 아예 안 뜨는 것까지 확인 후 테스트 데이터 정리.

### 신규/수정 파일
```
삭제:
  src/main/resources/static/js/views/userOrderDelivery.js

수정:
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java      (status/page 파라미터, 페이지네이션 윈도우 계산)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberService.java            (listDelivery 시그니처 변경, totalDeliveryPages 추가)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberServiceImpl.java        (DELIVERY_PAGE_SIZE, offset 계산)
  src/main/java/com/kh/sajotuna/mds/member/model/mapper/MemberMapper.java        (@Param 기반 시그니처, countDeliveriesByMemberId 추가)
  src/main/resources/mappers/MemberMapper.xml                                    (deliveryStatusFilter sql 조각, OFFSET/FETCH, count 쿼리)
  src/main/webapp/WEB-INF/views/order/userOderDelivery.jsp                       (필터 탭 링크화, 페이지네이션 위젯 추가)
  src/main/resources/static/css/style_order.css                                 (필터 탭 a로 변경, .pagination 스타일 추가)
```

### 3-30-5. 리뷰 작성 완료 상태 반영

사용자님이 "리뷰 작성하고 나서 완료 상태 처리도 되어있는지" 확인 요청 → 확인해보니 3-30-2에서 "리뷰 작성" 버튼만 연결했을 뿐, 이미 리뷰를 작성한 주문인지 여부는 반영이 안 돼서 리뷰 작성 후에도 계속 "리뷰 작성" 버튼이 뜨는 상태였음(클릭하면 `ReviewController`가 자체적으로 막긴 하지만 화면에서 미리 구분은 안 됐음) → 이번에 구현.

- `MyPageDeliveryDTO.hasReview`(boolean) 필드 추가. `selectDeliveriesByMemberId`에 `CASE WHEN EXISTS (SELECT 1 FROM REVIEW r WHERE r.OD_ID = rep.OD_ID) THEN 1 ELSE 0 END AS HAS_REVIEW` 추가 — `AdminCouponMapper.selectCouponList`의 `hasHistory` EXISTS 패턴과 동일하게 재사용(이 프로젝트에서 이미 검증된 boolean 매핑 방식).
- `userOderDelivery.jsp`: `item.hasReview`가 true면 "리뷰 작성" 버튼 대신 읽기 전용 배지("리뷰 작성 완료")로 교체.
- **실제 리뷰 작성 흐름으로 라이브 검증**: 테스트 계정으로 배송완료 주문에 진짜 `POST /review/write`를 호출해서 리뷰 등록 → 배송 목록 화면이 "리뷰 작성 완료" 배지로 즉시 바뀌는 것 확인 → 같은 주문에 리뷰 재작성 시도 시 `ReviewController`가 여전히 정상적으로 막는 것도 확인 → 검증에 쓴 REVIEW 행은 실제 상품 상세 페이지에 공개로 노출되는 데이터라 다른 테스트 데이터보다 먼저 즉시 삭제.

### 3-30-6. 리뷰 작성 완료 후 원래 페이지로 복귀 (returnUrl)

사용자님이 직접 화면에서 리뷰를 작성해보고 지적: 리뷰 등록 성공하면 `ReviewController.write()`가 항상 `redirect:/`(메인페이지)로 보내서, 배송 목록 페이지에서 "리뷰 작성"으로 들어간 경우에도 메인으로 튕겨나감 → 원래 있던 페이지(필터/페이지 상태 포함)로 돌아가게 수정.

- **오픈 리다이렉트 방지 패턴은 새로 만들지 않고 `MemberController.isSafeRedirect()`(로그인 후 원래 가려던 페이지로 돌아가는 데 이미 쓰던 것 — "/"로 시작하되 "//"/역슬래시는 거부)를 `ReviewController`에도 동일하게 복제**해서 씀. 별도 공용 유틸로 뽑진 않음(사용처가 두 컨트롤러뿐이라 굳이 분리 안 함).
- `GET /review/write`와 `POST /review/write` 둘 다 `returnUrl` 파라미터를 받음. GET은 안전하면 `addReview.jsp`에 숨은 필드로 심어서 폼 제출 시 그대로 따라가게 하고, POST는 성공 시 `returnUrl`(안전하면)로, 실패(중복작성 등) 시엔 재시도 URL에 `returnUrl`을 다시 붙여서 이어감. 둘 다 안전하지 않거나 없으면 기존처럼 `/`로 폴백.
- `userOderDelivery.jsp`의 "리뷰 작성" 링크가 `returnUrl=/member/orderDelivery?status={현재 필터}&page={현재 페이지}`를 같이 넘겨서, 리뷰 작성 후 정확히 보던 필터/페이지로 돌아옴.
- **라이브 검증**: (1) 배송 목록 → 리뷰 작성 → 등록 → `Location` 헤더가 `/`가 아니라 `returnUrl`로 지정한 배송 목록 URL인 것 확인 (2) `returnUrl=https://evil.com`, `returnUrl=//evil.com`(오픈 리다이렉트 시도) 둘 다 거부되고 `/`로 폴백되는 것 확인.

### 3-30-7. "마이페이지로 돌아가기" 링크 404 수정

사용자님이 리뷰 작성 후 "마이페이지로 돌아가기"를 눌렀다가 에러("527 오류"로 리포트됨) 재현 → 실제로는 500/527이 아니라 **404**였고(스택트레이스 안의 줄 번호 527을 에러 코드로 오인한 것), 원인은 `userOderDelivery.jsp`의 링크가 `/member/mypage`(소문자)인데 실제 라우트는 `/member/myPage`(대문자 P)라서 안 맞았던 것 — PROJECT_AUDIT.md 버그 10번에 이미 기록돼있던 사이트 전역 이슈의 한 인스턴스. 이 파일이 이번 세션에서 직접 작성한 것이라 범위 내로 보고 `/member/myPage`로 수정. 다른 페이지들의 동일 오타는 그대로 남아있음(PROJECT_AUDIT.md 참고).

### 3-30-8. 마이페이지(`member/myPage.jsp`) 데이터 바인딩 + admin 형식으로 UI 통일

사용자님이 마이페이지 스크린샷 보내면서 지적: (1) 회원 정보가 "이름값"/"닉네임값" 같은 플레이스홀더 그대로 나옴 (2) 빠른메뉴/하위 메뉴들을 admin 마이페이지 형식으로 통일해달라 → 확인해보니 컨트롤러(`MemberController.myPageForm()`)는 이미 실제 `MemberDTO`(`loginMember`)와 `couponList`를 모델에 채워서 넘기고 있었는데, JSP가 그 데이터를 전혀 안 쓰고 완전히 정적인 목업 텍스트만 렌더링하고 있었음(3-30 작업 시작 전부터 있던 상태, 이번 세션에서 손 안 댄 부분).

- **데이터 바인딩**: `member/myPage.jsp`를 `${loginMember.xxx}` 기반 실데이터 렌더링으로 전면 교체. 등급은 `MemberDTO`에 `GRADE_ID`만 있고 이름이 없어서, `MemberMapper.xml`의 `selectByMemberId`에 `GRADE` 테이블 LEFT JOIN을 추가하고 `MemberDTO.gradeName` 필드를 새로 만들어서 "BRONZE" 같은 실제 등급명이 나오게 함. 쿠폰 개수도 하드코딩된 "5장" 대신 `${couponList.size()}`(Jakarta EL 5.0의 메서드 호출 문법)로 실제 개수 표시.
- **UI를 admin/adminPage.jsp 형식으로 통일**: `#MemberInfo`(회색 배경 div들)를 admin과 동일한 `.card.profile-card`(아바타+이름+등급배지+닉네임 헤더 + `.info-list`의 라벨/값 행) 구조로 교체. "빠른 메뉴"/"내 선물 관리"/"고객센터" 3개 섹션 전부 admin의 `.quick-menu-grid`/`.quick-menu-tile`(아이콘+라벨 카드) 패턴으로 통일 — 기존엔 3개 섹션이 서로 다른 시각 스타일(단순 사각형 버튼 vs 설명문구 포함 카드)이라 사용자님이 "안 헷갈리게" 요청한 부분을 해결. 아이콘은 admin의 기존 SVG(주문·배송, 문의) 일부를 재사용하고, 장바구니/찜 아이콘은 `header.jsp`의 기존 하트/카트 아이콘 path를 그대로 재사용해서 사이트 전체 아이콘 언어를 통일함. `href="#"`(대응 화면 없음) 클릭 시 페이지 점프 방지 스크립트도 admin과 동일하게 적용.
- **실제로 동작하는 링크만 연결**: 주문·배송 조회(`/member/orderDelivery`), 주문 취소/환불(→ 유저용 취소 신청 화면이 없어서 가장 가까운 실제 화면인 `/member/orderDelivery?status=canceled`로 연결, 읽기 전용 확인 용도), 쿠폰 상세(`/member/couponView`). 나머지(리뷰 작성/문의사항/문의내역/공지사항)는 대응 화면이 프로젝트에 아예 없어서 admin과 동일하게 `href="#"` 비활성 처리.
- **`/member/cart`, `/member/wish` 링크는 시도했다가 되돌림** — 실제로 눌러보니 컨트롤러 매핑 자체는 있지만 리턴하는 뷰 이름(`member/cart`)에 대응하는 JSP 파일이 없어서(PROJECT_AUDIT.md 버그 9번, product 패키지 담당 영역) 404가 남 → 새로 깨진 링크를 노출하지 않기 위해 두 타일 다 임시로 `href="#"` 처리하고 주석으로 이유/복구 방법을 남겨둠. **버그 9번 관련 참고: 실제로는 500이 아니라 404였음(Spring Boot 3.x가 JSP 뷰 리졸브 실패를 404로 처리) — PROJECT_AUDIT.md에도 정정 기록함.**
- **CSS 전면 교체** — `style_myPage.css`를 `style_admin_mypage.css`와 동일한 선택자 구조(`.card`, `.profile-card-top`, `.info-list`/`.info-row`, `.quick-menu-grid`/`.quick-menu-tile`)로 다시 작성하되 `.member-mypage-page`로 스코프. admin은 5개 타일 고정폭 그리드(`repeat(5, 1fr)`)를 쓰지만, 회원 페이지는 섹션마다 타일 개수가 다를 수 있어(4개/4개/3개) `repeat(auto-fit, minmax(150px, 1fr))`로 유연하게 처리해 3개짜리 고객센터 섹션에서 빈 칸이 안 생기게 함.
- **정보 수정 버튼은 그대로 둠** — `/member/updateInfo`는 원래부터 대응 컨트롤러가 없는 404(PROJECT_AUDIT.md 버그 10번, 이번 세션 시작 전부터 있던 문제)라 새로 만든 문제가 아니고, 회원정보 수정 기능 자체를 새로 구현하는 건 이번 요청 범위 밖이라 링크만 유지하고 손대지 않음.

### 검증
테스트 계정으로 로그인 후 `/member/myPage` 실제 응답 확인: `loginMember`의 이름/등급(BRONZE)/아이디/휴대폰/이메일/포인트가 전부 실제 DB 값으로 렌더링됨, 쿠폰 개수 0장 정상 표시, 모든 타일 href 확인(`orderDelivery`/`orderDelivery?status=canceled`/`couponView`는 200, `cart`/`wish`는 프로젝트의 기존 버그로 404라 이번엔 `#`로 비활성화해서 노출 안 함).

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MemberDTO.java   (gradeName 필드 추가)
  src/main/resources/mappers/MemberMapper.xml                        (selectByMemberId에 GRADE LEFT JOIN)
  src/main/webapp/WEB-INF/views/member/myPage.jsp                    (실데이터 바인딩 + admin 형식 UI로 전면 재작성)
  src/main/resources/static/css/style_myPage.css                     (style_admin_mypage.css 패턴으로 전면 재작성)
```

### 3-30-9. 마이페이지 하위 섹션을 리스트 형식으로 재조정 + 실데이터 배지

3-30-8 직후 사용자님이 디자인 시안(스크린샷)을 보내며 정정: "빠른 메뉴"는 그대로 두고, 그 아래(내 선물 관리~고객센터)는 아이콘 타일 그리드가 아니라 **제목+설명+배지+화살표(›)로 구성된 리스트 행** 형식이어야 한다고 요청.

- **"내 선물 관리" → "주문관리"로 재구성**: 시안에 맞춰 항목을 주문/배송조회, 주문취소/환불 2개로 정리(장바구니/찜 항목은 시안에 없었고, 어차피 헤더 아이콘으로 이미 접근 가능해서 제거 — 위 PROJECT_AUDIT.md 참고 항목의 `/member/cart`,`/member/wish` 404 이슈도 이걸로 자연히 회피됨).
- **"리뷰 작성"을 별도 섹션으로 분리**: 설명 문구 + "작성 가능한 리뷰 N개" CTA 배지(배송완료 필터로 연결).
- **"고객센터"도 동일한 리스트 행 형식으로 통일**(문의사항/문의내역/공지사항, 전부 대응 화면 없어 `href="#"`).
- **배지 숫자는 실제 데이터로 계산**: `MemberMapper`에 `countActiveDeliveries`(배송완료/취소환불 이전 단계인 진행중 주문 수 - "주문/배송 조회" 배지)와 `countReviewableOrderDetails`(배송완료된 주문 상세 중 리뷰 미작성 건수 - "리뷰 작성" 배지) 신규 추가. 대표 상품 1건이 아니라 `ORDERDETAIL` 전체 기준으로 세야 "몇 개 리뷰를 쓸 수 있는지"가 정확해서, 리뷰 카운트는 대표상품 서브쿼리가 아니라 `ORDERDETAIL`을 직접 조인해서 계산.
- 신규 CSS(`.list-card`/`.list-row`/`.list-row-title`/`.list-row-desc`/`.list-row-badge`/`.list-row-chevron`, `.review-cta-card`/`.review-cta-badge`)는 admin에 없는 새 컴포넌트라 이번에 새로 디자인(시안 그대로: 흰 카드 안에 구분선으로 나뉜 행, 우측 정렬 배지+화살표).

### 검증
테스트 계정으로 실제 값 확인: "주문/배송 조회" 배지 9(진행중 주문 개수와 일치), "작성 가능한 리뷰 0개"(배송완료 주문에 이미 리뷰가 있어서 0이 정확한 값), 리스트 행 3개 섹션 모두 제목/설명/화살표 정상 렌더링.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/member/model/mapper/MemberMapper.java   (countActiveDeliveries, countReviewableOrderDetails 추가)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberService.java       (〃)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberServiceImpl.java   (〃)
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java (activeOrderCount/reviewableCount 모델 추가)
  src/main/resources/mappers/MemberMapper.xml                               (신규 count 쿼리 2개)
  src/main/webapp/WEB-INF/views/member/myPage.jsp                          (주문관리/리뷰작성/고객센터를 리스트 행 형식으로 재작성)
  src/main/resources/static/css/style_myPage.css                          (.list-row/.review-cta 등 신규 스타일)
```

### 3-30-10. "내가 쓴 리뷰" 조회/삭제 기능 신규 구현

사용자님이 마이페이지 "리뷰 작성" 섹션에서 본인이 쓴 리뷰를 조회/삭제할 수 있게 해달라고 요청 → 리뷰 도메인에 이런 기능 자체가 아예 없어서 새로 구현.

- **`ReviewMapper`에 4개 메서드 추가**: `selectMyReviews`(내 리뷰 목록, product 상세 화면의 `getReviewList`와 동일한 조인 패턴 + 상품 대표이미지 LEFT JOIN 추가), `selectReviewImagesByReviewIds`(N+1 방지용 배치 이미지 조회), `selectReviewImageSaveNamesByReviewId`(삭제 시 디스크에서 같이 지울 파일명 조회), `deleteReview`(`WHERE REVIEW_ID=? AND MEMBER_ID=?`로 소유권 검증까지 WHERE절에서 처리 - admin의 `confirmPayment` 등과 동일한 관례). `REVIEWIMAGE`는 `REVIEW` 삭제 시 FK `ON DELETE CASCADE`라 DB 행은 자동 정리되지만, 실제 업로드 파일은 별도로 지워야 해서 삭제 전에 파일명을 먼저 조회해두고 DB 삭제 성공(영향 행 1건) 확인 후 물리 파일 삭제.
- **`ReviewServiceImpl.listMyReviews()`** 작성 시, `ProductServiceImpl`에 있는 것으로 이미 알려진 버그(리뷰 이미지 리스트를 반복문 밖에서 한 번만 만들어서 모든 리뷰가 공유해버리는 문제, PROJECT_AUDIT.md 버그 2번)를 반복하지 않도록 `Map<reviewId, List<ReviewImagesDTO>>`로 리뷰별로 새 리스트를 만들어서 정확히 배정.
- **신규 화면 `GET /review/myReviews`**(`review/myReviews.jsp`) — 상품 썸네일(없으면 "상품 이미지가 없습니다" 안내), 별점(★ 5개 중 채워진 개수), 리뷰 본문, 첨부 사진(있으면), 작성일, 삭제 버튼(confirm 확인 후 폼 제출)을 카드 목록으로 표시. **신규 엔드포인트 `POST /review/delete/{reviewId}`**로 삭제 처리 후 flash 메시지와 함께 목록으로 리다이렉트.
- 마이페이지의 "리뷰 작성" CTA 카드에 "내가 쓴 리뷰 조회·삭제 ›" 링크 추가해서 진입 경로 연결.
- 신규 CSS `style_myReviews.css`(기존 `.order-card`/`.list-card` 시각 언어와 통일: 흰 카드, 구분선, 크림톤 배지).

### 검증
테스트 계정으로 실제 흐름 확인: 목록 조회(기존 테스트 리뷰 1건 정상 표시) → `POST /review/delete/{id}` 실제 호출 → 목록에서 사라지고 "아직 작성한 리뷰가 없습니다" 빈 상태로 전환 확인 → 존재하지 않는/본인 소유가 아닌 리뷰 ID로 삭제 시도 시 "본인이 작성한 리뷰만 삭제할 수 있습니다" 에러로 정상 차단되는 것 확인. 마이페이지 → "내가 쓴 리뷰" 링크 연결도 확인.

### 신규/수정 파일
```
신규:
  src/main/webapp/WEB-INF/views/review/myReviews.jsp
  src/main/resources/static/css/style_myReviews.css

수정:
  src/main/java/com/kh/sajotuna/mds/review/model/dto/ReviewDTO.java          (productImagePath/productImageSaveName 필드 추가)
  src/main/java/com/kh/sajotuna/mds/review/model/mapper/ReviewMapper.java    (selectMyReviews 등 4개 메서드)
  src/main/resources/mappers/review/ReviewMapper.xml                        (〃)
  src/main/java/com/kh/sajotuna/mds/review/model/service/ReviewService.java (listMyReviews/deleteReview 추가)
  src/main/java/com/kh/sajotuna/mds/review/model/service/ReviewServiceImpl.java (〃, 이미지 배치 조회 + 파일 삭제)
  src/main/java/com/kh/sajotuna/mds/review/controller/ReviewController.java (GET /myReviews, POST /delete/{reviewId})
  src/main/webapp/WEB-INF/views/member/myPage.jsp                           ("내가 쓴 리뷰" 링크 추가)
  src/main/resources/static/css/style_myPage.css                           (.review-cta-link 스타일)
  src/main/webapp/WEB-INF/views/common/header.jsp                          (style_myReviews.css 링크 추가)
```

### 3-30-11. 리뷰 삭제 후 재작성 허용 여부 — 논의만 하고 보류

3-30-10 직후 사용자님이 "삭제했더니 다시 리뷰 작성이 가능해지는건 버그 같다"고 지적. 검토해보니 스키마(REVIEW 테이블에 어떤 형태로든 흔적)를 안 남기고는 "예전에 썼었다가 지웠다"는 사실을 영구히 기억할 방법이 논리적으로 없음 — 두 가지 대안(① `IS_DELETED` 컬럼 추가 후 소프트 삭제로 전환 ② 스키마 무변경, `REVIEW_TEXT`만 비우기)을 제시했고, 사용자님은 ①(새 컬럼 추가)을 선호했지만 **"월요일에 팀원들과 논의해보고 결정하겠다"며 실제 스키마 변경은 이번엔 보류**하기로 함.

- **실제로 한 것**: 라이브 DB에 `ALTER TABLE`을 실행하려고 스크립트까지 준비했었으나 사용자님 지시로 실행하지 않고 삭제함 — **DB 스키마도, 애플리케이션 코드도 이번엔 전혀 안 건드림.**
- 3-30-10에서 구현한 "내가 쓴 리뷰" 삭제 기능은 원래 방식(REVIEW 행 실제 DELETE, 재작성 허용) 그대로 유지 상태.
- 방식 ②(스키마 무변경)를 택하더라도 상품 상세 페이지 평균 별점/리뷰 개수 집계(product 패키지, 제 담당 영역 밖)에 "빈 리뷰가 별점으로 카운트되는" 부작용이 있다는 점은 사용자님도 인지하고 있음.
- 자세한 트레이드오프와 다음에 이어서 진행할 방향은 `PROJECT_AUDIT.md`의 "정책적 고려가 필요한 부분" 11번 항목에 기록해둠 — 팀 논의 후 방향이 정해지면 그 항목부터 이어서 진행하면 됨.

### 3-30-12. 빠른 메뉴에도 알림 배지 추가

사용자님이 처음 시안 스크린샷엔 빠른 메뉴 타일에도 배지가 있었는데 실제 구현엔 빠져있다고 지적. 3-30-9에서 이미 계산해둔 `activeOrderCount`/`reviewableCount` 모델을 그대로 재사용해서, "주문·배송 조회"/"리뷰 작성" 타일 우상단에 작은 원형 배지(`quick-menu-badge`, 0이면 안 보임)를 추가. "문의사항"/"문의내역"은 대응 데이터가 없어 배지 없이 그대로 둠. 실제 값(진행중 주문 9, 작성 가능한 리뷰 1)으로 정상 렌더링 확인.

### 3-30-13. "내가 쓴 리뷰"에 페이징 추가 + 썸네일 크기 통일

사용자님 요청 2건: (1) 이 목록에도 페이징 추가 (2) 썸네일 크기를 주문·배송 페이지(80px)와 통일.

- 배송 목록 페이지(3-30-4)와 동일한 패턴으로 서버 사이드 페이징 적용: `ReviewMapper.selectMyReviews`에 `OFFSET/FETCH` + `countMyReviews` 신규 추가, `ReviewService.listMyReviews(memberId, page)`/`totalMyReviewPages(memberId)`, 컨트롤러의 페이지 윈도우 계산(5개 창)까지 동일한 구조로 재사용. 페이지 크기는 10건 고정.
- `style_myReviews.css`의 `.review-thumb`을 64px → 80px로 맞춤(`.item-thumb`과 동일 규격), no-image 텍스트도 같이 11px로 조정.
- 테스트 리뷰 11건을 추가로 만들어서(총 12건) 1페이지 10건+"다음", 2페이지 2건+"이전"이 정상 동작하는 것 확인 후 전부 정리(`REVIEW.FK_REVIEW_OD`엔 CASCADE가 없어서 주문 삭제 전에 리뷰부터 먼저 지워야 한다는 것도 이번에 확인).

### 3-30-14. 쿠폰 뷰(`/member/couponView`) 실데이터 연동 + CSS 신규 작성

마이페이지에서 "쿠폰" 행을 눌러서 들어가는 `/member/couponView` 화면도 사용자님이 확인해보니 여전히 정적 목업(하드코딩된 쿠폰 3장) + CSS 자체가 안 먹은 상태(글자만 있고 스타일 없음)였음.

- **CSS 원인 진단 정정(중요)**: 처음엔 `usercouponView.jsp` 자체 `<link href=".../style_coupon.css">`가 가리키는 `style_coupon.css` 파일이 아예 없다고 판단해서 새로 작성했는데, **사용자님이 확인 후 정정** — 이 화면 전용으로 이미 잘 디자인된 `style_usercouponView.css`가 실제로 존재하고 있었음(`.coupon-page`/`#CouponSummary`/`.coupon-card` 등 원래 정적 목업과 정확히 맞는 선택자). 다만 (a) JSP 자신의 `<link>`가 엉뚱하게 존재하지도 않는 `style_coupon.css`를 가리키고 있었고 (b) `header.jsp`의 전역 CSS 목록에도 등록이 안 돼서 **완전히 고아 파일**이었던 것 — 검색을 `style_coupon.css`로만 좁게 해서 이 프로젝트 관례(`style_<JSP파일명>.css`)를 따르는 실제 파일을 못 찾은 게 제 실수. **어느 CSS(새로 만든 `style_coupon.css`+재작성 마크업 vs 기존 `style_usercouponView.css`+그에 맞는 마크업)로 최종 확정할지는 사용자님이 디자인 검토 후 알려주기로 함 — 결정 전까지 추가 코드 변경 보류.** 자세한 내용은 `PROJECT_AUDIT.md` 정책 항목 2번 참고.
- **부수 발견한 진짜 원인 버그**: `MemberMapper.selectCouponsByMemberId`의 SQL은 `resultType="CouponDTO"`(product 패키지의 통합 쿠폰 DTO)를 쓰는데, Java 쪽 인터페이스(`MemberMapper`/`MemberService`/`MemberServiceImpl`/`MemberController`)는 전부 `coupon` 패키지의 별도 클래스인 `List<MypageCouponDTO>`로 선언되어 있던 **타입 불일치**. 제네릭 소거 덕분에 컴파일 에러도, 런타임 캐스팅 에러도 안 났지만(모델에 그대로 통째로 넘기기만 해서), 실제 런타임 객체는 `CouponDTO`인데 필드명이 다름(예: `deadLineStr` vs 실제 `deadlineStr`) — 이 화면이 실데이터 연동을 시도했다면 계속 빈 값만 나왔을 것. `MypageCouponDTO`를 전부 `CouponDTO`로 교체하고, 사용처 0건 확인 후 `MypageCouponDTO.java` 삭제.
- **화면 재작성**: `couponList`(실제 `CouponDTO` 목록)를 JSTL로 바인딩. 쿠폰 사용/만료 여부를 구분할 별도 컬럼이 없어서(체크아웃 미구현으로 `COUPONHISTORY.TYPE`의 'USE'/'EXPIRE'는 프로젝트 전체에서 한 번도 안 쓰임 - 'ISSUE'만 사용) `deadlineStr`(YYYY-MM-DD)과 컨트롤러가 넘겨주는 `todayStr`을 문자열로 비교해서 사용가능/만료만 판단. 원래 목업에 있던 "사용완료" 항목은 판단할 근거 자체가 없어서 이번엔 빼고 보유쿠폰/사용가능/만료쿠폰 3개로 정리.
- 할인율(`couponValue`, BigDecimal 0.1=10%)을 `${coupon.couponValue * 100}`로 퍼센트 변환해서 표시. 검색창은 서버 왕복 없이 클라이언트 JS(`static/js/views/usercouponView.js`, 순수 이름 필터)로 처리 — 데이터 양이 적어 서버사이드로 갈 필요 없다고 판단.
- "사용" 버튼은 체크아웃/쿠폰적용 플로우 자체가 프로젝트에 없어서 여전히 시각적 버튼만 있고 실제 동작은 연결 안 함(만료 쿠폰은 disabled 처리).

### 검증
실제 COUPON 시드 데이터 중 사용가능 2장(그 중 1장은 마감일이 오늘이라 "오늘까지는 사용가능" 경계값 케이스) + 만료 1장을 테스트 계정에 발급해서 확인: 보유쿠폰 3/사용가능 2/만료쿠폰 1 집계 정확, 할인율 %가 정확히 변환(0.1→10%, 0.2→20%)되는 것, CSS/JS 정상 로드(200), 헤더/푸터 정상 연결(`site-footer` 1회) 확인. **다만 이건 제가 새로 만든 `style_coupon.css` 기준 검증이고, CSS를 어느 쪽으로 최종 확정할지는 위 정정 내용대로 아직 미정 — 방향 정해지면 그에 맞춰 재검증 필요. 테스트 발급 쿠폰은 화면 확인용으로 남겨둠(정리 필요).**

### 신규/수정 파일
```
신규:
  src/main/resources/static/css/style_coupon.css
  src/main/resources/static/js/views/usercouponView.js

삭제:
  src/main/java/com/kh/sajotuna/mds/coupon/model/dto/MypageCouponDTO.java

수정:
  src/main/java/com/kh/sajotuna/mds/member/model/mapper/MemberMapper.java   (CouponDTO로 교체)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberService.java      (〃)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberServiceImpl.java  (〃)
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java (〃, todayStr 모델 추가)
  src/main/webapp/WEB-INF/views/member/usercouponView.jsp                  (실데이터 바인딩으로 전면 재작성)
  src/main/webapp/WEB-INF/views/common/header.jsp                         (style_coupon.css 링크 추가)
```

### 3-30-15. 쿠폰 뷰 디자인 확정: admin 형식 통일 + 만료 섹션 제거 + 페이징

사용자님이 디자인 검토 후 방향 확정: 제가 새로 만든 `style_coupon.css` 쪽으로 가되(기존 고아 파일 `style_usercouponView.css`는 그대로 안 씀), admin 쿠폰 뷰(`admincouponView.jsp`/`style_admincouponView.css`) 형식과 더 통일하고, 만료 쿠폰은 유저에게 아예 안 보여주고 "사용 가능한 보유 쿠폰"만 노출하는 방향 + 페이징 추가.

- **레이아웃을 admin과 동일한 2단 구조로 교체**: `.coupon-view-page`(바깥 배경 #f8f6f2) + `.coupon-view-page-card`(안쪽 흰 카드, width 800px, border-radius 12px) — 기존에 섹션마다 개별 카드를 쓰던 제 원래 스타일(myPage/orderDelivery와 같은 방식) 대신, admin 쿠폰 뷰처럼 큰 카드 하나 안에 전부 담는 방식으로 통일. 쿠폰 카드/할인율/버튼 색상·크기도 admin 쪽(`#806746`, `#b59b7b` 톤)에 맞춤.
- **만료 쿠폰 섹션 + 사용가능/만료쿠폰 요약 박스 완전 제거** — `selectCouponsByMemberId` SQL 자체에 `C.DEADLINE >= TRUNC(SYSDATE)` 조건을 추가해서 서버에서부터 만료 쿠폰을 아예 조회하지 않음(화면에서 숨기는 게 아니라 쿼리 단계에서 제외). 요약도 "보유쿠폰" 카운트 하나로 단순화(= 사용 가능한 쿠폰 개수와 동일한 의미가 됨) — admin의 "등록된 쿠폰 (N)" 헤더 패턴 그대로 재사용.
- **페이징 추가**: 배송/리뷰 목록과 동일한 서버사이드 방식(페이지당 10건, OFFSET/FETCH, 5개 창 페이지네이션). `MemberMapper`에 `countCouponsByMemberId` 신규 추가.
- **부수 정리**: `MemberService.listCoupon()`이 원래 마이페이지의 "보유 쿠폰 N장" 배지에도 쓰이고 있었는데, 이 배지는 전체 리스트가 아니라 개수만 필요해서 별도 `countCoupons()` 메서드로 분리(마이페이지가 페이지당 10건으로 잘린 리스트의 `.size()`를 쓰다가 배지 숫자가 최대 10에서 멈추는 버그가 될 뻔한 것을 미리 방지). `myPage.jsp`의 `${couponList.size()}` → `${couponCount}`로 교체.

### 검증
테스트 계정에 사용 가능한 쿠폰을 12장까지 늘려서 1페이지(10장+다음), 2페이지(2장+이전) 정상 동작 확인. 만료 쿠폰(테스트로 넣었던 것)이 화면 어디에도 안 나오는 것(HTML에 "만료"/"사용가능"/"summary-box" 문자열 자체가 0건), 마이페이지의 "보유 쿠폰" 배지도 새 `countCoupons()` 기준으로 정확히 12장 표시되는 것까지 확인.

### 신규/수정 파일
```
수정:
  src/main/resources/mappers/MemberMapper.xml                                (쿠폰 쿼리에 만료 제외 + 페이징, countCouponsByMemberId 추가)
  src/main/java/com/kh/sajotuna/mds/member/model/mapper/MemberMapper.java    (〃)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberService.java       (listCoupon 페이징화, countCoupons/totalCouponPages 추가)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberServiceImpl.java   (〃)
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java (couponView 페이징 파라미터, myPage는 countCoupons로 교체)
  src/main/webapp/WEB-INF/views/member/usercouponView.jsp                   (admin 형식 2단 레이아웃, 만료 섹션 제거, 페이징 추가)
  src/main/webapp/WEB-INF/views/member/myPage.jsp                           (couponList.size() -> couponCount)
  src/main/resources/static/css/style_coupon.css                           (admin 톤으로 전면 재작성)
  src/main/resources/static/js/views/usercouponView.js                     (단일 리스트 기준으로 단순화)
```

### 3-30-16. 쿠폰 뷰: "사용" 버튼 제거 + 마이페이지 복귀 링크 추가

사용자님 지적: 쿠폰 사용은 체크아웃(주문서 작성) 화면에서 하는 거지 쿠폰 보관함 화면에서 할 일이 아니므로 "사용" 버튼은 애초에 없는 게 맞다는 판단 → 각 쿠폰 카드의 `.coupon-use` 버튼과 관련 CSS 제거. 다른 목록 페이지(배송/리뷰)와 마찬가지로 하단에 "마이페이지로 돌아가기" 링크(`.coupon-back`/`.btn-back-mypage`, 동일한 스타일)도 추가.

### 3-30-17. 관리자 마이페이지 "일반 메뉴"도 새 리스트 형식으로 통일 + 테스트 데이터 전체 정리

사용자님이 마이페이지 화면 테스트를 마무리 지으면서, admin 마이페이지의 "일반 메뉴"가 초록색 아코디언 헤더(`#ccd5ae`)+작은 글씨(13~14px)로 되어있어 새로 만든 유저 마이페이지 디자인과 안 맞는다고 지적 → admin 쪽도 통일.

- `admin/adminPage.jsp`의 "일반 메뉴"를 기존 2단 구조(그룹 헤더 3개 + 하위 항목)의 아코디언에서, `member/myPage.jsp`의 "주문관리"/"고객센터"와 동일한 `.list-card`/`.list-row`(제목+설명+화살표) 평평한 리스트 5줄(상품 등록/주문·배송 관리/쿠폰 조회 및 등록/문의사항 처리/공지 작성)로 재구성. 실제 화면 이동이 있는 3개는 기존 라우트 그대로 유지, 대응 화면 없는 2개는 기존처럼 `href="#"`.
- `style_admin_mypage.css`의 `.accordion`/`.accordion-header`(초록 배경)/`.accordion-panel` 규칙을 전부 제거하고, `style_myPage.css`의 `.list-row` 관련 규칙을 `.admin-mypage-page` 스코프로 동일하게 이식.
- 이번 세션에서 만든 모든 테스트 데이터(테스트 계정 `delvtest`, 주문 24건, 리뷰 12건, 쿠폰발급이력 13건) 전체 정리 완료 — 잔존 0건 확인.

### 3-30-18. 세션은 살아있는데 회원 행이 없어진 경우 처리 (마이페이지 null 가드)

3-30-17 직후 사용자님이 직접 마이페이지 스크린샷을 보내며 날카롭게 지적: "계정 삭제됐으면 이 페이지 연결이 안 되어야 정상 아니냐" — 정확히 맞는 지적이었음. 원인은 제가 테스트 계정을 DB에서 삭제하는 동안 사용자님 브라우저는 로그인 세션을 계속 들고 있었던 것 — 세션은 서버 메모리에 살아있어서 `WebConfig`의 `LoginInterceptor`(로그인 여부만 확인)는 통과시키는데, `MemberController.myPageForm()`이 `service.getMemberByMemberId()`가 `null`을 반환할 수 있다는 걸 전혀 확인 안 하고 그대로 모델에 넣어버려서 화면에 빈 필드만 나오는 상태였음.

- **수정**: `myPageForm()`에서 `getMemberByMemberId()` 결과가 `null`이면(세션은 유효한데 실제 회원 행이 없어진 경우 - 탈퇴/관리자 삭제 등) `session.invalidate()`로 세션을 무효화하고 `/member/login`으로 리다이렉트(flash 메시지 "회원 정보를 찾을 수 없습니다. 다시 로그인해주세요." 포함).
- **라이브 재현 검증**: 새 테스트 계정으로 로그인해서 세션을 살려둔 채 DB에서 그 회원 행만 직접 삭제 → 마이페이지 재요청 시 수정 전엔 200 + 빈 필드, 수정 후엔 302로 로그인 페이지 이동 + 새 세션 발급 + flash 메시지 정상 표시까지 확인.
- **범위 참고**: 같은 패턴(`session.getAttribute(LOGIN_SESSION)`을 쓰지만 회원 상세를 다시 조회하진 않는) `wishlistForm`/`cartForm`/`userOrderDeliveryForm`/`userCouponViewForm`은 회원 상세 재조회가 없어서 이 정도로 눈에 띄게 깨지진 않음(목록 쿼리가 그냥 빈 결과를 반환) — `myPageForm`만 회원 필드 전체를 다시 바인딩해서 증상이 뚜렷하게 나타난 것. 다른 메서드들도 근본적으로는 같은 종류의 gap이 있지만 이번엔 실제로 증상이 재현된 `myPageForm`만 수정.

### 신규/수정 파일
```
수정:
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java (myPageForm에 null 가드 + 세션 무효화 추가)
```

### 3-30-19. 오늘 세션 마무리 점검 (재검증 + 죽은 코드 정리)

하루 마무리하면서 오늘 만든 것 전체를 한 번 더 점검.

- **기능 재검증**: 새 테스트 계정으로 `/member/myPage`, `/member/orderDelivery`, `/review/myReviews`, `/member/couponView` 전부 200 확인, 데이터 없는 상태에서 각 페이지의 빈 상태 문구가 정상 표시되고 페이지네이션 위젯이 안 뜨는 것(1페이지뿐일 때) 확인, 오늘 새로 만들거나 수정한 CSS/JS 파일(`style_order.css`, `style_myPage.css`, `style_myReviews.css`, `style_coupon.css`, `style_admin_mypage.css`, `views/usercouponView.js`) 전부 200 확인.
- **죽은 코드 점검**: 오늘 수정한 CSS 파일들의 클래스가 대응 JSP에서 전부 쓰이고 있는지, 오늘 추가한 `MemberService`/`MemberMapper`/`ReviewService`/`ReviewMapper`의 신규 메서드가 전부 실제로 호출되는지, 새로 추가한 import가 전부 실제로 쓰이는지 grep으로 전수 확인 — 전부 정상.
- **정리한 것**: `userOderDelivery.jsp`에 남아있던 `id="order-status-filter"`/`id="order-list"`/`id="order-empty"` 3개 — 원래 클라이언트 JS 필터용 훅이었는데 서버사이드 페이징으로 바꾸면서 그 JS 파일(`userOrderDelivery.js`)을 삭제했을 때 이 id들만 지우는 걸 깜빡했던 것. CSS/JS 어디서도 참조 안 하는 것 확인 후 제거.
- **문서 정합성 확인**: `PROJECT_AUDIT.md` 전체를 다시 읽고 오늘 추가한 항목들이 서로 모순되지 않는지 확인(예: 쿠폰 CSS 오진단 → 정정 → 최종 결정까지 흐름이 앞뒤가 맞는지). 번호가 일부 비순차적(13 다음 16, 17이 나온 뒤 14/15가 이어지는 구간)인 건 기존 문서의 섹션 구조 때문 — 다른 항목들이 이 번호를 서로 인용하고 있어서(`"정책 항목 9번"` 등) 번호를 다시 매기면 그 참조들이 깨질 위험이 있어 이번엔 손대지 않음.

### 이번에 새로 발견한 것 (범위 밖이라 수정 안 하고 PROJECT_AUDIT.md에만 기록)
- **`header.jsp:30`의 `data-logged-in`이 항상 `false`로 나옴** — `sessionScope.loginMemberId`라는 세션 키가 프로젝트 어디에서도 저장되지 않음(실제 키는 `LOGIN_SESSION`). 로그인 상태로 홈에 갈 때마다 장바구니/찜 localStorage가 "비회원 초기화" 로직에 의해 매번 조용히 삭제되는 실질적 버그. `common/header.jsp` 담당자 확인 필요, 자세한 내용은 PROJECT_AUDIT.md 참고.

### 신규/수정 파일
```
신규:
  src/main/resources/static/js/views/userOrderDelivery.js

수정:
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java     (뷰 이름 수정)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberServiceImpl.java      (listDelivery N+1 루프 제거)
  src/main/java/com/kh/sajotuna/mds/member/model/mapper/MemberMapper.java     (selectProductByOrderId 삭제)
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MyPageDeliveryDTO.java   (qty/productCount 필드 추가)
  src/main/resources/mappers/MemberMapper.xml                                 (selectDeliveriesByMemberId 재작성, selectProductByOrderId 삭제)
  src/main/webapp/WEB-INF/views/order/userOderDelivery.jsp                    (header/footer include + JSTL 데이터 바인딩으로 전면 재작성)
  src/main/resources/static/css/style_order.css                              (.page-content 스코프 수정, out_for_delivery 색상 추가, 미사용 버튼 CSS 제거)
  src/main/webapp/WEB-INF/views/member/myPage.jsp                             (주문·배송 조회 타일 2곳에 링크 추가)
```

---

## 3-31. 2026-08-31: 새 환경에서 어제 작업 전체 재검증 (코드 변경 없음)

새 작업환경(`c:\work sapace\05_Framework\TunaProject_MDS`)에서 3-30 시리즈(유저 주문/배송 확인, 마이페이지, 내가 쓴 리뷰, 쿠폰 뷰) 전체를 처음부터 다시 라이브 검증. **이번 세션은 순수 검증만 수행 — 코드 변경 0건**(PROJECT_AUDIT.md에 새로 발견한 사항 1건만 기록 추가, 아래 참고).

### 사전 점검
- git status 깨끗함(미커밋 변경 없음), 현재 브랜치 `BJY_works`.
- 서버가 이미 8797 포트에서 실행 중(devtools). `mvnw compile` 재실행 → 컴파일 에러 0건, devtools 자동 재기동 확인 → 현재 소스와 실행 중인 인스턴스가 일치함을 확인 후 검증 시작.

### 코드-문서 정합성 재확인 (grep 기반 대조)
아래 전부 HANDOFF.md/PROJECT_AUDIT.md의 서술과 실제 코드 상태가 일치함을 확인 — 어제 기록에 잘못된 부분 없음:
- `MemberMapper.xml`의 `selectDeliveriesByMemberId` 등 3곳 모두 `LEFT JOIN DELIVERY` (INNER JOIN 버그 수정 유지).
- `selectProductByOrderId`(N+1 원인 메서드) 코드베이스 전체에서 0건 — 삭제 확인.
- `MemberController.myPageForm()`에 null 가드 + `session.invalidate()` 존재.
- `coupon/MypageCouponDTO.java` 파일 없음 — 삭제 확인.
- `header.jsp`가 `style_coupon.css`만 로드하고 `style_usercouponView.css`(고아 파일)는 안 불러옴 — 결정대로 유지.
- `userOderDelivery.jsp`에 죽은 id(`order-status-filter`/`order-list`/`order-empty`) 없음 — 정리 확인.
- `adminPage.jsp`/`style_admin_mypage.css`에 `accordion` 관련 클래스/CSS 완전히 없고 `list-card` 형식으로만 존재.
- `MemberMapper`/`MemberService`에 `countActiveDeliveries`/`countReviewableOrderDetails` 정상 존재 및 호출됨.

### 실제 라이브 검증 (신규 테스트 계정 2개, 서버 8797 + 라이브 DB)

**테스트 계정 1 (`qatest01`, MEMBER_ID=33)** — 회원가입 API로 생성 후 로그인, 다음 순서로 실제 화면/API 호출:
1. **주문/배송 목록 페이징**: 테스트 주문 24건(CART 1 + PAYMENT_COMPLETED 2(DELIVERY 행 없음) + PREPARING 2 + SHIPPED 2 + OUT_FOR_DELIVERY 2 + 취소대기 2 + 취소완료 2 + DELIVERED 11)을 jshell로 직접 INSERT. 전체 필터(`status=all`)에서 23건(CART 제외)이 10+10+3으로 정확히 3페이지 분할되는 것, 상태별 필터(`preparing`=4, `shipped`=2, `out_for_delivery`=2, `canceled`=4, `delivered`=11→10+1 페이지분할) 전부 정확한 건수로 서버사이드 필터링+페이징이 함께 정상 동작하는 것 확인. 취소대기/취소완료 배지가 `DELIVERY_STATUS`/`ORDER_STATUS` 조합대로 2건씩 정확히 갈리는 것도 확인.
2. **리뷰 작성 → returnUrl 복귀 → 내가 쓴 리뷰 조회/삭제 전체 플로우**: DELIVERED 주문 11건 중 10건은 `POST /review/write`로 벌크 작성(내가 쓴 리뷰 페이징 검증용, 10건은 1페이지에 꽉 참), 남은 1건으로 전체 플로우를 정밀 검증 — 배송목록 화면에서 실제 렌더링된 "리뷰 작성" 링크의 `returnUrl` 파라미터를 그대로 따라가서 `GET /review/write`(hidden `returnUrl` 필드 정상 삽입 확인) → `POST /review/write`(성공 시 `Location` 헤더가 정확히 원래 배송목록 URL, `/`가 아님) → 배송목록에서 "리뷰 작성 완료" 배지로 전환 확인 → 이 시점 "내가 쓴 리뷰"가 11건이 되어 10+1로 정확히 페이지 분할되는 것 확인(방금 쓴 리뷰가 최신순으로 1페이지 맨 위, 가장 먼저 썼던 리뷰가 2페이지로 밀림 — 정렬 정상) → `POST /review/delete/{reviewId}` 실제 호출 → `/review/myReviews`로 리다이렉트, 목록에서 사라짐, 배송목록의 해당 카드가 "리뷰 작성" 버튼으로 원복, 마이페이지 "작성 가능한 리뷰" 배지 숫자도 정확히 갱신되는 것까지 확인.
3. **쿠폰 뷰 페이징 + 만료 제외**: 사용가능 쿠폰 12장(활성 11장 + 마감일=오늘인 경계값 1장) + 이미 만료된 쿠폰 1장을 발급 상태로 INSERT → `/member/couponView`가 정확히 12장(10+2 페이지 분할)만 노출하고 만료 쿠폰은 어느 페이지에도 안 나오는 것, 마이페이지의 "보유 쿠폰 12장" 배지도 일치하는 것 확인.
4. **세션 유효 + 회원 행 삭제**: 위 검증에 쓴 하위 데이터(REVIEW/COUPONHISTORY/PRODUCTORDER)를 전부 지운 뒤 MEMBER 행까지 삭제 — 이 계정은 이 시점에 정리를 겸함.

**테스트 계정 2 (`qatest02`)** — 세션-회원삭제 시나리오만 깨끗하게 재현하기 위해 별도로 생성(하위 데이터 없이 즉시 MEMBER만 삭제 가능하게). 로그인 세션을 살려둔 채 `DELETE FROM MEMBER`로 회원 행만 제거 → `GET /member/myPage` 단발 호출: `302 → /member/login`(리다이렉트 URL에 `redirectURL` 파라미터 없음 = `LoginInterceptor`가 아니라 컨트롤러의 null 가드 분기를 정확히 탄 것), 새 `JSESSIONID` 발급(구 세션 invalidate 확인), 이어지는 `/member/login` 요청에서 플래시 메시지 "회원 정보를 찾을 수 없습니다. 다시 로그인해주세요." 정상 렌더링까지 확인.
   - (참고: 중간에 이미 소모된 세션 쿠키로 같은 테스트를 반복 시도했다가 "플래시 메시지가 안 뜬다"는 오탐을 한 번 겪음 — 원인은 재검증 스크립트 실수(같은 세션으로 두 번째 요청)였고 기능 자체는 문제없음, 새 계정으로 깨끗하게 재현해서 확인 완료.)

### 새로 발견한 것 (범위 밖 — PROJECT_AUDIT.md에만 기록, 코드 수정 안 함)
- **`MemberServiceImpl.signUp()`이 `ROLE`을 안 채워서, 폼(버그 5로 원래 제출 자체가 안 됨)을 우회해 API를 직접 호출하면 `ORA-01400`(NOT NULL 위반)으로 500** — 기존 버그 6번(같은 경로에서 `memberName` 누락 시 500)과 같은 뿌리, `ROLE` 컬럼 한정으로 더 구체적인 사례. PROJECT_AUDIT.md 버그 6번에 각주로 추가함. 이번 세션에서 테스트 계정을 만들다가 실제로 겪음(`role=USER`를 API 호출에 명시적으로 넣어서 우회).

### 데이터 정리 (파일 + DB 전부 완료 확인)
- 이번 세션에서 만든 파일 업로드 없음(리뷰/쿠폰 테스트 전부 텍스트 데이터, 이미지 첨부 없이 진행) — `uploads/` 정리 불필요.
- DB: `MEMBER`(qatest01, qatest02), `PRODUCTORDER`(24건, CASCADE로 ORDERDETAIL/DELIVERY 동반 삭제), `REVIEW`(11건), `COUPONHISTORY`(13건), `COUPON`(13건, `COUPON_NAME LIKE 'QATEST%'`) 전부 ID 기준으로 직접 삭제 — 마무리에 `LOGIN_ID IN ('qatest01','qatest02')`/`COUPON_NAME LIKE 'QATEST%'`/`MEMBER_ID=33` 기준 잔존 건수 재조회로 전부 0건 확인.
- (참고: 테스트 데이터 삽입에 쓴 jshell 스크립트에서 한글 리터럴을 직접 소스에 적었더니 mojibake로 깨져 들어간 경우가 2건 있었음 — ①리뷰 본문은 실제 앱 API(`multipart/form-data`)로 다시 써서 정상 확인 후 문제없음, ②테스트 쿠폰 이름은 SQL 리터럴이 깨진 채로 들어갔지만 페이징/만료제외 로직 검증에는 지장 없어서 그대로 쓰고 삭제로 마무리함 — 실제 애플리케이션 코드의 인코딩 문제가 아니라 jshell 소스 파일 인코딩 이슈, 재확인 완료.)

### 결론
어제(3-30 시리즈) 구현한 유저 주문/배송 확인, 마이페이지, 내가 쓴 리뷰, 쿠폰 뷰 기능 전부 새 환경에서 코드 변경 없이 재검증 통과. 문서(HANDOFF.md/PROJECT_AUDIT.md)와 실제 코드 상태 100% 일치 확인. 미결 항목(리뷰 재작성 정책, 쿠폰 CSS 확정)은 지시대로 손대지 않음.

---

## 3-32. 2026-08-31: `KGH_works` → `server_for_merge` 병합 검토 + 실제 병합 + 병합 결과물 검증

사용자님이 팀원별 작업 브랜치를 순차적으로 합치기 위해 `BJY_works` 기반의 `server_for_merge` 브랜치를 새로 파고, 첫 번째로 `KGH_works`(BE005 주문결제, BE014 멤버정보수정 기능)를 병합하기 전 검토 요청. **이번 세션은 병합 전/후 코드 리뷰 + 실제 빌드/기동 검증 위주 — 직접 작성한 신규 코드 없음(문서 정리 제외).**

### 1차 검토 (병합 전, `git merge --no-commit` 드라이런)
- Git 텍스트 충돌은 0건(merge-base 이후 `server_for_merge`가 코드를 안 건드려서). 문제는 충돌이 아니라 **조용한 삭제**였음: `KGH_works`가 리팩토링 과정에서 `member/userUpdateInfo.jsp`, `product/cart.jsp`, `member/userWithdraw.jsp`, `style_search/cart/wish.css`를 지운 채로 푸시함.
  - `member/userUpdateInfo.jsp` 삭제는 진짜 회귀버그(같은 커밋에서 `/member/updateInfo` GET 매핑을 신규로 만들면서 정작 뷰 파일은 지움 → 신규 기능이 바로 404).
  - `product/cart.jsp` 삭제는 기존에 이미 알려진 버그(PROJECT_AUDIT.md 버그#9 — `cartForm()`이 `"member/cart"`를 리턴하는데 실제 파일은 `product/cart.jsp`)의 원본 자료를 잃는 문제였고, 신규 회귀는 아니었음.
  - `header.jsp`가 전역으로 링크하는 CSS(`style_search/cart/wish.css`)와 `style.css`의 `.icon-badge`(헤더의 `#wishBadge`/`#cartBadge`가 실사용) 삭제는 **사이트 전역 영향** — HANDOFF 3-4/3-5에서 이미 진단했던 "header.jsp가 모든 CSS를 무조건 로드 + 스코프 없는 선택자" 문제가 그대로 재발한 사례.
  - `userWithdraw.jsp` 삭제는 실제로는 무해(대응 GET 매핑 자체가 없음, PROJECT_AUDIT 버그#10과 일치) — 복구 불필요 항목으로 판정.
- KGH 작업자에게 위 파일들(`userWithdraw.jsp` 제외) 복구 요청 → 재푸시 확인.

### 2차 검토 (KGH 재푸시 후)
- 복구 확인 + 추가로 `/wish`,`/cart`가 리턴하는 뷰 이름이 `"member/wish"`,`"member/cart"` → **`"product/wish"`,`"product/cart"`로 수정**된 것 확인(PROJECT_AUDIT 버그#9의 나머지 절반이 이번에 같이 해결됨). `style_member.css`는 KGH의 수정분이 merge-base와 동일하게 되돌아가서 스코프 이슈 자체가 이번 병합 범위에서 빠짐.
- 병합 드라이런 재실행 → 충돌 0건, `mvnw clean compile` BUILD SUCCESS.
- 작업자 코멘트로 "회원탈퇴 화면(`userWithdraw.jsp`)이 비동기식(`@PostMapping /withdraw` + `@ResponseBody`)으로 짜여서 성공 후 화면 이동을 프론트에서 처리해야 한다"는 이슈 전달받음 — 실제 코드 확인 결과 `userWithdraw.jsp` 자체에 "실제 탈퇴 기능 구현 시 이 화면으로 forward/redirect 연결 필요"라는 TODO 주석이 원래부터 있었고, 프론트 JS 어디에도 `/withdraw` 호출이나 이 화면 이동 코드가 없어서(grep 0건) **현재는 탈퇴 성공 후 완료 화면으로 연결하는 코드가 아예 없는 상태**. 두 가지 해결 옵션(A: 비동기 유지 + 프론트 이동 처리 + 신규 GET 매핑 추가, B: 동기 폼 제출로 전환해서 컨트롤러가 바로 뷰 forward)을 사용자님께 전달, 팀 결정 대기(코드 미수정).

### 실제 병합 + 결과물 검증
사용자님이 실제로 `git merge KGH_works`를 `server_for_merge`에 수행. 이후 결과물을 처음부터 재검증:
- 충돌 마커 잔존 0건, 소스 상 `MemberMapper.xml` 중복 없음(정상적으로 `mappers/member/MemberMapper.xml` 1개로 rename됨).
- `mvnw clean compile` BUILD SUCCESS, 실제 서버 기동(포트 8797)까지 성공 — 빈 생성/MyBatis 매퍼 파싱 문제 없음.
- `curl`로 스모크테스트: `/`, `/member/login` 200, `/member/cart`(비로그인) 302 정상 리다이렉트, `/css/style_cart.css`,`/css/style_search.css`,`/css/style_wish.css`,`/css/style.css` 전부 200.
- **`/member/updateInfo`(비로그인) 500 재현** — `WebConfig.LoginInterceptor`의 `addPathPatterns`에 `/member/myPage`,`/member/couponView`,`/member/wish`,`/member/cart`,`/member/orderDelivery`,`/order/**`는 있는데 KGH가 새로 만든 `/member/updateInfo`만 빠져서, 비로그인 상태로 `MemberController.updateInfoForm()`이 그대로 호출되고 `member.getRole()`에서 NPE → 500 스택트레이스 노출. 같은 패턴이 `updateNickname`/`updatePhone`/`updateEmail`/`updateName`/`updateBirth`/`updateGender`/`updatePassword`(전부 세션 null 체크 없이 `member.getMemberId()` 호출) POST API에도 있음. **이번 세션 범위 밖(KGH 담당)이라 코드 수정은 안 함, PROJECT_AUDIT.md 버그#18로 신규 기록만.**

### (참고) 병합 검토 중 겪은 삽질: 빌드 캐시로 인한 가짜 장애
병합 드라이런을 여러 번 반복하는 과정에서 `target/classes`에 `mappers/MemberMapper.xml`(기존)과 `mappers/member/MemberMapper.xml`(드라이런 중 KGH 버전이 컴파일되며 생긴 잔재)이 동시에 남아, MyBatis가 같은 namespace의 `<sql id="deliveryStatusFilter">`를 중복으로 읽어 `IllegalArgumentException`으로 서버가 죽는 현상이 발생함. **소스 코드/브랜치 자체의 버그가 아니라 순수 빌드 산출물(target) 문제** — `target` 폴더 삭제(또는 STS의 Maven Update)로 해결됨. 이후 `BJY_works` 소스 자체는 애초에 `MemberMapper.xml`이 1개뿐이었던 것도 재확인함. `target` 삭제 직후 STS에서 즉시 재기동하면 `ClassNotFoundException: MdsApplication`이 나는데, 이건 컴파일이 아직 안 된 것뿐이라 STS에서 **Maven Update(Alt+F5)**로 재빌드하면 해결됨 — 다음에 비슷한 상황(다른 브랜치 병합 드라이런 후) 겪으면 먼저 `target` 삭제 + Maven Update부터 시도할 것.

### 신규/수정 파일
```
없음 (코드 변경 0건 — 병합은 사용자님이 직접 수행, 문서만 갱신)
```

---

## 3-33. 2026-08-31: `JWC_works` → `front_for_merge` 병합 검토 + 실제 병합 + 병합 결과물 검증

`server_for_merge`(=3-32까지 반영된 `KGH_works` 병합 결과) 기준으로 `front_for_merge` 브랜치를 새로 파서, 프론트 담당 팀원 브랜치 `JWC_works`를 병합. 이번 세션도 3-32와 동일하게 **병합 전/후 코드 리뷰 + 실제 빌드/기동/스모크테스트 위주 — 직접 작성한 신규 코드 없음(문서 정리 제외)**.

### 범위 확인: 스타일가이드 PDF가 설명하는 범위와 실제 브랜치 상태가 다름
프론트 작업자가 사용자님께 전달한 `메종드사조_스타일가이드.pdf`(레포 루트, git 추적 대상 아님 — MS Edge에서 열어야 한글이 안 깨짐)는 `JWC_works` 커밋 `6e8b236`, `7b885e4` 기준으로 홈/로그인/회원가입/주문·결제/주문완료/상품상세/리뷰작성/쿠폰/배송지 추가 **9개 페이지**, CSS 13개 파일을 `style.css` 하나로 통합(기존 파일 삭제)하는 대규모 작업을 설명하고 있었음.

- `git fetch --all` 후 확인한 결과 로컬/원격 `JWC_works` HEAD는 **`6e8b236`(홈페이지 재작업) 하나뿐**이고, `7b885e4`는 저장소 어디에도 없는 오브젝트였음(`git cat-file -t` 실패).
- 커밋 메시지만 보고 판단한 게 아니라, 스타일가이드가 언급한 시그니처 클래스명(`.auth-shell`,`.auth-visual`,`.login-card`,`.signup-card`,`.order-card`,`.gender-pill` 등)과 "삭제됐다"는 CSS 파일 9개(`style_login.css`,`style_signUp.css`,`style_order.css`,`style_orderComplete.css`,`style_payment.css`,`style_addreview.css`,`style_usercouponView.css`,`style_deliveryAddress.css`,`style_util_da.css`)를 `JWC_works` 트리 전체에서 직접 grep/byte-diff로 재검증 — 전부 홈페이지 외엔 흔적 0건, CSS 파일들도 전혀 삭제되지 않고 그대로 남아있었음.
- 사용자님 확인: `7b885e4`는 작업 중 컴파일 오류/파일 손상이 생겨서 커밋했다가 **일부러 revert한 버전** — 절대 가져오면 안 됨. 프론트 작업자는 이후 `hero-bg.jpg`와 전달받은 스타일가이드 PDF를 참고해서 나머지 8개 페이지 작업을 다시 할 예정. **즉 이번 병합의 실제 범위는 처음부터 끝까지 "홈페이지 + header.jsp/footer.jsp 리디자인" 하나뿐이었고, 이건 의도된 정상 상태.**

### 병합 전 검토 (`git merge --no-commit --no-ff` 드라이런, merge-base `98107ef`)
- KGH_works 때와 달리 **조용한 파일 삭제 없음**(diff 전부 M/A, D 없음). 변경 파일: `header.jsp`,`footer.jsp`,`home.jsp`,`style.css`,`style_home.css` 수정 + `home.js`,`img/home/hero-bg.jpg` 신규 + `MyPageCouponDTO.java`(`@Alias` 추가, 무해) + `.vscode/settings.json`(개인 에디터 설정, 이후 JWC가 자체적으로 삭제 커밋 `f9980ab`를 추가로 푸시해서 병합 시점엔 이미 정리됨).
- `header.jsp`/`footer.jsp`는 충돌 없이 자동 병합됨 — `front_for_merge`(백엔드 트랙, 커밋 `987574d`/`ddaee8b`/`96e4ee9`) 쪽은 이 파일들에 `<link>` 태그 추가(`style_myReviews.css`,`style_coupon.css`,`style_adminMaintenance.css`)만 했을 뿐 마크업 자체는 안 건드려서, JWC의 새 마크업(flex 헤더, `.header-actions` 래퍼, `.search-submit` 버튼, `.footer-contact`/`.footer-social`)이 그대로 살아남음.
- **`style.css`에서 텍스트 충돌 9곳 발생.** 원인: `front_for_merge` 쪽도 독립적으로 같은 헤더/푸터 CSS 섹션을 손대고 있었는데, 두 브랜치 다 같은 스타일가이드 팔레트(`--gsf-sage`,`--gsf-caramel`,`--gsf-ink` 등, 값까지 거의 동일)를 참고한 것으로 보임 — 다만 `front_for_merge` 쪽은 **옛 헤더 DOM 구조**(CSS Grid, `.icon`/`.sign`이 `header` 바로 아래)를 겨냥한 CSS였고 JWC 쪽은 **새 flex 구조**를 겨냥한 CSS였음. header.jsp가 이미 JWC 버전으로 자동 병합됐으므로, **9곳 전부 JWC_works 쪽을 채택하는 게 정답**이라고 판단(옛 CSS를 쓰면 새 마크업의 `.search-submit`/`.footer-contact` 등에 대응하는 스타일이 없어 깨짐). `--gsf-cream` 변수는 양쪽 다 이미 제거했고 다른 곳 참조도 없어 안전.
- JS 영향 재검토(사용자님 요청): `header.js`가 실제로 참조하는 건 `getElementById('cartBadge'/'wishBadge')`와 `document.body.dataset.loggedIn/homeUrl` 뿐 — 둘 다 JWC 새 마크업에서도 id/data-속성이 그대로 유지됨. `cartWishService.js`는 DOM 의존 없이 `localStorage`+전역함수(`window.addToCart` 등)로만 다른 페이지와 연결돼 있어 마크업 변경의 영향을 안 받음. `#search_input`→`#headerSearchInput` id 변경, `.home-page` 래퍼 삭제 둘 다 이걸 참조하는 다른 JS/CSS가 전체 코드베이스에 원래 없었던 것도 grep으로 확인. `home.js`(신규)는 완전히 독립적인 IIFE라 로드 순서 문제도 없음. → **결론: 충돌 9곳을 JWC 쪽으로 채택해도 인터랙션/비즈니스 로직 JS가 깨질 지점 없음.**

### 실제 병합 + 결과물 검증
사용자님이 `git merge JWC_works`를 `front_for_merge`에 실행, 충돌 9곳을 JWC_works 쪽으로 해결(+ 프론트 작업자가 이어서 작업하기 편하도록 `style.css`를 JWC_works와 완전히 동일한 내용으로 맞춤). 커밋 후 재검증:
- 충돌 마커 잔존 0건(다른 CSS 파일의 `================================` 장식 구분선은 기존부터 있던 false positive, 실제 마커 아님).
- `style.css`가 CRLF 줄바꿈 차이 제외하고 JWC_works와 byte-identical한 것 확인. `header.jsp`도 JWC_works 대비 다른 팀원이 추가한 `<link>` 3줄만 더 있는 것 외엔 동일, `footer.jsp`/`home.jsp`/`style_home.css`/`home.js`/`MyPageCouponDTO.java`는 완전히 동일.
- `mvnw clean compile` BUILD SUCCESS(80개 소스파일).
- 실제 서버 기동(포트 8797) + `curl` 스모크테스트: `/`,`/member/login` 200, `/member/cart`(비로그인) 302, `/css/style.css`,`/css/style_home.css`,`/js/views/home.js`,`/img/home/hero-bg.jpg` 전부 200. `/` 응답 HTML에 `id="bannerSlider"`,`class="home-hero"`,`class="header-actions"`가 실제로 렌더링되는 것(=header.jsp의 EL 기반 body 클래스 트릭이 실제 요청에서도 정상 동작)과 `id="wishBadge"`/`id="cartBadge"`가 그대로 살아있는 것(회귀 없음)까지 확인.
- 병합 커밋: `b6551d9`(부모: `f81b21c` + `f9980ab`).

### 신규/수정 파일
```
없음 (코드 변경 0건 — 병합은 사용자님이 직접 수행, 문서만 갱신)
```

---

## 3-34. 2026-08-31: DTO 통합 후속 - 재발한 쿠폰 DTO 중복 삭제 + wish/cart 패키지 이원화 정리

3-28(admin DTO 통합) 이후 병합된 다른 팀원 브랜치들이 가져온 DTO 중복을 재검증해달라는 사용자님 요청 → PROJECT_AUDIT.md에 없던 새 발견 2건을 찾아 사용자님 확인 후 정리.

### 조사 결과
1. **`coupon.model.dto.MyPageCouponDTO` 재발** — 3-28에서 정확히 같은 패턴(구 `coupon.model.dto.MypageCouponDTO`, COUPON 테이블을 product 패키지의 통합 `CouponDTO`와 중복 매핑)을 찾아 삭제했었는데, `#BE005_260826 주문 결제 기능 추가` 커밋(`fa37b9b`)이 대소문자만 바꾼 동명 클래스를 다시 들여옴. `coupon.mapper.CouponMapper`(빈 인터페이스)/`coupon.service.CouponServiceImpl`(빈 클래스)/`CouponServiece`(빈 인터페이스, 오타)/`CouponController`(엔드포인트 1개, DTO 미참조) 전부 껍데기라 실사용 0건 확인.
2. **`wish`/`cart` 전용 패키지와 `member` 패키지가 같은 기능을 이원 구현** — `#BE008_260828 찜 기능 추가`(`d73f507`)가 `WishController`/`CartController`+`WishMapper`/`CartMapper`(각각 `wish.xml`/`cart.xml`)로 찜/장바구니 CRUD를 새로 만들었는데, 기존 `MemberController.wishlistForm()`/`cartForm()` + `MemberMapper.selectWishesByMemberId()`/`selectCartsByMemberId()`(`MyPageWishDTO`/`MyPageCartDTO`)가 이미 같은 WISH/CART 테이블 조회를 하고 있었음. `product/wish.jsp`/`product/cart.jsp`를 직접 확인해보니 두 백엔드 중 어느 쪽 모델 데이터도 안 쓰고 `header.jsp`의 localStorage(`wishItems`/`cartItems`)로만 렌더링되고 있어서(기존 TODO 주석에 명시), 어느 쪽을 지워도 화면엔 영향 없는 것도 확인. `myPage.jsp`/`header.jsp` 등 어디에도 `/member/wish`,`/member/cart` 링크가 없는 것도 재확인(3-30 마이페이지 개편 때 이미 빠짐).

### 사용자님 결정 + 적용
1. **`MyPageCouponDTO.java` 삭제**(참조 0건). `coupon.*` 패키지 구조 자체(현재 살아있는 `product.model.dto.coupon.CouponDTO` 등을 `coupon.*`로 옮기는 리팩토링 포함)는 사용자님이 별도로 직접 진행하기로 해서 이번 작업 범위에선 손대지 않음.
2. **wish/cart는 전용 패키지(`wish.*`/`cart.*`) 유지, `member` 패키지 쪽 중복 기능 제거** — `MemberController`의 `wishlistForm`/`cartForm`(`/member/wish`,`/member/cart`), `MemberService`/`MemberServiceImpl`의 `listWish`/`listCart`, `MemberMapper`(+xml)의 `selectWishesByMemberId`/`selectCartsByMemberId` 전부 삭제. `MyPageWishDTO.java`/`MyPageCartDTO.java` 삭제. `WebConfig`의 `LoginInterceptor` 보호 경로 목록에서도 더 이상 존재하지 않는 `/member/wish`,`/member/cart` 제거.
   - **참고: `wish.WishController.myWish()`/`cart.CartController.getCartList()`는 지금도 `redirect:home/home`으로 끝나서 조회 결과를 실제 화면에 렌더링하지 않는 상태 — 사용자님 확인: 프론트 연결 작업이 아직 진행 중이라 의도적으로 비워둔 것, 이번 정리 범위 밖.**

### 검증
`mvnw compile` BUILD SUCCESS. 삭제한 3개 DTO(`MyPageCouponDTO`/`MyPageWishDTO`/`MyPageCartDTO`)와 그 매퍼 메서드 참조가 프로젝트 전체에 0건인 것 grep으로 재확인.

### 신규/수정/삭제 파일
```
삭제:
  src/main/java/com/kh/sajotuna/mds/coupon/model/dto/MyPageCouponDTO.java
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MyPageWishDTO.java
  src/main/java/com/kh/sajotuna/mds/member/model/dto/MyPageCartDTO.java

수정:
  src/main/java/com/kh/sajotuna/mds/member/controller/MemberController.java     (wishlistForm/cartForm 제거)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberService.java          (listWish/listCart 제거)
  src/main/java/com/kh/sajotuna/mds/member/service/MemberServiceImpl.java      (〃)
  src/main/java/com/kh/sajotuna/mds/member/model/mapper/MemberMapper.java      (selectWishesByMemberId/selectCartsByMemberId 제거)
  src/main/resources/mappers/member/MemberMapper.xml                          (〃)
  src/main/java/com/kh/sajotuna/mds/util/config/WebConfig.java                (인터셉터 경로에서 /member/wish,/member/cart 제거)
```

---

## 3-35. 2026-08-31: 쿠폰 패키지 재구성(`coupon.model`로 이동) 검증

3-34 직후 사용자님이 직접 진행한 `coupon.*` 패키지 재구성 결과를 Claude Code가 검증. 코드 변경은 전부 사용자님이 직접 수행, 이번엔 리뷰/검증 + 문서화만 담당.

### 변경 내용 (사용자님 작업)
`product.model.dto.coupon.CouponDTO`/`CouponHistoryDTO`/`getCouponDTO` 3개를 `coupon.model` 패키지로 이동(`product.model.dto.coupon` 하위 → `coupon.model`, `dto` 세그먼트도 제거). 이 3개를 참조하던 12개 파일(`AdminCouponController`/`AdminCouponMapper`/`AdminCouponService`/`AdminCouponServiceImpl`, `MemberController`/`MemberService`/`MemberServiceImpl`/`MemberMapper`, `OrderServiceImpl`, `PaymentViewDTO`, `DetailPageDTO`, `ProductMapper`, `ProductServiceImpl`)의 import 경로를 전부 새 패키지로 갱신.

### 검증 결과 — 문제 없음
- `grep -r "product.model.dto.coupon"` 전체 프로젝트 0건 — 옛 경로를 참조하는 곳이 코드에는 하나도 안 남음(주석 1곳 제외, 아래 참고).
- `import com.kh.sajotuna.mds.coupon.model.CouponDTO` 등 새 경로 import 12개 파일 전부 정상 확인, 누락/오타 없음.
- `@Alias("CouponDTO")`/`@Alias("CouponHistoryDTO")`/`@Alias("getCouponDTO")` 각각 프로젝트 전체에 1건씩만 존재 — 패키지 이동으로 별칭 충돌이나 MyBatis `resultType`/`parameterType`(문자열 참조) 깨짐 없음.
- `mvnw compile` BUILD SUCCESS.
- **낡은 주석 1곳 발견 + 수정**: `AdminCouponMapper.xml`의 주석이 여전히 "`CouponDTO(product.model.dto.coupon)`"라는 옛 경로를 가리키고 있어서 `coupon.model`로 고침(동작에는 영향 없는 문서 코멘트).
- **참고로 남겨둠, 이번엔 손 안 댐**: `coupon.controller.CouponController`(엔드포인트 1개, `/coupon/couponview`)/`coupon.mapper.CouponMapper`(빈 인터페이스, `@Mapper` 없음)/`coupon.service.CouponServiceImpl`(빈 클래스, `@Service` 없음)/`CouponServiece`(빈 인터페이스, 오타)는 이번 이동에 포함 안 돼서 여전히 빈 껍데기 상태 — DTO만 먼저 옮긴 것으로 보이며, 나머지 스캐폴딩 정리는 이어서 진행하실 계획이면 그때 확인.

### 신규/수정/삭제 파일
```
사용자님 작업(이동/수정):
  src/main/java/com/kh/sajotuna/mds/product/model/dto/coupon/CouponDTO.java        -> coupon/model/CouponDTO.java
  src/main/java/com/kh/sajotuna/mds/product/model/dto/coupon/CouponHistoryDTO.java -> coupon/model/CouponHistoryDTO.java
  src/main/java/com/kh/sajotuna/mds/product/model/dto/coupon/getCouponDTO.java     -> coupon/model/getCouponDTO.java
  (+ 위 3개를 참조하던 12개 파일의 import 경로 갱신)

Claude Code 수정:
  src/main/resources/mappers/admin/AdminCouponMapper.xml   (낡은 주석의 옛 패키지 경로만 수정)
```

---

## 3-36. 2026-08-31: 죽은 `coupon.*` 스캐폴딩 삭제 + `productDetailPreview.jsp` 제거

3-35에서 "참고로 남겨둠, 손 안 댐"으로 적어뒀던 `coupon.controller.CouponController`/`coupon.mapper.CouponMapper`/`coupon.service.CouponServiceImpl`/`CouponServiece`에 대해, 사용자님이 "유저 쪽에서 쿠폰 기능을 따로 안 쓰고 admin이 전담 관리하는 게 맞다고 보는데 어떻게 생각하냐" 질문 → Claude Code가 사실관계 재확인 후 동의 의견 제시, 승인받아 삭제.

### 삭제 전 재확인한 사실
- `CouponController`의 유일한 엔드포인트(`GET /coupon/couponview`)가 리턴하는 뷰 `coupon/couponview`가 `WEB-INF/views/coupon/` 밑에 파일로 아예 존재하지 않음 — 접속 시 뷰 리졸브 실패(404)만 남는 상태였음.
- `/coupon/couponview`를 링크하는 곳 프로젝트 전체 0건.
- `CouponMapper`는 `@Mapper` 없음, `CouponServiceImpl`은 `@Service` 없음 — 애초에 Spring/MyBatis 빈으로 등록된 적 없음, 대응 매퍼 XML도 없음.
- 실제로 동작하는 유저용 쿠폰 조회(`MemberController.userCouponViewForm()` → `/member/couponView`)와 관리자 쿠폰 관리(`AdminCouponController`)가 이미 이 역할을 전부 커버하고 있어서, 이 4개가 담당할 몫 자체가 없음.

### 적용
- `coupon.controller.CouponController.java`, `coupon.mapper.CouponMapper.java`, `coupon.service.CouponServiceImpl.java`, `coupon.service.CouponServiece.java` 삭제(빈 디렉터리 `controller`/`mapper`/`service`도 정리). `coupon.model`(`CouponDTO`/`CouponHistoryDTO`/`getCouponDTO`, 3-35에서 이동한 것)은 그대로 유지.
- `mvnw compile` BUILD SUCCESS로 재검증.
- **사용자님이 별도로 `productDetailPreview.jsp`(`src/main/webapp/productDetailPreview.jsp`, `WEB-INF/views` 밖의 독립 파일)를 직접 삭제** — 더 이상 필요 없는 파일이라 정리. Claude Code가 grep으로 프로젝트 전체(Java/JSP/JS)에 이 파일을 참조하는 곳이 없는 것을 확인, 문제 없음.

### 참고: 8번 버그(찜/장바구니 대표이미지 INNER JOIN) 진행 상황
사용자님이 담당 팀원에게 직접 전달 완료 — 다음 브랜치 병합 때 반영될 예정. PROJECT_AUDIT.md에도 상태 갱신해둠.

### 신규/수정/삭제 파일
```
삭제:
  src/main/java/com/kh/sajotuna/mds/coupon/controller/CouponController.java
  src/main/java/com/kh/sajotuna/mds/coupon/mapper/CouponMapper.java
  src/main/java/com/kh/sajotuna/mds/coupon/service/CouponServiceImpl.java
  src/main/java/com/kh/sajotuna/mds/coupon/service/CouponServiece.java
  src/main/webapp/productDetailPreview.jsp   (사용자님 직접 삭제)
```

---

## 3-37. 2026-08-31 저녁: 새 환경에서 `frontfix` 브랜치 인수 — 프론트 CSS/JS 규격화 작업 검토/검증

새 작업환경에서 `frontfix` 브랜치(현재 HEAD `e30a369`, `JWC_works`에 `Util_branch` 등을 병합해온 상태)를 인수받아, 팀원(프론트 담당 JWC1226)이 진행 중인 "CSS/JS 규격화" 작업을 검토/검증. **이번 세션은 검증이 주 목적이었으나, 검증 도중 실제 서버 500 에러와 HANDOFF 3-5/3-6과 동일한 클래스의 CSS 회귀가 발견되어 최소 범위로 직접 수정함.**

### 배경 확인: 이 브랜치의 CSS 규격화는 스타일가이드 PDF가 설명하는 범위보다 훨씬 넓음
레포 루트의 `메종드사조_스타일가이드.pdf`(git 비추적)는 `JWC_works` 커밋 `6e8b236`(홈페이지 재작업, HANDOFF 3-33에서 이미 검증/병합됨) 기준으로 **9개 페이지, CSS 13개 파일을 `style.css` 하나로 통합**하는 작업만 설명하고 있음(`admin` 전용 CSS와 `default.css`는 손대지 않았다고 문서에 명시).

그런데 실제 이 브랜치의 CSS 디렉터리는 `default.css`/`style.css`/`style_user.css`/`style_admin.css` **4개**뿐이고, `git log`로 추적한 결과 이후 커밋 `cb082dd`(`#FE017、#FE018、#TB004`, 같은 작성자 JWC1226)가 **21개 페이지별 CSS 파일 전체**(admin 6개 + user 13개, 스타일가이드가 "안 건드렸다"고 명시한 admin 포함)를 `style_user.css`(4727줄)/`style_admin.css`(2142줄) 2개로 통합한 것으로 확인됨. 즉 **스타일가이드 PDF는 이 브랜치의 현재 상태를 설명하는 문서가 아니라, 그 전 단계(홈페이지만) 스냅샷** — 디자인 토큰(`--gsf-*`)·hero 배경 패턴·페이지+카드 2중 래퍼 같은 원칙 자체는 여전히 유효하지만, "CSS 13개 → style.css 1개"라는 파일 구성 설명은 더 이상 실제와 안 맞음. 사용자님께 참고로 전달.

### 회귀 확인 결과: 5개 화면 중 1개가 실제로 500 에러

로그인 필요한 4개 화면(`myPage`/`orderDelivery`/`myReviews`/`couponView`) 검증을 위해 테스트 계정(`cssqa01`)을 회원가입 API로 직접 생성(폼이 아니라 API 직접 호출 — PROJECT_AUDIT.md 버그 5번대로 회원가입 폼 자체가 깨져있어서, `role=USER`도 명시해서 버그 6번도 우회) 후 로그인해서 5개 화면 + admin 마이페이지(admin/1234) 전부 실제 요청:

| 화면 | 결과 |
|---|---|
| `/` (home) | 200, `home-hero` 정상 |
| `/member/myPage` | 200, `member-mypage-page` 정상 |
| `/member/orderDelivery` | 200, `order-delivery-page` 정상 |
| `/review/myReviews` | 200, `my-reviews-page` 정상 |
| `/member/couponView` | **500** (아래 참고) |
| `/member/myPage` (admin 계정) | 200, `admin-mypage-page` 정상 |

**`/member/couponView` 500 원인**: `MyBatis BindingException: Invalid bound statement (not found): MemberMapper.selectCouponsByMemberId`. `MemberServiceImpl.listCoupon()`이 호출하는 페이징 버전 매퍼 메서드(`selectCouponsByMemberId(memberId, offset, pageSize)`)에 대응하는 XML `<select>` 문이 없고, 비페이징 버전(`selectAllCouponsByMemberId`, `order` 패키지의 결제 화면 쿠폰 드롭다운이 별도로 씀)만 남아있었음. **이건 CSS 작업과는 무관한 Java/매퍼 버그** — 조사해보니 이 브랜치가 `BJY_works`에서 이미 정리됐던 3-34/3-35/3-36(쿠폰 도메인 통합, `coupon.*` 죽은 스캐폴딩 삭제, wish/cart 중복 제거)을 아직 못 받은, 더 오래된 상태에서 갈라져 나온 것으로 보임(아래 "범위 밖 발견" 참고). 원래 상태로 봤을 때 이 XML 문이 통째로 빠진 것으로 판단, **`mappers/member/MemberMapper.xml`에 페이징 버전 `<select id="selectCouponsByMemberId">`를 새로 추가**해서 해결(기존 비페이징 쿼리와 동일 조건 + `selectDeliveriesByMemberId`와 같은 `OFFSET/FETCH` 패턴). 라이브 재검증: 200 확인.

### CSS 회귀 확인: HANDOFF 3-5/3-6과 동일한 "스코프 없는 body{} 전역 leak" 재발

`header.jsp`가 4개 CSS를 전 페이지에 무조건 로드하는 구조는 그대로인데, `style_user.css`(21개 병합 대상 중 13개)가 옛 페이지별 CSS를 "원본 내용" 주석 구간으로 그대로 이어붙이면서, 그 안에 있던 **스코프 없는 `body{}`/`:root{}` 규칙 3곳**이 그대로 살아남아 사이트 전역에 leak되고 있었음:

1. **옛 `style_member.css`** (로그인/회원가입): `body { margin:0; background-color:#f8f6f2; }` — 스코프 없음.
2. **옛 `style_payment.css`** (결제): `body { margin:0; font-family:Arial, sans-serif; color:#333; }` — 스코프 없음, `default.css`의 기본 글꼴(맑은 고딕 계열)을 사이트 전역에서 Arial로 덮어씀.
3. **옛 `style_addreview.css`** (리뷰 작성): 이 페이지 전용 `:root{ --ink; --bg-page:transparent; --font-base:'Pretendard'... }` + `body{ background:var(--bg-page); color:var(--ink); font-family:var(--font-base); font-size:16px; line-height:1.6; }` — 둘 다 스코프 없음.

**영향**: 확인해보니 이번에 검증한 5개 화면은 전부 자기 wrapper div(`.member-mypage-page`/`.order-delivery-page`/`.my-reviews-page`/`.coupon-view-page`, admin도 동일 패턴)가 `min-height:100vh` + 명시적 배경을 이미 갖고 있어서 화면 자체가 깨지진 않음(구조 검증 통과, 위 표 참고) — 다만 `<header>`/`<footer>`처럼 이 wrapper 바깥에 있는 요소는 `body`의 `color`/`font-family`를 상속받으므로, 페이지 로드 순서(`style.css` → `style_user.css` → `style_admin.css`)상 **가장 나중에 정의된 `body{}` 규칙(3번, 리뷰작성 전용 톤)이 사실상 사이트 전체의 기본 글꼴/글자색을 정하고 있었음** — 새 페이지를 만들 때 wrapper가 100vh를 안 채우거나(짧은 콘텐츠 등) 명시적 배경을 깜빡하면 바로 겉으로 드러날 수 있는 잠재 버그. `style_admin.css`는 같은 방식(6개 파일 병합)인데도 이 문제가 없음(전부 `.admin-xxx-page` 등으로 스코프됨, `--admin-*` 접두사로 별도 네임스페이스) — **대조적으로 잘 처리된 참고 사례**.

**수정**: `style_user.css`에서 1번/2번은 이미 `style.css`의 hero 배경 시스템(`body.login-hero`/`body.signup-hero`/`body.order-hero`)과 각 페이지 wrapper의 자체 배경으로 완전히 대체돼 불필요해진 규칙이라 삭제. 3번은 `body.review-write-hero`로 스코프(header.jsp가 이미 이 hero 클래스를 붙여주고 있어 새 마크업 변경 없이 바로 적용됨) — 리뷰 작성 페이지 자체의 디자인(투명 배경으로 hero가 비쳐 보이게, Pretendard 톤 등)은 그대로 유지하면서 다른 페이지로의 leak만 차단.

### 패턴 자체에 대한 피드백 (요청하신 3번 항목)

1. **`header.jsp`의 전역 CSS 로드 구조 자체(모든 페이지가 default/style/style_user/style_admin 4개를 전부 로드)는 그대로 유지되고 있고, 이게 근본 위험 요인이라는 점도 그대로임.** 스타일가이드 PDF의 "07 다른 CSS와의 충돌 방어" 원칙(스코프 우선순위로 방어, 다른 파일 안 건드림)은 신규로 작성하는 CSS엔 잘 지켜지고 있지만(`style_admin.css`, `style_user.css`의 `body:has(.update-page)` 같은 방어 패턴 참고), **옛 파일을 "원본 내용 그대로" 병합해 넣는 방식은 이 원칙을 자동으로 어기게 만든다** — 옛 파일 작성 당시엔 "내 페이지만 로드된다"고 가정했던 스코프 없는 선택자가 그대로 살아나기 때문. 이번엔 3곳만 재발했지만, **앞으로 나머지 8개 페이지(주문/결제/주문완료 등, 스타일가이드 08 체크리스트가 이미 `style.css`로 옮겼다고 표시한 페이지들 포함)에 같은 "원본 내용 그대로 붙여넣기" 방식을 반복하면 같은 클래스의 버그가 계속 재발할 가능성이 높음.**
2. **권장**: 페이지별 CSS를 큰 파일로 병합할 때, 병합 전에 반드시 `body`/`main`/`#title`처럼 스코프 없는 태그·ID 선택자가 있는지 먼저 훑고, 있으면 그 페이지의 wrapper 클래스(`.xxx-page`)나 `body.xxx-hero`로 감싼 뒤 병합하는 걸 체크리스트 항목으로 명시하는 게 좋아 보임 — `style_admin.css`가 이미 이렇게 하고 있어서 그대로 참고하면 됨. `grep -n "^body\s*{\|^main\s*{\|^#"` 한 줄이면 병합 직후 바로 확인 가능.
3. **JS 쪽은 별문제 없음.** `home.jsp`는 아직 정적 목업이라(사용자님이 이미 인지하신 대로 "메인페이지 작업 자체도 미완") 실질적인 인터랙션 JS가 배너 슬라이더(`common/bannerSlider.js`, 여러 페이지가 재사용하는 순수 인터랙션이라 `common/`에 두는 것도 합리적) 하나뿐이고, `views/<page>.js`+`<도메인>/<기능>Service.js` 분리 패턴은 그 외 이미 존재하는 페이지들(admin 3종, `signUp.js`+`memberService.js`, `usercouponView.js` 등)에서 일관되게 잘 지켜지고 있음. 옛 `views/home.js`(배너 로직 포함)는 `common/bannerSlider.js`로 대체되며 정상 삭제됨(고아 파일 없음 확인).

### 범위 밖 발견 (수정 안 함, PROJECT_AUDIT.md에만 기록)

이 브랜치(`frontfix`)가 `BJY_works`에서 이미 진행됐던 3-34/3-35/3-36 정리(죽은 `coupon.*` 스캐폴딩 삭제, `coupon.model.dto.MyPageCouponDTO` 삭제, `CouponDTO`의 `coupon.model` 패키지 이동, `member` 패키지의 wish/cart 중복 제거)를 아직 못 받은, 더 오래된 지점에서 갈라져 나온 상태인 것을 확인함 — 실제 소스에 `coupon.controller.CouponController` 등 4개 죽은 클래스, `MyPageCouponDTO`, 옛 `product.model.dto.coupon.CouponDTO` 경로, `member` 패키지의 `wishlistForm`/`cartForm` 중복이 전부 그대로 남아있음. 기능이 깨진 상태는 아니라 코드는 안 건드렸고, PROJECT_AUDIT.md 정책 항목 2번에 기록만 해둠 — 나중에 이 브랜치가 `BJY_works` 계열과 다시 합쳐질 때 참고할 것.

### 건드리지 않은 것 (사용자님 지시대로)
- "내가 쓴 리뷰" 삭제/재작성 정책(스키마 변경 보류) — 코드/스키마 둘 다 안 건드림.
- `wish`/`cart` 프론트 연결(`WishController`/`CartController`의 `redirect:home/home`) — 별도 진행 중인 작업이라 범위 밖으로 두고 손대지 않음.

### 테스트 데이터 정리
회원가입 API로 만든 테스트 계정 `cssqa01`(주문/리뷰/쿠폰/찜/장바구니 등 하위 데이터는 생성하지 않음, 읽기 전용 검증만 수행) — jshell + ojdbc11로 `MEMBER_ID` 기준 직접 삭제, 관련 테이블(PRODUCTORDER/REVIEW/COUPONHISTORY/WISH/CART) 전부 0건인 것 확인 후 MEMBER 1건 삭제, 최종 `LOGIN_ID='cssqa01'` 잔존 0건 확인. 업로드 파일 생성 없음(uploads/ 변경 없음 확인).

### 신규/수정 파일
```
수정:
  src/main/resources/mappers/member/MemberMapper.xml   (selectCouponsByMemberId 페이징 버전 추가)
  src/main/resources/static/css/style_user.css         (스코프 없는 body{}/:root{} 3곳 삭제/스코프)
  PROJECT_AUDIT.md                                       (조치 완료 2건 + 브랜치 다이버전스 신규 발견 기록)
```

---

## 3-38. 2026-08-31 저녁: 홈페이지 마무리 - 검색창 색상 + 상품 카드 퀵액션 재구성

사용자님이 스크린샷 3장(빨간 펜 주석)으로 직접 지적한 3가지를 반영. 카드 레이아웃 변경 전 애매한 부분(가격줄의 기존 장바구니 버튼 처리 방향, 실동작 연결 여부)은 AskUserQuestion으로 먼저 확인 후 진행.

### 반영 내용
1. **헤더 검색창 배경색**: `#site-header .search-input`의 `background-color`를 `#faf9f6` → `#FDFBF9`로 변경(`style.css`).
2. **상품 카드 오른쪽 위 퀵버튼: 찜(하트) → 장바구니로 교체** — 클래스명 `.product-like`/`.product-like-svg` → `.product-cart-quick`/`.product-cart-quick-svg`로 변경(위치/크기/색상은 옛 찜버튼 값 그대로 재사용: 흰색 85% 원형, `--gsf-text` 아이콘색, hover 시 `--gsf-caramel`), 아이콘만 하트 path에서 기존 `.product-cart-svg`가 쓰던 장바구니 bag path로 교체.
3. **가격 줄의 기존 장바구니 버튼(`.product-cart`, 베이지색 원) 삭제** — 사용자님 확인(질문 응답): 카드에 장바구니 액션이 위(퀵버튼)/아래(가격줄) 두 곳에 중복되지 않도록 정리. `.product-price-row`도 `justify-content: space-between` 등 버튼과 짝지어져 있던 규칙 정리.
4. **별점+찜 영역(`.product-meta`) 확장 + 찜 표시를 찜 버튼으로 전환** — `<span class="product-wish-count">`를 `<button class="product-wish-toggle">`로 교체(찜 개수 텍스트는 그대로, 버튼 패딩/pill 배경/hover 강조색 추가로 탭 가능한 영역처럼 보이게 함), `.product-meta`에 `padding`/`gap` 추가로 터치 영역 확장.
5. **실동작(JS) 연결은 이번엔 보류** — 사용자님 확인(질문 응답): 홈페이지 상품 카드가 아직 완전 정적 목업(실데이터 미연동)이라, 지금 이 두 버튼만 `window.addToCart`/`window.toggleWish`에 연결하면 오히려 다른 정적 요소들과 비일관 상태가 됨 → 이번엔 시각적 변경만 적용, 실제 데이터/기능 연동은 홈페이지 데이터 바인딩 작업 때 같이 진행하는 걸로.

### 검증
`mvnw compile` 통과. 실행 중인 서버(8797)에 홈(`/`) 재요청 — 200, `product-cart-quick`/`product-wish-toggle` 클래스가 카드 4개(8회/4회, svg 클래스 포함) 정상 렌더링, 옛 `product-like`/`product-cart`(가격줄 버전) 잔존 0건, `style.css`에 `#FDFBF9` 반영 확인. `.product-like`/`.product-cart`/`.product-wish-count`를 참조하는 다른 JSP/CSS가 있는지 전체 검색 — 홈페이지 전용이었고 다른 페이지(searchProduct.jsp 등)에서 재사용 중이 아니었음을 확인 후 안전하게 삭제.

### 3-38-1. 추가 수정: 배너 좌우 여백(body 배경) 색상 빠뜨림

사용자님이 재확인: 검색창은 바뀌었는데, 스크린샷의 빗금 표시(배너 좌우 바깥 여백 - `.home-container` 바깥, `body.home-hero` 배경이 비쳐 보이는 영역)는 안 바뀌었다고 지적 — 처음에 원 표시(검색창)만 반영하고 빗금 표시된 영역을 놓쳤던 실수. `body.home-hero`의 배경(원래 9개 hero 페이지 공용 `--gsf-cream`)에 홈페이지 전용 오버라이드를 추가해서 `#FDFBF9`로 변경(다른 8개 hero 페이지는 공용 토큰 그대로 유지 - 이번 요청이 홈페이지 마무리에 한정된 것이라 다른 페이지까지 건드리지 않도록 스코프함). `style.css`에 실제 반영 확인.

### 3-38-2. 추가 수정: 카드 확대 요청 → 되돌림 → 재조정 (열 개수는 4 유지, 찜 하트만 장바구니 아이콘 크기로)

사용자님이 "상품 카드를 전체적으로 키워달라(찜 버튼이 작아 보여서)"고 요청 → 처음엔 이걸 "카드+장바구니 퀵버튼을 다 같이 키워달라"로 이해해서 `#product-list`를 4열→3열로 바꾸고 내부 패딩/폰트를 크게 올렸는데, 사용자님이 바로 정정: (1) "장바구니 퀵 아이콘 정도의 크기가 되게" 요청은 카드가 아니라 **찜 하트 아이콘**을 그 정도 크기로 키워달라는 뜻이었음 (2) 카드 자체는 **1fr 4열 그리드는 유지**한 채, **수정 전(이번 세션 손대기 전) 비율을 기준으로** 최대한 키워달라는 뜻이었음.

- **열 개수**: `repeat(3,1fr)` → `repeat(4,1fr)`로 원복, gap도 24px로 원복.
- **카드 내부 요소**: 원래(이번 세션 손대기 전) 값 기준 약 1.25배로 통일감 있게 재조정 — `.product-info` padding 8px10px→10px13px, `.product-name` 16→20px, `.product-description` 13→16px, `.product-price` 17→21px, `.product-badge` 11→13px, `.product-meta` gap 8→10px.
- **찜 하트를 장바구니 퀵버튼 아이콘(20px)과 비슷한 크기로**: `.product-wish-toggle` 안의 "♡ 342" 텍스트를 `<span class="product-wish-icon">♡</span><span class="product-wish-count-num">342</span>`로 분리해서, 하트만 20px(장바구니 아이콘과 동일), 개수 숫자는 별점과 같은 15px로 따로 키움(하나의 폰트 크기로 묶여있으면 숫자까지 커져서 어색해지는 것 방지).

### 검증
`mvnw compile` 통과, 홈(`/`) 200 재확인, `grid-template-columns: repeat(4, 1fr)` 원복 확인, `product-wish-icon`/`product-wish-count-num` 카드 4개 전부 정상 렌더링 확인.

### 3-38-3. 추가 수정: 카드 간격 통일 + 별점/찜 아이콘·숫자 크기 짝맞춤

사용자님이 스크린샷(초록 화살표)으로 지적: (1) 카드 좌우 여백(40px)과 카드 사이 간격(24px)이 서로 달라 안 균일함 - 좁아져도 되니 통일하고 남는 폭은 카드로 (2) 글자 크기는 지금이 적당하니 더 안 키워도 됨, 다만 별점 텍스트가 커진 찜 하트(20px)에 비해 그대로라 어색함 - 크기 맞추고, 찜 줄의 아이콘/숫자 정렬도 다듬어달라.

- **간격 통일**: `#product .home-container`의 좌우 padding 40px → 20px, `#product-list`의 `gap` 24px → 20px로 맞춤(남는 폭은 `1fr` 그리드라 자동으로 카드 쪽에 더 배분됨).
- **별점도 찜처럼 아이콘/숫자 분리**: `<span class="product-rating">★ 4.9 (1,245)</span>` → `<span class="product-rating"><span class="product-rating-star">★</span><span class="product-rating-score">4.9 (1,245)</span></span>`. 별(`.product-rating-star`)은 찜 하트(`.product-wish-icon`)와 같은 20px, 점수 텍스트(`.product-rating-score`)는 찜 개수(`.product-wish-count-num`)와 같은 15px로 맞춰서 두 줄이 서로 짝이 맞게 함. **주의**: `.product-rating`은 `wish.jsp`(`.wishlist-container .product-rating`)도 같이 쓰는 공용 클래스라, 구조 변경은 `#product-list .product-rating`으로 스코프해서 홈페이지에만 적용 - 다른 페이지는 기존 방식(단순 텍스트) 그대로 안전하게 유지됨(확인함).
- **정렬**: 아이콘/숫자 각각에 `line-height: 1`을 줘서 글자 상자 높이 차이로 인한 미세한 세로 어긋남을 줄임(`.product-meta`/`.product-wish-toggle`/`.product-rating` 전부 `align-items: center` flex 유지).

### 검증
`mvnw compile` 통과, 홈(`/`) 200 재확인, `gap: 20px` 반영 확인, `product-rating-star`/`product-rating-score` 카드 4개 정상 렌더링 확인. `.wishlist-container .product-rating`을 쓰는 `wish.jsp`(현재도 `/wish` 자체는 라우팅 미완성으로 404 - 이번 세션과 무관한 기존 상태)의 CSS 선택자가 그대로 살아있어 영향 없음을 grep으로 확인.

### 3-38-4. 추가 수정: 별/하트 아이콘 세로 위치 보정

사용자님이 재확인: `align-items: center`로도 여전히 어긋나 보임 - 정확히는 "숫자는 정상이고 별/하트 아이콘이 아래로 처져 보인다"는 것까지 짚어주심(글리프 자체가 폰트 상자 안에서 실제 잉크가 아래쪽에 치우쳐 그려지는 문제로 추정). `align-items: baseline`으로 한 번 바꿔봤다가 다시 `center`로 되돌리고, 대신 `.product-rating-star`/`.product-wish-icon` 둘 다 `transform: translateY(-2px)`로 위로 살짝 보정. **브라우저 도구가 없어 픽셀 단위로 직접 확인은 못 했음 - 추정치이니 여전히 안 맞으면 몇 px 더/덜 필요한지 알려주시면 바로 조정 가능.**

### 3-38-5. 추가 수정: 별 아이콘 재보정 + 별점을 리뷰 링크로 전환

- 별 아이콘이 여전히 처져 보인다는 피드백 → `.product-rating-star`의 `translateY`를 `-2px` → `-4px`로 확대(하트는 그대로 유지, 지적 없었음).
- **별점(`.product-rating`)을 클릭 가능한 리뷰 링크로 전환** — `<span>` → `<a href="#" aria-label="리뷰 보기">`로 교체, `.product-wish-toggle`과 동일한 pill 버튼 스타일(패딩/모서리/hover 배경)을 적용해서 찜 버튼과 나란히 짝을 이루는 클릭 요소처럼 보이게 함. 실제 href는 아직 홈페이지가 정적 목업이라 상품 ID가 없어 `#`로 남겨두고, `<!-- TODO -->` 주석으로 실제 연동 시 `/mds/detail/{productId}#reviews` 형태로 바꿔야 함을 표시.
- **브라우저 도구가 없어 이번에도 픽셀 단위 확인은 못 함 — 추정치로 조정.**

### 3-38-6. 추가 수정: baseline 정렬로 복귀 + 링크의 hover 밑줄 제거

- 사용자님 피드백: `-2px`/`-3px`/`-4px` translateY로 미세조정하는 것보다 예전에 잠깐 시도했던 `align-items: baseline`이 제일 잘 맞았다 → `#product-list .product-rating`/`.product-wish-toggle` 둘 다 `baseline`으로 되돌리고, `.product-rating-star`/`.product-rating-score`/`.product-wish-icon`/`.product-wish-count-num`의 `line-height:1`+`transform:translateY(...)` 보정을 전부 제거(baseline 정렬 자체가 이 조합에 더 자연스러워서 수동 보정이 불필요해짐).
- 사용자님 지적: 별점 링크(`<a>`)에 마우스를 올리면 밑줄이 생겨서 찜 버튼(`<button>`, 밑줄 없음)과 다르게 보임 → 원인은 `default.css:21`의 전역 `a:hover, a:focus, a:active { text-decoration: underline; }` 규칙이 새로 만든 `<a class="product-rating">`에도 적용된 것(버튼은 이 규칙 대상이 아니라 원래 안 걸렸음). `#product-list .product-rating`/`:hover`/`:focus`/`:active`에 `text-decoration: none`을 명시적으로 다시 선언해서 찜 버튼과 동일하게 밑줄 없는 아이콘 버튼처럼 보이게 함.

### 3-38-7. 추가 수정: 아이콘 1px 축소 + 색상 확인

- 하트/별 아이콘 둘 다 20px → 19px로 미세 축소(사용자님: "글자 라인에 맞게, 그게 제일 예뻤던 듯").
- **별점 색상이 검게 보인다는 지적** — 코드 확인 결과 `.product-rating { color: var(--gsf-subtext); }`가 이미 정상 존재하고(클래스 선택자가 `default.css`의 `a{color:#333}`(태그 선택자)보다 항상 우선), `.product-wish-toggle`과 완전히 동일한 토큰을 쓰고 있어 CSS상으로는 이미 하트와 같은 색이어야 함(다른 곳에서 `.product-rating`/`.product-rating-star`/`.product-rating-score`를 재정의하는 규칙도 전체 파일 검색으로 없음을 확인). **브라우저 도구가 없어 직접 렌더링 확인은 못 해서 단정은 못 하지만, 오늘 style_user.css를 여러 번 고쳤어서 브라우저에 예전 캐시가 남아있을 가능성이 높음 — 하드 리프레시(Ctrl+Shift+R) 후에도 여전히 검게 보이면 알려달라고 요청함.**

### 3-38-8. 추가 수정: 별점 줄 왼쪽 정렬 + "전체보기" 문구 + 별 색상 진짜 원인 발견

사용자님이 스크린샷(초록 동그라미)으로 3가지 추가 지적:

1. **별점 줄이 위 텍스트(상품명/가격 등)보다 살짝 오른쪽에서 시작함** — 원인: 별점을 pill 버튼으로 만들면서 준 `padding: 4px 10px`(hover 히트 영역용) 때문에, 실제 별 아이콘이 `.product-meta`의 `padding-left: 2px`까지 합쳐 총 12px 오른쪽으로 밀려있었음. `#product-list .product-rating`에 `margin-left: -12px`를 줘서 그 12px을 정확히 상쇄 - hover 히트 영역(패딩)은 그대로 넓게 유지하면서 보이는 아이콘 위치만 위 텍스트와 같은 왼쪽 선에 맞춤.
2. **"전체보기" → "전체 상품 보기"**로 문구 변경(`section-more` 링크).
3. **별 색상이 여전히 검게 보이는 진짜 원인 발견** — 하트(♡)는 정상인데 별(★)만 계속 검게 나오는 게 이상해서 재조사한 결과, **Windows 환경에서 `★`(U+2605)가 (하트 ♡와 달리) 컬러 이모지 폰트로 렌더링되는 경우가 있어서 CSS `color`를 아예 무시하는 문제**로 추정됨(이모지 방식으로 그려지는 글리프는 미리 정해진 색으로 고정되어 텍스트 색 상속을 안 받음). 표준 해결법인 **텍스트 표시 지정자(Variation Selector-15, U+FE0E)**를 별 문자 바로 뒤에 붙여서(`★︎`, 마크업상 `★&#xFE0E;`) 무조건 흑백 텍스트 글리프로 그려지게 강제 - 이러면 CSS `color`가 정상적으로 먹음. **브라우저 도구가 없어 이 진단/수정이 실제로 화면에서 해결되는지 직접 확인은 못 했음 - 반영 후에도 여전히 까맣게 보이면 알려달라고 요청함(그 경우 폰트 자체를 명시적으로 지정하는 등 다른 방법 필요).**

### 3-38-9. 추가 조사: 별점 텍스트까지 전부 검게 나오는 문제 - !important로 강제 해결

사용자님이 재확인: 아이콘(★)뿐 아니라 "4.9 (1,245)" **텍스트까지** 검게 나오는 반면 찜 쪽(♡ + "342")은 아이콘·텍스트 둘 다 정상 — U+FE0E 가설(컬러 이모지 폰트) 하나로는 텍스트까지 검게 나오는 걸 설명할 수 없어서 재조사함.

- **캐싱 가능성부터 배제**: `curl -I`로 실제 응답 헤더 확인 → `Cache-Control: no-store`(Spring Boot devtools가 정적 리소스 캐시를 완전히 꺼둠) — 브라우저 캐시 문제일 가능성 자체를 확실히 배제함.
- **CSS 코드 자체를 재검토**: `.product-rating { color: var(--gsf-subtext); }`(클래스 선택자)가 `default.css`의 `a { color:#333 }`(태그 선택자)보다 명세상 항상 이겨야 하고, 파일 전체를 다시 검색해도 이걸 가로채는 다른 규칙(`#product-list a`, `.product-card a` 등)이나 JS로 인라인 스타일을 주입하는 코드도 전혀 없음을 재확인 — **CSS 소스만 보면 이론적으로 이미 정상이어야 하는 상태**라, 정확한 근본 원인은 못 찾음(브라우저 도구가 없어 실제 계산된 스타일을 직접 못 봐서 최종 확인 불가).
- **실용적 해결**: 원인 규명 대신, 가장 구체적인 선택자(`#product-list .product-rating`)에 `color: var(--gsf-subtext) !important`를 직접 명시해서 무슨 규칙이 이기고 있었든 확실히 덮어쓰게 함. 자식 스팬(`.product-rating-star`/`.product-rating-score`)도 `color: inherit`으로 명시해서 혹시 모를 개별 오버라이드 가능성까지 차단.
- **여전히 브라우저에서 직접 확인은 못 했음 - 반영 후 재확인 요청.**

### 3-38-10. 진짜 원인 발견 (사용자님이 DevTools로 직접 확인): `href="#"` + 전역 `a:visited` 명시도 함정

`!important`를 되돌려달라는 사용자님 요청(원인 규명을 가리지 않기 위해) 후, 사용자님이 직접 Chrome DevTools Elements 패널로 취소선 그어진 규칙들을 확인 → **진짜 원인 특정**: `default.css:22`의 `a:visited { color: #333; }`가 이기고 있었음.

- **왜**: `href="#"`는 현재 페이지 자기 자신을 가리키는 링크라서, 브라우저가 클릭하지 않아도 바로 `:visited`로 취급함. `a:visited`는 타입 선택자(a) + 가상클래스(:visited) 조합이라 명시도가 `(0,1,1)`인데, `.product-rating` 단독 클래스는 `(0,1,0)`이라 **`a:visited`가 더 높아서 이김** — 처음에 "클래스가 항상 태그 선택자를 이긴다"고만 생각하고 `a:visited`(가상클래스 포함이라 명시도가 실제로는 더 높음)를 놓친 게 제 분석 실수였음.
- **수정**: `#product-list .product-rating`(이미 있던, ID+클래스 조합이라 명시도 `(1,1,0)`으로 `a:visited`를 확실히 이김)에 `color: var(--gsf-subtext)`를 직접 명시 — `!important` 없이 정상적인 명시도로 해결.
- **같은 원인의 자매 버그 발견 + 동시 수정**: "전체 상품 보기" 링크(`.section-more`, 이것도 `href="#"`)도 순수 클래스 선택자라 완전히 같은 문제가 있었음(다만 이건 아직 스크린샷으로 직접 지적받진 않음 - 코드 재검토 중 같은 패턴임을 발견해서 선제적으로 같이 고침). `#product .section-more`로 스코프해서 명시도를 올림. `home.jsp`에서 `.section-more`는 이 한 곳에서만 쓰여서 스코프해도 안전함을 확인.
- **프로젝트 전체에 걸친 패턴 위험(기록만, 이번엔 전수 수정 안 함)**: 이 사이트에는 아직 실제 라우트가 없어 `href="#"`로 남겨둔 placeholder 링크가 많은데(`TODO(placeholder route)` 주석들 참고), **순수 클래스 선택자만으로 색을 입힌 `href="#"` 링크는 전부 동일하게 `a:visited`에 이 색이 밀릴 위험이 있음.** PROJECT_AUDIT.md에 패턴으로 기록해둠 - 다른 페이지 작업 때 이 함정을 참고할 것.

### 신규/수정 파일
```
수정:
  src/main/resources/static/css/style.css       (검색창 배경색 + body.home-hero 배경 전용 오버라이드)
  src/main/resources/static/css/style_user.css  (.product-like→.product-cart-quick, .product-cart 삭제, .product-wish-count→.product-wish-toggle+아이콘/숫자 분리, 카드 내부 비율 확대, 간격 통일, 별점 아이콘/숫자 분리, align-items:baseline로 정렬 + 밑줄 제거, 아이콘 19px로 축소, 별점 줄 margin-left 보정, color를 ID+클래스 스코프로 옮겨 a:visited 이기게 함, .section-more도 동일 패턴으로 수정)
  src/main/webapp/WEB-INF/views/home/home.jsp   (카드 4개 마크업 동일하게 갱신, 별점을 <a href="#"> 링크로 전환 + TODO 주석, "전체 상품 보기" 문구, ★ 뒤에 U+FE0E 추가)
  PROJECT_AUDIT.md                                (href="#" + a:visited 명시도 함정 패턴 기록)
```

---

## 3-39. 2026-08-31 밤: 홈 상품 목록 "더보기" + 무한스크롤 (서버 없이 목업 데이터로)

사용자님 요청: (1) 기본으로 8개 상품이 보이게(4열 유지) (2) 카드 아래 "더보기" 클릭 시 8개 추가 노출, 그 이후부터는 스크롤 시 8개씩 자동 로드 (3) "이거 서버 없이 구현될까?" 질문.

**답변**: 서버 없이 클라이언트에서 구현 가능 - 다만 실제 상품 데이터베이스가 없어서(홈페이지 자체가 실데이터 미연동 상태), 진짜 새 상품이 계속 나오는 게 아니라 목업 8종을 순환(offset % 8)해서 재사용하는 방식임을 먼저 설명하고 진행.

### 구현
- **정적 마크업(JSTL 하드코딩 4장) → 전부 JS 렌더링으로 전환**: `home.jsp`의 `#product-list`를 빈 `<div>`로 비우고, 이 프로젝트의 기존 컨벤션(인터랙션 JS ↔ 도메인 서비스 JS 분리)을 그대로 따라 2개 파일로 분리:
  - `static/js/product/homeProductService.js`(신규) — 목업 상품 8종 배열 + `fetchProducts(offset, limit)`. **실제 API인 것처럼 `Promise`를 반환**하게 만들어서, 나중에 진짜 백엔드가 생기면 이 함수 내부만 `fetch('/api/products?...')`로 바꾸면 되고 호출부(`views/home.js`)는 그대로 재사용 가능하도록 설계.
  - `static/js/views/home.js`(신규, 원래 있던 배너 로직은 3-38에서 이미 `common/bannerSlider.js`로 옮겨져 있어 이름 재사용에 문제없음 확인) — `HomeProductService`가 준 데이터로 `.product-card` DOM을 직접 빌드(3-38에서 확정된 마크업 구조 - `.product-cart-quick`/`.product-wish-toggle`/`.product-rating` 전부 동일하게 재사용)해서 `#product-list`에 append. 페이지 로드 시 8개 렌더 → "더보기" 버튼 클릭 시 8개 추가 + 버튼 숨김 + 스크롤 리스너 등록 → 이후 스크롤이 문서 하단 400px 이내로 오면 자동으로 8개씩 추가 로드.
- **"더보기" 버튼**: `#product-list` 바로 아래 `#productLoadMore`(`.btn-load-more`, 흰 배경 pill + 아래방향 화살표 아이콘, hover 시 캐러멜 톤) 신규 추가.
- CSS: `#product-list`/`.product-card` 등 카드 자체 스타일은 3-38에서 이미 확정된 걸 그대로 재사용(변경 없음), `.product-load-more-wrap`/`.btn-load-more`/`.btn-load-more-svg`만 신규 추가.

### 검증
`mvnw compile` 통과, 서버 재요청으로 `/js/product/homeProductService.js`/`/js/views/home.js` 200, `#product-list`가 빈 컨테이너로(JS가 채우는 구조로) 렌더링되는 것, `#productLoadMore` 버튼 마크업 정상 존재 확인. **JS 실행 결과(실제로 8개가 그려지는지, 버튼 클릭/스크롤이 정상 동작하는지)는 브라우저 도구가 없어 직접 확인 못 함 - 화면에서 실제로 눌러보고 스크롤해봐야 함.** 새로 만들어지는 `.product-rating`/`.section-more`도 3-38-10에서 고친 CSS 스코프(`#product-list .product-rating`)를 그대로 타므로 동적으로 추가된 카드도 색상 문제 없이 렌더링될 것으로 예상(코드 검토 기준, 마찬가지로 직접 확인 필요).

### 신규/수정 파일
```
신규:
  src/main/resources/static/js/product/homeProductService.js
  src/main/resources/static/js/views/home.js

수정:
  src/main/webapp/WEB-INF/views/home/home.jsp        (#product-list를 빈 컨테이너로, "더보기" 버튼 추가, script 태그 2개 추가)
  src/main/resources/static/css/style_user.css       (.product-load-more-wrap/.btn-load-more(-svg) 신규 추가)
```

### 3-39-1. 추가 수정: 찜 하트 모양을 헤더와 통일

사용자님이 스크린샷으로 지적: 카드의 찜 하트(유니코드 ♡ 글자)가 헤더의 찜 아이콘(SVG 하트)과 생김새가 달라 위화감이 있음 → `views/home.js`의 `.product-wish-icon`을 `<span>♡</span>` 대신 `header.jsp`가 쓰는 것과 완전히 같은 SVG path(`M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z`)로 교체. CSS도 텍스트 글자 스타일(font-size)에서 `#site-header .icon-svg`와 동일한 SVG 스타일(`fill:none; stroke:currentColor; stroke-width:1.8`)로 변경. 크기는 기존 19px 유지.

### 신규/수정 파일
```
수정:
  src/main/resources/static/js/views/home.js     (하트를 ♡ 텍스트 → 헤더와 동일한 SVG로 교체)
  src/main/resources/static/css/style_user.css   (.product-wish-icon을 SVG 스타일로 변경)
```

### 3-39-2. 추가 수정: 별점 아이콘도 SVG로 통일

사용자님 요청으로 별(★, 유니코드 텍스트 - 3-38-10에서 a:visited 명시도 문제까지 겪었던 그 문자)도 하트와 같은 방식으로 SVG 아이콘으로 교체. 하트(outline/stroke)와 달리 ★는 원래 채워진 모양이라 `fill: currentColor`(stroke 없음)로 구현. 이제 두 아이콘 다 SVG라 유니코드 글리프 관련 문제(컬러 이모지 렌더링, a:visited 명시도 등)에서 완전히 자유로워짐.

### 신규/수정 파일
```
수정:
  src/main/resources/static/js/views/home.js     (별을 ★ 텍스트 → SVG로 교체)
  src/main/resources/static/css/style_user.css   (.product-rating-star를 SVG 스타일로 변경)
```

---

## 3-40. 2026-09-01: 홈페이지 배경에 산수화 이미지(`hero-bg.jpg`) 적용 시도 → 단색으로 원복

스타일가이드 PDF(섹션 02 "배경 산수화 삽입 방법")가 원래 설계했던 산수화 배경 이미지를 홈페이지에 실제로 적용해봤으나(학/새/대나무를 페이지 상단 여백에, 산을 푸터 위에 배치하는 방식, 이미지 4조각으로 크롭 + 배경 누끼 처리까지 진행), **실제 화면에 적용해보니 이미지가 너무 산만하고 지금 UI 컨셉의 기획 의도와 맞지 않는다고 판단 — 전부 되돌리고 기존처럼 단색 배경(`#FDFBF9`)으로 유지하기로 결정함.**

- 관련해서 추가됐던 CSS(`.home-hero-deco`/`-crane`/`-birds`/`-bamboo`/`-mountains` 및 미디어쿼리)와 `home.jsp`의 장식 마크업을 전부 제거, `body.home-hero`도 `position:relative` 없이 단순 배경색만 남김.
- 크롭해서 만들었던 이미지 파일(`hero-crane.png`/`hero-birds.png`/`hero-bamboo.png`/`hero-mountains.png`) 삭제 — 원본 `hero-bg.jpg`(JWC_works가 추가한 기존 에셋)는 그대로 유지.
- `mvnw compile` + 서버 재확인으로 홈페이지가 정상적으로 단색 배경 상태로 돌아온 것 확인.

---

## 3-41. 2026-09-01: 문서 정리 + 다음 단계(나머지 페이지 CSS/JS 규격화) 인수인계 계획

홈페이지 기준 작업이 일단락돼서, (1) 누적된 md 문서 3종을 정리하고 (2) 오늘까지의 상태를 최신화하고 (3) 완전히 새 환경에서도 그대로 이어받을 수 있게 다음 단계 계획을 확정한 세션. **코드 변경은 없음(문서 작업만).**

### 문서 정리 내용

- **`HANDOFF.md`**
  - 맨 앞에 "이 문서를 읽는 법" + **지금 상태 요약 표**(브랜치/미커밋 변경/진행 중 작업/다음 단계/CSS·JS 구성/서버 정보) + **구간별 목차 표** 추가 — 1700줄이 넘어가면서 새 세션이 어디부터 읽어야 할지 알기 어려워진 문제 해결.
  - 문서 중간(3-19와 3-20 사이)에 끼어 있던 `## 4. 참고 메모리` 블록을 문서 맨 끝 **부록 A**로 이동 — 섹션 번호가 3-19 → 4 → 3-20으로 튀던 것 정리.
  - 최초 제목이 `관리자 기능 3종 작업 인수인계`였는데 실제 내용은 프로젝트 전반으로 넓어진 지 오래라 `TunaProject_MDS 작업 인수인계 문서`로 변경하고, 원래 제목의 설명문은 섹션 1의 리드 문장으로 내림.
  - 섹션 사이 `---` 구분선 누락(3-39/3-40 앞) 보정.
- **`PROJECT_AUDIT.md`**
  - 맨 앞에 항목 수 기준 **현황 요약 표**와 "이 문서 쓰는 법"(번호는 고정 ID라 재사용/재번호 금지) 추가.
  - "잠재적 위험 요소"의 번호가 `1~13` → `16~19` → `14~15` 순으로 뒤엉켜 있던 것을, **번호는 그대로 둔 채 소제목 순서만 바꿔서** `1~4`(심각도 높음) → `5~13`(구조적 위험) → `14~15`(인증 가드/설정) → `16~19`(이후 세션 추가 발견) 순으로 정렬. HANDOFF.md와 대화에서 "잠재적 위험 7번", "정책 항목 11번"처럼 번호로 참조하는 곳이 많아서 **재번호는 하지 않음**.
- **`HANDOFF_NEXT_SESSION_PROMPT.txt`** — 내용이 "frontfix 인수 + 검증" 시점 기준이라 지금과 안 맞아서, 아래 "다음 단계" 기준으로 전면 재작성.

### 다음 단계 (다음 세션에서 할 일)

**목표: 홈페이지에서 확립한 패턴을 나머지 페이지 전체에 적용. 서버(백엔드) 연동은 범위 밖.**

> **`MemberMapper.xml` 처리 방침(2026-09-01 사용자 결정)**: 3-37에서 고친 쿠폰 페이징 문(`selectCouponsByMemberId` 추가)은 **`frontfix`에 커밋하지 않기로 함.** 원인 추적 결과 이건 `frontfix`만의 문제가 아니라 KGH의 `0d46824`(#BE014)가 페이징 문을 비페이징으로 개조하면서 거의 모든 브랜치에 퍼진 문제이고, `BJY_works`도 동일하게 `/member/couponView`가 500임(PROJECT_AUDIT.md "조치 완료" 항목 참고). → **`BJY_works`에서 먼저 고친 뒤 병합으로 내려보내는 순서로 진행.** 그때까지 `frontfix`의 이 변경은 미커밋 상태로 남겨두고, **다음 세션이 임의로 커밋하거나 다시 고치지 말 것.**
>
> **브랜치 전제(2026-09-01 확인)**: `frontfix`는 프론트 담당자에게 넘겨주려고 만든 **로컬 전용 임시 브랜치**이고, 사용자(팀장)의 실제 작업 브랜치는 `BJY_works`(wish/cart/쿠폰 정리 완료 상태)다. 3-37에서 기록한 "이 브랜치가 3-34~3-36 정리를 못 받았다"는 것도 **브랜치 시차이지 버그가 아니므로 `frontfix`에서 되돌려 고치지 말 것** — 합칠 때 `BJY_works` 쪽 상태가 기준이 된다.

1. **홈페이지 결과물 전달·병합** — 지금 `frontfix`의 미커밋 변경분(`home.jsp` + `style.css`/`style_user.css` + `js/product/homeProductService.js`/`js/views/home.js`)이 프론트 담당자(JWC1226)의 작업과 같은 파일을 건드리고 있어서, 그대로 각자 진행하면 `style_user.css`에서 충돌이 크게 남. 전달 → 병합 → 병합 결과물을 3-32/3-33에서 했던 방식(diff 검토 → 빌드 → 기동 → 스모크 테스트)으로 검증하는 순서로 진행할 것.
2. **나머지 페이지 CSS 통합 적용** — 현재 CSS 4개(`default`/`style`/`style_user`/`style_admin`) 구성 자체는 유지하되, 각 페이지가 실제로 그 규격을 따르고 있는지 점검·보정.
3. **나머지 페이지 JS 분리** — 인라인 `<script>`가 남아있는 5개 페이지를 `views/<페이지>.js` + `<도메인>/<기능>Service.js`로 분리.

### 다음 세션이 바로 쓸 수 있는 현황 데이터 (2026-09-01 기준 실측)

**인라인 `<script>`가 아직 남아있는 JSP 5개** (JS 분리 대상):

| 파일 | 비고 |
|---|---|
| `admin/adminPage.jsp` | 관리자 마이페이지 |
| `member/myPage.jsp` | 유저 마이페이지 |
| `product/cart.jsp` | 장바구니 — **`wish`/`cart`는 다른 담당자가 별도 진행 중이라 손대지 말 것** |
| `product/wish.jsp` | 찜 — 위와 동일 |
| `product/searchProduct.jsp` | 상품 검색 |

→ 실제로 이번에 건드릴 수 있는 건 `adminPage.jsp`/`myPage.jsp`/`searchProduct.jsp` 3개.

**이미 분리 완료된 JS** (패턴 참고용): `views/` 11개(`addCoupon`/`addProduct`/`addreview`/`adminMaintenance`/`adminOrderDelivery`/`admincouponView`/`header`/`home`/`productdetail`/`signUp`/`usercouponView`), 서비스 쪽 `admin/` 4개 + `common/` 3개(`bannerSlider`/`cartWishService`/`pagination`) + `member/memberService.js` + `product/homeProductService.js`.

**CSS 쪽에서 확인된 예외 1건**: `member/userWithdraw.jsp`가 **전체 JSP 25개 중 유일하게 `common/header.jsp`를 include하지 않고** 자기 `<head>`에서 `default.css`/`style_user.css`를 직접 `<link>`하는 독립 페이지 상태. 규격화 대상이면 header/footer include 방식으로 맞춰야 하고, 모달성 화면이라 의도적으로 뺀 것이면 그 이유를 문서에 남길 것(담당자 확인 필요).

**hero 배경 클래스가 붙는 페이지 9개**(`header.jsp`가 요청 경로 보고 `body`에 부여): `home`/`login`/`signup`/`order`/`order-complete`/`product-detail`/`review-write`/`coupon`/`delivery`. 새 페이지를 규격화할 때 이 목록에 추가가 필요한지 같이 확인할 것.

### 작업할 때 반드시 지킬 것 (지금까지 실제로 데인 것들)

1. **옛 페이지별 CSS를 "원본 그대로" 이어붙이지 말 것** — `header.jsp`가 CSS 4개를 전 페이지에 무조건 로드하는 구조라, 스코프 없는 `body{}`/`main{}`/`#id{}` 선택자가 하나라도 섞여 들어오면 **사이트 전체로 샌다**. 3-5/3-6에서 크게 겪었고 3-37에서 또 3곳 재발했음. 병합 직후 `grep -n "^body\s*{\|^main\s*{\|^#" style_user.css` 한 줄로 바로 확인 가능. `style_admin.css`가 이걸 제대로 지킨 참고 사례(전부 `.admin-xxx-page`로 스코프 + `--admin-*` 접두사).
2. **`href="#"` placeholder 링크에 색을 입힐 땐 순수 클래스 선택자만 쓰지 말 것** — `default.css:22`의 `a:visited{color:#333}`(명시도 `(0,1,1)`)가 클래스 하나(`(0,1,0)`)를 이겨서 색이 검게 나옴. `href="#"`는 자기 자신을 가리켜서 클릭 없이도 `:visited` 취급. ID 스코프(`#product-list .product-rating` 등)로 명시도를 올릴 것. 3-38-10 / `PROJECT_AUDIT.md` 잠재적 위험 19번 참고.
3. **아이콘은 유니코드 글리프 대신 SVG로** — `★`/`♡`는 환경에 따라 컬러 이모지 폰트로 렌더링돼 CSS `color`를 무시하거나 세로 정렬이 어긋남. 헤더(`#site-header .icon-svg`)와 동일한 SVG 스타일(`fill:none; stroke:currentColor; stroke-width:1.8`, 채움 아이콘은 `fill:currentColor`)로 통일. 3-39-1 / 3-39-2 참고.
4. **화면 확인은 사용자만 가능** — Claude Code 환경엔 브라우저/렌더링 도구가 없어서 픽셀 단위 결과(정렬·색·간격)를 직접 못 본다. 코드/기하 계산으로 추정해서 반영한 뒤엔 반드시 사용자에게 확인을 요청할 것. 실제로 3-38-4~3-38-10에서 잘못된 추정으로 여러 번 헛돌았고, 최종 원인은 사용자가 DevTools로 직접 찾았음.
5. **테스트 데이터는 만들었으면 반드시 정리**(파일 + DB 양쪽). PowerShell에서 한글 문자열 `-like` 필터가 조용히 실패한 적이 있으니 **ID 기준으로 직접 삭제**할 것.

---

## 3-42. 2026-09-01: 나머지 페이지 CSS/JS 규격화 실행 (3-41 계획의 2단계)

3-41 계획대로 홈페이지에서 확립한 패턴을 전 페이지에 적용. **서버 연동은 계획대로 범위 밖.**

### 시작 시점에 3-41과 달랐던 것

| 항목 | 3-41 기준 | 실제 |
|---|---|---|
| 홈페이지 변경분 | "미커밋" | 이미 `a9bdcfa`로 커밋 + `origin/frontfix` 푸시 완료 |
| `frontfix` | "로컬 전용" | 원격에도 존재 |
| 관리 문서 4개 | "커밋 대상 아님" | `a9bdcfa`에 함께 커밋됨(`.gitignore`에 등록된 적 없었음) |

3-37에서 고쳤던 `MemberMapper.xml` 쿠폰 페이징 문은 미커밋 변경이라 새 환경에 딸려오지 않음 → 3-41 방침대로 손대지 않고 3-43에서 `BJY_works`에 반영.

> **증상 범위 정정**: `/member/couponView` 500은 **USER 계정일 때만**이다. `MemberController.userCouponViewForm()`이 role로 분기해 ADMIN은 `listCoupon()`을 타지 않고 `admin/admincouponView`로 빠진다.

### 달성한 규격 지표

| 지표 | 결과 |
|---|---|
| 인라인 `<script>` 가진 JSP | **0 / 25** |
| `common/header.jsp` 미include JSP | **0 / 25** |
| 절대경로 `<script src="/...">` | **0** |
| 유니코드 글리프 아이콘(★♡♥✓×) | **0** (전부 SVG) |
| `style_user`/`style_admin`의 스코프 없는 `body{}`/`main{}` | **0** |

### (1) 인라인 `<script>` 분리 — 5개 페이지

> **범위 정정(사용자 확인)**: 3-41은 `cart`/`wish`를 "다른 담당자"로 제외했으나, **담당자가 다른 건 서버 쪽이고 뷰(JSP/CSS/JS)는 이쪽 담당**이라는 확인을 받아 5개 전부 작업. 찜/장바구니의 **서버 연동은 여전히 범위 밖**.

| 페이지 | 분리 결과 |
|---|---|
| `admin/adminPage.jsp` | `admin/adminMypageService.js` + `views/adminPage.js` |
| `member/myPage.jsp` | `views/myPage.js` |
| `product/searchProduct.jsp` | `views/searchProduct.js` |
| `product/cart.jsp` | `product/cartService.js` + `views/cart.js` |
| `product/wish.jsp` | `product/wishService.js` + `views/wish.js` |

**공용 `common/placeholderLinks.js` 신설** — `adminPage`/`myPage`가 각자 갖고 있던 "`href="#"` 클릭 시 상단 점프 막기" 코드를 통합. **반드시 페이지 wrapper로 스코프해서 호출**하는 것이 원칙(`footer.jsp`에도 `href="#"`가 8개라 문서 전체에 걸면 25개 페이지 푸터가 전부 바뀐다).

> **의도적 동작 변경**: 기존 `adminPage.jsp`는 문서 전체를 걸어 관리자 마이페이지에서만 푸터 링크까지 막혀 있었다(`myPage.jsp`는 스코프됨 — 주석엔 "동일 패턴"이라 적혀 있었지만 실제론 달랐음). 이번에 **둘 다 자기 wrapper로 스코프**해 통일.

**`common/cartWishService.js` 중복 정리**: 이 파일이 이미 `getCartItems()`/`getWishList()`를 공개하는데도 `cart.jsp`/`wish.jsp`가 같은 localStorage 읽기를 각자 재구현하고 있었고, save 함수도 3곳에 중복. 공용에 `saveCartItems`/`saveWishList`/`getCartKey`를 추가해 정리. **기존 전역 함수(`window.addToCart`/`toggleWish`/`isWished`)는 하위 호환으로 유지.**

**JSP 표현식 처리**: 인라인 스크립트 안에 `<c:url>`이 박혀 있던 것(`wish`의 `DETAIL_BASE_URL`, `cart`의 `/order/payment`)은 외부 `.js`로 옮길 수 없으므로, **컨테이너의 data 속성으로 넘기고 `dataset`으로 읽는 방식**으로 전환(`header.jsp`의 `<body data-home-url>`과 같은 패턴).

### (2) `member/userWithdraw.jsp` 규격화

전체 JSP 25개 중 유일하게 `header.jsp`를 include하지 않던 독립 페이지. 사용자 결정으로 대상에 포함.

- JSP: `<!DOCTYPE>`~`</html>` 직접 작성 → header/footer include + `<div class="withdraw-page">` wrapper
- CSS: **`.withdraw-page main {}`이 `main`을 후손으로 가정**하고 있어, wrapper 방식으로 바꾸면 3-5/3-6과 똑같이 규칙이 통째로 안 먹는다. 형제 페이지 `.update-page`와 같은 3단 패턴으로 재구성 — 배경은 `body:has()`, 폭은 `main:has()`, 카드 스타일은 wrapper 자신
- **부수 효과**: 페이지 고유 `<title>`이 사라지고 `header.jsp`의 공용 title을 쓴다(나머지 24개도 이미 그런 상태라 일관성 측면은 오히려 맞음)
- hero 배경 클래스는 추가하지 않음(3-41 확인 항목)

### (3) 삭제됐던 `userUpdateInfo.js` 복구 — 이번 세션 최대 발견

`member/userUpdateInfo.jsp:230`이 `/js/userUpdateInfo.js`를 로드하는데 **그 파일이 없었다.** 단순 404가 아니라 **회원정보 수정 화면 전체가 죽어 있던 상태** — 아코디언 8개 항목의 펼침·저장·취소·중복확인 버튼이 전부 이 JS에 달려 있었다.

- 파일은 `dbd3a75`(#FE015, 프론트 담당)가 정상 생성 → **`0e37e8f`(#BE005 "주문 결제 기능 추가", KGH)가 삭제.** 주문/결제와 무관한 프론트 파일이 백엔드 커밋에 휩쓸림. 6개 브랜치엔 아직 살아있음
- **`MemberMapper.xml` 쿠폰 페이징 문 실종(`0d46824`, 동일 작성자)과 같은 패턴** — 백엔드 커밋이 타 담당자 영역 파일을 조용히 지우거나 개조한 사고가 최소 2회. 팀 공유 필요

복구는 원본 복원이 아니라 **현재 컨벤션으로 재작성**: 위치를 `views/`로 옮기고, 중복확인 3종의 직접 `fetch`를 **기존 `member/memberService.js` 재사용**으로 바꿔 약 45줄 제거. 흐름이 같은 핸들러 3개를 `setupDuplicateCheck(config)` 하나로, 저장 분기도 `CHECKED_FIELDS` 테이블로 통합. 원본 셀렉터(id 28개 + class 4개)가 현재 JSP와 전부 일치하는 것을 대조 확인 후 작업.

JSP도 `<c:url>` 2줄로 교체했고, 같은 김에 `signUp.jsp`의 절대경로 2줄도 통일.

**낡은 주석 2곳 수정**: `userUpdateInfo.jsp`/`userWithdraw.jsp`가 "UPDATE 백엔드가 없다"고 적고 있었으나, **`96e4ee9`(#BE014)가 이미 `POST /member/update*` 8개 + 대응 `<update>` 문을 전부 구현**해뒀다.

> **즉 회원정보 수정은 "백엔드는 다 됐는데 프론트가 안 붙은" 상태다.** 저장 버튼은 여전히 no-op이고 연동은 범위 밖이라 하지 않았으며, 대신 `views/userUpdateInfo.js` 상단 TODO에 어느 분기에서 어느 엔드포인트를 부르면 되는지 전부 적어뒀다.
> **회원 탈퇴 링크도 깨져 있다**: `/member/userWithdraw`(GET) 매핑이 없어 404. 백엔드에 있는 건 `POST /member/withdraw`. (AUDIT 버그 13번)

### (4) 아이콘 유니코드 글리프 → SVG 전면 전환

규격 3번이 홈/헤더에만 적용돼 있던 것을 사용자 지시로 전체 적용. 문제의 본질은 `★`/`♡`/`♥`/`✓`가 **환경에 따라 컬러 이모지로 렌더링되면 CSS `color`가 무시되고 정렬이 어긋난다**는 것.

**공용 아이콘 클래스를 `style.css`에 신설**(admin/user 양쪽에서 쓰므로 진짜 공용 파일에):

| 클래스 | 규격 |
|---|---|
| `.icon-star` | `fill:currentColor` |
| `.icon-heart` / `.is-filled` | `stroke:currentColor` 1.8 / 채움 토글 |
| `.icon-check`, `.icon-close` | `stroke:currentColor` 2.5 |
| `.icon-inline` | `0.9em` + `vertical-align:-0.15em` |

크기는 전부 **em 기준**이라 각 자리의 기존 `font-size`를 그대로 따라가고, 색은 `currentColor`라 기존 `color` 규칙이 그대로 먹는다.

전환 17개소: `productDetail.jsp`(4) / `views/productdetail.js`(찜 토글을 **글리프 교체 → `.is-filled` 클래스 토글**로) / `addReview.jsp`(별점 버튼 5개) / `orderComplete.jsp`·`userWithdraw.jsp`(✓) / `userOderDelivery.jsp`(배송 4단계 ✓ — EL 삼항을 `<c:if>`+SVG로. `.step-icon`이 미완료를 `color:transparent`로 감추는 구조라 `stroke:currentColor`로 **동작 동일 유지**) / `views/wish.js`(★) / `addProduct.jsp`+`views/addProduct.js`×3+`views/addreview.js`(×).

**부수 개선**: `×`가 SVG가 되면 버튼 텍스트가 사라지므로 해당 5곳에 `aria-label` 신규 추가. `.modal-close`/`.remove-btn`은 글리프 텍스트 정렬로 가운데가 맞던 구조라 `display:flex` 정렬을 명시.

> **⚠️ 크기는 전부 추정치다.** 같은 `font-size`라도 **SVG가 글리프보다 커 보인다**(글리프는 em 박스 안에 자체 여백이 있어 실제 잉크가 박스보다 작다). 자리별 배율을 따로 잡았고 조정 지점엔 전부 `⚠️ 근사치라 화면 확인 필요` 주석을 달아뒀다 — `grep -rn "근사치라 화면 확인 필요" src/main/resources/static/css/`로 바로 찾을 수 있다.
>
> `.icon-inline` 0.9em · `.tag-remove`/`.modal-close`의 × 0.7em · `.complete-icon`의 ✓ 0.7em · `.remove-btn`의 × 0.85em · `.step-icon`의 ✓ 1em · `#wish-button`의 ♡ 1.5em · `.star-btn`의 ★ 1em(=44px)

### 검증

`mvnw compile` 통과. 실제 HTTP 요청으로 USER 7개 + ADMIN 6개 + 비로그인 3개 화면 **전부 200**. 신규/변경 JS 정적 서빙 200, 중복확인 API 3종 정상 응답, `/member/updateInfo`에 JS가 쓰는 **id 28개 전부 렌더** 확인.

**라우트가 없는 뷰 4개**(`userWithdraw`/`orderComplete`/`productDetail`/`addReview`)는 요청으로 닿을 수 없어 **임시 컨트롤러로 렌더링만 확인 후 즉시 삭제**(잔존 0건 확인). 전부 200이고 SVG가 의도한 개수만큼 렌더됨. 서빙되는 JS 5개도 실코드 글리프 0건 확인. 테스트 계정은 매번 생성 후 삭제(자식 테이블 참조 확인 포함).

> **재확인한 기존 문제**: 세션 만료 상태로 `/member/updateInfo` 요청 시 **500**. `updateInfoForm()`에 `myPageForm()`이 3-30-18에서 추가한 것과 같은 null 가드가 없다. 다른 화면은 같은 상황에서 302로 빠진다. (AUDIT 버그 15번)

### 화면 확인이 필요한 것 (사용자만 가능)

브라우저가 없어 픽셀 결과를 못 본다. 아래는 **코드/기하로 맞춘 추정**:

1. **아이콘 SVG 크기 — 가장 손볼 가능성이 높음.** 특히 상품상세 찜 버튼 하트, 리뷰 별점 입력 버튼 5개, 완료 화면 체크, 태그/이미지 삭제 ×
2. **`member/userWithdraw` 레이아웃** — 헤더/푸터가 새로 붙고 CSS를 3단으로 재구성. 단 라우트가 없어 임시 컨트롤러 없이는 못 엶
3. **`/member/updateInfo` 조작** — 아코디언, 취소 원복, 중복확인 메시지 색, 저장 시 표시값 갱신
4. **`cart`/`wish` 조작** — 수량 증감, 선택 삭제, 정렬 탭, 찜 해제 애니메이션(300ms), "주문하기" 이동
5. **관리자 마이페이지 푸터 링크** — 위 "의도적 동작 변경" 참고

### 신규/수정 파일

```
신규 JS:
  common/placeholderLinks.js (27)   admin/adminMypageService.js (26)
  views/adminPage.js (24)           views/myPage.js (10)
  views/searchProduct.js (56)       views/userUpdateInfo.js (295, 복구+재작성)
  product/cartService.js (73)       product/wishService.js (73)
  views/cart.js (166)               views/wish.js (146)

수정:
  css/style.css (공용 .icon-* 신설)  css/style_user.css  css/style_admin.css
  js/common/cartWishService.js       js/views/{addProduct,addreview,productdetail}.js
  views: admin/{addProduct,adminPage}, member/{myPage,signUp,userUpdateInfo,userWithdraw},
         order/{orderComplete,userOderDelivery}, product/{cart,searchProduct,wish,productDetail},
         review/addReview
```

---

## 3-43. 2026-09-01: `BJY_works`에서 쿠폰 페이징 매퍼 문 복구 (3-41 방침 이행)

3-42까지 끝낸 프론트 작업을 `frontfix`에 커밋하고, **3-41에서 "`BJY_works`에서 먼저 고친 뒤 병합으로 내려보낸다"고 정해둔 순서대로** 브랜치를 옮겨와 매퍼를 고친 세션. 목적은 테스트 서버 배포를 위해 `BJY_works` → `main` 라인을 정상화하는 것.

### 무엇을 고쳤나

`src/main/resources/mappers/member/MemberMapper.xml`에 **페이징 문 `selectCouponsByMemberId`를 추가**(+19줄). 이 파일 1개만 변경.

`BJY_works`에서도 `frontfix`와 완전히 같은 상태였음을 먼저 확인했다:

| 항목 | 상태 |
|---|---|
| `MemberMapper.java:37` | `selectCouponsByMemberId(memberId, offset, pageSize)` **선언 있음** |
| `MemberMapper.xml` | 대응하는 `<select>` 문 **없음** (`selectAllCouponsByMemberId` / `countCouponsByMemberId` 2개뿐) |
| `MemberServiceImpl.java:117` | `listCoupon()`이 그 메서드를 **실제로 호출** |

→ 컴파일은 통과하지만 호출 시점에 `BindingException` → USER 계정의 `/member/couponView`가 500. (원인 커밋 `0d46824` 추적 내용은 `PROJECT_AUDIT.md` "조치 완료" 항목 참고)

### 비페이징 문을 지우지 않은 이유

`selectAllCouponsByMemberId`(비페이징)는 **`OrderServiceImpl`이 2곳에서 결제 화면의 쿠폰 선택 드롭다운용으로 호출**하고 있다(전체 목록이 필요). 즉 페이징 문과 용도가 달라 **둘 다 있어야 한다.** 사고 커밋이 바로 이 둘을 하나로 합치려다(기존 페이징 문의 id를 비페이징 이름으로 바꾸고 `OFFSET` 줄 삭제) 생긴 것이라, **XML 양쪽 문에 "둘 다 필요하니 합치지 말 것 + 사고 커밋 해시"를 주석으로 박아뒀다.** 같은 실수가 세 번째로 반복되지 않게 하는 게 목적.

쿼리 자체는 위 비페이징 문과 WHERE/ORDER를 동일하게 맞췄고, `OFFSET/FETCH`는 같은 파일의 `selectDeliveriesByMemberId`가 쓰는 패턴을 그대로 재사용했다.

### 검증

`./mvnw compile` 통과 + devtools 재시작 후 실제 HTTP 요청. **role 분기 때문에 ADMIN 계정으론 증상이 안 보이므로 반드시 USER 계정으로 확인해야 한다**(`MemberController.userCouponViewForm()`이 ADMIN이면 `listCoupon()`을 타지 않고 `admin/admincouponView`로 빠짐).

| 항목 | 결과 |
|---|---|
| `/member/couponView` (USER, 쿠폰 0건) | **500 → 200** |
| `/member/couponView` (USER, 쿠폰 3건) | 200, **쿠폰 카드 3건 정상 렌더** |
| 쿠폰명 / 마감일(`DEAD_LINE_STR`) | 정상 출력 |
| `?page=1`, `?page=2` | 둘 다 200 (OFFSET/FETCH 동작) |
| USER 6개 화면 / ADMIN 6개 화면 | 전부 200 (회귀 없음) |

빈 목록만으로도 `BindingException` 발생 여부는 판별되지만, **컬럼 매핑과 OFFSET/FETCH까지 실제로 태우려고** 테스트 계정에 쿠폰 3건을 직접 발급해서 확인했다.

**비페이징 문 회귀 없음 확인 방법**: MyBatis는 기동 시 전체 매퍼 XML을 파싱하면서 중복 statement id가 있으면 실패한다. 정상 기동했으므로 두 문이 충돌 없이 공존하는 것이 확인됨. (`/order/payment`가 GET에 405를 주는 건 `@PostMapping` 전용 매핑이라 그런 것으로, 이번 변경과 무관)

**테스트 데이터 정리 완료**: `COUPONHISTORY` 3행 + 계정(`cpqa01`, MEMBER_ID=41) 삭제. 잔여 테스트 계정 0건, 고아 `COUPONHISTORY` 0건까지 확인.

> **⚠️ 시퀀스 이름 함정(다음에 시드 넣을 때 참고)**: 쿠폰 발급 INSERT에 `SEQ_COUPONHISTORY`를 썼다가 `ORA-02289`(시퀀스 없음)가 났다. 실제 이름은 **`SEQ_CHIST_ID`** — 이 스키마의 시퀀스는 **테이블명이 아니라 PK 컬럼명 기준**으로 붙어 있다(`SEQ_OD_ID`, `SEQ_POP_ID`, `SEQ_CD_ID`, `SEQ_CHIST_ID` …). `USER_SEQUENCES`를 먼저 조회하는 게 빠르다.

### 병합 전에 확인된 것 (`frontfix` ↔ `BJY_works`)

테스트 서버 배포를 위해 병합하기 전에 두 브랜치의 다이버전스를 미리 조사했다. 공통 조상은 `21708ab`.

- **코드 충돌 없음**: 두 브랜치가 같이 건드린 파일은 관리 문서 3종(`HANDOFF.md`/`PROJECT_AUDIT.md`/스타일가이드 PDF)뿐이고, `src/` 아래엔 겹치는 파일이 하나도 없다.
- **문서는 수정-수정 충돌**: `1a914f3 "PR 을 위한 개인 작업 관리 파일 제거"`가 한 번 지웠다가 이후 커밋에서 되살아나서, 삭제-vs-수정이 아니라 양쪽 다 내용이 있는 상태(frontfix 1832줄 / BJY_works 1510줄). → **문서 4종은 이번에 git 추적에서 빼기로 결정**(아래 참고)이라 이 충돌 자체가 사라진다.
- **⚠️ `cart`/`wish` 화면이 병합 후 도달 불가가 됨**: `BJY_works`가 3-34 정리 때 `MemberController`의 `/wish`·`/cart` 매핑을 제거했는데, `WishController`/`CartController`는 양쪽 브랜치가 동일하고 **둘 다 `product/wish`·`product/cart` 뷰를 반환하는 메서드가 없다**(전부 redirect). 병합하면 4개 경로가 전부 404가 된다 → 상세와 후속 판단은 3-44 및 `PROJECT_AUDIT.md` 버그 16번.
- **관리 문서 4종을 git 추적에서 제외하기로 결정** — `a9bdcfa`에 딸려 `origin/frontfix`까지 올라간 것을 `main` 전에 빼기로 함. `BJY_works`에도 커밋돼 있어 한쪽만 지우면 delete/modify 충돌이 나므로 **양쪽에서 같이 제거**해야 한다. 실행 결과는 3-44.

### 신규/수정 파일

```
수정:
  src/main/resources/mappers/member/MemberMapper.xml   (페이징 문 selectCouponsByMemberId 추가, +19줄)
```

---

## 3-44. 2026-09-01: 전 브랜치 병합·최신화 + `main` 배포 + 테스트 서버 가동

3-42(프론트 규격화)와 3-43(매퍼 복구) 결과물을 실제로 합쳐서 `main`까지 올리고, 팀 테스트 서버를 띄운 세션. **코드 변경은 없고 병합·검증·배포만 했다.**

### 진행 순서

1. `BJY_works`에 `frontfix`(3294ddd) → `Util_branch`(a1fb97e) 순으로 병합
2. 관리 문서 4종을 git 추적에서 제외 (아래 참고)
3. 푸시 → `Start_branch` PR → `main` PR
4. 테스트 서버 배포

### 병합 결과물 검증 (푸시 전, 3-32/3-33과 같은 방식)

| 항목 | 결과 |
|---|---|
| 병합 충돌 | 없음 — 충돌 마커 0건, 워킹트리 clean |
| 관리 문서 4종 | **미추적 유지** (`frontfix` 병합으로 되살아나지 않음) |
| 매퍼 수정(3-43) | 페이징·비페이징 문 둘 다 공존 확인 |
| 3-42 프론트 결과물 | 신규 JS 10개 전부 존재 |
| 규격 지표 5종 | 인라인 `<script>` 0/25, `header.jsp` 미include 0, 절대경로 script 0, 글리프 아이콘 0, 스코프 없는 `body{}`/`main{}` 0 |
| `./mvnw compile` | 통과 |
| 서버 기동 | 정상 (`APPLICATION FAILED` 0건) |
| 스모크 테스트 | USER 6개 + ADMIN 6개 + 비로그인 3개 화면 **전부 200** |

`/member/couponView`가 USER 계정으로 200인 것까지 확인 — 3-43 매퍼 수정이 병합 후에도 살아있다. 테스트 계정은 매번 생성 후 삭제(잔여 0건).

### 브랜치 최신화 결과

`main` 트리 해시와 **완전히 동일**: `main` / `BJY_works` / `frontfix` / `Util_branch` / `Start_branch` + 각각의 `origin/*`. 로컬↔원격 16개 브랜치 전부 in sync(ahead/behind 0).

`main`과 다른 채로 남은 브랜치 5개는 **팀원 개인 작업 브랜치와 이미지 전용 브랜치**라 지금 맞출 필요 없음: `JJY_Work`, `JWC_works`, `KGH_works`, `product_images`, `origin/KCH_works`(로컬에 없는 원격 전용). 이 브랜치들엔 3-43 매퍼 수정이 아직 없으므로, **각 담당자가 `main`을 받아가면 자연히 해소된다.**

### 테스트 서버

**`http://192.168.30.24:8797/`** (`#014_260901 [환경구축] main 브랜치 배포 및 테스트 서버 구축`)

배포 반영 확인:

| 항목 | 결과 |
|---|---|
| `/`, `/member/login`, `/member/signUp` | 200 (응답 5~27ms) |
| 3-42 신규 JS 10개 | 전부 200 |
| `style.css`의 SVG 공용 아이콘 클래스 | 6건 확인 |
| 홈 인라인 `<script>` / 글리프 | 0 / 0 |

> **주의: 로컬 개발 서버와 포트가 같다(둘 다 8797).** `localhost:8797` = devtools 붙은 로컬 개발 서버, `192.168.30.24:8797` = 팀 테스트 서버. 헷갈리지 말 것.

### 관리 문서 4종 git 추적 제외 (완료)

`HANDOFF.md` / `PROJECT_AUDIT.md` / `HANDOFF_NEXT_SESSION_PROMPT.txt` / `메종드사조_스타일가이드.pdf` — `a9bdcfa`에 딸려 들어가 `origin/frontfix`까지 올라갔던 것을, **`main`에 올라가기 전에 추적 제외 처리 완료.** 현재 4개 모두 untracked 상태이며 로컬(사용자 관리)에만 존재한다.

- 이 문서들은 원래부터 "git commit 대상 아님"이 원칙이었다(문서 맨 앞 "이 문서를 읽는 법" 참고).
- **재유입 주의**: `.gitignore`에는 아직 등록돼 있지 않다. `git add .` 류를 쓰면 다시 딸려갈 수 있으니 등록해두는 것을 권장.

### 남은 이슈 (배포 상태 기준)

- **`cart` / `wish` 화면이 도달 불가** — `/member/cart`, `/member/wish`, `/cart`, `/wish` **4개 경로 전부 404**. 뷰(JSP/CSS/JS)는 3-42에서 규격화까지 끝나 있는데 `product/cart`·`product/wish`를 반환하는 컨트롤러 메서드가 프로젝트 전체에 0곳이다. **서버 담당자가 다르고 아직 연결 전인 구간이라 사용자가 이미 인지하고 있으며, 테스트 케이스 정리와 함께 구현 요청 예정.** 자세한 경로별 상태는 3-43 참고, 항목은 `PROJECT_AUDIT.md` 버그 16번.
- **화면 육안 확인분**은 3-42의 "화면 확인이 필요한 것" 목록이 그대로 유효하다. 이제 테스트 서버가 떴으니 거기서 확인 가능(단 `userWithdraw`는 라우트가 없어 여전히 못 엶).

### 신규/수정 파일

```
(코드 변경 없음 - 병합/검증/배포만)
```

---

## 3-45. 2026-09-01: 리뷰 삭제 후 재작성 차단 구현 (정책 확정 → 스키마 + 코드 반영)

3-30-11에서 보류했던 정책이 **"삭제하면 그 주문상품엔 영구히 재작성 불가"로 확정**되어 스키마 설계부터 검증까지 진행. `PROJECT_AUDIT.md` 정책 11번이 조치 완료로 닫혔다.

### 설계: 소프트 삭제(원래 선호안) 대신 별도 이력 테이블로 간 이유

정책 11번의 선호안은 방식 1(`REVIEW.IS_DELETED` 소프트 삭제)이었으나 **별도 `REVIEWHISTORY` + 하드 삭제 유지**로 변경했다.

소프트 삭제는 `REVIEW`를 읽는 **모든** 쿼리에 `IS_DELETED='N'`을 빠짐없이 넣어야 하는데, 거기엔 평균 별점/리뷰 개수 집계가 들어간다(`product/detailPage.xml` 2곳, `product/product.xml` 1곳). 이 3곳은 **product 담당자 영역**이고, 한 곳만 빠뜨려도 "삭제된 리뷰가 별점에 계속 잡히는" 부작용이 생긴다 — 정책 11번이 방식 2의 단점으로 지적한 바로 그 문제다. **별도 테이블 방식은 `REVIEW` 행이 실제로 사라지므로 집계 3곳을 안 건드려도 정확하다.**

### 사용자 초안에서 고친 것

초안은 `rhis_id / review_id / member_id` 3컬럼에 **`review_id`를 `Review.review_id`로 FK** 거는 구조였는데, 이러면 목적 달성이 불가능하다:

| FK 동작 | 결과 |
|---|---|
| NO ACTION | `REVIEW` 삭제 자체가 막힘 |
| CASCADE | 이력도 같이 삭제 → **"썼었다"는 기억이 사라짐** |
| SET NULL | 어느 주문상품이었는지 **식별 불가** |

원인은 기억할 대상을 잘못 잡은 것. "review_id N번이 있었다"가 아니라 **"이 회원이 이 `od_id`의 리뷰 권한을 썼다"** 를 기억해야 한다. → **`od_id`에 unique, `review_id`엔 FK 없음**으로 수정. `od_id`는 주문→회원이 유일하게 결정되므로 복합 unique 불필요.

명명은 `PHIST_ID`/`CHIST_ID` 패턴을 따라 **`RHIST_ID`** 가 맞다(초안의 `RHIS_ID`를 그대로 받아썼다가 사용자 지적으로 정정).

### 최종 스키마 (사용자가 직접 `schema.sql` 반영 + 실행)

```sql
CREATE TABLE REVIEWHISTORY (
    RHIST_ID    NUMBER      NOT NULL,
    OD_ID       NUMBER      NOT NULL,
    MEMBER_ID   NUMBER      NOT NULL,
    REVIEW_ID   NUMBER,                       -- FK 아님(하드 삭제 대상). 삭제되면 NULL
    SCORE_FIX   NUMBER,
    WRITTEN_AT  TIMESTAMP   DEFAULT SYSTIMESTAMP NOT NULL,
    DELETED_AT  TIMESTAMP,                    -- NULL이면 아직 살아있는 리뷰
    CONSTRAINT PK_REVIEWHISTORY PRIMARY KEY (RHIST_ID),
    CONSTRAINT UK_RHIST_OD      UNIQUE (OD_ID),          -- ★ 재작성 영구 차단
    CONSTRAINT FK_RHIST_OD      FOREIGN KEY (OD_ID)     REFERENCES ORDERDETAIL(OD_ID),
    CONSTRAINT FK_RHIST_MEMBER  FOREIGN KEY (MEMBER_ID) REFERENCES MEMBER(MEMBER_ID),
    CONSTRAINT CK_RHIST_SCORE   CHECK (SCORE_FIX BETWEEN 1 AND 5)
);
```

- FK 2개에 **CASCADE를 걸지 않았다** — 이력이 같이 지워지면 존재 이유가 사라진다. 회원 탈퇴는 `MEMBER_STATUS=0` 소프트 삭제라 FK가 탈퇴를 막지 않는 것도 확인.
- **기존 리뷰 이관 INSERT를 `schema.sql`에 포함**(REVIEW 시드 뒤, `COMMIT` 앞). 빠지면 기존 리뷰 보유자가 "미작성"으로 판정돼 중복 작성이 열린다.

> **설계 검토 중 같이 잡은 것 2건**
> - `PRODUCTIMAGE.PRODUCT_TITLE_IMAGE`: DBML 주석의 `check IN (1,2,3)`이 실제 DB(`IN (0,1,2)`)와 불일치 → **DB가 맞고 문서가 낡은 것**, 문서만 수정
> - `REVIEWLIKE`에 `(REVIEW_ID, MEMBER_ID)` unique가 **실제로 없었음**(같은 리뷰 중복 추천 가능) → `UK_REVIEWLIKE` 추가(당시 중복 0건)

### 코드 변경

| 파일 | 변경 |
|---|---|
| `mappers/review/ReviewMapper.xml` | `checkReviewExists`를 `REVIEWHISTORY` 기준으로. `insertReviewHistory`/`markReviewHistoryDeleted` 신규 |
| `review/.../ReviewMapper.java` | 위 두 메서드 선언 |
| `review/.../ReviewServiceImpl.java` | `writeReview()`에 이력 기록, `deleteReview()`에 "삭제됨" 표시 |
| `mappers/member/MemberMapper.xml` | 마이페이지 `HAS_REVIEW`/리뷰가능 건수 판정을 `REVIEWHISTORY` 기준으로 |

**집계 3곳은 예정대로 변경 없음.** `deleteReview()`는 DELETE 후 이력을 `REVIEW_ID=NULL, DELETED_AT=SYSTIMESTAMP`로 UPDATE한다(FK가 아니라 DELETE 후에도 값으로 조회 가능). 이력이 없는 경우(도입 전 데이터)엔 삭제를 되돌리지 않고 경고 로그만 남긴다.

### 검증

`user01` 계정으로 실제 요청 + DB 확인:

| 시나리오 | 결과 |
|---|---|
| `POST /review/delete/2` | `REVIEW` 행 0개 |
| 삭제 후 이력 | **행 보존**, `review_id=NULL`, `deleted_at` 기록 |
| 리뷰가능 건수 | 삭제 전 0 → 후 **0** (안 늘어남) |
| **삭제 후 작성 화면 / 화면 우회 POST** | **둘 다 302 차단, 리뷰 생성 0건** |
| 미작성 상태에서 작성 | 200 진입 → 성공, **이력 자동 생성** |
| USER 화면 5개 회귀 | 전부 200 |

### ⚠️ 낡은 빌드 산출물이 서버 기동을 막음 (팀 공유 필요)

서버가 안 떠서 추적한 결과, `target/classes/mappers/`에 **소스에 없는 낡은 XML 2개**(`MemberMapper.xml` 루트 위치, `CouponMapper.xml`)가 남아 MyBatis가 함께 로드하다 `Could not resolve type alias 'MyPageWishDTO'`로 실패. 브랜치 이동/병합으로 소스에선 정리됐는데 **`mvnw compile`이 낡은 산출물을 지우지 않아서** 생긴 일. **`./mvnw clean compile`로 해결.**

> 팀원들이 `main`을 받은 뒤 서버가 안 뜨면 십중팔구 같은 원인이다. **브랜치를 크게 오간 뒤엔 `compile`이 아니라 `clean compile`.**

### 테스트 데이터 (사용자 직접 테스트용, **정리 필요**)

`user01`에게 리뷰 미작성 배송완료 주문을 만들어뒀다. `ORDER_ID=7` / `OD_ID=8,9` / `TRACKING_NO='TEST-REVIEW-001'`. 정리는 **`sql/cleanup_review_test_data.sql`** (확인 SELECT → 삭제 → 검증 순).

> **검증 중 발생시킨 데이터 오염과 복구** — curl로 리뷰를 등록했는데 **curl이 한글을 잘못 인코딩**해 본문이 깨져 저장됐고(`DELIVERY.COMPANY`도 동일), 시드 원본 값으로 복구 완료. **jshell도 `.jsh` 파일의 한글을 플랫폼 기본 인코딩으로 읽어 깨뜨린다** — DB에 한글을 넣을 땐 텍스트를 별도 UTF-8 파일에 쓰고 `Files.readString(path, StandardCharsets.UTF_8)`로 읽어 `PreparedStatement`에 바인딩할 것.

### 3-45-1. 사용자 수동 테스트로 드러난 후속 건 3가지

**리뷰 재작성 차단 자체는 "픽스 확인 완료"** 를 받았고, 그 과정에서 3건이 나왔다.

**① [수정 완료] 상품 2건 이상인 주문에서 대표 외 나머지가 리뷰 경로를 잃는 기존 버그** (AUDIT 버그 17번)

주문/배송 화면은 주문 1건당 카드 1개에 리뷰 버튼 1개를 두고 상태를 **대표 주문상세(`OD_ID` 최솟값) 기준**으로만 판정했다. 반면 배지는 `ORDERDETAIL` 전건을 센다. 그래서 상품 2건짜리 주문에서 대표만 리뷰를 쓰면 **버튼은 "완료"로 잠기는데 배지는 "1개"** — 들어갈 경로가 없는 상태가 된다. 이번 리뷰 작업과 무관한 기존 결함이며, 시드 주문이 대부분 상품 1건이라 안 보였을 뿐(테스트용 2건짜리 주문이 드러냄).

**수정**: `selectDeliveriesByMemberId`에 "주문별로 아직 리뷰 안 쓴 주문상세 중 최소 `OD_ID`" 서브쿼리(`nr`)를 추가하고, 리뷰 링크용 `OD_ID`를 **대표가 아니라 그 값**으로, `HAS_REVIEW`를 **그 값이 없을 때만 1**로 변경. `odId`는 리뷰 링크 전용이고 표시용 이름/수량/이미지는 대표(`rep`)가 따로 담당하므로 **JSP는 변경하지 않았다**(DTO 주석 2줄만 갱신).

**② [미수정 — 보류] 빠른메뉴 "리뷰 작성" 타일이 클릭해도 무반응** (AUDIT 버그 18번)

`myPage.jsp:88`이 `href="#"`(주석대로 `/review/write`는 `odId` 필수라 목록 진입점이 없음). 여기에 `placeholderLinks.js`가 상단 점프를 막으면서 완전 무반응이 됐는데, 타일에 `${reviewableCount}` 배지까지 떠서 눌러야 할 것처럼 보인다. 같은 화면의 동작하는 링크(`/member/orderDelivery?status=delivered`)로 보내면 **한 줄로 해결**되지만, **프론트 담당자가 뷰 작업 중이라 JSP 충돌을 피하려고 이번엔 보류.**

**③ [버그 아님] "주문·배송 조회" 배지 기준 확인**

`countActiveDeliveries`는 **"아직 끝나지 않은 주문 건수"** 를 주문 단위로 센다(`ORDER_STATUS != 'CART'` + `DELIVERY_STATUS`가 NULL이거나 `DELIVERED`/`CANCELED`가 아님). 즉 **DELIVERY 행 없음 + 배송준비중 + 배송중 + 배송출발**이 전부 포함. "배송중/배송출발만 세는 것 아니냐"는 확인 요청에 대해 **배송준비중도 포함**이 정답이며, user01 실데이터(3건)가 화면의 "3"과 일치.

### 3-45-2. 전체 죽은 코드/주석 점검

| 점검 | 결과 |
|---|---|
| XML statement ↔ Java 매퍼 메서드 양방향 짝 | 불일치 **0건** |
| 미참조 JS / CSS 파일 | **0건** |
| 호출부 없는 서비스 메서드 | **0건** |
| 미참조 클래스 | **1건 → 삭제** |
| 미사용 import | **3건 → 기록만** |

- **삭제**: `coupon/model/getCouponDTO.java` — Java·XML·JSP 어디서도 참조 0건이고 `@Alias`를 쓰는 매퍼 문도 없는 완전한 죽은 클래스(`1da14ab`에서 유입, 3-35/3-36 coupon 정리 때 누락). 클래스명이 소문자로 시작해 컨벤션에서도 벗어나 있었다.
- **기록만**: `cart` 패키지 미사용 import 3건 — 담당자가 달라 병합 충돌을 피해 손대지 않음(AUDIT 잠재적 위험 19번).
- **죽은 주석 5곳 수정**: 존재하지 않는 CSS(`style_addProduct.css`, `style_admin_mypage.css`)를 가리키던 주석 3곳 — 실제로 지금 헤더 선택자를 재정의하는 CSS가 없음을 확인하고, 방어 규칙은 유지한 채 이유 설명만 현재 구조에 맞게 수정. 부정확한 TODO 2곳(`header.jsp`의 "찜/장바구니 컨트롤러 미구현" → 클래스는 있고 **목록 매핑만 없음**)을 정확한 진단으로 교체. 나머지 TODO 4건은 코드 대조 결과 사실이라 유지.
- **과한 주석 축약**: 이번 세션에 넣은 5줄짜리 설명들을 1~2줄로 정리(상세 근거는 AUDIT 항목 번호 참조로 대체).

### 신규/수정 파일

```
수정:
  sql/schema.sql                                   (사용자 직접 - REVIEWHISTORY, UK_REVIEWLIKE, 이관 INSERT)
  mappers/review/ReviewMapper.xml                  mappers/member/MemberMapper.xml
  review/model/mapper/ReviewMapper.java            review/model/service/ReviewServiceImpl.java
  member/model/dto/MyPageDeliveryDTO.java (주석)    css/style.css (주석)
  webapp/.../common/header.jsp (주석)               webapp/.../member/myPage.jsp (주석)
신규:
  sql/cleanup_review_test_data.sql
삭제:
  java/.../coupon/model/getCouponDTO.java           uploads/product/* (고아 파일 10개, 3-44 정리분)
```

---

## 3-46. 2026-09-01: 카테고리/태그 확정본 반영 SQL 작성 (실행은 사용자)

팀에서 카테고리·태그가 확정되어, 테스트용 임시 데이터를 걷어내고 확정본으로 교체하는 스크립트를 작성했다. **SQL 작성만 했고 DB 실행은 사용자가 직접 한다**(요청사항). 기존 `schema.sql`은 건드리지 않고 **별도 파일**로 만들었다.

### 요구사항

- 테스트용 임시 카테고리(6개)/태그(5개) 제거 → 확정 카테고리 **15개** / 태그 **58개** 등록
- 상품은 이후 관리자 "상품 등록" 화면으로 직접 등록할 예정
- 따라서 **실행 직후 카테고리·태그와 상품 사이 연결이 0건**이어야 함
- 연결이 걸림돌이면 샘플 상품과 **연계 데이터도 전부 정리**

### 삭제 순서를 이렇게 잡은 이유

`schema.sql`의 FK 삭제 규칙상 `PRODUCT`를 그냥 지울 수 없다.

```
PRODUCT 삭제 → PRODUCTIMAGE / CATEGORYDETAIL / TAGDETAIL / OPTIONDETAIL / WISH 는 CASCADE
   ↑ 그런데 OPTIONDETAIL 을 ORDERDETAIL·CART 가 NO ACTION 으로 참조 → CASCADE 가 막힘
        ↑ ORDERDETAIL 은 다시 REVIEW·REVIEWHISTORY 가 NO ACTION 으로 참조
   PRODUCTORDER 는 POINTHISTORY·COUPONHISTORY 가 NO ACTION 으로 참조
```

→ **리뷰 → 주문참조 이력 → 장바구니/찜 → 주문 → 상품 → 카테고리/태그** 순서. 순서를 바꾸면 FK 위반으로 중간에 멈춘다.

### 판단이 들어간 3가지

| 항목 | 결정 | 이유 |
|---|---|---|
| 쿠폰 이력 | **행은 유지, `ORDER_ID`만 NULL 로** | `ISSUE` 행까지 지우면 회원 보유 쿠폰이 날아간다 |
| 포인트 이력 | 주문 연결분 **삭제** (잔액 초기화는 주석 처리) | 주문 단위 이력이라 주문과 함께 정리. 단 **이력만 지우면 `MEMBERPOINT` 잔액과 어긋나므로** 초기화 구문을 주석으로 제공 |
| 시퀀스 초기화 | **주석 처리(선택)** | 안 해도 기능 문제 없음(이어지는 번호 부여). 1번부터 쓰고 싶을 때만 해제 |

`MEMBER`/`GRADE`/`PAYMENT`/`COUPON` 마스터는 유지한다.

### 안전장치

- **0번 블록**: 실행 전 지워질 양을 보는 COUNT 쿼리 (먼저 이것만 돌려보도록 안내)
- **10번 블록**: 실행 후 검증 — `CATEGORY 15` / `TAG 58` / 상품 계열 전부 0 / **카테고리·태그↔상품 연결 0건**

### 데이터 검증

전달받은 원본 목록과 생성된 INSERT 문을 **이름·색상 전부 diff로 대조해 완전 일치** 확인(이름·색상 중복 0건).

> **태그 개수 정정**: 처음 주석에 63개로 적었다가 원본을 세어보니 **58개**였다(6+6+2+6+7+9+6+8+7+1). 파일 주석과 검증 쿼리 모두 58로 수정.

원본의 빈 줄(그룹 구분)은 `-- [가격대] 6개` 식 주석으로 옮겼다. `TAG` 테이블엔 그룹 컬럼이 없어 이름/색상만 저장된다.

### 부수 효과

- **`sql/cleanup_review_test_data.sql`은 실행 불필요해진다** — 이 스크립트가 `PRODUCTORDER`를 전부 지우므로 3-45의 테스트 주문(`ORDER_ID=7`)도 함께 사라진다.
- `uploads/product/`는 3-44에서 고아 파일을 정리해 이미 비어 있고, 남아있던 `PRODUCTIMAGE` 행도 실제 파일 없는 시드 플레이스홀더였다. → **실행 후부터는 DB↔디스크가 실제로 맞아떨어져** `/admin/maintenance` 정합성 검사가 의미 있게 동작한다.

### 같은 시점에 확인한 것: `hero-bg.jpg` 삭제는 안전

커밋 `0b49a2a`가 `static/img/home/hero-bg.jpg`(174KB)를 지웠는데, 3-40에서 배경을 단색으로 원복하며 참조를 이미 걷어냈기 때문에 **코드 내 `img/home`·`hero-bg` 참조가 0건**임을 확인했다. 깨지는 화면 없음.

### 신규 파일

```
sql/reset_category_tag.sql   (268줄, 실행은 사용자)
```

---

## 3-47. 2026-09-01: 리뷰 스키마 재설계 (`REVIEWHISTORY` 폐기 → `REVIEW_STATUS`, 좋아요 일원화)

팀 피드백으로 3-45의 설계가 뒤집혔다. **"단순 리뷰 작성 중복 체크라면 이력 테이블은 과하다 — 컬럼으로 해결하라"**, **"`REVIEWLIKE` 테이블이 있으면 `REVIEW.LIKE_COUNT`는 중복이니 둘 중 하나로 취합하라"**. 사용자가 DBML/`schema.sql`을 직접 수정했고, 이 세션은 **스키마 검토 + 리뷰/멤버 영역 코드 선반영**을 담당했다.

> **역할 분담**: 스키마 수정과 DB 실행은 사용자(팀장)가 직접. product 담당 영역 코드는 담당자가 고쳐서 내일 병합. **DB 최신화는 코드가 다 모인 뒤에** 하기로 정함 — 그래야 런타임 오류 구간이 안 생긴다.

### 확정된 설계

| 항목 | 변경 전 (3-45) | 변경 후 |
|---|---|---|
| 재작성 차단 | `REVIEWHISTORY` 테이블 + `UK_RHIST_OD` | **`REVIEW.REVIEW_STATUS`(0/1) 소프트 삭제 + 기존 `UK_REVIEW(MEMBER_ID, OD_ID)`** |
| 좋아요 수 | `REVIEW.LIKE_COUNT` 컬럼 **와** `REVIEWLIKE` 테이블 (이중 관리) | **`REVIEWLIKE` 테이블로 일원화**, 컬럼 삭제 |

좋아요는 "누가 눌렀는지"(토글·중복방지·`is_liked` 표시)가 필요해서 테이블을 남기는 쪽이 유일하게 성립한다. 기존엔 `ProductServiceImpl.java:104-110`이 토글할 때 컬럼과 테이블을 **각각 갱신**하고 있어서 어긋날 여지도 있었다.

3-45에서 이력 테이블을 택했던 이유(소프트 삭제는 평균 별점/리뷰 수 집계 3곳에 필터를 빠짐없이 넣어야 함)는 그대로 유효하다 — 이제 **우회가 불가능하므로 그 3곳에 `REVIEW_STATUS = 1`을 반드시 넣어야 한다**(전부 product 영역, 아래 전달 목록).

### 사용자 `schema.sql` 수정 검토 결과

방향·문법(`DEFAULT 1 NOT NULL` 순서), `CK_MEMBER_STATUS` 추가, 시드 4건 `REVIEW_STATUS=1` 반영 모두 정상. 아래 3건을 지적했다.

1. **`DROP TABLE REVIEHISTORY`(2행) 오타** — `W`가 빠져 있어, 실 DB에 존재하는 `REVIEWHISTORY`가 스크립트 재실행으로도 **안 지워진다**(`ORA-00942`로 넘어감). 원래부터 있던 오타인데 테이블 정의가 사라진 지금 문제가 됨.
2. **`SEQ_REVIEW_RHIST_ID` 정리 누락** — `DROP SEQUENCE`(54행)/`CREATE SEQUENCE`(82행) 두 줄이 남아, 쓰는 곳 없는 시퀀스가 계속 생성됨.
3. **`reset_category_tag.sql`이 중간에 멈춤** — `REVIEWHISTORY` 참조 4곳, 특히 `DELETE FROM REVIEWHISTORY;`가 삭제 블록 첫 줄이라 테이블이 없으면 거기서 실패. → **이번 세션에서 4곳 모두 제거함**(이 파일은 Claude가 작성한 스크립트라 정리까지 진행).

> **✅ 3건 모두 조치 완료 (2026-09-01 밤).** 1·2번은 사용자가 직접 `schema.sql`을 정리했다 — 2행 오타를 `DROP TABLE REVIEWHISTORY`로 수정, 82행 `CREATE SEQUENCE`는 삭제하고 **54행 `DROP SEQUENCE`는 일부러 남겼다**(실 DB에 시퀀스가 살아 있어 내일 이 줄이 지워야 한다). 3번은 이 세션에서 `reset_category_tag.sql`의 `REVIEWHISTORY` 참조 4곳을 제거했다. **다음 세션은 이 3건을 다시 지적하지 말 것.**

참고로 함께 전달한 것: **시드 좋아요가 전부 0이 된다**(옛 시드는 `LIKE_COUNT`에 5·2를 박아뒀는데 `INSERT INTO REVIEWLIKE`는 0건 — 유지하려면 추가 필요, 시드 회원이 3명이라 5는 재현 불가) / `schema.sql` 재실행은 3-46 결과물을 초기화하므로 **`schema.sql` → `reset_category_tag.sql` 순서**로 돌려야 함 / DBML 문서에 `ReviewHistory` 정의와 `Ref` 2줄이 아직 남아 있음 / `REVIEW.VIEW_COUNT`는 리뷰 도메인 java·xml·jsp 전수 grep 0건인 죽은 컬럼.

### 코드 반영 (리뷰/멤버 영역만)

| 파일 | 변경 |
|---|---|
| `mappers/review/ReviewMapper.xml` | `checkReviewExists`를 `REVIEW` 기준으로(**`REVIEW_STATUS`는 일부러 안 봄** — 삭제해도 행이 남아 차단 유지) / `insertReviewHistory`·`markReviewHistoryDeleted` 삭제 / `selectMyReviews`의 `r.LIKE_COUNT` → `REVIEWLIKE` 서브쿼리, `AND r.REVIEW_STATUS = 1` 추가 / `countMyReviews`에 같은 필터 / `deleteReview`를 `DELETE` → `UPDATE ... REVIEW_STATUS = 0` / `deleteReviewImagesByReviewId`·`deleteReviewLikesByReviewId` 신설 |
| `review/model/mapper/ReviewMapper.java` | 이력 메서드 2개 제거, 삭제용 메서드 2개 추가 |
| `review/model/service/ReviewServiceImpl.java` | `writeReview()`의 이력 기록 제거 / `deleteReview()`가 소프트 삭제 후 이미지·좋아요 행을 직접 삭제 |
| `mappers/member/MemberMapper.xml` | `HAS_REVIEW` 판정과 리뷰가능 건수의 `NOT EXISTS` 2곳을 `REVIEWHISTORY` → `REVIEW`로(여기도 **`REVIEW_STATUS` 무관**) |

**소프트 삭제로 바뀌면서 FK `ON DELETE CASCADE`가 더 이상 안 걸린다** — `REVIEWIMAGE`/`REVIEWLIKE` 행이 자동으로 안 지워지므로 서비스에서 명시적으로 삭제해 **하드 삭제 시절과 같은 결과**를 유지했다(이미지 파일 삭제 로직은 원래대로).

> **`checkReviewExists`와 `MemberMapper`의 `NOT EXISTS` 2곳은 `REVIEW_STATUS`를 보면 안 된다.** 필터를 넣는 순간 삭제한 주문상세가 "미작성"으로 되살아나 재작성이 열린다. 반대로 **표시·집계 쿼리는 반드시 필터를 넣어야 한다** — 이 구분이 이번 설계의 핵심이다.

### product 담당자 전달 목록 (미수정)

`LIKE_COUNT` 컬럼이 사라지고 `REVIEW_STATUS`가 생기면 아래는 **손대지 않으면 런타임 SQL 오류**다.

| 위치 | 필요한 변경 |
|---|---|
| `product/detailPage.xml:16`(평균별점), `:24`(리뷰 수) | `WHERE`에 `AND R.REVIEW_STATUS = 1` 추가 — **안 넣으면 삭제된 리뷰가 별점에 계속 잡힘** |
| `product/product.xml:19`(목록 평균별점) | 동일 |
| `product/detailPage.xml:102` | `r.LIKE_COUNT` → `(SELECT COUNT(*) FROM REVIEWLIKE rl2 WHERE rl2.REVIEW_ID = r.REVIEW_ID)` |
| `product/detailPage.xml:105`(`getReviewList`) | `WHERE`에 `AND r.REVIEW_STATUS = 1` 추가 |
| `product/detailPage.xml:131`(`updateLikeCount`), `:146`(`updateLikeDiscount`) | statement 삭제 (컬럼이 없어짐) |
| `ProductMapper.java:40-41` | 위 두 메서드 선언 삭제 |
| `ProductServiceImpl.java:104-110` | `updateLikeCount`/`updateLikeDiscount` 호출 제거 — `insertReviewLike`/`deleteReviewLike`만 남기면 됨. 단 반환값(`increase`)으로 on/off를 판정하고 있으니 **`insertReviewLike` 결과만으로 판정하도록 정리 필요** |

### 검증

DB가 아직 옛 스키마(컬럼 `LIKE_COUNT` 있음, `REVIEW_STATUS` 없음)라 **라이브 검증은 내일 DB 최신화 이후에만 가능하다.** 이번 세션에서 가능한 정적 검증만 수행:

| 항목 | 결과 |
|---|---|
| `./mvnw compile` | 통과 |
| 매퍼 XML well-formed (`DocumentBuilder` 파싱) | `ReviewMapper.xml` 12 statement / `MemberMapper.xml` 23 statement 정상 |
| XML statement id ↔ Java 매퍼 메서드 양방향 짝 | 불일치 0건 |
| `REVIEWHISTORY` / `insertReviewHistory` / `markReviewHistoryDeleted` 잔존 참조 | `src/` 전체 0건 |
| 우리 영역에서 `REVIEW`를 읽는 지점 | 4곳 전부 의도대로(표시·집계 2곳은 필터 있음, 권한 판정 2곳은 필터 없음) |

**내일 DB 최신화 후 반드시 확인할 것**: 리뷰 작성 → 삭제 → **재작성 차단**(화면·우회 POST 둘 다), 삭제 후 **마이페이지 리뷰가능 건수가 안 늘어나는지**, 삭제 후 **상품 상세의 평균 별점·리뷰 수에서 빠지는지**(product 수정분 병합 후), 좋아요 토글이 `REVIEWLIKE`만으로 정상 동작하는지.

### 같은 세션에서 처리한 것

- **카테고리 오타 정정** — 확정 목록과 대조해 `주류・주얼리` → **`패션・주얼리`**(`reset_category_tag.sql:148`). 나머지 14개는 순서·표기까지 일치. 이 이름을 참조하는 코드는 이 SQL 한 곳뿐. 실 DB는 내일 스크립트 재실행으로 반영된다.
- **3-46 결과 검증(1단계)** — 실 DB에서 `CATEGORY 15` / `TAG 58`, 상품 계열·연결 전부 0건 확인. `/admin/product/add` 드롭다운도 카테고리 15개 / 태그 58개 정상 렌더. 주요 화면 스모크(USER·ADMIN 10개 경로) 전부 200, 기존 404(`cart`/`wish` 4경로, `/product/search`)만 그대로.
- **브랜치 현황** — `BJY_works`에 프론트 담당자 작업 `85d15f1 #TB011_TC-18`(CSS 3 + JS 4 + JSP 6, `style_user.css` 400줄·`searchProduct.jsp` 192줄)이 PR #66 + `FrontSet_branch` 병합으로 들어와 있다.

### 신규/수정 파일

```
수정:
  sql/schema.sql                                        (사용자 직접 - REVIEW_STATUS 추가/LIKE_COUNT 제거/REVIEWHISTORY 삭제)
  sql/reset_category_tag.sql                            (카테고리 오타 정정 + REVIEWHISTORY 참조 4곳 제거)
  src/main/resources/mappers/review/ReviewMapper.xml
  src/main/resources/mappers/member/MemberMapper.xml
  src/main/java/.../review/model/mapper/ReviewMapper.java
  src/main/java/.../review/model/service/ReviewServiceImpl.java
```

---

## 3-48. 2026-09-01: 상품 등록 - 옵션 1개 고정 → 개수 제한 없이 추가 가능하게 변경

관리자 상품 등록 화면이 **옵션을 딱 1개만 만들 수 있는 구조**여서 옵션이 여러 개인 상품을 등록할 수 없던 것을 해결. 사용자 요청은 프론트였지만, **프론트만 고치면 저장이 안 되는 구간**이라 백엔드까지 함께 작업했다.

### 왜 백엔드까지 건드렸나

조사해보니 **매퍼는 이미 옵션 N개를 넣을 수 있는 상태**였다(`insertProductOption` + `insertOptionDetail`이 각각 1건씩 넣는 단순 구조). 1개로 묶어두고 있던 건 그 위 3개 층이었다:

| 층 | 1개 고정이던 지점 |
|---|---|
| JSP | `옵션명`/`판매가격`/`재고`가 각각 고정 `form-row` 1개씩 |
| JS | `optionNameInput`/`priceInput`/`stockInput` 단일 id를 읽어 FormData에 3개 필드로 append |
| Controller | `@RequestParam String optionName, int price, int stock` |
| Service | `OptionDTO` 1개 생성 → insert 1회 |

### 변경 내용

**전송 형식**: 인덱스 붙은 multipart 파라미터(`options[0].price` 등) 대신 **같은 화면이 이미 쓰고 있는 `tagsJson` 패턴을 그대로 따라 `optionsJson`** 하나로 보낸다.

```
optionsJson = [{"optionName":"기본","price":10000,"stock":5}, ...]
```

| 파일 | 변경 |
|---|---|
| `admin/addProduct.jsp` | 고정 3행 → `#optionList`(빈 컨테이너) + `#addOptionButton`("＋ 옵션 추가") 한 덩어리로 교체. 행 자체는 JS가 그린다 |
| `js/views/addProduct.js` | `createOptionRow()`/`addOptionRow()`/`updateOptionRows()`/`collectOptions()` 신설. 삭제 버튼은 기존 `CLOSE_ICON_SVG`+`.tag-remove` 재사용. **행이 1개만 남으면 삭제 버튼을 감춰** 최소 1개를 보장. 등록 시 `optionsJson`으로 직렬화 |
| `css/style_admin.css` | `.option-area`/`.option-list`/`.option-row`/`.option-field`/`.option-row-index` 신설. **전부 `.product-register`로 스코프**(주변 기존 규칙들은 스코프가 없지만, 신규분만이라도 3-5/3-6 재발을 막기 위해) |
| `AdminProductController` | 파라미터 3개 → `optionsJson` 1개 |
| `AdminProductService`(+`Impl`) | 시그니처 변경 + `parseOptions()` 신설. 파싱·검증 후 **옵션 1건마다 `PRODUCTOPTION` + `OPTIONDETAIL` 1건씩** insert |

**행 번호 배지(`.option-row-index`)를 넣은 이유**: 검증 실패 메시지가 "옵션 2의 판매가격을 입력해 주세요." 형태라, 화면에 같은 번호가 보이지 않으면 어느 행이 문제인지 찾을 수 없다. 중간 행을 지워도 1,2,3...으로 다시 매긴다.

### 검증 규칙 (프론트·서버 양쪽)

옵션명 필수 / 가격·재고 필수 + 0 이상 / **최소 1개** / **같은 상품 안에서 옵션명 중복 금지**(구매 화면에서 서로 구분이 안 되므로). 서버는 화면을 우회한 호출도 막도록 같은 규칙을 `parseOptions()`에서 다시 검사한다. 옵션 검증은 **파일을 쓰기 전에** 끝내도록 배치했다.

### 라이브 검증

사용자 서버(IDE 기동, 8797)에는 이 빌드가 안 붙으므로 **별도 포트 8798로 두 번째 인스턴스를 띄워** 실제 요청으로 확인하고 종료했다(8797은 그대로 200 유지 확인).

| 시나리오 | 결과 |
|---|---|
| 옵션 3개(Basic/Large/Gift Set) 등록 | 성공 — `PRODUCTOPTION` 3건 + `OPTIONDETAIL` 3건이 같은 상품에 정상 연결, 가격·재고 각각 저장 |
| `optionsJson` 누락 / 빈 배열 | "옵션을 최소 1개 이상 등록해 주세요." |
| 옵션명 중복 | "옵션명이 중복됩니다: Basic" |
| 옵션명 공백 / 가격 음수 / 재고 음수 | 각각 정확한 메시지로 거부 |
| 깨진 JSON | "옵션 정보가 올바르지 않습니다." |
| 실패 7건 후 orphan | **파일 0건** — 커밋 후 디스크 쓰기(`saveOnCommit`) 구조가 그대로 동작 |
| 렌더링 | `#optionList`/`#addOptionButton` 정상, 옛 id(`optionNameInput` 등) 잔존 0건 |

**테스트 데이터 정리 완료**: 등록했던 상품(`PRODUCT_ID=6`)과 옵션 3건(`OPTION_ID=14,15,16`)을 id 기준으로 삭제, 업로드 파일 2개 삭제. 정리 후 `PRODUCT`/`PRODUCTOPTION`/`OPTIONDETAIL`/`PRODUCTIMAGE`/`CATEGORYDETAIL`/`TAGDETAIL` 전부 0건, `CATEGORY 15`/`TAG 58` 그대로인 것 확인.

> **`PRODUCT` 삭제 시 `PRODUCTOPTION`은 CASCADE로 안 지워진다** — `OPTIONDETAIL`만 CASCADE라 옵션 행은 남는다. 상품을 지울 일이 생기면 옵션도 같이 지워야 고아가 안 생긴다(이번 정리에서 확인).

### 3-48-1. 화면 확인 후 수정: 옵션이 1개일 때도 삭제 버튼이 보이고 눌리던 것

사용자 화면 확인 결과, 행이 1개뿐인데도 `×`가 그대로 보이고 클릭하면 삭제까지 됐다.

- **원인**: `updateOptionRows()`가 `removeButton.hidden = true`로 감추는데, 재사용한 `.tag-remove`가 `display:flex`를 갖고 있어서 **브라우저 기본 `[hidden]{display:none}`(작성자 CSS보다 우선순위가 낮다)이 밀렸다.** 속성은 켜졌지만 그려지긴 계속 그려진 것.
- **수정**: `.product-register .option-remove[hidden]{display:none}` 규칙을 명시적으로 추가(명시도 `(0,2,0)` > `.tag-remove` `(0,1,0)`). 더불어 클릭 핸들러에도 **행이 1개 이하면 무시**하는 방어를 넣어 스타일이 다시 밀리더라도 마지막 행은 안 지워지게 했다.

> `hidden` 속성으로 요소를 감출 때, 그 요소가 `display`를 지정하는 클래스를 쓰고 있으면 항상 이 함정에 걸린다. 3-38-10의 `a:visited` 건과 같은 계열(작성자 CSS vs 기본 동작의 우선순위) 문제.

### 화면 확인이 필요한 것 (사용자만 가능)

브라우저가 없어 **JS 동작과 픽셀 결과는 확인 못 했다.** 서버 왕복은 curl로 검증했지만 아래는 눈으로 봐야 한다:

1. **"＋ 옵션 추가" 클릭 시 행이 늘어나는지**, 삭제 버튼으로 지워지는지, 1개만 남으면 삭제 버튼이 사라지는지
2. **행 정렬** — 번호 배지(22px)와 삭제 버튼(25px)을 입력칸(38px) 높이 가운데에 맞추려고 `margin-bottom:9px`/`7px`을 줬는데 **근사치다**(`⚠️ 근사치라 화면 확인 필요` 주석 있음)
3. 좁은 폭에서 행이 줄바꿈(`flex-wrap`)될 때 모양

### 부수 확인

`HANDOFF_NEXT_SESSION_PROMPT.txt`의 "pdftotext / jshell / node 는 있음"에서 **`node`는 실제로 없다**(Git Bash·PowerShell 양쪽 PATH 모두 없음). 그래서 이번에 JS 문법 검사를 못 했고 괄호 균형 확인 + 코드 리뷰로 대체했다. 부록 A에도 기록해둠.

### 신규/수정 파일

```
수정:
  src/main/webapp/WEB-INF/views/admin/addProduct.jsp
  src/main/resources/static/js/views/addProduct.js
  src/main/resources/static/css/style_admin.css
  src/main/java/.../admin/controller/AdminProductController.java
  src/main/java/.../admin/model/service/AdminProductService.java
  src/main/java/.../admin/model/service/AdminProductServiceImpl.java
```

---

## 3-49. 2026-09-01: 리뷰 작성 페이지 규격 통일 ("혼자만 다르고 고쳐도 안 바뀌던" 원인)

프론트 담당자가 **"이 페이지만 규격이 다르고, 아무리 고쳐도 안 바뀐다"** 며 넘긴 건. 원인은 3가지가 겹쳐 있었다.

### 원인

| # | 문제 | 결과 |
|---|---|---|
| 1 | **페이지 wrapper가 없고 `#review-form`(ID)이 컨테이너 역할** | 다른 페이지는 `.my-reviews-page`/`.order-delivery-page` 처럼 클래스 wrapper를 쓰는데 이 페이지만 ID. **나중에 클래스 선택자로 뭘 덮어써도 ID(0,1,0,0)한테 밀린다** — "고쳐도 안 바뀐다"의 주원인 |
| 2 | **`body`에 직접 글꼴/색/크기를 지정** | `body.review-write-hero{color; font-family:Pretendard; font-size:16px; line-height:1.6}` — 이 페이지에서만 **헤더·푸터까지** 다른 톤이 됐다. 사이트 토큰(`--gsf-*`)을 바꿔도 이 페이지는 자기 토큰(`--ink`/`--bg-page`/`--font-base`)을 봐서 반응하지 않았다 |
| 3 | **스코프 없는 선택자가 사이트 전역으로 샘** | `*{}`, `h2{}`, `.subtitle{}`, `.product-price{}`, `button:focus-visible/input/textarea/label:focus-within{}`, `@media`의 `:root{}`·`*{}` — HANDOFF 3-5/3-6과 같은 계열. 3-37에서 `body{}`/`:root{}`만 잡고 나머지는 남아 있었다 |

`.product-price`는 **홈 상품카드(402행)와 리뷰 페이지(3341행)에 각각 스코프 없이 정의**돼 있어 나중 것이 이기는 상태였다(지금은 프론트 담당자가 홈 카드에서 가격을 빼서 실제 충돌은 없었지만, 되돌아오면 바로 터질 지뢰였다).

### 조치

- **`.review-write-page`(wrapper) + `.page-content`(카드) 2단 구조로 변경** — `.my-reviews-page`와 동일한 형태. JSP에 wrapper div 추가, `<form id="review-form">`에 `class="page-content"` 부여(id는 JS가 계속 쓰므로 유지).
- **블록 전체(419줄)를 `.review-write-page` 아래로 스코프** — 선택자 50개. 브레이스 깊이를 추적하는 스크립트로 일괄 변환한 뒤 diff 전수 검토.
- **토큰 선언을 `body.review-write-hero` → `.review-write-page`로 이동** — 구조는 wrapper에, 톤은 body에 걸려 hook이 둘로 갈려 있었다. `header.jsp`의 경로 매칭(`/review/write`)이 어긋나면 톤만 통째로 사라지는 구조였음. 이제 wrapper 하나에 같이 붙어 다닌다.
- **`body`에 걸려 있던 글꼴/색/배경을 wrapper로 이동** — 헤더·푸터가 이 페이지에서만 달라 보이던 것 해소.
- **중복 `*{box-sizing:border-box}` 삭제** — `default.css:24`에 이미 전역으로 있어 불필요했다.

### 전역 leak 제거의 영향 (확인 결과: 사실상 없음)

지웠던 `h2{font-size:30px;font-weight:700;letter-spacing:-.02em}`가 다른 페이지에 영향을 주는지 전수 확인했다. **`<h2>`를 쓰는 JSP 15개 전부 이미 자기 스코프 규칙을 갖고 있어**(클래스 선택자가 태그 선택자를 이기므로) 이 규칙은 애초에 적용되지 않고 있었다.

| 페이지 | 실제로 적용되던 규칙 |
|---|---|
| `myPage` / `adminPage` | `.member-mypage-page .section-title` / `.admin-mypage-page .section-title` |
| `cart` | `.cart-container .page-title` |
| `orderComplete` | `#ShareLink h2` |
| `searchProduct` | `.sp-sidebar-banner .banner-content h2` |
| `home` | `.section-header h2` |
| `login` / `signUp` | `.auth-visual-inner h2` |
| `footer` | `.site-footer .company-info .footer-brand` |
| `addProduct` 등 admin | `.section-title h2` |

`button:focus-visible` 등의 `outline: 2px solid var(--bronze)`도 **페이지 밖에선 `--bronze`가 정의되지 않아 선언 자체가 무효**였다(적용되던 건 `outline-offset:2px` 뿐). `*{box-sizing}`은 `default.css`와 동일값.

### 검증

`clean compile` 통과. 임시 라우트(`/dev/review-preview`)로 별도 포트(8798) 인스턴스를 띄워 렌더링 확인 후 **컨트롤러 파일 삭제 + `clean compile`로 빌드 산출물에도 안 남은 것까지 확인**(소스·`target/classes` 모두 0건).

| 항목 | 결과 |
|---|---|
| 리뷰 작성 페이지 렌더 | 200, `.review-write-page` / `.page-content` 정상 출력 |
| 서빙되는 `style_user.css` | `.review-write-page` 규칙 50개 포함, **전역 leak 0건** |
| 스모크(admin 로그인) | `/`, `login`, `signUp`, `myPage`, `admin/product/add`, `admin/order`, `admin/coupon`, `admin/maintenance` **전부 200** |
| CSS 중괄호 균형 | 677/677 |
| 사용자 서버(8797) | 영향 없음, 200 유지 |

### 화면 확인이 필요한 것 (사용자만 가능)

1. **리뷰 작성 페이지 전체** — 폭·여백·배경이 그대로인지. wrapper가 `min-height:100vh` + 배경, `.page-content`가 폭/테두리를 맡는 구조로 바뀌었다
2. **이 페이지의 헤더·푸터** — 이제 사이트 공통 글꼴/색을 쓴다(예전엔 Pretendard 16px + `--ink`). **의도적으로 바꾼 부분이라 어색하면 알려줄 것**
3. 다른 페이지의 `<h2>` — 위 표대로라면 안 변해야 정상. 혹시 변한 곳이 있으면 그 페이지에 스코프 규칙이 없다는 뜻

> **남은 규격 이슈**: 이 페이지는 여전히 자체 토큰(`--ink`/`--muted`/`--line`/`--font-base` 등)과 Pretendard 글꼴을 쓴다. 구조 규격은 맞췄지만 **시각 규격(`--gsf-*` 토큰으로 통일)은 아직**이다. 값이 바뀌면 화면이 눈에 띄게 달라져서 확인이 필요한 작업이라 이번엔 손대지 않았다.

### 3-49-1. 화면 확인 후 수정: 콘텐츠 좌측 쏠림 + 메인페이지와 색감 통일

**① 콘텐츠가 왼쪽으로 쏠림 (기존부터 있던 문제)**

`.page-content`는 `--page-max: 1200px`인데 그 안의 섹션들은 `max-width: var(--content-max)`(760px)라서, flex column 기본 정렬 때문에 왼쪽에 붙고 오른쪽에 360px이 비어 있었다(화면상 콘텐츠/카드 비율 68%가 계산과 일치). **규격 통일 작업으로 생긴 게 아니라 `#review-form` 시절부터 있던 상태.** `.review-hero`와 섹션 4종 그룹에 `margin: 0 auto`를 줘서 가운데로 맞춤.

> 참고로 남겨둔 선택지: `--page-max`를 840px(콘텐츠 760 + gutter 40×2)로 줄이면 카드가 콘텐츠를 감싸는 형태가 되어 `.my-reviews-page`(카드 800px)와 더 비슷해진다. 사용자 확인 결과 현재 상태로 유지.

**② 메인페이지와 색감 통일 (사용자 지시)**

홈 카테고리 아이콘이 쓰는 2톤과 홈 상품 이미지 표현을 그대로 가져왔다.

| 대상 | 변경 전 | 변경 후 |
|---|---|---|
| 상품 카드(`.review-product-card`) | `--papaya` `#faedcd` | **`--gsf-peach-pale`** — 홈 카테고리 "노란 계열" 아이콘 배경 |
| 사진 추가 박스(`.upload-box-btn`) | `--beige` `#e9edc9` | **`--gsf-sage-pale`** — 홈 카테고리 "초록 계열" 아이콘 배경 |
| 상품 썸네일(`.product-thumbnail`) | `--cornsilk` 단색 | **`linear-gradient(135deg, --gsf-peach, --gsf-sage-light)`** — 홈 `.product-img`와 동일 |
| 업로드 사진 타일(`.photo-preview-list li`) | `--papaya` | 위와 동일한 그라데이션 |

hover는 원래도 `--sage`(= `--gsf-sage`)라 홈 카테고리 hover와 이미 같았다.

**부수 정리**: 이 변경으로 `--papaya`/`--beige`/`--cornsilk` 사용처가 0이 되어 토큰 선언에서 삭제(그대로 두면 "이 페이지 전용 팔레트"로 오해될 수 있음). 남은 페이지 전용 토큰은 `--ink`/`--muted`/`--line`/`--danger`/`--bg-page`/`--font-base`/폭 3종 + `--sage`/`--bronze`(둘 다 `--gsf-*` 참조). **시각 규격 통일이 한 걸음 더 진행된 셈** — 남은 건 본문 색(`--ink`)과 글꼴(Pretendard).

### 신규/수정 파일

```
수정:
  src/main/webapp/WEB-INF/views/review/addReview.jsp   (wrapper div + form에 page-content 클래스)
  src/main/resources/static/css/style_user.css         (리뷰 작성 블록 419줄 전면 스코프 + 구조 개편)
```

---

## 3-50. 2026-09-01: 전 페이지 공통 - 콘텐츠가 짧을 때 카드 아래 생기던 빈 띠 제거

사용자 지적: **뷰포트보다 콘텐츠가 짧으면 카드가 콘텐츠 높이에서 끊기고 그 아래 푸터까지 어색한 공백이 남는다.** 홈·리뷰 작성 등 여러 화면에서 동일하게 발생하는 공통 문제였다.

### 원인 (두 겹)

`header.jsp`가 `<main>`을 열고 `footer.jsp`가 닫는 구조이고, `style.css`에 이미 `main{flex:1 0 auto}`가 있어 **`<main>`은 남는 높이를 이미 다 차지하고 있었다.** 그런데,

1. **각 페이지 wrapper가 `min-height:100vh`를 또 걸고 있었다** — `body{min-height:100vh; padding-top:69px}` 위에 겹쳐져 **페이지가 항상 `69px + 푸터`만큼 길어졌다**(콘텐츠가 짧아도 늘 스크롤이 생기던 원인).
2. **높이를 채우는 건 wrapper뿐이고 그 안의 카드**(배경·좌우 보더를 가진 박스)**는 콘텐츠 높이 그대로였다** — 카드가 끝난 자리부터 푸터까지 wrapper 배경만 남아 "잘린 카드 + 빈 띠"로 보였다.

> `style_admin.css`의 `.product-register` 주석에 이미 1번과 같은 진단이 적혀 있었다(*"여기서 또 100vh를 강제하면 페이지가 불필요하게 길어지고 잘려 보이는 원인이 됨"*). 한 페이지에서 발견하고 전체엔 적용되지 않은 상태였다.

### 조치 (`style.css` 한 곳에 집중)

- `main`을 **세로 flex 컨테이너**로 변경(`display:flex; flex-direction:column`) — 자식이 페이지당 블록 하나씩이라 배치 결과는 동일.
- **최상위 wrapper 21종 + 홈 `#product`에 `flex:1 0 auto`** — main의 남는 높이를 이어받는다.
- **wrapper 안에 카드가 따로 있는 10개 페이지**는 wrapper도 세로 flex로 만들고 카드에 `flex:1 0 auto`를 줘서 **카드가 푸터까지 이어지게** 함.
- **wrapper의 중복 `min-height:100vh` 10곳 전부 제거**(`style_user.css` 5 + `style_admin.css` 5).

### 판단이 들어간 3가지

| 항목 | 결정 | 이유 |
|---|---|---|
| 대상 선택자 | **목록을 명시** (`:last-child` 같은 위치 기반 X) | JSP들이 `</main>` 직전에 `<script>`를 두기 때문에 main의 마지막 자식이 스크립트인 경우가 많아 위치 선택자가 안 맞는다 |
| `main:has(.update-page)` / `(.cart-container)` / `(.wishlist-container)` / `(.search-result-page)` / `(.withdraw-page)` 페이지 | **대상에서 제외** | 이 페이지들은 **`main` 자체가 카드**라 `main{flex:1 0 auto}`로 이미 높이를 채우고 있었다 |
| `.auth-shell`(로그인/회원가입) | **제외** | 화면 가운데 떠 있는 카드가 의도된 디자인. 늘리면 전체 높이로 퍼져 디자인이 깨진다 |

가로 정렬이 깨질 위험도 미리 확인했다 — **카드 10개가 전부 `width` + `margin:0 auto`** 라서, wrapper가 flex로 바뀌어도 auto 마진이 그대로 가운데 정렬을 유지한다(flex에서도 auto 마진은 동작).

### 검증

`compile` 통과, 중괄호 균형 유지(`style.css` 56/56, `style_user.css` 677/677, `style_admin.css` 317/317). 서빙되는 `style.css`에 fill 규칙 30개 셀렉터 반영, `style_user.css`의 `min-height:100vh` 0건 확인. 스모크(admin 로그인) 9개 경로 전부 200.

**화면 확인 필요(사용자만 가능)**: 25개 페이지 전부가 대상이라 육안 확인이 필요하다. 특히 (1) 카드가 푸터까지 이어지는지 (2) 콘텐츠가 짧은 화면에서 불필요한 스크롤이 사라졌는지 (3) 카드의 가로 위치·폭이 그대로인지.

### 신규/수정 파일

```
수정:
  src/main/resources/static/css/style.css        (main 세로 flex + wrapper/카드 fill 규칙 신설)
  src/main/resources/static/css/style_user.css   (wrapper min-height:100vh 5곳 제거)
  src/main/resources/static/css/style_admin.css  (wrapper min-height:100vh 5곳 제거)
```

---

## 3-51. 2026-09-01: 뒤로가기로 돌아왔을 때 클릭 잔상이 남는 문제

사용자 지적: 관리자 마이페이지에서 타일을 눌러 이동한 뒤 **뒤로가기로 돌아오면 눌렀던 타일이 계속 강조된 채로 남는다.** 일부 화면에서만 발생(쿠폰 등록에선 없음).

### 원인

**`:focus`에 hover와 같은 강조를 준 것**이 원인이다.

```css
.admin-mypage-page .quick-menu-tile:hover,
.admin-mypage-page .quick-menu-tile:focus { background-color: #fbf8f2; ... }
```

브라우저는 뒤로가기로 페이지를 복원할 때 **직전에 포커스였던 요소로 포커스를 되돌린다.** 클릭한 링크가 그 요소이므로 `:focus`가 계속 맞아 강조가 그대로 남는다. 쿠폰 등록 화면엔 이런 "hover 같은 `:focus`"가 없어서 증상이 없었다.

### 조치: `:focus` → `:focus-visible`

`:focus-visible`은 **브라우저가 포커스 링을 보여줄 만하다고 판단할 때만**(키보드 Tab 이동 등) 맞는다. 마우스 클릭으로 생긴 포커스에는 안 맞으므로 잔상이 사라지고, **키보드 접근성은 그대로 유지된다.**

전수 조사 후 "클릭 요소에 hover 같은 강조를 주는" 7곳을 바꿨다.

| 파일 | 대상 |
|---|---|
| `style_admin.css` | `.admin-mypage-page`의 `.quick-menu-tile`, `.list-row` |
| `style_user.css` | `.member-mypage-page`의 `.quick-menu-tile`, `.list-row` / `#product-list .product-rating`(홈 별점 링크) / `.info-edit-header`(회원정보 아코디언) / `.btn-save-field` |

**폼 입력(`input`/`select`/`textarea`)의 `:focus`는 그대로 뒀다** — 입력 중인 칸이 강조되는 건 의도된 동작이고, 잔상 문제와 무관하다.

**앵커(`<a>`)는 밑줄이 별도 문제였다.** `default.css:21`의 전역 `a:hover, a:focus, a:active { text-decoration: underline }` 때문에, 배경 강조만 `:focus-visible`로 옮기면 이번엔 클릭 후 **밑줄**이 남는다. 처음엔 앵커 5곳에 개별 규칙을 넣었으나, 아래 3-51-1에서 전역 한 줄로 대체했다.

### 3-51-1. `default.css` 대신 명시도로 처리 (사용자 지시)

위에서 "`default.css:21`의 전역 `a:focus` 밑줄은 남아 있다"고 적었는데, 사용자 확인: **`default.css`는 다른 팀도 함께 쓰는 공통 규약이라 절대 수정 금지.** 대신 우선도(명시도)를 높여 처리하기로 함.

`style.css`에 규칙 하나를 추가했다.

```css
a:focus:not(:focus-visible) {
    text-decoration: none;
}
```

- **`:focus:not(:focus-visible)`** = "포커스는 있지만 브라우저가 포커스 링을 보여줄 상황은 아닌 경우" = **마우스 클릭으로 생긴 포커스**. 뒤로가기로 돌아왔을 때가 정확히 여기에 해당한다.
- 명시도 **`(0,2,1)` > `default.css`의 `a:focus` `(0,1,1)`** — `:not()`은 인자의 명시도를 그대로 갖는다. 파일 로드 순서와 무관하게 이긴다.
- **키보드 Tab 이동(`:focus-visible`)과 마우스 hover의 밑줄은 그대로** 유지되므로 접근성 손실이 없다.

이 규칙 하나가 사이트 전체 링크를 커버하므로, 3-51에서 앵커 5곳에 개별로 넣었던 `:focus { text-decoration: none }` 3블록은 **중복이 되어 삭제**했다. `default.css`는 diff 0건인 것을 확인했다.

### 검증

`compile` 통과, 중괄호 균형 유지(`style.css` 58/58, `style_user.css` 677/677, `style_admin.css` 317/317). 서빙되는 CSS에 `focus-visible`과 `a:focus:not(:focus-visible)` 반영 확인, 주요 화면 200. **`default.css`는 diff 0건** 확인. **실제 "클릭 → 뒤로가기" 동작 확인은 브라우저가 필요해 사용자 몫.**

### 신규/수정 파일

```
수정:
  src/main/resources/static/css/style.css        (a:focus:not(:focus-visible) 전역 규칙 신설 - 3-51-1)
  src/main/resources/static/css/style_user.css   (:focus → :focus-visible 5곳)
  src/main/resources/static/css/style_admin.css  (:focus → :focus-visible 2곳)
```

---

## 3-52. 2026-09-01: 문서·주석 최신화 및 정리

이번 세션(3-47~3-51)에서 코드가 크게 바뀌면서 낡거나 과해진 주석·문서를 정리한 세션. **동작 변경은 없다.**

### 낡은 주석 수정 (실제 코드와 어긋난 것)

| 위치 | 무엇이 틀렸나 |
|---|---|
| `AdminProductMapper.java:25` | "**기본 옵션**(가격/재고) 등록"이라고 적혀 있었으나 3-48 이후 옵션 N개를 반복 등록한다 → "옵션 1건 등록 + 상품-옵션 연결, 여러 개면 반복 호출"로 정정 |
| `OptionDTO.java` | "admin 상품 등록도 **기본 옵션 1개**를 만드는데…"가 동일하게 낡음 → "옵션 개수만큼 반복" + `optionId`는 selectKey, `popId`는 별도 insert가 채운다는 설명으로 교체 |
| `style_admin.css` `.quick-menu-tile` 주석 | 밑줄 차단을 "아래에서 `:focus`로 따로 막아둔다"고 했는데 3-51-1에서 `style.css` 전역 규칙으로 옮겨감 → 참조 위치 정정 |

> `product/detailPage.xml`의 `LIKE_COUNT` 3곳은 **일부러 그대로 뒀다** — product 담당자에게 넘긴 수정 목록(3-47)에 포함된 항목이라, 여기서 고치면 병합 때 충돌한다.

### 과한 주석 축약 (3-45-2에서 세운 관례 적용)

이번 세션에 넣은 설명형 주석이 길어져서, **"상세 근거는 HANDOFF 섹션 번호로 참조"** 원칙에 맞춰 줄였다.

| 위치 | 변화 |
|---|---|
| `style.css` 빈 띠 규칙 | 18줄 → 5줄 (3-50 참조) |
| `style.css` `a:focus:not(:focus-visible)` | 13줄 → 5줄 (3-51 참조) |
| `style_user.css` 리뷰 작성 블록 배너 | 14줄 → 8줄 (3-49 참조) |
| `style_user.css` 리뷰 토큰 선언 | 7줄 → 5줄 (3-49-1 참조) |
| `style_admin.css` `:focus-visible` / OPTION 섹션 / `[hidden]` | 각각 4→2, 5→4, 3→2줄 |
| `views/addProduct.js` 옵션 섹션 헤더 | 6줄 → 4줄 |
| `addProduct.jsp` 옵션 마크업 주석 | 3줄 → 2줄 |

### 문서 정리

- `HANDOFF.md`: "지금 상태 요약"의 진행 중인 작업·미커밋 변경(17개 파일)·다음 단계를 오늘 결과로 교체, 목차에 3-47~3-52 반영.
- `PROJECT_AUDIT.md`: 현황 요약 수치 갱신, **잠재적 위험 20번의 실측치 정정**(약 90개 → 실제 102개, `body{}`/`main{}`은 0건 유지), **21번 신규 추가**(클릭 잔상 트랩).
- `HANDOFF_NEXT_SESSION_PROMPT.txt`: 카테고리/태그 단계 기준이던 내용을 오늘 상태(리뷰 스키마 대기 + 프론트 규격화 진행)로 전면 재작성.

### 검증

`compile` 통과, 중괄호 균형 유지(`style.css` 58/58, `style_user.css` 675/675, `style_admin.css` 317/317), `addProduct.js` 괄호 균형 유지. 주요 화면 7개 200. 규격 지표 재측정: **인라인 `<script>` 0/25**, **글리프 아이콘 0**(남은 4건은 전부 "SVG로 바꿨다"는 설명 주석 안의 문자).

### 신규/수정 파일

```
수정(주석만):
  java/.../admin/model/mapper/AdminProductMapper.java   java/.../product/model/dto/detail/OptionDTO.java
  css/style.css   css/style_user.css   css/style_admin.css
  js/views/addProduct.js   webapp/.../admin/addProduct.jsp
문서:
  HANDOFF.md   PROJECT_AUDIT.md   HANDOFF_NEXT_SESSION_PROMPT.txt
```

---

## 3-53. 2026-09-02: DB 최신화 실행 완료 + 상품 60건 일괄 등록 사전 점검

작업 환경이 집 → 외부로 바뀐 뒤 이어받은 세션. **DB 실행은 사용자가 직접 했고**, Claude는 결과 검증과 사전 점검을 맡았다.

### 진행된 것 (사용자 직접)

3-47이 정한 순서 `(1) product 병합 → (2) schema.sql → (3) reset_category_tag.sql` 중 **(2)(3)을 먼저 실행**했다. product 담당자가 "DB부터 돌린 뒤에 고치고 싶다"고 해서 의도적으로 순서를 바꾼 것이며, **착오가 아니다.**

- `schema.sql` + `reset_category_tag.sql` 2종 실행 → DB 초기화·최신화 완료
- 실행 후 필요 없어진 `DROP` 구문(`REVIEWHISTORY` 테이블 / `SEQ_REVIEW_RHIST_ID` 시퀀스)을 제거하고 커밋·푸시
- 현재 `BJY_works`, 워킹트리 clean, `origin/BJY_works`와 동기화. `FrontSet_branch` PR 준비 중

### DB 검증 결과 — 전부 의도대로

| 항목 | 결과 |
|---|---|
| `REVIEW` 컬럼 | `REVIEW_STATUS` 생성, **`LIKE_COUNT` 제거됨** |
| `REVIEWHISTORY` 테이블 / `SEQ_REVIEW_RHIST_ID` | **둘 다 삭제 확인** (3-47 설계 변경 반영) |
| `CATEGORY` / `TAG` | **15 / 58** — 확정본 정확히 일치 |
| `PRODUCT` / `CATEGORYDETAIL` / `TAGDETAIL` | **0 / 0 / 0** — 상품 등록 대기 상태 |
| `MEMBER` | 2 (유지) |

3-46 스크립트의 의도(상품·연계 데이터 정리 후 카테고리/태그만 확정본으로)가 그대로 달성됐다.

### ⚠️ 현재는 코드 절반만 최신 (의도된 과도기)

`REVIEW_STATUS` 대응이 **member/review 영역에만** 들어가 있고 `product/` 매퍼엔 0건이다. 3-47 "product 담당자 전달 목록" 7건이 전부 미수정 상태:

```
detailPage.xml:102        r.LIKE_COUNT                     ← 컬럼 없음 → ORA-00904
detailPage.xml:131,146    update REVIEW set LIKE_COUNT...  ← 컬럼 없음
detailPage.xml:16,24      평균별점·리뷰수                   ← REVIEW_STATUS 필터 없음
product.xml:19            목록 평균별점                     ← REVIEW_STATUS 필터 없음
ProductMapper.java:40-41  updateLikeCount/updateLikeDiscount 선언
ProductServiceImpl.java:105,108  위 두 메서드 호출
```

**예상 증상**: 상품 상세 진입 시 `ORA-00904: "LIKE_COUNT": invalid identifier`로 500. 지금은 `PRODUCT`가 0건이라 드러나지 않지만 **상품을 등록하는 순간 재현된다.** product 담당자 수정분이 병합돼야 해소된다.

> **PR 시 주의**: 이 상태가 담긴 PR이 product 수정분보다 먼저 병합되면, 그 사이 상품이 등록될 때 상세 화면이 깨진다. PR 설명에 **"product 매퍼 수정분(3-47 전달 목록 7건)과 함께 병합되어야 함"** 을 남길 것.

### 상품 60건 일괄 등록 사전 점검 — 등록 자체는 안전

팀원들이 분담해 admin 화면으로 60건을 등록할 예정이라 등록 경로가 깨진 코드를 타는지 점검했다.

```
GET  /admin/product/add  → 카테고리·태그 드롭다운(AdminProductMapper)   ✅
POST /admin/product/add  → insertProduct / Option / OptionDetail /
                            CategoryDetail / ProductImage / Tag         ✅
                         → ApiResponse(JSON) 반환                       ✅ 리다이렉트 없음
```

- `AdminProductMapper.xml`에 `REVIEW`·`LIKE_COUNT` 참조 **0건** — 깨진 조회 코드와 완전히 분리돼 있다.
- 등록 성공 시 JSON만 돌려주므로 **깨진 상세 화면으로 튀지 않는다.**
- `uploads/product/` 디렉터리가 현재 없지만 `FileUploadUtil`이 `mkdirs()`로 자동 생성하므로 첫 업로드 때 만들어진다.

**분담 작업이라 주의할 점 3가지**

1. **새 태그를 만들면 중복 행이 생길 수 있다** — `TAG_NAME`에 unique 제약이 없고(PK는 `TAG_ID`뿐), 등록 로직이 `findTagByName` → 없으면 `insertTag`인 find-or-create다. 두 사람이 동시에 같은 새 태그를 만들면 **같은 이름의 태그가 2행** 생긴다. → **확정된 58개 중에서만 고르고 "태그 추가"는 쓰지 않기**로 공유하면 위험이 사라진다. 꼭 필요하면 한 사람이 몰아서 할 것.
2. **등록 결과를 확인할 admin 목록 화면이 없다** — `/admin/product` 아래엔 `add`만 있다. 중간 점검이 필요하면 DB로 카운트·중복 확인해야 한다.
3. **업로드 이미지는 git 추적을 유지한다**(사용자 결정) — `main`에 이미지가 함께 올라가야 테스트 서버에서 각 PC로 접속해 확인할 때 문제가 없기 때문. **`.gitignore`에 `uploads/`를 넣지 말 것.**

### product 병합 후 실행할 검증 체크리스트

DB는 이미 최신이므로, product 수정분이 들어오면 아래를 그대로 돌리면 된다. **유저 화면은 반드시 USER 계정으로** (role 분기 때문에 admin으론 증상이 안 보인다).

**A. 리뷰 재작성 차단** (3-47 핵심)

| # | 확인 | 통과 기준 |
|---|---|---|
| A1 | 리뷰 작성 → `REVIEW_STATUS` | `1` |
| A2 | 리뷰 삭제 → 행 상태 | **행 유지 + `REVIEW_STATUS=0`** (하드 삭제 아님) |
| A3 | 삭제 후 작성 화면 재진입 | **차단**(리다이렉트) |
| A4 | 삭제 후 화면 우회 POST 직접 호출 | **차단 + 리뷰 생성 0건** |
| A5 | 삭제 후 마이페이지 "작성 가능한 리뷰" | **안 늘어남** |

**B. 표시·집계에서 삭제 리뷰 제외** (product 병합분 필요)

| # | 확인 | 통과 기준 |
|---|---|---|
| B1 | 상품 상세 평균 별점 | 삭제한 리뷰가 **빠짐** |
| B2 | 상품 상세 리뷰 개수 | 동일 |
| B3 | 상품 목록 평균 별점 | 동일 |
| B4 | "내가 쓴 리뷰" 목록 | 삭제분 안 보임 |

**C. 좋아요 `REVIEWLIKE` 일원화**

| # | 확인 | 통과 기준 |
|---|---|---|
| C1 | 좋아요 토글 | `REVIEWLIKE` 행만 증감, `LIKE_COUNT` 참조 오류 없음 |
| C2 | 상세 화면 좋아요 수 | `REVIEWLIKE` 행 수와 일치 |
| C3 | 같은 사용자 중복 좋아요 | `UK_REVIEWLIKE`로 차단 |

**D. 회귀**

`mvnw clean compile` 통과 / USER·ADMIN 주요 화면 200 / `LIKE_COUNT` 잔존 참조 0건.

> **`REVIEW_STATUS` 필터 규칙(가장 틀리기 쉬운 지점)**
> **표시·집계 쿼리는 `= 1` 필수 / 권한 판정 쿼리는 필터 금지.**
> 권한 판정(`checkReviewExists`, 마이페이지 리뷰가능 건수, 다품목 주문의 `NEXT_OD_ID`)에 필터를 넣으면
> 삭제한 주문상세가 "미작성"으로 되살아나 **재작성이 열린다.**

### 코드 변경

```
(없음 - DB 실행은 사용자, Claude는 검증·점검만)
```

---

## 3-54. 2026-09-02: 마이페이지·관리자 뷰 수정 + 주문 다품목 표시 + 테스트 더미 데이터

3-53에 이어 같은 날 진행. 상품 60건 등록이 돌아가는 동안 **뷰 수정 요청을 순차로 처리**하고, 그 결과를 화면에서 확인할 **테스트용 주문/리뷰 더미 데이터**를 만들었다. DB 실행은 전부 사용자가 직접 했다.

### 3-54-1. `ReviewMapper.xml` 소프트 삭제 복구 (병합 회귀)

3-47에서 `REVIEW_STATUS` 소프트 삭제로 바꿔둔 `deleteReview`가 **병합 과정에서 옛 하드 삭제 버전으로 되돌아가 있었다.** "삭제 쿼리가 상태 변경이어야 하는데 안 바뀌었다"는 제보로 발견.

- 되돌아간 것은 `ReviewMapper.xml` **하나뿐**이고, `99f2e84`는 `selectMyReviews`의 REVIEWLIKE 조인만 건드렸다는 것을 확인.
- 그래서 `git checkout`으로 통째로 되돌리지 않고 **수동 병합** — 소프트 삭제(`UPDATE ... SET REVIEW_STATUS = 0`)와 `selectMyReviews`/`countMyReviews`의 `AND r.REVIEW_STATUS = 1`을 복구하면서 `99f2e84`의 REVIEWLIKE 조인은 그대로 살렸다.
- 사용자가 커밋(`9f37338`)해서 이미 반영됨.

> **교훈**: 병합 후에는 "내가 최근에 바꾼 매퍼 문"이 살아있는지 확인할 것. 컴파일도 통과하고 화면도 뜨기 때문에 **실제로 삭제를 눌러보기 전까지 드러나지 않는다.**

### 3-54-2. 마이페이지 빠른메뉴 "리뷰 작성" 타일 (AUDIT 버그 18번 해소)

`href="#"`라 클릭해도 무반응이던 타일을 조건부 링크로 교체했다. AUDIT 18번이 제안한 "무조건 주문·배송으로" 대신 **아래쪽 "리뷰 작성" 섹션과 같은 기준**으로 맞췄다.

- 쓸 리뷰가 있으면 → `/review/write?odId=<가장 먼저 쓸 주문상세>`
- 없으면 → `/member/orderDelivery?status=delivered`

이를 위해 `selectNextReviewableOdId`를 신설했다. **`countReviewableOrderDetails`와 조건이 완전히 같아야** 배지 숫자와 실제 이동 대상이 어긋나지 않는다(둘 다 `REVIEW_STATUS`를 보지 않음 — 정책 11번).

```
MemberMapper.xml   selectNextReviewableOdId 추가
MemberMapper.java / MemberService / MemberServiceImpl / MemberController   nextReviewableOdId 배선
myPage.jsp         타일 + 하단 .review-cta-badge 가 같은 URL(reviewTileUrl) 재사용
```

### 3-54-3. 관리자 상품 등록 화면 4건 + 서버 길이 검증

| 요청 | 조치 |
|---|---|
| 대표 이미지에 필수 표시 | `<span class="required">*</span>` 추가 (이후 추가 이미지·상품 설명에도 추가) |
| 드롭다운 화살표 위치 | `appearance:none` + 인라인 SVG 배경, `right:14px` |
| 태그 글자 가독성 | 3-54-4 참고 |
| 입력칸 글자수 제한 표시 | `data-maxchars` + `.char-counter` |

**길이 제한을 서버에도 넣었다.** 원래 화면 카운터가 `0 / 2000`이었는데 컬럼이 전부 BYTE 단위라 한글로 채우면 카운터가 여유 있다고 표시한 채 `ORA-12899`가 났다(사용자가 실제로 겪은 "이상한 오류"의 정체).

```
PRODUCT_NAME    VARCHAR2(150)  → 50자
PRODUCT_TITLE   VARCHAR2(200)  → 60자
PRODUCT_CONTENT VARCHAR2(4000) → 1300자
OPTION_NAME     VARCHAR2(100)  → 30자
```

`AdminProductServiceImpl.requireMaxLength()`가 **글자 수(코드 포인트) + UTF-8 바이트 수 이중 검사**를 한다. 글자 수만 보면 이모지(4바이트)로 컬럼을 넘길 수 있기 때문. 화면(`data-maxchars`)과 서버 상수는 **반드시 같은 값**이어야 한다.

라이브 검증: 51자 상품명 → `{"success":false,"message":"상품명은(는) 50자 이내로 입력해 주세요."}`, 31자 옵션명도 동일하게 차단됨.

> **⚠️ 추가 이미지만 검증이 없다** — 필수 표시(`*`)는 붙였지만 화면·서버 어디에도 검사가 없어 안 넣어도 등록된다. 60건 등록 중이라 임의로 막지 않고 보류. 대표 이미지·설명 이미지·상품 설명은 양쪽 다 검증 있음.

### 3-54-4. 태그 글자색 — 흰 테두리 → 명암비 계산

처음에 `-webkit-text-stroke: 2px #fff`로 글자 둘레에 흰 테두리를 둘렀는데 **연한 파스텔 배경에서 흰 halo가 글자를 뭉개서 오히려 더 안 읽혔다**(사용자 지적). 방향 자체가 틀렸다고 판단하고 접근을 바꿨다.

**배경 밝기에 맞춰 글자색을 계산**하도록 변경. 이미 있던 `getContrastColor()`를 밝기 임계값(`> 160`) 대신 **WCAG 상대 휘도 기반 명암비 계산**으로 교체하고, 진한 글자색을 `#4b433d` → `#1f1b18`로 내렸다.

실제 태그 58색으로 검증한 결과:

| | 변경 전 | 변경 후 |
|---|---|---|
| AA(4.5:1) 미달 | 16건 | **3건** |
| 최악 명암비 | 3.19:1 | **4.21:1** |

이후 "60대+(`#975fff`)가 안 보인다"는 추가 지적 → 명암비만 비교하면 진한 글자가 **1.13배**로 간신히 이기는 색이었다. 채도 높은 중간 톤에서 이 계산이 실제 가독성을 과대평가하므로 **편향 상수**를 도입:

```js
const TAG_TEXT_WHITE_BIAS = 1.25;   // 진한 글자가 이 배수 이상 앞서야 채택
```

현재 팔레트의 경계값은 `1.13`(#975fff) → `1.41`(#f15151) → `1.61`(#f0603a) → `1.85`(#a97aff)이라, **1.25는 #975fff·#ee3434만 흰 글자로 넘긴다.** 빨강 계열까지 넘기려면 1.7로 올리면 됨(주석에 적어둠).

JSP가 서버에서 그리는 기존 태그는 배경색만 있으므로, 로드 시 `#existingTagList .product-tag`를 훑어 글자색을 입힌다.

### 3-54-5. ⚠️ 내가 만든 회귀 1건 — CSS 셀렉터 목록 중간 교체

3-54-3의 드롭다운 화살표 작업 때, 원래 이런 규칙이었던 것을

```css
.input-area input,
.input-area select{ ... }
```

`select` 블록만 교체하는 방식으로 고쳤더니 `.input-area input,`이 그대로 남아 **화살표가 `<input>`에도 붙었다.** 상품명·상품 게시글 제목이 드롭다운처럼 보이는 증상으로 드러남.

> **셀렉터가 콤마로 나열된 규칙을 부분 교체하지 말 것.** 주석을 사이에 끼워도 CSS는 콤마 목록을 그대로 이어 붙여 파싱한다. 공통 뼈대 / 개별 규칙으로 **분리**하는 것이 맞다.

### 3-54-6. 글자수 카운터 위치 — 입력칸 아래 → 라벨 아래

카운터를 `.input-area` 안에 두니 그 칸 높이가 `42px → 61px`가 되고, `.form-row`가 `align-items:center`라 **입력칸이 위로 약 10px 밀려 보였다**(여유 공간이 부족해 깨진 것처럼 보임).

- **기본 정보 칸**: 카운터를 `<label>` 안 고정 문구 아래로 이동 → `.input-area`가 다시 `42px`가 되어 **입력칸 위치·크기가 카운터 없던 때와 동일**해짐. 라벨 안에 있으면 한 글자마다 필드 이름이 재낭독되므로 `aria-hidden="true"` 부여.
- **옵션 행**: 라벨과 **같은 줄** 오른쪽(`.option-field-head`)으로 이동 → 옵션명 칸 높이가 판매가격·재고와 같아져 행 아래끝 정렬도 함께 복구.
- **상품 설명(textarea)**: `.textarea-bottom` 별도 줄이라 변경 없음.
- `@media(max-width:700px)`에서 `.form-row`가 세로 배치로 바뀌므로 **절대배치는 쓰지 않았다**(입력칸을 덮게 됨).

`updateCharCounter`는 `[data-for="<id>"]`로 문서 전체를 찾으므로 DOM 위치가 바뀌어도 JS 수정이 필요 없다.

### 3-54-7. 주문/배송내역 — 다품목 주문 표시

15품목 주문인데 화면에 `수량: 2개`만 나오고, **어떤 상품을 샀는지 확인할 방법이 없었다.**

**(1) 수량 합계** — 표시하던 `QTY`가 대표 상품 1건의 수량이었다. 대표 상품 서브쿼리에 이미 있던 윈도우 함수 옆에 합계를 추가(추가 비용 없음):

```sql
COUNT(*) OVER (PARTITION BY od.ORDER_ID) AS PRODUCT_COUNT,
SUM(od.QTY) OVER (PARTITION BY od.ORDER_ID) AS TOTAL_QTY   -- 추가
```

**(2) 품목 드롭다운** — 카드에 `주문 상품 N건 모두 보기` 버튼을 달고, 펼치면 상품명·옵션명·수량·`PRICE_FIX × QTY`를 보여준다. 현재 상품 가격이 아니라 **주문 시점 단가(`PRICE_FIX`)** 를 쓴다.

**N+1 회피** — 주문마다 조회하지 않고 한 페이지의 주문 ID(10건)를 `foreach`로 넘겨 **쿼리 1회**로 끝낸 뒤 서비스에서 주문별로 나눠 담는다.

```
MyPageOrderItemDTO.java        신규
MyPageDeliveryDTO.java         totalQty / items 추가
MemberMapper.xml               TOTAL_QTY + selectOrderItemsByOrderIds 신규
MemberServiceImpl.listDelivery 품목 조회 후 주문별 분배
userOderDelivery.jsp           버튼 + 펼침 영역
js/views/orderDelivery.js      신규 (document 위임, hidden 토글)
style_user.css                 .order-delivery-page 스코프
```

검증: 주문 22번 15품목을 DB와 1:1 대조 — 상품명·옵션명·수량·금액 전부 일치. `단가합 11,397,400 − 할인합 227,948 = 주문금액 11,169,452` 검산도 전 주문 일치.

### 3-54-8. 테스트 더미 데이터 SQL 작성 (`sql/dummy_order_review.sql`, 신규)

주문 0건·리뷰 0건이라 위 화면들을 확인할 수 없어서 더미를 만들었다. **작성·검증만 하고 실행은 사용자.**

- **카테고리별 대표 상품 15개에 리뷰 2~6개** (리뷰어 6명, 총 리뷰 60건)
- **`dummy_buyer`** — 주문 8건으로 `PAYMENT_WAITING`/`PAYMENT_COMPLETED`(배송행 없음) / `PREPARING` / `SHIPPED` / `OUT_FOR_DELIVERY` / `DELIVERED`(3품목 중 1건만 리뷰 = AUDIT 17번 케이스) / `CANCELED` / `CART`(목록에서 빠져야 하는 음성 케이스) 전부 커버
- **`dummy_zero`**(배송완료 12건·리뷰 0건 → 배지 12) / **`dummy_many`**(12건 전부 작성 → 배지 0) — 3-54-2 타일 분기 양쪽 확인용
- 계정 `dummy_rv01`~`06` / `dummy_buyer` / `dummy_zero` / `dummy_many`, 비밀번호 전부 `1234`(기존 해시 재사용)

**상품 ID를 하드코딩하지 않는다** — 실행 시점의 `CATEGORYDETAIL`/`OPTIONDETAIL`을 조회해 대표 상품을 고르므로 상품이 늘어난 뒤 다시 돌려도 동작한다. 맨 위 정리 블록이 `dummy_`로 시작하는 계정만 지우므로 재실행 가능(실제 회원은 건드리지 않음).

#### 첫 실행 실패 — `PLS-00425`

```
ORA-06550: PLS-00425: SQL에서, 함수 인수와 리턴 형태가 SQL 형태이어야 합니다
ORA-06550: PL/SQL: ORA-00904: 부적합한 식별자
```

원인: INSERT 문 **안에서** PL/SQL 로컬 컬렉션을 직접 참조했다.

```sql
VALUES (..., v_txt(1 + MOD(v_seq, v_txt.COUNT)), ...)
--            ^^^^^ SQL 엔진은 함수 호출로 해석 → ORA-00904
--                                ^^^^^^^^^^^ PL/SQL 전용 → PLS-00425
```

→ 스칼라 변수로 먼저 꺼낸 뒤 넘기도록 수정. **컴파일 단계 실패라 데이터도 시퀀스도 전혀 움직이지 않았다.**

### 3-54-9. 다음 과제 — 다품목 주문의 품목별 리뷰 작성 (미착수, 설계만)

현재 카드의 리뷰 버튼은 **"아직 안 쓴 것 중 첫 번째"** 로 걸려 있어(3-45 AUDIT 17 조치) 3건 다 쓸 수는 있다. 다만 **어떤 상품을 쓰는지 모르고, 순서를 못 고르고, 뭐가 남았는지 안 보인다.**

**합의된 방향(구현은 다음 세션)**: 3-54-7에서 만든 드롭다운 각 행에 `리뷰 작성` / `작성 완료`를 단다.

- 백엔드 변경 0 — `/review/write?odId=`가 이미 품목 단위이고 서버에서 소유자·배송완료·중복작성을 전부 재검증한다(`ReviewServiceImpl.getWriteInfo`)
- 필요한 것: `selectOrderItemsByOrderIds`에 `HAS_REVIEW` 한 컬럼 + DTO 필드 + JSP 행 우측 버튼 + 카드 버튼 라벨(`리뷰 작성 (2건 남음)`)
- **⚠️ `HAS_REVIEW`에 `REVIEW_STATUS` 필터를 넣지 말 것** — 삭제한 리뷰도 행이 남아 재작성을 영구 차단하는 구조(정책 11번)라, 필터를 넣으면 화면엔 버튼이 보이는데 누르면 "이미 리뷰를 작성한 주문입니다"가 뜬다.
- 채택하지 않은 대안: 주문 상세 페이지 신설(드롭다운과 중복) / 리뷰 작성 완료 후 "다음 상품" 흐름(리뷰 페이지 담당 영역, 위 방식 위에 얹는 게 나음)

### 코드 변경

```
수정
  admin/model/service/AdminProductServiceImpl.java   길이 검증 4종
  member/controller/MemberController.java            nextReviewableOdId 배선
  member/model/dto/MyPageDeliveryDTO.java            totalQty / items
  member/model/mapper/MemberMapper.java              시그니처 2건
  member/service/MemberService(.Impl).java           품목 조회·분배
  mappers/member/MemberMapper.xml                    selectNextReviewableOdId / TOTAL_QTY / selectOrderItemsByOrderIds
  static/css/style_admin.css                         화살표·카운터·태그
  static/css/style_user.css                          주문 품목 드롭다운
  static/js/views/addProduct.js                      글자수 카운터 + 명암비 계산
  views/admin/addProduct.jsp                         필수 표시·글자수·카운터 위치
  views/member/myPage.jsp                            리뷰 타일 분기
  views/order/userOderDelivery.jsp                   총수량 + 드롭다운

신규
  member/model/dto/MyPageOrderItemDTO.java
  static/js/views/orderDelivery.js
  sql/dummy_order_review.sql

이미 커밋됨(사용자)
  mappers/review/ReviewMapper.xml                    9f37338
```

---

## 3-55. 2026-09-02: 헤더 닉네임 노출 + 품목별 리뷰 상태 표시

3-54 커밋 후 이어서 진행. **병합 직후 3-54 작업물 15개가 전부 살아있는지 먼저 확인했다**(3-54-1의 교훈 적용 — 회귀 0건).

### 3-55-1. 헤더에 이름 대신 닉네임 (#TB006_TC-12)

헤더가 `${sessionScope.loginSession.memberName}`으로 **이름**을 노출하고 있었다. 단순 치환이 안 되는 이유가 있었다 — **세션 DTO에 닉네임이 아예 없었다.**

```java
// 기존: 세션엔 memberId / memberName / role 3개뿐
new MemberDTO(member.getMemberId(), member.getMemberName(), member.getRole())
```

그래서 4곳을 같이 고쳤다.

| 파일 | 변경 |
|---|---|
| `MemberDTO.java` | 세션 생성자에 `nickname` 추가(3-arg → 4-arg, 호출부 1곳뿐) |
| `MemberServiceImpl.login()` | 닉네임도 세션에 담음 |
| `common/header.jsp` | `memberName` → `nickname`, `<c:out>`으로 이스케이프 |
| `MemberController.updateNickname` | **성공 시 세션 값도 갱신** |

> **마지막 항목이 없으면 새 버그가 된다** — 회원정보 수정에서 닉네임을 바꿔도 세션은 그대로라 **재로그인 전까지 헤더가 옛 닉네임을 계속 보여준다.** 세션에 값을 복사해 두는 필드를 늘릴 때마다 "그 값을 바꾸는 경로"를 같이 찾아야 한다.

**닉네임 최대 길이는 8자**(7자로 알려져 있었으나 확인 결과 8자). 세 곳이 같은 정규식을 쓰고 있고 전부 일치하는 것을 확인했다:

```
^[가-힣a-zA-Z0-9_]{2,8}$
  MemberDTO.java:41 (@Pattern) / MemberServiceImpl.nicknameUpdate / views/signUp.js
```

**UI 점검에서 문제 1건 발견** — `.welcome`에 CSS 규칙이 **아예 없어서** 상속 크기(16px)로 렌더됐고, 바로 옆 `로그아웃`(13px)과 글자 크기가 어긋나 보였다. 규칙을 신설했다.

넘침 위험은 없다 — `#search_box{flex:1}`이라 닉네임이 길어지면 검색창이 줄어들 뿐이고 `.sign`이 `white-space:nowrap`이라 줄바꿈도 없다. `max-width:160px`는 검증을 우회한 값이 들어와도 헤더가 안 밀리게 하는 보험.

이후 요청으로 **닉네임만 굵게, "님"은 일반 굵기 + 사이 한 칸**으로 분리했다.

```html
<span class="welcome-nickname">최대여덟자닉네임</span> 님
```

- 굵기를 `.welcome`이 아니라 안쪽 `.welcome-nickname`에 준다.
- 띄어쓰기는 **같은 줄에 리터럴 한 칸**으로 둔다(줄바꿈+들여쓰기가 한 칸으로 접히는 동작에 기대지 않기 위해).
- `<strong>`이 아니라 `<span>`을 쓴 이유: 의미상 강조가 아니라 순수 시각 처리라서. `<strong>`이면 스크린리더가 "중요한 내용"으로 읽는다.

**테스트 계정**: `dummy_nick8` / `1234`, 닉네임 `최대여덟자닉네임`(한글 8자 = 규칙상 최대, 한글이 가장 넓어 최악의 경우). `sql/dummy_order_review.sql`의 `3-1` 섹션에도 넣어 리셋해도 살아난다.

**검증**(8798 별도 포트 + 8797): `dummy_buyer`(이름 `상태확인` / 닉네임 `상태확인러`)로 **닉네임이 나오는지 이름이 나오는지 구분** 확인 → `상태확인러님` ✅. `dummy_nick8`은 9글자 정상 렌더 + 마이페이지 200.

> **CSS만 바뀐 경우는 서버를 재시작하지 않아도 된다** — `cp src/main/resources/static/css/style.css target/classes/static/css/`로 바로 반영된다. devtools는 `/static`을 재시작 트리거에서 제외하므로 **로그인 세션이 유지된다.** 이번처럼 사용자가 화면을 보고 있을 때 유용하다.

### 3-55-2. 다품목 주문 - 품목별 리뷰 작성 여부 표시

3-54-9에서 설계만 해둔 것을 반영했다. 팀장 지침은 **"최대한 지금 형태 유지"** 라 카드 하단 버튼(다음 미작성 품목으로 이동)은 그대로 뒀다.

1. **배송완료 카드는 펼친 채로 시작** — 리뷰 상태를 봐야 할 게 결국 배송완료 주문이라, 배송완료 탭뿐 아니라 전체 탭에서도 같은 기준으로 동작한다.
   ```jsp
   <c:set var="itemsOpen" value="${item.deliveryStatus == 'DELIVERED'}"/>
   <div class="order-items" ... ${itemsOpen ? '' : 'hidden'}>
   ```
   `aria-expanded`와 버튼 문구도 초기 상태에 맞춰 렌더한다. **안 맞으면 첫 클릭이 반대로 동작한다.**

2. **품목별 상태 텍스트** — `리뷰 작성 완료`(`.is-done`) / `리뷰 미작성`(`.is-todo`). **배송완료 주문에만** 표시한다. 배송 전엔 애초에 리뷰를 못 쓰는데(`getWriteInfo`가 막음) "미작성"이라고 적으면 오해를 준다.

`selectOrderItemsByOrderIds`에 `HAS_REVIEW` 한 컬럼을 추가했다. **`REVIEW_STATUS` 필터를 넣지 않는다**(정책 11번) — 넣으면 삭제한 품목이 "미작성"으로 보이는데 누르면 `checkReviewExists`가 막아서 화면과 동작이 어긋난다.

### 3-55-3. `hasReview` 이름 충돌 정리

위 작업으로 **의미가 다른 `HAS_REVIEW`가 두 개**가 됐다. 팀장이 "나중에 터질 수 있으니 정리하자"고 판단해 이름을 갈랐다.

| 단위 | 이전 | 이후 | 계산식 | 쓰는 곳 |
|---|---|---|---|---|
| 주문 | `HAS_REVIEW` / `hasReview` | **`ALL_REVIEWED` / `allReviewed`** | `nr.NEXT_OD_ID IS NULL` | 카드 하단 배지/버튼 |
| 품목 | `HAS_REVIEW` / `hasReview` | 그대로 | `EXISTS (… rv.OD_ID = od.OD_ID)` | 드롭다운 각 행 |

카드 하단 배지 문구도 층위가 드러나게 바꿨다: `리뷰 작성 완료` → **`이 주문 리뷰 모두 완료`**. 안 바꾸면 다 쓴 주문에서 같은 문구가 4번(품목 3 + 카드 1) 나온다.

> **이름만 바꾸는 변경은 반드시 실측할 것** — MyBatis는 컬럼명↔프로퍼티가 안 맞아도 **예외 없이 조용히 기본값(`false`)을 넣는다.** 컴파일도 통과한다. 이번엔 양방향으로 확인했다:
>
> | 계정 | 카드 | 품목 |
> |---|---|---|
> | `dummy_buyer` (3건 전부 작성) | `이 주문 리뷰 모두 완료` ✅ | 완료 3 / 미작성 0 ✅ |
> | `dummy_zero` (12건 전부 미작성) | 배지 0 · `리뷰 작성` 버튼 3 ✅ | 완료 0 / 미작성 12 ✅ |
>
> `allReviewed`가 뭉개졌다면 `dummy_buyer`에서 배지 대신 버튼이 떴을 것이다.

### 3-55-4. 주석 정리

이번 세션에 붙인 주석 중 과하게 긴 것들을 관례("짧게 쓰고 근거는 HANDOFF 번호로 참조")에 맞게 줄였다.

```
addProduct.js        태그 명암비 설명 5줄 → 1줄, WHITE_BIAS 10줄 → 3줄
orderDelivery.js     파일 헤더 9줄 → 3줄
userOderDelivery.jsp 펼침/리뷰상태 주석 3건 축약
MemberMapper.xml     ALL_REVIEWED / HAS_REVIEW 주석 축약
style.css            .welcome 주석 3줄 → 1줄
```

`addProduct.js`에 남은 3줄짜리들은 기존 섹션 헤더(`/* ===== 기존 태그 클릭 ===== */`)라 그대로 뒀다.

### 코드 변경

```
수정
  member/model/dto/MemberDTO.java             세션 생성자에 nickname
  member/model/dto/MyPageDeliveryDTO.java     hasReview → allReviewed
  member/model/dto/MyPageOrderItemDTO.java    hasReview 추가
  member/service/MemberServiceImpl.java       login()에 닉네임
  member/controller/MemberController.java     updateNickname 세션 갱신
  mappers/member/MemberMapper.xml             ALL_REVIEWED 개명 + HAS_REVIEW 신규
  static/css/style.css                        .welcome / .welcome-nickname
  static/css/style_user.css                   .order-item-review
  static/js/views/addProduct.js               주석 축약
  static/js/views/orderDelivery.js            주석 축약
  views/common/header.jsp                     닉네임 노출
  views/order/userOderDelivery.jsp            기본 펼침 + 품목별 리뷰 상태
  sql/dummy_order_review.sql                  dummy_nick8 계정 추가
```

### 다음 (미착수)

**#TB019_TC-29 결제 화면** — 결제 페이지 도달 경로가 아직 복잡해 보류. 요구사항 3가지:

1. 포인트 사용 시 필요한 **최소금액 안내 문구** 출력
2. **할인율 적용되어 할인되는 금액** 출력
3. **포인트 사용액 / 쿠폰 사용액 / 등급 할인액을 모두 별도 표시**

⚠️ 시작 전에 **AUDIT 23번**(체크아웃이 `PRODUCTORDER.TOTAL_PRICE`를 0으로 저장)을 먼저 볼 것. 금액 표시를 고치는 작업인데 저장 자체가 0이면 화면만 고쳐도 소용이 없다.

---

## 3-56. 2026-09-02: 결제 화면 금액 안내(#TB019_TC-29) + 결제 재개 + 배송비 기준 정돈

3-55 커밋·`main` 병합 후 이어서 진행. **병합 직후 3-54/3-55 산출물 15개 생존 확인(회귀 0건)** 을 먼저 했다.

### 3-56-1. AUDIT 23번(체크아웃 `TOTAL_PRICE` = 0) 해소 확인

21번 이후 앱에서 만들어진 실주문 10건을 전수 확인 → **16:42 이후 `TOTAL_PRICE=0`이 한 건도 없다.** 21번은 그 사이 수정된 옛 코드의 산물. 현재 코드는 `verifiedData.setTotalPrice(totalPrice)` → `insertProductOrder` 로 정상 저장한다.

### 3-56-2. 배송비 기준 확정 및 정돈 (담당자 위임)

검산 중 **주문 47번과 49번이 조건이 같은데 3,000원 갈린 것**을 발견했다. 담당자 확인 결과 **"할인 전 금액" 기준으로 확정.**

기준 자체를 어긴 곳은 없었다(4곳 모두 이미 할인 전 금액 사용). 진짜 문제는 **`50000`/`3000`이 4곳에 하드코딩**돼 한 곳만 고치면 조용히 갈라지는 구조였던 것.

```java
// OrderServiceImpl - 이제 여기가 유일한 판정 지점
private static final long FREE_SHIPPING_THRESHOLD = 50_000L;
private static final long SHIPPING_FEE = 3_000L;
private long calcDeliveryFee(long productTotalPriceBeforeDiscount) { ... }
```

화면(`cartService.js`)은 서버와 물리적으로 합칠 수 없으므로 상수로 빼고 상호 참조 주석을 달았다. 경계값 9개 전후 동치 + 실제 주문 금액 재현 일치 확인.

> **매직넘버가 서버·화면 양쪽에 흩어지면 반드시 갈라진다.** 이 프로젝트에서 배송비(3-56-2)·포인트 최소치(3-56-3) 두 번 나왔다. 한쪽을 단일 출처로 삼고 다른 쪽이 그것을 참조하게 만들 것.

### 3-56-3. #TB019_TC-29 결제 화면 금액 안내

요구 3가지를 반영하면서 **실제 결함 3건**을 발견해 같이 고쳤다.

**(1) 화면 금액 ≠ 실제 결제 금액 (가장 중요)**

서버는 `상품가 x (1-쿠폰) x (1-등급)` 을 BigDecimal로 **한 번에 곱하고 마지막에 한 번만 HALF_UP**, 화면은 **단계마다 floor** 였다. 전수 검사 결과 **67.35% 조합에서 최대 2원 어긋남.** `clientPaidAmount`는 서버가 받기만 하고 검증에 쓰지 않아 결제 실패는 안 나지만, **보이던 금액과 다른 금액이 결제된다.**

할인율이 소수 둘째 자리까지만 쓰이므로(쿠폰 0.1~0.3 / 등급 0.02~0.15) **100 단위 정수 연산**으로 부동소수 오차 없이 서버와 같은 값을 내도록 `applyRates()`를 만들어 교체했다.

표시용 두 금액은 총 할인액을 쪼개서 만든다 — **쿠폰 + 등급 = 총 할인액이 항상 정확히 맞아떨어진다**(화면에서 숫자를 더해보는 사용자가 있다).

검증: **1,250만 건 전수 검사 불일치 0건.**

**(2) 포인트가 결제금액보다 많으면 결제 불가**

보유 50,000P로 35,000원짜리를 사면 최종 금액이 음수가 되고, 제출하면 서버가 `"사용 포인트가 결제 금액보다 많습니다"`로 거부한다. **사용 가능 상한(`할인후상품가 + 배송비`)으로 자동 제한 + 안내**를 넣었다.

**(3) 포인트 최소치 `1000`이 3곳에 하드코딩**

`OrderServiceImpl.POINT_MIN_USE` → `PaymentViewDTO.pointMinUse` → JSP 문구 + `window.pointMinUse` → JS. **JSP/JS에 숫자가 하나도 남지 않았다.**

**요구사항 반영 결과**

| 요구 | 구현 |
|---|---|
| 1. 포인트 최소금액 안내 | 보유 포인트 상황에 맞춰 동적 안내. **보유 < 최소면 입력칸 비활성화 + "N P 더 필요"** |
| 2. 할인율 적용 금액 | 등급 할인 금액을 원 단위로 표시(할인율은 `#grade_discount`에 별도) |
| 3. 세 금액 별도 표시 | 쿠폰 / 등급 / 포인트 각각 `#DiscountInfo` 안에 |

부수 정리:
- 죽어 있던 `#point-warning`(JSP에만 있고 JS가 안 쓰던 요소)을 살려 **`alert` → 인라인 경고**로. alert는 입력값을 0으로 되돌려 다시 치게 만들었다.
- 안내 문구·상하한 보정을 **`calculate()` 한 곳으로** 모음(입력/쿠폰변경/최초로드가 모두 여기를 거친다).
- 서버 렌더 금액에 `<fmt:formatNumber>` 적용. JS가 채우는 값만 콤마가 있어 화면이 섞여 보였다.

### 3-56-4. 결제 재개 (헤더 영수증 아이콘)

> 팀장 의도: **"대부분의 쇼핑몰은 결제 페이지를 장바구니처럼 일정 시간 담아놓고, 실수로 다른 화면에 갔다가 돌아와 결제를 이어서 진행할 수 있다."** 주문/배송내역은 결제 후 확인하는 영역이라 마이페이지가 맞다.

처음엔 "결제 화면은 POST 전용이라 헤더 링크 불가"라고 판단해 영수증 아이콘을 주문/배송내역에 걸었으나, 위 의도를 듣고 **재개 가능한 구조로 다시 만들었다.**

```
PendingCheckoutDTO (신규)  ... cartIds 또는 popId+qty + savedAt
SessionConst.PENDING_CHECKOUT
GET /order/payment (신규)  ... 세션의 선택으로 화면을 다시 만든다
```

**화면이 아니라 "선택"만 저장하는 것이 핵심.** 만들어둔 `PaymentViewDTO`를 되살리면 가격·재고·보유 포인트·쿠폰이 낡아서, 30분 전 가격으로 결제하려다 서버 검증에서 튕긴다. 돌아올 때 전부 다시 조회한다.

- TTL 30분. 만료되면 세션에서 지우고 장바구니로 안내
- **결제 성공 시 반드시 비운다** — 안 비우면 아이콘이 이미 산 주문을 다시 열어 중복 결제로 이어진다
- 담아둔 사이 상품이 내려간 경우 `try/catch`로 잡아 장바구니로(안 잡으면 500)

검증(실측): 담긴 것 없음 → `302 /cart/my-cart` / 바로구매 후 복귀 → 수량·금액 그대로 / 장바구니 3건 후 복귀 → `112,800원` 3건 / 결제 완료 후 → 자동으로 비워짐 / 비로그인 → 로그인 후 복귀 URL 유지.

### 3-56-5. 같이 고친 깨진 경로 3건

| 증상 | 원인 | 조치 |
|---|---|---|
| **`/member/orderDelivery` 404** | pull에서 JSP 파일명 오타를 고쳤는데(`userOderDelivery` → `userOrderDelivery`) **`MemberController` 한 줄이 옛 이름을 반환** | 문자열 수정. `OrderController` 쪽은 새 이름이라 멀쩡했고 **마이페이지 경로만 죽어 있었다** |
| `redirect:/product/cart` 404 | 컨트롤러가 없는 경로. `cart.jsp`에도 TODO로 남아 있었음 | `CART_URL = "redirect:/cart/my-cart"` 상수로 |
| checkout 실패 시 405 | 실패하면 `redirect:/order/payment`인데 GET 매핑이 없었음 | 3-56-4의 GET 신설로 **자동 해소** — 이제 결제 화면으로 돌아가 오류를 보고 재시도 가능 |

> **파일명을 고칠 땐 그 이름을 문자열로 쓰는 곳을 전부 찾을 것.** 뷰 이름은 컴파일러가 잡아주지 않아 실행해야만 드러난다. `grep -rn "<옛이름>"` 한 번이면 된다.

### 3-56-6. 테스트 계정 / 데이터

전부 비밀번호 `1234`. 장바구니에도 3건씩(합계 112,800원 = 배송비 무료 구간) 담아둠.

| 아이디 | 등급 | 포인트 | 쿠폰 | 확인 대상 |
|---|---|---|---|---|
| `dummy_pay1` | PLATINUM 15% | 50,000P | 10%·20%·30% | 세 금액 전부 + **포인트 상한 제한** |
| `dummy_pay2` | BRONZE 2% | **500P** | 없음 | **최소금액 미달 안내 + 입력 비활성화** |
| `dummy_pay3` | SILVER 5% | **1,000P** | 15% | **경계값(딱 최소치)** |

확인 경로: 장바구니 → 주문하기, 또는 상품 상세(`/mds/detail/12`) → 바로 구매 → 다른 화면 → 헤더 영수증 아이콘.

⚠️ **세션 기반이라 서버 재시작(devtools)·로그아웃이면 담긴 결제가 사라진다.** 개발 중엔 이게 가장 흔한 "왜 장바구니로 튕기지?"의 원인.

### 코드 변경

```
신규
  order/model/dto/PendingCheckoutDTO.java

수정
  order/controller/OrderController.java    GET /payment 신설, 세션 저장·정리, CART_URL 상수
  order/service/OrderServiceImpl.java      배송비 상수+메서드, POINT_MIN_USE
  order/model/dto/PaymentViewDTO.java      pointMinUse
  util/SessionConst.java                   PENDING_CHECKOUT
  member/controller/MemberController.java  뷰 이름 오타(404) 수정
  static/js/views/payment.js               서버와 동일한 정수 계산, 인라인 경고, 상한 제한
  static/js/product/cartService.js         배송비 상수화 + 서버 참조 주석
  views/order/payment.jsp                  천단위 구분자, 동적 포인트 안내, 입력 비활성화
  views/common/header.jsp                  영수증 아이콘 → /order/payment
  views/product/cart.jsp                   낡은 TODO 주석 정리
```

---

## 3-57. 2026-09-02 밤: `JWC_works` 병합 충돌 해결 + product 전달 목록 검수 + AUDIT 버그 1번 조치

집에서 작업분을 하나로 합치는 과정. `JWC_works`(`3e4d83f #종합버그 처리`)를 `BJY_works`에 병합하다 충돌 2건이 났고, 그 김에 **3-47 전달 목록 검수 + 3-53 체크리스트 A~D**까지 한 번에 진행했다.

> **운영 방침 변경(2026-09-02 밤, 사용자 지시)**: **이제 담당자 구분 없이 발견한 건 우리가 다 고친다.** 내일부터 시연이라 "남의 영역이니 기록만" 하던 기존 규칙은 더 이상 적용하지 않는다.

### 충돌 2건

| 파일 | 성격 | 처리 |
|---|---|---|
| `order/OrderController.java` | **양쪽이 같은 버그를 각자 고침** — JWC는 리터럴 `"redirect:/cart/my-cart"`, 이쪽(3-56)은 같은 값을 `CART_URL` 상수로 추출 | 동작이 동일하므로 상수 쪽 유지 |
| `js/views/productdetail.js` | JWC가 `activateTab()` 추출 + `#review` 해시로 리뷰 탭 열기(리뷰 페이지네이션에 필요)를 추가 | **JWC 쪽 채택하되 중복 선언 제거** |

> **⚠️ 그대로 받았으면 상세 페이지 JS가 통째로 죽었다.** JWC 블록에 `const wishButton` / `const wishCount` 선언이 들어 있는데 **HEAD(3-42 작업)가 이미 파일 상단 13~14행에서 같은 이름을 선언**하고 있었다. 같은 스코프 중복 선언이라 `Identifier 'wishButton' has already been declared` → 파싱 단계에서 스크립트 전체가 죽는다. **컴파일은 통과하므로 안 드러난다** — 3-54-1/3-56-5와 같은 계열의 병합 사고.

### 병합 회귀 확인 (프롬프트 2단계)

최근 작업물이 되돌아가지 않았는지 전수 확인 — **전부 생존**.

`style.css` main 세로 flex 4건(3-50) / `a:focus:not(:focus-visible)`(3-51-1) / `style_user.css`의 `.review-write-page` 50개 규칙(3-49) / `focus-visible` 10건(3-51) / 스코프 없는 `body{}`·`main{}` **0건** / `min-height:100vh` **0건** / `ReviewMapper.xml` 소프트 삭제(3-54-1) / `REVIEWHISTORY` 잔존 0건 / 헤더 닉네임(3-55).

### product 전달 목록(3-47) 검수 — 7건 중 6건 완료, **1건 누락분 보완**

병합에 product 담당자 수정분이 함께 들어왔다. `LIKE_COUNT` 제거, `updateLikeCount`/`updateLikeDiscount` 삭제, 좋아요 수를 `REVIEWLIKE` 서브쿼리로 계산, `getReviewList`·`product.xml`·`wish.xml`에 `REVIEW_STATUS = 1` 적용까지 정상.

**빠진 것**: `product/detailPage.xml`의 `productDetail` — **평균 별점·리뷰 수 서브쿼리 2곳에 `REVIEW_STATUS = 1`이 없었다.** 같은 작성자가 다른 집계엔 전부 넣은 걸 보면 단순 누락. 이 세션에서 추가했다.

**검증에 쓴 데이터가 마침 완벽했다** — `PRODUCT 11`번은 리뷰가 딱 1건인데 그게 소프트 삭제된 것(`REVIEW_ID=94`, `OD_ID=91`, 작성자 `dummy_buyer`)이라, 필터가 없으면 `평균 5.0 / 리뷰 1개`, 있으면 `0 / 0`으로 갈린다. 화면이 **"리뷰 0개 / 리뷰가 없습니다"** 로 나오는 것 확인.

### 3-53 검증 체크리스트 A~D

| | 결과 |
|---|---|
| **A** 재작성 차단 | ✅ `odId=91`로 작성화면 **302**, 화면 우회 POST도 **302**, `REVIEW` 행 1건 그대로(새로 안 생김) |
| **B** 표시·집계 제외 | ✅ 위 상품 11번 |
| **C** 좋아요 `REVIEWLIKE` 일원화 | ✅ (아래 AUDIT 버그 1번 조치 후) 토글 200 / `on`·`off` 응답, 비로그인 `login-required`. 검증 후 `REVIEWLIKE` 0행 |
| **D** USER 화면 회귀 | ✅ `myPage`·`orderDelivery`·`myReviews`·`couponView`·**`wish/my-wish`·`cart/my-cart` 전부 200** |

> **AUDIT 버그 16번(cart/wish 4경로 404) 해소** — JWC 병합으로 컨트롤러 진입점이 붙어 이제 로그인 상태에서 200이다.

### AUDIT 버그 1번 조치 완료 — `ProductController`가 세션을 잘못된 키로 읽던 것

체크리스트 C가 **500**으로 막혀서 추적한 결과, `NullPointerException: MemberDTO.getMemberId() because "user" is null`. 원인은 **AUDIT 버그 1번이 그대로 살아있던 것**이다.

- `ProductController` 3곳(59·79·109행)이 `SessionConst.LOGIN_MEMBER`(`"loginMember"`)로 세션을 읽는데, **그 키를 세션에 넣는 코드가 프로젝트 전체에 0건**이다(실제 키는 `LOGIN_SESSION`, `LOGIN_MEMBER`는 Model attribute 이름 — 부록 A에 적혀 있던 바로 그 함정).
- 59행(`addReviewPage`)은 null 가드가 있어 조용히 실패(내가 누른 좋아요 표시가 항상 꺼짐), **79행(쿠폰 발급)·109행(좋아요)은 바로 역참조해 NPE 500.**

**조치**: 3곳 모두 `LOGIN_SESSION`으로 교체 + `user == null` 가드로 정정(기존 `user.getMemberId() == null`은 비로그인을 잡으려던 의도였으나 그 전에 이미 터진다).

**함께 고친 것**: `reviewLike`가 `@Controller`인데 `@ResponseBody`가 없어 반환값 `"on"`/`"off"`가 **뷰 이름으로 취급**되던 문제 — 세션 키만 고쳤으면 500 대신 뷰 없음 오류가 났을 것이다. `@ResponseBody`를 붙여 응답 본문으로 돌려주게 했다.

> **남은 것**: 이 두 엔드포인트(`/mds/coupon/{id}`, `/mds/review/like/{id}`)는 **아직 화면에서 호출하는 코드가 0건**이다. 서버는 정상화됐으니 좋아요 버튼을 붙일 때 `fetch`로 연결만 하면 된다.

### 그 밖에

- **관리 문서 4종이 다시 git 추적 중**(`2b843ee`에서 재유입). 3-43/3-44 방침과는 다르지만, **사용자가 이동 중 백업 목적으로 의도해서 넣은 것** — 집이 아닌 곳에서 작업 후 커밋할 때 제거하고 재커밋할 예정이므로 **지금은 그대로 둔다.**
- 레포 루트 사본이 바탕화면 사본보다 최신이다(09-02 23:30 vs 09-01 23:10). 이 세션의 갱신은 레포 루트 쪽에 했다.
- **검증 방법 주의**: `./mvnw -q compile | tail; echo $?` 는 `tail`의 종료코드를 읽어 **항상 0**이다. 이번에 이 때문에 여분 `}` 하나를 못 잡을 뻔했다. 파일로 리다이렉트한 뒤 `$?`를 보거나 `BUILD SUCCESS`를 직접 grep할 것.

### 검증

`clean compile` → **BUILD SUCCESS**(출력 직접 확인), 매퍼 XML 11개 파싱 정상, 충돌 마커 0건, `productdetail.js` 괄호 균형. 8798 별도 포트로 공개 화면·상세·검색·USER 6개 화면 전부 200. **테스트로 만든 `REVIEWLIKE` 행 0건 확인**(토글이 짝수 번 돌아 상쇄).

### 신규/수정 파일

```
충돌 해결:
  order/controller/OrderController.java        js/views/productdetail.js
수정:
  product/controller/ProductController.java    (세션 키 3곳 + null 가드 + @ResponseBody)
  mappers/product/detailPage.xml               (평균별점·리뷰수 서브쿼리에 REVIEW_STATUS = 1)
병합으로 함께 들어온 것: 21개 파일 + docs/ADMIN_BINDING_HANDOVER.md (JWC1226 작성)
```

---

## 3-58. 2026-09-03: 메인페이지(`home.jsp`) 서버 연동 — 정적 목업 → 실데이터

가장 급한 것으로 지목된 건. `home.jsp`가 그동안 **완전 정적 목업**이었다(카테고리 15개 하드코딩, 상품 카드는 `homeProductService.js`의 목업 8종을 무한스크롤로 순환). 서버 쪽(product 담당)이 검색 페이지를 이미 실데이터로 연동해둔 상태라, 그 기반을 그대로 재사용해 홈도 연동했다.

### 발견: 라우팅이 이미 이중으로 쪼개져 있었다

- `/`(`HomeController`)는 모델 데이터 없는 빈 스텁, `/mds/list`(`ProductController`)는 `MainPageDTO`(상품+배너)를 담아 **`home/home`으로 반환**하는 완성된 코드가 있었다 — 그런데 **`/mds/list`를 호출하는 화면이 프로젝트 전체에 0건**이었다(죽은 라우트). 지난 세션들에서 반복됐던 "같은 화면에 경로가 두 개"류 문제의 또 다른 사례.
- 조치: `/mds/list`를 삭제하고, **`/`(`HomeController`) 하나로 통합**. `MainPageDTO.getList()`(전체 130건, 배너 포함)는 홈이 원하는 모양(찜 많은 순 상위 8개, 배너 없음)과 안 맞아서 안 쓰고, **검색 페이지가 이미 쓰는 `getSearchList(SearchDTO, page)`를 그대로 재사용**했다(찜 많은 순 정렬이라 "인기 선물" 문구와도 맞아떨어짐).

### 무엇을 바꿨나

| 파일 | 변경 |
|---|---|
| `util/controller/HomeController.java` | `ProductService` 주입, `service.getSearchList(new SearchDTO(), 1)` + `service.getCategories()`를 모델에 담아 `home/home` 렌더 |
| `product/controller/ProductController.java` | 죽은 `/mds/list`(`getList`) 삭제, 미사용 `MainPageDTO` import 정리 |
| `home/home.jsp` | 카테고리 15개 하드코딩 → `<c:forEach items="${categoryList}">`. 상품 카드(JS 무한스크롤 8종 목업) → `<c:forEach items="${productList}" end="7">` SSR, 카드 마크업은 `searchProduct.jsp`와 완전히 동일하게 맞춤(`.product-card`/`.product-img`/`.product-meta` 등 — 3-42/3-57에서 이미 두 화면이 같은 클래스 체계를 쓰기로 확정돼 있었다) |
| `js/product/homeProductService.js`, `js/views/home.js` | **삭제** — SSR로 바뀌면서 참조 0건이 됨(orphan 파일 방지 관례) |

### 카테고리 아이콘 재배치 (수작업, 화면 확인 필요)

`categoryList`는 DB 실데이터라 이름이 확정 15종(`reset_category_tag.sql` 기준: 생일/명절/기념일/합격・응원/상품권/맛있는 선물/가벼운 선물/출산・돌/결혼・집들이/주류/화장품/패션・주얼리/명품선물/스포츠/건강)과 정확히 일치하는데, **옛 목업 카테고리 15개와는 이름이 다르다**(옛 목업엔 "육아용품"/"리빙·키친"이 있고 DB엔 없음, DB엔 "명절"/"기념일"이 있고 옛 목업엔 없음, `·`(U+00B7)/`・`(U+30FB) 점 문자도 다름).

- 기존에 손으로 그려둔 SVG 아이콘 13개는 **이름으로 매칭**해서 그대로 재사용(`<c:choose>`/`<c:when test="${category.categoryName == '...'}">`).
- DB에만 있는 "기념일"은 아이콘이 없어서, **옛 목업에서 쓸 곳이 없어진 "리빙·키친" 아이콘(소파 모양)을 재사용**했다(`<c:otherwise>`). 주제가 안 맞는 임시 배치 — 실제 아이콘 확보 전까지의 땜빵.
- DB에만 있는 "명절"은 옛 목업의 "육아용품" 아이콘(유모차 모양)을 재사용했는데, 이건 우연히 이름 매칭이 아니라 **하드코딩 순서가 우연히 그렇게 배치**된 것 — 실제로는 `<c:when>`에 "명절" 조건을 추가로 만들어 유모차 아이콘을 명시적으로 배정했다.
- **⚠️ 화면 확인 필요: 아이콘-이름 매칭이 시각적으로 괜찮은지, 특히 "명절"(유모차 아이콘)·"기념일"(소파 아이콘)은 명백히 임시라 교체가 필요할 수 있음.**

### "더보기" 단순화

목업 시절엔 8개씩 무한스크롤로 계속 불러왔는데, 실데이터는 SSR 8개 고정 + **"상품 더보기"/"전체 상품 보기" 둘 다 `/mds/searchList`(실제 페이지네이션이 있는 검색 결과 페이지)로 보내는 링크**로 바꿨다. 무한스크롤 UX를 유지하려면 JSON API를 새로 만들어야 하는데, 이미 완성된 검색 페이지로 보내는 쪽이 새 코드 없이 더 안전하다고 판단했다.

### 검증

`clean compile` → BUILD SUCCESS. 별도 포트(8798)로 띄워 확인:

| 항목 | 결과 |
|---|---|
| `/` | 200, `category-item` 15개(DB 이름과 1:1 일치), `product-card` 8개(실제 상품명/실제 `productId`) |
| 카테고리 아이콘 매칭 | 15개 전부 자기 이름에 맞는 `<c:when>` 분기를 탔고(각 아이콘의 첫 `<path>`로 식별), "기념일"만 의도대로 `<c:otherwise>` 폴백 |
| `/mds/detail/6`(카드 링크) | 200 |
| `/mds/searchList?category=7`(카테고리 링크) | 200 |
| 상품 이미지(`/uploads/product/...`) | 200 (실제 파일 응답 확인) |
| 회귀 스모크(로그인, 회원가입, admin 4종, 검색, 마이페이지) | 전부 200 |
| 사용자 로컬 서버(8797) | 영향 없음, 200 유지 |

### 남은 것

- 카테고리 아이콘(명절/기념일) 실제 그림 교체 — 위 참고
- "인기 선물" 정렬 기준이 찜 많은 순인데, 실제 서비스라면 판매량/최신순 등 다른 기준을 원할 수도 있음 — 확인 필요
- 홈 상단 히어로 배너(3장 슬라이드)는 이번 범위에서 손대지 않음 — 마케팅 카피 고정 텍스트라 실데이터 연동 대상이 아니라고 판단했음(3-40에서 이미 결론 낸 부분과 같은 맥락)

### 신규/수정 파일

```
수정:
  src/main/java/.../util/controller/HomeController.java       (실데이터 연동)
  src/main/java/.../product/controller/ProductController.java (죽은 /mds/list 삭제)
  src/main/webapp/WEB-INF/views/home/home.jsp                 (카테고리/상품 SSR 전환)
삭제:
  src/main/resources/static/js/product/homeProductService.js
  src/main/resources/static/js/views/home.js
```

---

## 3-59. 2026-09-03: 화면 확인 3건 — 비로그인 장바구니, 홈 더보기 중복 기능, 이미지 호버 태그

3-58(홈 서버 연동) 직후 화면을 확인한 사용자가 지적한 3건. 전부 조치 완료.

### ① 비로그인 상태에서 상품 상세 "장바구니"가 실제로 담기고, 뒤로가기해도 헤더 뱃지가 안 지워짐

**원인**: `productdetail.js`의 `#cart-button`에 **클릭 핸들러가 아예 없었다**(파일 끝에 "장바구니 API는 여기서 확인되지 않아 기존 동작을 건드리지 않는다"는 주석만 남아 있었음). 그런데 서버 쪽엔 이미 완성된 진짜 장바구니가 있었다 — `CartController.insertCart()`(`POST /cart/add-cart`)가 `CartDTO(popId, qty)`를 받아 실제 `CART` 테이블에 넣고, **비로그인이면 서버가 `/member/login`으로 리다이렉트**하는 로그인 가드까지 이미 갖추고 있었다. 이 실제 엔드포인트를 호출하는 화면이 **프로젝트 전체에 0건**이었다(죽은 엔드포인트).
- 그 대신 `searchProduct.jsp`/`wish.jsp`의 장바구니 담기 버튼은 전부 `window.addToCart()`(`common/cartWishService.js`)라는 **localStorage 임시 목업**을 호출하고 있었는데, 이건 로그인 여부를 전혀 안 본다 — 그래서 "비로그인인데 담기고 헤더 뱃지가 올라가는" 증상이 나온 것.
- **조치**: 상품 상세 페이지의 `#cart-button`을 "바로 구매"(`#buy-button`)와 완전히 같은 패턴(hidden form 생성 → `POST /cart/add-cart` submit)으로 실제 서버에 연결했다. 재고/수량 검증도 바로구매와 동일하게 클라이언트에서 먼저 확인한다.
- 결과: 비로그인 상태로 누르면 브라우저가 `/member/login`으로 이동한다(로컬스토리지를 아예 안 건드리므로 헤더 뱃지도 원래 안 올라간다 — "뒤로가기해도 안 지워짐" 문제가 애초에 발생할 여지가 없어짐). 로그인 상태로 누르면 실제 `CART` 테이블에 들어가고 `/cart/my-cart`로 이동한다.
- **범위 밖으로 남긴 것**: `searchProduct.jsp`/`wish.jsp`의 카드 퀵버튼은 여전히 localStorage 목업이다. 상품 상세 하나만 고쳐서 "장바구니 담기 경로가 페이지마다 다르게 동작"하는 상태가 생겼는데, 이번 요청 범위가 상세 페이지였고 나머지 두 곳은 카드 UI(수량 지정 없음, 옵션 목록에서 어떤 옵션을 담을지 카드만 봐선 알 수 없음)라 서버 연동 방식이 또 달라야 해서 별도 확인 후 진행하는 게 맞다고 판단해 손대지 않았다. **다음에 반드시 정리할 것**(AUDIT에 기록).

### ② 홈 "상품 더보기"가 상단 "전체 상품 보기"와 목적지가 같아 기능이 겹침

3-58에서 "더보기"를 그냥 `/mds/searchList` 링크로 단순화했는데, 상단 "전체 상품 보기"도 같은 링크라 **버튼 두 개가 같은 곳으로 가는 죽은 UX**였다는 지적. "더보기 누르면 실제로 8개가 더 보이고, 그 다음부턴 번호 페이지네이션"으로 다시 만들었다.

- `HomeController`가 이제 `page` 쿼리 파라미터를 받는다. 새 쿼리를 만들지 않고 `service.getList()`가 이미 주는 전체 목록(찜 많은 순, 페이징 없음, 130건)을 그대로 받아 Java에서 8개 단위로 잘라 쓴다.
  - `page=1`(기본): 1~8번 8개 + "더보기" 버튼(`?page=2`로 링크)
  - `page=2`: 1~16번 16개를 **누적**해서 한 화면에(더보기를 누른 그 순간엔 8개가 "더" 나타난 것처럼 보임) + 더보기 버튼은 사라지고 번호 페이지네이션이 뜬다
  - `page=3` 이상: 그때부터는 누적하지 않고 8개짜리 구간만(`(page-1)*8` ~ `page*8`) — `page=3`의 시작 지점이 정확히 16번째 다음이라 앞서 보여준 16개와 자연스럽게 이어진다
- 페이지네이션 마크업은 `searchProduct.jsp`가 쓰는 `.sp-pagination`/`.sp-page-btn`/`.sp-btn-prev`/`.sp-btn-next` 클래스를 그대로 재사용(새 CSS 없음), 링크만 `/mds/searchList` 대신 `/`로 바뀐다.
- 상단 "전체 상품 보기"는 그대로 `/mds/searchList`를 가리킨다 — "전체(검색/필터 가능한 카탈로그)로 가고 싶다"와 "인기 선물 목록을 이어서 더 보고 싶다"가 이제 서로 다른 동작이라 더는 겹치지 않는다.

> **화면 확인 필요**: 페이지 번호 배분 규칙(8/16/8...)이 사용자가 원한 그림과 맞는지, "더보기"를 누른 직후(16개 화면)에 스크롤 위치가 어색하지 않은지는 실제로 눌러봐야 안다.

### ③ 상품 이미지 호버 시 떠야 하는 태그가 안 보임

CSS(`style_user.css`)에 `.sp-tag-popup`(이미지 호버 시 아래쪽에서 올라오는 태그 pill 목록)이 **이미 완성돼 있었는데**, 정작 그 요소를 렌더링하는 JSP 마크업이 어디에도 없었다 — `searchProduct.jsp`(3-58 이전부터), `home.jsp`(3-58에서 그 구조를 그대로 복사했으니 같이 없음) 둘 다.

- `ProductListDTO.tagData`는 `"이름|색상,이름|색상,..."` 형태로 LISTAGG된 문자열(`product.xml`의 `getList` 쿼리). 두 파일에 `fn` 태그리이브러리를 추가하고, `.product-img` 안에 `fn:split(tagData, ',')` → 각 조각을 다시 `fn:split(..., '|')[0]`로 이름만 뽑아 `.sp-tag-popup` 안에 `.sp-product-tag` pill로 뿌리는 마크업을 추가했다. 색상 값은 안 쓴다(CSS가 이미 고정 sage-pale 색으로 그리도록 설계돼 있었음).
- 호버 트리거는 CSS가 `.sp-product-card:hover .sp-tag-popup`로 걸려 있어서, `home.jsp` 카드에 빠져 있던 **`sp-product-card` 클래스도 같이 추가**했다(`searchProduct.jsp`엔 원래 있었음).

### 검증

`clean compile` → BUILD SUCCESS. 별도 포트(8798)로 확인:

| 항목 | 결과 |
|---|---|
| `/`(page=1) | 8카드, 더보기 버튼 O, 페이지네이션 X |
| `/?page=2` | 16카드(누적), 더보기 X, 페이지네이션 O(현재 2, 1~5 창) |
| `/?page=3` | 8카드, 페이지네이션 O(이전 링크 `page=2`) |
| 비로그인 `POST /cart/add-cart` | 302 → `/member/login` |
| 로그인(`dummy_buyer`) 후 실제 담기 | 302 → `/cart/my-cart`, `CART` 테이블에 실제 행 생성 확인 → 검증 후 삭제(잔존 0건) |
| `.sp-tag-popup` 렌더 | 홈 8/8, 검색 20/20, 태그 이름 정상 분리(`|`/색상 잔존 0건) |
| 회귀 스모크 | 로그인·회원가입·검색·상세·마이페이지·admin 4종 전부 200 |
| 사용자 로컬 서버(8797) | 영향 없음 |

### 신규/수정 파일

```
수정:
  src/main/java/.../util/controller/HomeController.java        (page 파라미터 + 8/16/8 페이징 로직)
  src/main/resources/static/js/views/productdetail.js          (#cart-button → 실제 POST /cart/add-cart)
  src/main/webapp/WEB-INF/views/home/home.jsp                  (더보기/페이지네이션 + 태그 팝업 + sp-product-card)
  src/main/webapp/WEB-INF/views/product/searchProduct.jsp      (fn 태그리이브러리 + 태그 팝업 마크업)
```

---

## 3-60. 2026-09-03: "담당자 구분 없이 발견한 건 다 고친다" 대규모 라운드 — 상품 상세/장바구니/찜/결제/리뷰 (AUDIT 27, 29~48)

3-59 이후 사용자가 "요청한 것 말고도 찾아서 다 처리해달라"고 범위를 넓혀서, 여러 차례에 걸쳐 스크린샷·직접 재현으로 신고한 것 + 자체 발견분을 묶어 처리한 가장 큰 라운드. `PROJECT_AUDIT.md`에 **27, 29~48번**으로 전부 기록돼 있고(각 항목에 근본 원인·조치 내용 상세), 여기는 영역별 요약만.

### 상품 상세 페이지 (AUDIT 29~33) — "상세 페이지가 심각하다"는 지적으로 전체 재검토

- **가장 심각**: 옵션 가격이 `(실제가 - 대표가)`로 계산돼 기본 옵션이 항상 "0원"으로 보이던 버그 (`ProductServiceImpl`의 불필요한 차감 루프 제거)
- 카테고리/이동경로/짧은 설명이 전 상품 공통 하드코딩 텍스트였던 것 → 실제 DTO 필드(`categoryNames`, `productName`)로 교체
- 등급 할인율 하드코딩 → `getMemberGrade` 신설해 실제 등급별 `DISCOUNT_RATE` 반영
- 대표이미지가 2건 이상이면(`PRODUCT_TITLE_IMAGE` DB 제약 없음) `TooManyResultsException`으로 상세 페이지 전체 500 → `ROWNUM=1` 방어
- **비로그인 상태에서 할인 없이 정상가만 취소선 그어져 보이던 것**(사용자가 "오히려 버그 같다"고 지적) — 할인가 행이 아예 없을 땐 정상가 취소선도 걸리지 않도록 `#price-info:has(.sale-price)`로 스코프 좁힘

### 검색/찜 카드 리뷰 링크 + 같은 계열 점검 (AUDIT 34)

검색 결과 카드는 리뷰를 눌러도 안 움직이던 것 확인(`href="#"` 방치) — 메인 카드와 같은 컴포넌트인데 링크만 안 걸려 있었음. 같은 계열로 찜 카드도 점검해 동일하게 고침.

### 장바구니/찜 선택모드 + 페이지네이션 전면 개편 (AUDIT 35~38)

- 체크리스트가 항시 노출이던 것 → **어드민 쿠폰 화면과 동일한 "선택 모드" 로직**(`#toggleCartSelectButton`/`#toggleWishSelectButton` 토글 + `.selecting` 클래스로 체크박스 노출)으로 통일
- 둘 다 페이지네이션이 없었음 → 서버가 이미 전체 목록을 한 번에 내려주는 구조(`window.serverCartItems`)를 이용해 **클라이언트 사이드 페이지네이션** 추가(`searchProduct.jsp`의 `.sp-pagination` 클래스 재사용). 선택 상태는 `checkedState` 객체로 전체 아이템 기준으로 관리(현재 페이지 DOM에만 의존하면 "전체선택"/일괄삭제가 안 보이는 페이지 항목을 누락시킴 — 어드민 쿠폰 화면에서 이미 겪었던 것과 같은 함정)
- **장바구니 개별 삭제 버튼이 실행이 안 되던 것** — `cartService.js`의 `save()`가 빈 스텁이라 로컬 배열을 지워도 `render()`가 매번 `window.serverCartItems`(서버 원본, 안 바뀜)를 다시 읽어 원상복구되고 있었음. `removeFromServer`/`updateQtyOnServer`로 실제 `POST` 후 DOM 갱신하도록 재작성
- 찜 선택모드에 "장바구니로 넘기는 기능"은 문구만 있고 실제 담기 버튼이 없던 것 → `#wish-cart-btn` 신설, `addToCart(item, silent)`에 `silent` 옵션을 추가해 N건을 `Promise.all`로 조용히 담고 결과 요약 alert 하나만 띄움

### 장바구니/찜 상태 동기화 버그 2건 (사용자가 화면 사용 중 발견, AUDIT 41 외)

- **같은 상품을 퀵아이콘/상세페이지 옵션 선택 양쪽으로 재담기해도 수량이 안 늘어남** — `CartServiceImpl.insertCartInfo()`가 중복 `popId`를 만나면 안내 문구만 반환하고 실제 DB 갱신을 안 하고 있었음(죽은 분기). `mapper.incrementQty()` 신설해 실제로 수량을 더하도록 수정. 두 진입 경로(퀵아이콘/상세페이지)가 완전히 같은 `POST /cart/add-cart` → `insertCartInfo()` 코드를 타는 것 확인해 한 번의 수정으로 둘 다 해소
- **헤더 장바구니 뱃지가 퀵 담기 직후 바로 반영 안 됨** — `cartWishService.js`의 `addToCart()` 성공 분기에 `window.refreshCartBadge()` 호출이 아예 없었음(누락)
- **로그아웃 후 재로그인하면 이미 찜한 상품의 하트가 다시 빈 상태로 보이고, 누르면 "찜 해제"가 아니라 "찜 추가"를 시도** — `toggleWish()`가 방향 판단을 `localStorage` 캐시(`isWished()`)로 하고 있어서 로그아웃/재로그인으로 캐시가 비면 서버의 실제 상태와 어긋났음. 호출부(DOM의 `is-active` 클래스, 서버가 최초 렌더링 때 실제 `WISH` 데이터로 채움)가 판단한 `wasWished`를 인자로 넘기는 방식으로 변경 — 근본 원인은 `ProductListDTO`/`ProductDetailDTO`에 `wished` 필드가 아예 없어서 목록/상세 조회 쿼리가 "이 회원이 찜했는지"를 애초에 안 내려주던 것(`product.xml`/`detailPage.xml`에 `WISHED` 서브쿼리 추가로 근본 해결, JS 캐시 판단 로직은 부수적으로 같이 정리)

### 결제 페이지 (AUDIT 39~40, 42~46)

- **취소/뒤로가기 시 "양식 다시 제출 확인"(`ERR_CACHE_MISS`)** — `OrderController.paymentForm()`(`POST /order/payment`)이 뷰를 직접 렌더링해서 그 POST 자체가 브라우저 히스토리에 남아 있었음(PRG 패턴 미적용). GET으로 이미 같은 화면을 그리는 `paymentResume()`이 있어서, POST 핸들러를 `redirect:/order/payment`로 바꿔 해결 — 취소 버튼/뒤로가기 둘 다 동일 원인, 한 번에 해소
- **`GET /order/checkout` 405 Whitelabel 에러**(사용자가 결제 중 직접 재현) — `/order/checkout`은 결제 실행용 `POST` 전용인데 새로고침/뒤로가기로 GET 접근하면 그대로 405가 떴음. "로그아웃된 것 같다"는 사용자 추측은 코드상 배제(로그아웃이면 로그인 페이지지 405가 아님) → 원인은 순수 HTTP 메서드 불일치. **결제 로직 자체는 여전히 POST 전용으로 남기고**, `GET /order/checkout` 하나만 `redirect:/order/payment`로 안전하게 우회
- 포인트 1P만 입력했을 때 안내 문구가 겹쳐 보이던 것 — `#point` 레이아웃을 `point-input-row` + `#point-warning`으로 재구성, "0P는 사용 안 함" 문구와 "1,000P 이상부터 가능" 문구가 중복 노출되던 것을 정리
- 결제 페이지 폭이 좁아 상품명 줄바꿈 시 라벨까지 밀리던 것(`.order-card` 680px로 확대, `baseline` 정렬), 할인정보 섹션에 구분선 이후 여백이 아예 없던 것(`#DiscountInfo`가 공용 padding/border 규칙에서 빠져 있었음 — 추가)

### 리뷰 (AUDIT 47~48, 사용자 스크린샷)

- **리뷰 이미지가 전부 깨진 아이콘으로 나오던 것** — `detailPage.xml`의 `getReviewImages` 쿼리가 `REVIEW_IMAGE_PATH` 컬럼을 아예 안 뽑고 있어서 `<img src="${path}${name}">`가 파일명만 있는 무효 URL이 됐음. 같은 프로젝트의 `ReviewMapper.xml`(마이페이지 리뷰용)엔 이미 올바른 패턴이 있어서 그대로 가져와 추가
- **리뷰에 좋아요(하트) 인터랙션이 화면에 아예 없던 것** — 백엔드(`GET /mds/review/like/{reviewId}`, `ReviewDTO.isLiked`/`likeCount`)는 이미 다 있었는데(3-57에서 세션 키 버그까지 고쳐 정상 동작 중이었음) `productDetail.jsp`에 렌더링하는 버튼 마크업 자체가 없었음. `.review-like-btn` + 하트 SVG + `.review-like-count` 추가하고 기존 엔드포인트에 연결

### 드롭다운 화살표 위치 (AUDIT 27) — 앞서 "화면 확인 필요"로 미확인 남겨뒀던 것

사용자가 스크린샷으로 위치를 특정(상품 상세 "상품 옵션" 드롭다운). 확인해보니 `style_admin.css`의 `.input-area select`(이미 `appearance:none` + SVG 배경으로 처리됨)와 달리, `style_user.css`의 `#product-option`은 **애초에 그 처리가 전혀 없는 순수 네이티브 select**였음 — 네이티브 화살표가 상자 오른쪽 끝에 딱 붙어 그려지는 증상. 동일 패턴(`appearance:none` + `padding-right:38px` + 인라인 SVG 화살표, `background-position:right 14px center`)을 적용. 같은 계열 점검 중 결제 페이지 쿠폰 선택(`#coupon_id`)도 동일 문제라 같이 수정.

### 검증

전 항목 별도 포트(8798)에서 `clean compile` → BUILD SUCCESS 확인 후 curl/jshell(ojdbc11)로 직접 DB 조회·API 호출 검증. 장바구니/찜 데이터 조작은 테스트 후 삭제(더미 계정 `dummy_buyer`의 기존 찜 더미 2건은 실수로 두 차례 같이 지웠다가 즉시 발견해 복구 — 아래 참고). 최종적으로 `PROJECT_AUDIT.md` 요약표 **버그 48개 — 조치 완료 48 · 미해결 0**.

> **주의**: 이번 라운드 검증 중 `dummy_buyer`(MEMBER_ID=27)의 기존 찜 더미 데이터(상품 6·10 — 원래 지우지 말라고 지정된 계정)를 테스트 상품 ID와 우연히 겹쳐서 실수로 두 번 삭제했다가 두 번 다 직접 발견해서 복구함(`POST /wish/insert-wish`로 재삽입, `GET /wish/my-wish`로 존재 재확인). 다음에 이 계정으로 찜 관련 테스트할 때 상품 6/10은 건드리지 않도록 주의.

### 신규/수정 파일 (관리 문서 3종 제외, 약 45개)

```
신규:
  member/model/dto/DeliveryAddressDTO.java
  product/model/dto/detail/MemberGradeDTO.java
  static/js/views/deliveryAddress.js
삭제:
  static/js/product/homeProductService.js (죽은 파일 정리)
  static/js/views/home.js → home.jsp 인라인/재구성 과정에서 정리(3-58 연장)
주요 수정:
  product/{controller,model/service,model/mapper,model/dto}/*         (memberId 전달 체인, wished 필드)
  cart/{Controller,model/*}/*, resources/mappers/cart/cart.xml         (선택모드/페이징/삭제·수량변경/재담기 증가)
  wish 쪽 JS/JSP(선택모드/페이징/장바구니 담기 버튼)
  order/controller/OrderController.java, views/order/payment.jsp       (PRG, /checkout GET 우회, 포인트/레이아웃)
  resources/mappers/product/{product,detailPage}.xml                  (WISHED 서브쿼리, REVIEW_IMAGE_PATH)
  views/product/productDetail.jsp, static/js/views/productdetail.js   (가격/카테고리/설명/찜상태/리뷰이미지/좋아요버튼)
  static/js/common/cartWishService.js                                 (addToCart silent, toggleWish(wasWished), 뱃지갱신)
  static/css/style_user.css                                           (선택모드 CSS, 결제 레이아웃, #product-option/#coupon_id 화살표)
```

---

## 부록 A. 참고 메모리 (Claude Code 메모리에 저장돼 있어 다음 세션에도 자동으로 불러와짐)

- Jackson 3가 `tools.jackson.*` 네임스페이스를 씀 (Spring Boot 4.1.0 특성, `com.fasterxml.jackson.databind` 아님)
- 8797 포트에 devtools 붙은 서버가 이미 떠있는 경우가 많음 — 새로 띄우기 전에 `netstat -ano | grep :8797` 확인
- `LOGIN_SESSION`(진짜 세션 키) vs `LOGIN_MEMBER`(세션 아님, Model attribute 이름) 헷갈리지 않기
- admin/1234 계정의 bcrypt 해시는 jshell + 로컬 maven jar로 생성/검증 가능
- **DB 시퀀스는 테이블명이 아니라 PK 컬럼명 기준**으로 붙어 있음 — `SEQ_CHIST_ID`(COUPONHISTORY), `SEQ_OD_ID`, `SEQ_POP_ID`, `SEQ_CD_ID` 등. 시드 데이터 넣기 전에 `SELECT SEQUENCE_NAME FROM USER_SEQUENCES` 먼저 조회할 것 (3-43에서 `SEQ_COUPONHISTORY`로 시도해 `ORA-02289` 겪음)
- **역할 분기 때문에 admin 계정으로는 안 보이는 버그가 있음** — `/member/myPage`, `/member/couponView`, `/member/cart`, `/member/wish`는 컨트롤러에서 `role`로 분기해 ADMIN이면 admin 화면으로 빠진다. 유저 화면 검증은 반드시 USER 계정으로 할 것
- 회원가입 폼이 깨져 있어 테스트 계정은 API 직접 호출로 만들어야 하고 `role=USER` 명시 필요. **curl로 한글 값을 보내면 `Character decoding failed`로 400**이 나므로 이름/닉네임은 ASCII로 넣는 게 편함
- **한글을 DB에 넣을 땐 curl/jshell 소스에 직접 쓰지 말 것** — curl은 `Character decoding failed`(400)를 내거나 깨진 채 저장하고, jshell도 `.jsh` 파일을 플랫폼 기본 인코딩으로 읽어 한글을 깨뜨린다. 텍스트를 별도 UTF-8 파일에 쓰고 `Files.readString(path, StandardCharsets.UTF_8)`로 읽어 `PreparedStatement`에 바인딩할 것 (3-45에서 실제로 데이터 오염 → 복구함)
- **브랜치를 크게 오간 뒤엔 `mvnw compile`이 아니라 `mvnw clean compile`** — `compile`은 낡은 산출물을 지우지 않아서, 소스에서 옮겨지거나 삭제된 매퍼 XML이 `target/classes`에 남아 MyBatis 기동을 깨뜨린다 (3-45에서 겪음)
- **있는 도구**: `node` v24 / `jshell` / `pdftotext` / `perl`. **없는 도구**: `python`(스토어 스텁만 있음)
  - `node --check <파일>`로 JS 문법 검사, `new Function(소스)`로 실제 소스의 함수만 떼어와 검증도 가능(태그 명암비 58색 검증에 사용)
  - ⚠️ 2026-09-02 이전 문서엔 "node 없음"으로 잘못 적혀 있었다(3-54에서 정정). **환경 사실은 추측하지 말고 실행해서 확인할 것**
- **PL/SQL 블록을 실행하지 않고 컴파일만 검증하는 방법** — `DBMS_SQL.PARSE`는 PL/SQL 블록을 컴파일만 하고 `EXECUTE`를 부르지 않으면 실행하지 않는다. DML도 안 돌고 시퀀스도 안 당겨진다. 사용자가 직접 돌릴 SQL을 미리 검증할 때 유용 (3-54-8에서 `PLS-00425` 수정 후 사용)
  ```java
  CallableStatement cs = con.prepareCall(
    "DECLARE c INTEGER; BEGIN c := DBMS_SQL.OPEN_CURSOR; DBMS_SQL.PARSE(c, ?, DBMS_SQL.NATIVE); DBMS_SQL.CLOSE_CURSOR(c); END;");
  cs.setString(1, 블록텍스트); cs.execute();
  ```
- **jshell 스크립트 끝에 `/exit`를 빼먹으면 멈춘다**(입력 대기). 또 여러 줄로 이어지는 `.append(...)` 체인은 스니펫을 줄 단위로 평가해서 파싱 오류가 나므로 **한 줄로 붙일 것**
- **`jshell -J-D...`는 런처 JVM에만 적용된다.** 스니펫은 별도 원격 JVM에서 돌기 때문에 시스템 프로퍼티를 넘기려면 **`-R-D...`** 를 써야 한다 (3-54에서 겪음)
