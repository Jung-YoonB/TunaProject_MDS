# 관리자 화면 데이터 연동 인수인계

작성일: 2026-09-02 / 작성: JWC1226 (프론트)
대상: 관리자(admin) 도메인 담당자

검색·찜 화면을 실데이터로 연동하면서 관리자 화면 전체를 함께 점검했습니다.
**대부분 이미 정상 연동되어 있어 손대지 않았고**, 실제로 남은 항목과 제 작업이
관리자 코드에 남긴 영향만 아래에 정리합니다.

---

## 1. 점검 결과 요약

`${...}` 사용 개수만 보면 관리자 화면 대부분이 "정적 목업"처럼 보이지만,
**관리자 화면은 JSP에 EL을 쓰지 않고 REST + JS로 그리는 구조**라 그게 정상입니다.
(`@ResponseBody ApiResponse<T>` 엔드포인트 → `static/js/admin/*Service.js` → `static/js/views/*.js` 렌더링)

| 화면 | 연동 상태 | 비고 |
|---|---|---|
| `admin/addProduct.jsp` | ✅ 연동됨 | `categoryList`, `tagList` EL 바인딩 |
| `admin/admincouponView.jsp` | ✅ 연동됨 | `adminCouponService.js` (fetch 3) |
| `admin/addCoupon.jsp` | ✅ 연동됨 | `adminCouponService.registerCoupon` |
| `admin/adminOrderDelivery.jsp` | ✅ 연동됨 | `adminOrderService.js` (fetch 4) |
| `admin/adminMaintenance.jsp` | ✅ 연동됨 | `adminMaintenanceService.js` (fetch 2) |
| `admin/adminPage.jsp` | ❌ **목업** | 아래 2번 |

---

## 2. 유일하게 남은 연동: 관리자 마이페이지 (`admin/adminPage.jsp`)

`static/js/admin/adminMypageService.js` 가 하드코딩 값을 그대로 돌려줍니다.

```js
var MOCK_ADMIN = { memberName: '관리자', loginId: 'admin' };
function fetchProfile() { return Promise.resolve(MOCK_ADMIN); }
```

그래서 **어떤 계정으로 로그인하든 화면에는 항상 "관리자 (admin)"** 이 보입니다.

### 처리 방법

데이터는 이미 서버에서 넘어오고 있습니다.
`MemberController.myPageForm()` 이 `SessionConst.LOGIN_MEMBER`(= `"loginMember"`) 키로
실제 `MemberDTO` 를 담아 `admin/adminPage.jsp` 로 넘깁니다. 둘 중 하나만 하면 됩니다.

**방법 A — JSP에서 EL로 직접 렌더링 (권장)**

`adminPage.jsp` 의 4개 자리에 EL을 넣고, `adminMypageService.js` 와
`adminPage.js` 의 `render()` 호출을 걷어냅니다.

```jsp
<span id="profile-name">${loginMember.memberName}</span>
<span id="profile-subtitle">${loginMember.memberName} (${loginMember.loginId})</span>
<span id="val-name">${loginMember.memberName}</span>
<span id="val-login-id">${loginMember.loginId}</span>
```

**방법 B — 서비스 내부만 교체**

`fetchProfile()` 이 `Promise` 를 반환하는 시그니처만 유지하면
호출부(`views/adminPage.js`)는 건드릴 필요가 없습니다. JSP가
`window.serverAdminProfile` 같은 이름으로 값을 내려주고 그걸 읽게 하면 됩니다.
(같은 방식을 `product/wish.jsp` → `wishService.js` 에 적용해 뒀으니 참고하세요.)

> **주의:** `MemberDTO` 필드 중 이 화면이 쓰는 건 `memberName` / `loginId` 뿐입니다.
> 나머지 항목을 추가하려면 `MEMBER` 테이블에 실제 컬럼이 있는지 먼저 확인하세요.

---

## 3. 제 작업이 관리자 코드에 남긴 영향 (확인 필요)

검색 화면의 카테고리·태그 칩을 실데이터로 연동하면서, 관리자 쪽과 **같은 테이블을
조회하는 쿼리가 생겼습니다.** 관리자 코드를 직접 수정하지는 않았습니다.

### 3-1. 쿼리 중복

| 쿼리 | 관리자 쪽 | 사용자 쪽 (신규) |
|---|---|---|
| 카테고리 전체 조회 | `AdminProductMapper.selectAllCategories` | `ProductMapper.selectAllCategories` |
| 태그 전체 조회 | `AdminProductMapper.selectAllTags` | `ProductMapper.selectAllTags` |

관리자 전용 매퍼를 사용자 화면에서 끌어다 쓰면 도메인이 얽혀서 **의도적으로 따로 뒀습니다.**
합칠지 그대로 둘지는 담당자 판단에 맡깁니다. 합친다면 공용 매퍼(`common` 또는 `product`)
한 곳으로 모으는 쪽을 권합니다.

### 3-2. `TagOptionDTO` 를 사용자 쪽에서 참조하게 됨

`ProductMapper` / `ProductService` / `ProductServiceImpl` 이
`com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO` 를 import 합니다.

프로젝트 관례상 여러 도메인이 함께 쓰는 DTO는 `product.model.dto.mainPage` 로 옮기는 게 맞습니다.
(`CategoryDTO` 가 원래 admin의 `CategoryOptionDTO` 였다가 그렇게 합쳐진 선례가 있습니다.)

**다만 담당자가 지금 admin 패키지에서 작업 중이라 옮기면 충돌이 나서 그대로 뒀습니다.**
작업이 끝난 뒤 `TagOptionDTO` 를 `product.model.dto.mainPage` 로 옮기고
`@Alias("TagOptionDTO")` 를 유지한 채 import 4곳만 정리하면 됩니다.

---

## 4. 참고: 이번에 함께 고친 것 (관리자 도메인 밖)

같은 점검 과정에서 나온 것들이라 맥락 공유용으로만 남깁니다. 이미 수정 완료했습니다.

- `WishController` — `redirect:` 누락, 존재하지 않는 `/login` 으로 리다이렉트 (3곳)
- `CartController` — 담기/삭제 후 `cartList` 없이 뷰 반환(빈 장바구니로 보임), `removeCart` 비로그인 NPE
- `OrderController` — 매핑이 없는 `redirect:/product/cart`
- `wish.xml` — `PRODUCT_TITLE` 별칭 누락으로 상품명이 항상 null, LEFT JOIN + WHERE 로 대표 이미지 없는 상품 누락
- `searchProduct.jsp` — 모델명 불일치(`productList.product` vs `searchList`)로 검색 결과 0건
- `product.xml` `getList` — 검색 조건이 있을 때만 페이징하던 조건을 `pageSize > 0` 으로 변경

### 페이지 크기 기준 (2026-09-02 확정)

`ProductServiceImpl` 에 용도별 상수로 분리했습니다.
`MemberServiceImpl`(`COUPON_PAGE_SIZE`, `DELIVERY_PAGE_SIZE`),
`ReviewServiceImpl`(`MY_REVIEWS_PAGE_SIZE`) 과 같은 방식입니다.

| 화면 | 상수 | 값 |
|---|---|---|
| 상품 상세 리뷰 | `REVIEWS_PAGE_SIZE` | 5 |
| 검색 결과 상품 | `SEARCH_PAGE_SIZE` | 20 |
| 메인 상품 목록 | `NO_PAGING` | 0 (페이징 없음) |

---

# 작업 이어가기 (2026-09-02 21:xx 중단 시점)

작성: JWC1226 / 상태: **커밋 전, 로컬 수정만 있음**

## 지금 상태

`JWC_works` 브랜치. 수정 파일 21개 + 신규 `docs/`. **컴파일 BUILD SUCCESS**,
서버(8797) 실행해서 검색·상세·배너까지 실제 동작 확인 완료.

`.gitignore` 에 `.claude/`, `상품이미지/`(55MB 로컬 원본) 추가 - 스테이징에 안 올라감.
※ `uploads/` 밖에 git이 추적 중인 png는 **없음**(확인함). 따로 지운 파일 없음.

## 이번에 한 작업

### 검색 화면 (`searchProduct.jsp`) - 완료
- 모델명 불일치(`productList.product` → `searchList`)로 결과 0건이던 것 수정
- 이미지: `ProductListDTO.imagePath` 추가, `imagePath + titleImage` 조립
- "(예시)" 하드코딩 카드 3개 / 인기·신상품·할인 퀵필터 제거(CSS 포함)
- 카테고리 칩: CATEGORY 실데이터, **한 번 더 누르면 선택 해제**, 태그 유지
- 태그 칩: TAG 실데이터 29개, 중복 선택, 주소창 tag 값으로 상태 복원
- 페이지네이션: 하드코딩 1~5 → 실제 링크, keyword/category/tag 전부 유지
- 검색 폼 `action` `/search` → `/mds/searchList`
- 검색창 2곳 모두 `value`+`autocomplete="off"` (지워도 브라우저가 되채우던 문제)

### 상품 상세 (`productDetail.jsp`) - 완료
- **`detailPage()` 가 `detail` 을 model에 안 담아서 페이지 전체가 빈 값이었음**. 상품명은
  "코토나 타월 핸드타월 세트" 하드코딩 → `${detail.product.productTitle}` 로 교체
- 상세 페이지에서 리뷰가 아예 안 나오던 것 수정(`reviewList` + 페이지 정보 함께 담음)
- 리뷰 페이지네이션 UI 신규(5개/페이지). `#review` 해시로 리뷰 탭 유지
- 이미지 경로 오타 `/upload/` → `/uploads/` (3곳, 전부 깨져 있었음)
- 없는 상품 id(1~5 등) 접근 시 NPE 500 → 목록으로 리다이렉트

### 배너 (검색 화면 사이드바) - 완료
- `bannerList` 쿼리: 찜 많은 순 → **최근 등록순**(PRODUCT_ID DESC), 상품당 1장, 최대 5장
- `BannerDTO.imagePath` 추가, 슬라이드/도트를 같은 목록으로 렌더(개수 일치)
- 문구 3종은 그대로 두고 `index % 3` 순환

### 찜 화면 - 코드 완료, **검증 미완**
- `wish.xml`: `PRODUCT_TITLE` 별칭 누락으로 상품명이 항상 null이던 것 수정,
  LEFT JOIN+WHERE로 대표이미지 없는 상품이 사라지던 것 스칼라 서브쿼리로 교체,
  price/score/reviewCount 추가
- `wish.jsp` → `window.serverWishItems`, `wishService.js` 가 서버 목록 사용(목업 8건 삭제)
- 찜 해제/선택 삭제를 서버에 반영 후 새로고침

### 리다이렉트 버그 (Cart/Wish/Order) - 완료
- `redirect:/login`(매핑 없음) → `redirect:/member/login` 3곳
- 찜 추가 후 `"/mds/detail/N"`(뷰 이름 취급) → `redirect:` 붙임
- 담기/삭제 후 `cartList` 없이 뷰 반환해 빈 장바구니로 보이던 것 → `redirect:/cart/my-cart`
- `removeCart` 비로그인 NPE 가드 추가
- `redirect:/product/cart`(매핑 없음) → `redirect:/cart/my-cart`

### 페이지 크기 기준
`ProductServiceImpl` 상수로 분리. `product.xml` 페이징 조건은 `pageSize > 0` 으로 변경.

| 화면 | 상수 | 값 |
|---|---|---|
| 상품 상세 리뷰 | `REVIEWS_PAGE_SIZE` | 5 |
| 검색 결과 상품 | `SEARCH_PAGE_SIZE` | 20 |
| 메인 상품 목록 | `NO_PAGING` | 0 |

전체 상품 130개 = 7페이지(20×6 + 10) 확인.

## 남은 일 (우선순위 순)

1. **찜 화면 실행 검증** - `/wish/my-wish` 는 로그인이 필요해 아직 못 봄.
   일반 USER 계정으로 로그인해서 목록/이미지/찜 해제가 도는지 확인 필요.
   (관리자 계정은 안 됨 - 서버가 관리자 화면으로 돌려버림)
2. **리뷰 5개 상한 눈으로 확인** - 상품 35번이 리뷰 6개라 2페이지까지 나옴. 확인은 됐으나
   리뷰가 더 많은 상품으로 한 번 더 보면 좋음
3. `wish.jsp` 의 찜 카드에 **가격이 화면에 안 보임** - 원래 디자인이 그런지 확인 필요
4. `admin/adminPage.jsp` 목업 (위 2번 항목 참고, admin 담당자 몫)
5. `TagOptionDTO` 를 `product.model.dto.mainPage` 로 이동 (admin 작업 끝난 뒤)

## 확인용 명령

```bash
./mvnw -s <settings> compile          # BUILD SUCCESS 확인
./mvnw -s <settings> spring-boot:run  # 8797 포트
```
※ `C:\Users\user1\.m2\settings.xml` 이 0바이트 빈 파일이라 그냥 실행하면 Maven이 죽는다.
   그 파일을 지우면 기본값으로 정상 동작함.
