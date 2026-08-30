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

## 4. 참고 메모리 (Claude Code 메모리에 이미 저장됨, 다음 세션에도 자동으로 불러와짐)

- Jackson 3가 `tools.jackson.*` 네임스페이스를 씀 (Spring Boot 4.1.0 특성, `com.fasterxml.jackson.databind` 아님)
- 8797 포트에 devtools 붙은 서버가 이미 떠있는 경우가 많음 — 새로 띄우기 전에 `netstat -ano | grep :8797` 확인
- `LOGIN_SESSION`(진짜 세션 키) vs `LOGIN_MEMBER`(세션 아님, Model attribute 이름) 헷갈리지 않기
- admin/1234 계정의 bcrypt 해시는 jshell + 로컬 maven jar로 생성/검증 가능

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
