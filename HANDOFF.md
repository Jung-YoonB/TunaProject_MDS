# 관리자 기능 3종 작업 인수인계 (2026-08-28)

Claude Code와 함께 관리자 기능 3개(상품 등록 / 쿠폰 등록·삭제 / 주문·배송 상태 변경)의 백엔드를 처음부터 구현하고, Postman + 실제 DB 조회로 전부 검증까지 끝낸 상태. 아직 **git commit 전** (사용자가 직접 커밋할 예정).

---

## 1. 완료된 것

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

- 서버: `./mvnw spring-boot:run` (devtools 붙어있어서 `mvn compile`만 해도 자동 재시작됨). **재시작될 때마다 세션이 날아가서 재로그인 필요.**
- 로그인: `POST /member/login` body `loginId=admin&loginPw=1234`
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

1. **대시보드 요약 카운트 정의가 임의적**: `AdminOrderMapper.selectSummary()`에서 "신규주문 = ORDER_STATUS가 PAYMENT_WAITING/PAYMENT_COMPLETED", "배송준비중/배송중/취소환불 = DELIVERY_STATUS 기준"으로 나눴는데, 원래 목업 데이터의 의미가 명확하지 않아서 제가 자체적으로 정의한 것. 실제 기획 의도와 다를 수 있음.
2. **대표 상품 선정 방식**: 한 주문에 상품이 여러 개면 `ORDERDETAIL` 중 `OD_ID`가 가장 작은(가장 먼저 담긴) 1건만 대표로 보여주고 나머지는 "외 N건"으로 표시. 다른 기준(예: 최고가 상품)이 필요하면 `resources/mappers/admin/AdminOrderMapper.xml`의 `selectOrderList` 서브쿼리 수정 필요.
3. **DELIVERY 행이 항상 있다고 가정함**: `updateDeliveryStatus`는 UPDATE만 하고 INSERT는 안 함. 지금은 시드 데이터 + 지금까지의 주문이 전부 DELIVERY 행을 갖고 있어서 문제없었는데, **만약 사용자님이 만들 주문(체크아웃) 플로우가 주문 생성 시 DELIVERY 행을 안 만든다면, 그 주문은 관리자 화면에서 상태 변경 시도할 때 "해당 주문의 배송 정보를 찾을 수 없습니다" 에러가 남.** 체크아웃 플로우 만들 때 DELIVERY도 같이 INSERT하거나, 아니면 AdminOrderService 쪽에서 UPSERT로 바꿔야 함 — 둘 중 어느 쪽으로 할지는 체크아웃 설계에 달림.
4. **orderId 표시가 그냥 PK 숫자**: 목업엔 `20260915-001` 같은 포맷이 있었는데, 실제로는 `PRODUCTORDER.ORDER_ID`(순수 숫자)를 그대로 보여줌. 원래 JSP 주석에도 "실제 바인딩 시 별도 포맷팅 로직 필요"라고 적혀있던 부분이라 필요하면 포맷팅 추가.
5. **페이지네이션 버튼(1~5)이 아직 정적 목업**: 실제 페이징 쿼리 연동 안 돼있음. 지금은 전체 목록을 한 번에 불러와서 클라이언트에서 필터링하는 방식이라 데이터 많아지면 페이징이 필요해짐.
6. **필터(기간/검색어/상태)는 서버 왕복 없이 클라이언트에서 처리**: 지금 데이터 규모에선 괜찮지만, 주문이 많아지면 서버 사이드 필터링(쿼리 파라미터로 WHERE 절 추가)으로 바꾸는 게 나을 수 있음.
7. **deliveryStatus 대소문자 변환**: JS는 소문자(`preparing` 등), DB/Java는 대문자(`PREPARING`)를 씀 — 변환은 `adminOrderDelivery.jsp`의 `normalizeOrder()`(응답 받을 때)와 저장 버튼 핸들러(`.toUpperCase()`, 보낼 때) 두 군데서만 일어남. 체크아웃 플로우 등 다른 곳에서 이 값을 다룰 때 대소문자 헷갈리지 않게 주의.

---

## 4. 참고 메모리 (Claude Code 메모리에 이미 저장됨, 다음 세션에도 자동으로 불러와짐)

- Jackson 3가 `tools.jackson.*` 네임스페이스를 씀 (Spring Boot 4.1.0 특성, `com.fasterxml.jackson.databind` 아님)
- 8797 포트에 devtools 붙은 서버가 이미 떠있는 경우가 많음 — 새로 띄우기 전에 `netstat -ano | grep :8797` 확인
- `LOGIN_SESSION`(진짜 세션 키) vs `LOGIN_MEMBER`(세션 아님, Model attribute 이름) 헷갈리지 않기
- admin/1234 계정의 bcrypt 해시는 jshell + 로컬 maven jar로 생성/검증 가능
