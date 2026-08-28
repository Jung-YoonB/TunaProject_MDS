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

## 4. 참고 메모리 (Claude Code 메모리에 이미 저장됨, 다음 세션에도 자동으로 불러와짐)

- Jackson 3가 `tools.jackson.*` 네임스페이스를 씀 (Spring Boot 4.1.0 특성, `com.fasterxml.jackson.databind` 아님)
- 8797 포트에 devtools 붙은 서버가 이미 떠있는 경우가 많음 — 새로 띄우기 전에 `netstat -ano | grep :8797` 확인
- `LOGIN_SESSION`(진짜 세션 키) vs `LOGIN_MEMBER`(세션 아님, Model attribute 이름) 헷갈리지 않기
- admin/1234 계정의 bcrypt 해시는 jshell + 로컬 maven jar로 생성/검증 가능
