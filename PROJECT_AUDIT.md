# 프로젝트 전체 검증 결과 (버그 / 정책 검토 / 잠재적 위험)

## 이 문서 쓰는 법

- **항목 번호는 고정 ID다.** HANDOFF.md와 대화에서 "버그 5번", "정책 항목 11번", "잠재적 위험 19번"처럼 번호로 참조하는 곳이 많으므로 **재번호를 매기거나 번호를 재사용하지 말 것.** 새 항목은 항상 각 섹션의 마지막 번호 다음으로 이어 붙인다.
- **조치된 항목은 지우지 않는다** — `~~취소선~~` + `✅ 조치 완료` 표시로 남겨서, 같은 문제가 재발했을 때(실제로 여러 번 있었음) 이력을 바로 확인할 수 있게 한다.
- 담당 영역이 다른 항목(product/review/member 등)은 **기록만 하고 고치지 않는 것**이 이 프로젝트의 규칙. 팀원에게 공유해서 각자 고치도록 한다.
- **⛔ 이 문서를 갱신하는 것은 팀장(BJY) 한 사람만 한다.** 팀원(및 팀원이 쓰는 Claude)은 **읽기 전용 참고 자료로만** 쓸 것 — 항목 추가·수정·삭제, 오류 정정 모두 하지 말 것. 고칠 내용이 있으면 직접 손대지 말고 팀장에게 전달하면 팀장이 반영한다. (`HANDOFF.md` / `HANDOFF_NEXT_SESSION_PROMPT.txt`도 동일)

## 현황 요약 (2026-09-02 기준)

| 섹션 | 항목 수 | 비고 |
|---|---|---|
| 버그 (기능이 실제로 깨져 있음) | 18개 — 조치 완료 6 · 부분 조치 3 · 미해결 9 | **2026-09-02 밤 1번(세션 키 오독 → 쿠폰·좋아요 500)·16번(cart/wish 404) 조치 완료.** 남은 미해결은 product/member 영역의 오래된 항목들 |
| 정책적 고려가 필요한 부분 | 11개 — 조치 완료 1 | **11번(리뷰 삭제 후 재작성)은 2026-09-01 결정·구현 완료 → 같은 날 방식 재변경**(`REVIEWHISTORY` 테이블 폐기 → `REVIEW.REVIEW_STATUS` 소프트 삭제, HANDOFF 3-47). **product 영역 집계 3곳 필터 추가가 아직 미반영** |
| 잠재적 위험 요소 | 27개 — 조치 완료 10 | **19·21·22번은 "브라우저가 자동으로 붙이는 상태"(`:visited`/`:focus`/`[hidden]`)를 hover처럼 다루면 안 된다는 같은 계열.** **25·26·27번(2026-09-02 신규)은 "같은 규칙이 서버·화면 두 곳에 따로 적혀 갈라지는" 계열** — 금액 계산·정책 상수·뷰 이름. 조치 완료지만 재발하기 쉬운 유형이라 새 기능마다 확인할 것. **20번(`style_user.css` 최상위 `#id` 102개)·24번(추가 이미지 표시/검증 불일치)은 미조치** |
| ⚠️ 팀 공유 필요 | — | **백엔드 커밋이 타 담당자 프론트 파일을 조용히 삭제/개조한 사고 2건 확인**(`0e37e8f`, `0d46824`) — 아래 "조치 완료 (2026-09-01)" 참고 |
| 클린으로 판단된 항목 / 추가 제안 | — | SQL Injection 0건, PasswordEncoder 정상 등 |

---

## 감사 개요

2026-08-30~31, Claude Code와 함께 프로젝트 전체 파일을 훑어보며 진행한 감사 결과. HANDOFF.md와 마찬가지로 **git commit 대상 아님**(사용자가 직접 관리) — 팀원과 공유해서 각자 담당 영역을 고칠 수 있도록 만든 문서. 새로 발견되거나 조치된 내용이 있으면 이 파일에 계속 업데이트할 것.

**방법론**: 코드베이스를 회원/쿠폰, 상품/리뷰, 전체 보안·설정 3개 영역으로 나눠 병렬로 조사(각 영역 담당자 없이 코드만 보고 조사) + admin 3종 기능(상품/주문/쿠폰)은 이번 세션에서 계속 다룬 영역이라 별도로 직접 재검토. 전부 **읽기 전용 조사**였고, 아래 "조치 완료" 표시가 없는 항목은 전부 미수정 상태.

**최종 점검(2026-08-31)**: 이번 세션에서 실제로 수정한 전체 diff(39개 파일)를 `/code-review`로 한 번 더 검증. `util.FileUploadUtil.saveFile()`이 이번 리팩토링(orphan 방지) 이후 호출부가 하나도 안 남은 죽은 메서드로 남아있던 것을 발견해서 삭제(전체 코드베이스 grep으로 호출부 0건 확인 후 제거). 그 외 정합성 문제 없음 확인. 이후 `mvnw compile` + 서버 재기동 + 전체 admin/member 주요 엔드포인트 스모크 테스트(전부 200 확인) + 파일 정합성 검사 기능으로 이번 세션에서 만든 테스트 파일이 하나도 안 남아있는 것(orphan 0건) + DB에도 이번 세션 테스트 데이터가 하나도 안 남아있는 것까지 확인 완료.

---

## 조치 완료 (2026-09-01, 나머지 페이지 CSS/JS 규격화 세션 — HANDOFF.md 3-42)

- **`userUpdateInfo.js`가 통째로 삭제돼 회원정보 수정 화면이 죽어 있던 것 복구** — `member/userUpdateInfo.jsp`가 `<script src="/js/userUpdateInfo.js">`를 로드하는데 그 파일이 없었음(404). 단순한 죽은 참조가 아니라 **화면 전체가 무반응 상태**였음: 아코디언 8개 항목(이름/생년월일/성별/닉네임/비밀번호/휴대폰/이메일/배송지)의 펼침·저장·취소·중복확인 버튼이 전부 이 JS에 달려 있었기 때문.
  - **원인 추적**: 파일은 `dbd3a75`(#FE015_260827, 프론트 담당 JWC)가 정상 생성 → **`0e37e8f`(#BE005_260826 "주문 결제 기능 추가", 작성자 KGH)가 삭제**. 주문/결제와 무관한 프론트 파일이 백엔드 커밋에 휩쓸려 지워진 것. `Admin_branch`/`Coupon_branch`/`FrontSet_branch`/`Product_branch`/`Review_branch`/`Start_branch` 6개 브랜치엔 아직 살아있음.
  - **⚠️ 반복되는 패턴**: 위 "`/member/couponView` 500" 항목의 원인(`0d46824`, 동일 작성자가 기존 페이징 문을 비페이징으로 개조)과 **완전히 같은 종류의 사고**다. 백엔드 커밋이 다른 담당자 영역 파일을 조용히 지우거나 개조하는 일이 최소 2회 확인됨 — **팀에 공유해서 병합 시 주의 필요.**
  - **조치**: 원본을 그대로 되돌리지 않고 현재 컨벤션에 맞춰 `js/views/userUpdateInfo.js`로 재작성. 중복확인 3종의 직접 `fetch` 호출을 기존 `member/memberService.js`(`window.MemberService`) 재사용으로 바꿔 중복 코드 약 45줄 제거. 원본 셀렉터(id 28개 + class 4개)가 현재 JSP와 전부 일치하는 것을 대조 확인 후 작업. 라이브 검증 완료(`/member/updateInfo` 200, id 28개 전부 렌더, 중복확인 API 3종 정상 응답).
- **낡은 주석 2곳 수정** — `userUpdateInfo.jsp` / `userWithdraw.jsp`가 "실제 회원정보 UPDATE 백엔드가 없어(MemberMapper에 UPDATE 문 없음)"라고 서술하고 있었으나 사실이 아님. `96e4ee9`(#BE014)가 `MemberController`에 `POST /member/updateName`·`/updateBirth`·`/updateGender`·`/updateNickname`·`/updatePhone`·`/updateEmail`·`/updatePassword`·`/withdraw` 8개와 `MemberMapper.xml`의 대응 `<update>` 문 8개를 이미 전부 구현해 둠 → 현재 상태에 맞게 재작성.
- **`signUp.jsp`의 절대경로 `<script src="/js/...">` 2곳을 `<c:url>`로 통일** — 컨텍스트 패스가 `/`가 아니게 되면 깨지는 형태였음. 이로써 프로젝트 전체 JSP에 절대경로 script 참조 0건.

### 신규 항목 (버그, 미해결)

13. **회원 탈퇴 링크가 404** — `member/userUpdateInfo.jsp:201`이 `${contextPath}/member/userWithdraw`(GET)로 링크하는데 `MemberController`에 그 매핑이 없어서 404가 난다. 백엔드에 실제로 있는 것은 `POST /member/withdraw`(#BE014). 화면(`member/userWithdraw.jsp`)은 멀쩡히 존재하는데 **도달할 경로가 없는 상태**. → 탈퇴 기능을 실제로 연결할 때 `POST /member/withdraw` 호출 후 결과 화면으로 보내는 흐름으로 같이 정리 필요. (member 영역 = 팀장 담당이나, 서버 연동이라 3-42 범위 밖으로 두고 기록만 함)
14. **`product/searchProduct.jsp`를 반환하는 컨트롤러가 없음** — 이 뷰를 `return`하는 코드가 프로젝트 전체에 하나도 없어서 어떤 경로로도 렌더링되지 않는다. `ProductController.getList()`/`detailPage()`는 둘 다 `return "redirect:home/home"`이라 실제 뷰를 안 탄다(3-6에서 `productDetail.jsp`를 검증 못 한 것과 같은 원인). 헤더 검색창이 가리키는 `/search`도 컨트롤러 미구현(404). → **화면/JS는 규격화해 뒀으나(3-42) 아무도 볼 수 없는 상태.** product 담당 영역이라 기록만 함.

15. **세션 만료 상태로 `/member/updateInfo` 접근 시 500** — `MemberController.updateInfoForm()`이 세션에서 꺼낸 `MemberDTO`를 null 검사 없이 바로 사용한다. 같은 클래스의 `myPageForm()`은 3-30-18에서 "세션은 살아있는데 회원 행이 없어진 경우" 가드를 추가했는데, 이 메서드엔 그에 해당하는 가드가 없다. 재현: 로그인 → devtools 재시작 등으로 세션 소멸 → `/member/updateInfo` 요청 → 500(재로그인하면 정상 200). 다른 화면들은 같은 상황에서 302(로그인 리다이렉트)로 빠진다. → `myPageForm()`과 동일한 방식으로 null 가드 + 로그인 리다이렉트 추가 필요. (2026-09-01 3-42 세션의 회귀 테스트 중 발견, member 영역이나 이번 범위 밖이라 기록만 함)
16. ~~**`cart` / `wish` 화면이 도달 불가 — 4개 경로 전부 404** (2026-09-01 `main` 배포 후 실측, HANDOFF 3-44)~~
    - 실측: `/member/cart` `404` · `/member/wish` `404` · `/cart` `404` · `/wish` `404`. **`header.jsp`의 장바구니/찜 아이콘이 링크하는 `/cart`·`/wish`가 404**라 사용자가 어떤 경로로도 두 화면에 들어갈 수 없다.
    - 원인: `product/cart` 또는 `product/wish` **뷰 이름을 반환하는 컨트롤러 메서드가 프로젝트 전체에 0곳**이다.
      - `MemberController`의 `@GetMapping("/cart")`·`@GetMapping("/wish")`는 wish/cart 패키지 이원화 정리(3-34) 때 제거됨.
      - `CartController`(`@RequestMapping("/cart")`) / `WishController`(`@RequestMapping("/wish")`)에는 `/add-cart`·`/my-cart`·`/remove-cart` / `/insert-wish`·`/my-wish`·`/remove-wish` 같은 **하위 경로만 있고 목록 화면용 bare 매핑이 없으며**, 그 메서드들도 전부 `redirect:home/home` 또는 `redirect:/login`만 한다.
    - **화면 자체는 완성돼 있다** — `product/cart.jsp`·`product/wish.jsp`와 CSS, 그리고 3-42에서 규격화한 JS 4개(`product/cartService.js`, `product/wishService.js`, `views/cart.js`, `views/wish.js`)가 전부 준비된 상태. **컨트롤러 진입점만 생기면 바로 뜬다.**
    - **필요한 조치(서버 담당자)**: `CartController`/`WishController`에 목록 화면용 bare `@GetMapping` 하나씩 추가해서 각각 `product/cart` / `product/wish`를 반환하면 됨.
    - **담당자가 달라 아직 연결 전인 구간이며 팀장이 인지하고 있음** — 테스트 케이스 정리와 함께 구현 요청 예정. 프론트 쪽에서 임의로 컨트롤러를 만들지 말 것.

   - **✅ 조치 완료 (2026-09-02 밤, HANDOFF 3-57) — `JWC_works` 병합으로 컨트롤러 진입점이 붙었다.** 로그인 상태에서 `/wish/my-wish`·`/cart/my-cart` 200 확인. 장바구니는 DB(`CART`) 기반으로 동작하고, 찜은 `wish.jsp` → `window.serverWishItems` → `wishService.js` 경로로 서버 목록을 쓴다.
17. ~~**상품이 2건 이상인 주문에서 대표 상품 외 나머지가 리뷰 작성 경로를 잃음**~~ **✅ 조치 완료 (2026-09-01, HANDOFF 3-45)**
    - 증상: 주문/배송 조회 화면은 주문 1건당 카드 1개에 리뷰 버튼 1개를 두고 그 상태를 **대표 주문상세(OD_ID 최솟값) 1건 기준**으로만 판정했다. 그래서 상품이 2건 이상인 주문에서 대표만 리뷰를 쓰면 **버튼이 "리뷰 작성 완료"로 잠겨 나머지 상품은 영원히 리뷰를 쓸 수 없는데**, 마이페이지 배지는 `ORDERDETAIL` 전건을 세므로 "작성 가능 N개"라고 계속 표시되는 불일치가 생겼다.
    - 발견 경위: 리뷰 재작성 차단 기능(정책 11번) 수동 테스트용으로 만든 **상품 2건짜리 주문**에서 드러남. 시드 주문이 대부분 상품 1건이라 그동안 안 보였을 뿐이며, **이번 리뷰 작업과 무관한 기존 결함**이다.
    - 조치: `MemberMapper.selectDeliveriesByMemberId`에 "주문별로 아직 리뷰를 안 쓴 주문상세 중 최소 `OD_ID`"를 구하는 서브쿼리를 추가하고, 리뷰 링크용 `OD_ID`를 **대표 상품이 아니라 그 값**으로, `HAS_REVIEW`를 **그 값이 없을 때(=전 상품 작성 완료)만 1**로 바꿈. `odId`는 DTO 주석에도 "리뷰 작성 연결용"이라 명시돼 있고 표시용 이름/수량/이미지는 대표(`rep`)가 따로 담당하므로 **JSP는 변경하지 않았다.**
    - 검증: 수정 쿼리를 DB에 직접 실행해 주문 7(상품 2건, 대표만 작성)이 `OD_ID=9` + 버튼 활성으로 나오는 것, 배지(1개)와 화면 기준이 일치하는 것 확인.

18. ~~**마이페이지 빠른메뉴의 "리뷰 작성" 타일이 클릭해도 아무 반응이 없음**~~ **✅ 조치 완료 (2026-09-02, HANDOFF 3-54-2)**
    - **조치**: 아래 제안(무조건 주문·배송으로)보다 한 단계 낫게, **같은 화면의 "리뷰 작성" 섹션과 동일한 기준**으로 분기시켰다. 쓸 리뷰가 있으면 `/review/write?odId=<가장 먼저 쓸 주문상세>`, 없으면 `/member/orderDelivery?status=delivered`. 타일과 하단 `.review-cta-badge`가 같은 `reviewTileUrl`을 재사용하므로 두 진입점이 어긋날 수 없다.
    - 이를 위해 `MemberMapper.selectNextReviewableOdId`를 신설. **`countReviewableOrderDetails`와 조건이 완전히 같아야** 배지 숫자와 실제 이동 대상이 어긋나지 않는다(둘 다 `REVIEW_STATUS`를 보지 않음 — 정책 11번). 두 쿼리는 항상 같이 고칠 것.
    - 아래는 발견 당시 기록(원문 유지):

    - `member/myPage.jsp:88`이 `href="#"`다. 바로 위 주석대로 `/review/write`는 `odId`가 필수라 "리뷰 작성 목록" 진입점이 없어서 placeholder로 둔 것인데, 3-42에서 도입한 `common/placeholderLinks.js`가 `href="#"`의 페이지 상단 점프를 막으면서 **클릭 시 완전히 무반응**이 됐다.
    - 문제는 이 타일에 `${reviewableCount}` 배지까지 표시된다는 점 — 눌러야 할 것처럼 보이는데 아무 일도 안 일어난다(실사용 중 실제로 혼동 발생).
    - **한 줄 수정으로 해결 가능**: 같은 화면의 "리뷰 작성" 섹션이 이미 쓰고 있는 동작하는 링크로 보내면 된다.
      `href="<c:url value='/member/orderDelivery'><c:param name='status' value='delivered'/></c:url>"`
    - **미수정 사유: 2026-09-01 현재 프론트 담당자가 뷰(JSP)를 작업 중이라, JSP를 건드리면 충돌이 커진다는 팀장 판단.** 뷰 작업이 끝난 뒤 적용할 것.

19. **`cart` 패키지에 미사용 `import` 3건** (2026-09-01 전체 점검에서 발견, **미수정**)
    - `cart/Controller/CartController.java` : `RequestParam`
    - `cart/model/service/CartService.java` : `CartListDTO`, `List`
    - 기능 영향은 전혀 없는 정리 대상이지만, **cart 서버 영역은 담당자가 다르고 작업 중일 수 있어** 임의로 건드리면 병합 충돌만 만든다는 판단으로 기록만 함. 해당 담당자가 정리할 것.
    - 같은 점검에서 나온 죽은 클래스 `coupon/model/getCouponDTO.java`(참조 0건)는 **삭제 완료**(HANDOFF 3-45-2).

> **참고(버그 아님): 빠른메뉴 "주문·배송 조회" 배지 숫자의 기준** — `countActiveDeliveries`는 **"아직 끝나지 않은 주문 건수"** 를 주문 단위로 센다(`ORDER_STATUS != 'CART'` + `DELIVERY_STATUS`가 `NULL`이거나 `DELIVERED`/`CANCELED`가 아님). 즉 **DELIVERY 행 없음 + 배송준비중 + 배송중 + 배송출발**이 모두 포함되고 배송완료·취소만 빠진다. "배송중/배송출발만 센다"는 오해가 있었어 확인함(2026-09-01). 라벨이 "주문·배송 조회"라 숫자의 의미가 드러나지 않으므로, 뷰 작업 시 `aria-label`이나 툴팁에 "진행 중인 주문 N건"을 넣으면 명확해진다.


### 신규 항목 (잠재적 위험)

20. **`style_user.css`에 스코프 없는 최상위 `#id` 선택자가 102개 남아 있음** (2026-09-01 실측 - 원래 "약 90개"로 적었던 것을 정정) — `header.jsp`가 CSS 4개를 전 페이지에 무조건 로드하는 구조라, 잠재적으로 3-5/3-6과 같은 계열의 전역 leak 위험. 특히 **`#title`은 서로 다른 JSP 10개가 쓰고 있는 매우 일반적인 id**다(`addCoupon`/`admincouponView`/`login`/`signUp`/`usercouponView`/`userUpdateInfo`/`userWithdraw`/`orderComplete`/`payment`/`deliveryAddress`). 현재는 대부분 `.login-card #title`처럼 페이지별로 한 단계 더 스코프한 규칙이 덮고 있어 문제가 안 보이지만, **최상위 `#title{}`과 `#title h1`/`#title p`는 여전히 스코프 규칙이 없는 페이지로 새어 나간다.** `#buttonArea`/`#cancel-button`/`#add-button`/`#product-info` 같은 범용 id도 같은 위험.
    - **`body{}`/`main{}`은 0건 유지** — 3-37에서 3곳, 3-49에서 리뷰 작성 블록의 `*{}`/`h2{}`/`button:focus-visible{}` 등을 정리해 태그·전체 선택자 leak은 전부 없앴다. 남은 건 `#id`뿐이다.
    - 대조 사례: `style_admin.css`는 최상위 선택자가 1개뿐으로 깔끔하다.

21. **클릭 후 뒤로가기로 돌아왔을 때 "눌린 잔상"이 남는 패턴** (2026-09-01 발견 + 조치, HANDOFF 3-51/3-51-1)
    - **원인**: 브라우저는 뒤로가기로 페이지를 복원할 때 **직전에 포커스였던 요소로 포커스를 되돌린다.** 그래서 클릭한 링크/버튼에 `:focus`가 계속 맞고, `X:hover, X:focus { background... }`처럼 **hover와 같은 강조를 `:focus`에도 준 규칙**이 있으면 강조가 그대로 남는다.
    - **조치 완료**: 클릭 요소 7곳(`.quick-menu-tile`·`.list-row` user/admin, `#product-list .product-rating`, `.info-edit-header`, `.btn-save-field`)의 `:focus` → **`:focus-visible`** 로 교체. `:focus-visible`은 키보드 이동일 때만 맞으므로 접근성은 유지된다. **폼 입력(`input`/`select`/`textarea`)의 `:focus`는 의도된 동작이라 그대로 뒀다.**
    - **앵커는 밑줄이 별도 문제**: `default.css:21`의 전역 `a:hover, a:focus, a:active{text-decoration:underline}` 때문에 강조만 옮기면 이번엔 밑줄이 남는다. **`default.css`는 다른 팀도 함께 쓰는 공통 규약이라 수정 금지** → `style.css`에 `a:focus:not(:focus-visible){text-decoration:none}`(명시도 `(0,2,1)` > `(0,1,1)`)로 전역 처리.
    - **앞으로 지킬 것**: 클릭 요소에 hover 같은 강조를 줄 땐 **`:focus`가 아니라 `:focus-visible`** 을 쓸 것. 19번(`a:visited` 함정)과 같은 계열 — "브라우저가 자동으로 붙이는 상태"를 hover처럼 다루면 안 된다.
22. **`hidden` 속성으로 감출 요소에 `display`를 지정하는 클래스를 쓰면 안 감춰짐** (2026-09-01 발견 + 조치, HANDOFF 3-48-1)
    - 브라우저 기본 `[hidden]{display:none}`은 **작성자 CSS보다 우선순위가 낮다.** 상품 등록의 옵션 삭제 버튼이 `.tag-remove{display:flex}`를 재사용하고 있어서, JS가 `hidden`을 켜도 계속 보이고 클릭까지 됐다.
    - 조치: `.product-register .option-remove[hidden]{display:none}`으로 명시적으로 덮어쓰고, 클릭 핸들러에도 "행이 1개 이하면 무시" 방어를 넣음.
    - 19번·21번과 같은 계열(작성자 CSS가 브라우저 기본 동작을 이기는 함정).

23. ~~**체크아웃이 `PRODUCTORDER.TOTAL_PRICE`를 0으로 저장하는 것으로 보임**~~ **✅ 해소 확인 (2026-09-02, HANDOFF 3-56-1)**
    - 21번 이후 앱에서 만들어진 실주문 10건을 전수 확인한 결과 **16:42 이후 `TOTAL_PRICE=0`이 한 건도 없다.** 21번은 그 사이 수정된 옛 코드의 산물이었다(담당자 수정분이 `c3adbc7`로 들어옴). 현재 코드는 `verifiedData.setTotalPrice(totalPrice)` → `insertProductOrder` 로 정상 저장한다.
    - 아래는 발견 당시 기록(원문 유지):
    - 실측: `ORDER_ID=21`(`user01`이 앱에서 직접 넣은 실주문, `PAYMENT_COMPLETED`, 품목 2건)의 `TOTAL_PRICE`가 **0**인데, 그 주문의 `SUM(PRICE_FIX * QTY)`는 **320,900원**이다.
    - 같은 시점 더미 주문 11건은 전부 `단가합 − 할인합 = TOTAL_PRICE`가 정확히 일치했으므로, **데이터가 아니라 체크아웃 코드 쪽 문제**로 보인다.
    - 영향: 주문/배송내역 카드의 "금액"이 `0원`으로 뜬다. 마이페이지 등급 산정(`MEMBER.TOTAL_AMOUNT`)에도 주문 금액이 안 쌓인다.
    - **order/payment 담당 영역이라 기록만 함.** 재현: 로그인 → 장바구니 → 결제 → `SELECT ORDER_ID, TOTAL_PRICE FROM PRODUCTORDER ORDER BY ORDER_ID DESC`.

24. **상품 등록의 "추가 이미지"에 필수 표시(`*`)는 있는데 검증이 없음** (2026-09-02, **의도적 보류**, HANDOFF 3-54-3)
    - 팀장 요청으로 `추가 이미지`·`상품 설명` 헤딩에 필수 표시를 붙였는데, **추가 이미지만 화면·서버 어느 쪽에도 검사가 없어** 안 넣어도 등록된다.

      | 항목 | 화면 검증 | 서버 검증 |
      |---|---|---|
      | 대표 이미지 | ✅ | ✅ |
      | **추가 이미지** | ❌ | ❌ |
      | 설명 이미지 | ✅ | ✅ |
      | 상품 설명 | ✅ | ✅ |
    - **보류 사유**: 발견 시점에 팀원들이 상품을 일괄 등록하는 중이라, 검증을 넣으면 대표 이미지만 있는 상품이 막힌다는 판단. 등록이 끝난 뒤 **(a) 검증을 추가하거나 (b) 필수 표시를 떼거나** 둘 중 하나로 정리할 것 — 지금은 표시와 동작이 어긋난 상태다.

25. ~~**같은 금액을 서버와 화면이 다른 방식으로 계산해 최대 2원 어긋남**~~ **✅ 조치 완료 (2026-09-02, HANDOFF 3-56-3)**
    - 결제 금액을 서버(`OrderServiceImpl`)는 BigDecimal로 `상품가 x (1-쿠폰) x (1-등급)` 을 **한 번에 곱하고 마지막에 한 번만 HALF_UP**, 화면(`views/payment.js`)은 **단계마다 floor** 했다. 전수 검사 결과 **67.35% 조합에서 불일치**(최대 2원).
    - `clientPaidAmount`는 서버가 받아 DTO에 담기만 하고 **검증에 쓰지 않아** 결제가 실패하지는 않는다. 대신 **화면에 보이던 금액과 실제 결제 금액이 다르게** 저장된다 — 조용해서 더 위험한 유형.
    - 조치: 할인율이 소수 둘째 자리까지만 쓰이는 점을 이용해 **100 단위 정수 연산**으로 서버와 같은 값을 내는 `applyRates()`로 교체(부동소수 오차 없음). 표시용 쿠폰/등급 금액은 총 할인액을 쪼개 만들어 **쿠폰 + 등급 = 총 할인액**이 항상 맞아떨어지게 했다. 1,250만 건 전수 검사 불일치 0건.
    - **앞으로 지킬 것**: 금액을 서버와 화면이 각각 계산하면 반드시 갈라진다. 어느 쪽이 정답인지(= 저장되는 값) 정하고 다른 쪽이 **그 계산을 그대로 흉내내도록** 만들 것. 반올림 시점·단위까지 같아야 한다.

26. **매직넘버가 서버·화면 양쪽에 흩어져 정책이 갈라지는 패턴** (2026-09-02, 두 건 조치 완료 — HANDOFF 3-56-2/3-56-3)
    - 실제로 두 번 나왔다. **배송비**(`50000`/`3000` 4곳) — 주문 47번과 49번이 조건이 같은데 3,000원 갈렸다. **포인트 최소 사용액**(`1000` 3곳).
    - 조치 방식: **서버를 단일 출처로** 삼고 화면이 그것을 받아 쓰게 했다.
      - 배송비 → `OrderServiceImpl.FREE_SHIPPING_THRESHOLD` / `SHIPPING_FEE` + `calcDeliveryFee()`. 화면(`cartService.js`)은 물리적으로 합칠 수 없어 상수로 빼고 상호 참조 주석을 달았다.
      - 포인트 최소액 → `OrderServiceImpl.POINT_MIN_USE` → `PaymentViewDTO.pointMinUse` → JSP 문구 + `window.pointMinUse` → JS. **JSP/JS에 숫자가 하나도 없다.**
    - **앞으로 지킬 것**: 정책 값(임계금액·수수료·최소단위)을 화면에 직접 적지 말 것. 서버에서 내려보내거나, 불가피하면 상수로 빼고 양쪽에 "한쪽만 바꾸지 말 것" 주석을 남길 것.

27. **뷰 이름을 문자열로 반환하는 구조라 파일명을 고치면 조용히 404가 난다** (2026-09-02 발견·조치, HANDOFF 3-56-5)
    - pull에서 JSP 파일명 오타가 고쳐졌는데(`userOderDelivery.jsp` → `userOrderDelivery.jsp`) **`MemberController` 한 줄이 옛 이름을 반환**해 `/member/orderDelivery`가 404였다. `OrderController` 쪽은 새 이름이라 멀쩡했고 **마이페이지에서 들어가는 경로만** 죽어 있었다.
    - 컴파일러가 잡아주지 않고 그 화면을 실제로 열어봐야만 드러난다. **파일명을 고칠 땐 `grep -rn "<옛이름>"` 으로 참조를 전부 확인할 것.**
    - 같은 계열로 `redirect:/product/cart`(컨트롤러 없음 → 404)도 함께 고쳤다(`/cart/my-cart`).

---

## 조치 완료 (2026-08-31 저녁, 프론트 CSS/JS 규격화 검증 세션)

- **`/member/couponView` 500 에러 수정** — `MemberServiceImpl.listCoupon()`이 호출하는 페이징 버전 `MemberMapper.selectCouponsByMemberId(memberId, offset, pageSize)`에 대응하는 MyBatis XML 문(`<select id="selectCouponsByMemberId">`)이 아예 없어져 있었음(비페이징 버전 `selectAllCouponsByMemberId`만 남음 — 이건 `order` 패키지의 결제 화면 쿠폰 선택 드롭다운이 별도로 쓰고 있어 그대로 둠). `mappers/member/MemberMapper.xml`에 페이징 버전 문을 새로 추가해서 해결(기존 비페이징 쿼리와 동일한 WHERE/ORDER, `selectDeliveriesByMemberId`와 같은 `OFFSET/FETCH` 패턴 재사용). 라이브 검증 완료(테스트 계정으로 200 확인, 테스트 데이터 정리 완료).
  - **⚠️ 2026-09-01 원인 추적 완료 — 이건 `frontfix`/JWC 브랜치 문제가 아니라 거의 모든 브랜치에 퍼져 있는 문제임.** `git log --all -S`로 이 XML을 건드린 커밋을 전수 조사한 결과 딱 2개(둘 다 KGH 작성): `1e62318`(#BE005_260826, 08-28, 최초 추가) → `0d46824`(**#BE014_260830, 08-31 10:26, 커밋 본문 "병합 후 일부조정"**). 문제는 후자로, **기존 페이징 문의 id를 `selectCouponsByMemberId` → `selectAllCouponsByMemberId`로 바꾸고 `OFFSET #{offset} ROWS FETCH NEXT #{pageSize} ROWS ONLY` 한 줄을 삭제해서 비페이징 문으로 개조**했음(결제 화면 쿠폰 드롭다운용 비페이징 쿼리가 필요했던 것으로 보이는데, 새 문을 추가하지 않고 기존 문을 재활용함). Java 인터페이스엔 `selectAllCouponsByMemberId`/`selectCouponsByMemberId`/`countCouponsByMemberId` 3개가 그대로 선언돼 있어 컴파일은 통과하고 **호출 시점에만 `BindingException`으로 500**이 남. JWC의 CSS 통합 커밋(`cb082dd`)은 이 파일을 건드린 적 없음.
  - **영향 범위**: `0d46824`를 포함하는 모든 브랜치 — `BJY_works`, `Member_branch`, `Util_branch`, `frontfix`, `origin/JJY_Work`, `origin/JWC_works`, `origin/KGH_works`. **특히 `BJY_works`에서도 `MemberServiceImpl.listCoupon()`이 여전히 페이징 메서드를 호출하는데 XML 문이 없어서 `/member/couponView`가 동일하게 500임(코드 대조로 확인).** → **`frontfix`에 넣은 수정(비페이징 문은 그대로 두고 페이징 문을 별도로 추가)을 `BJY_works`에도 그대로 적용해야 함.**
  - **✅ 2026-09-01 `BJY_works`에 적용 완료** (HANDOFF.md 3-43). `selectCouponsByMemberId`(페이징) 문을 추가하고 비페이징 문은 그대로 유지. 라이브 검증까지 마침 — USER 계정으로 쿠폰 0건/3건 두 경우 모두 200, 쿠폰 카드 3건 정상 렌더, `?page=1,2` 동작 확인(테스트 데이터 정리 완료). 재발 방지로 XML 양쪽 문에 "둘 다 필요하니 하나로 합치지 말 것 + 사고 커밋 `0d46824`" 주석을 달아둠.
  - **남은 브랜치**: `Member_branch`, `Util_branch`, `origin/JJY_Work`, `origin/JWC_works`, `origin/KGH_works`는 아직 미적용. `frontfix`는 `BJY_works` 병합으로 내려받게 됨.
- **`style_user.css`의 스코프 없는 `body{}`/`:root{}` 3곳 재발 수정** — HANDOFF.md 3-5/3-6에서 이미 크게 겪었던 "header.jsp가 전체 CSS를 전역 로드 + 스코프 없는 태그 선택자"버그가, 이번 CSS 규격화(21개 페이지별 CSS → `style_user.css`/`style_admin.css` 통합, 담당: JWC1226) 과정에서 옛 `style_member.css`/`style_payment.css`/`style_addreview.css`를 "원본 내용" 그대로 이어붙이면서 그대로 재발했음. `style_admin.css`는 이 문제 없이 깔끔하게 스코프됨(대조적으로 잘 됨) — `style_user.css`만 해당. 자세한 내용은 HANDOFF.md 새 섹션 참고.

## 조치 완료 (2026-08-31)

- **리뷰 텍스트 500자 서버 검증 추가** — `ReviewServiceImpl.writeReview()`. DB 컬럼(`REVIEW_TEXT VARCHAR2(1500)`)이 바이트 기준이라 한글 500자(3바이트×500=1500)까지만 안전한데 서버 검증이 없었음. 화면의 `maxlength="500"`과 동일 기준으로 서버에도 추가. 라이브 검증 완료(아래 참고).
- **리뷰 이미지 업로드 콘텐츠타입 검증 추가** — `ReviewServiceImpl`에 admin 상품 등록과 동일한 방식으로 파일 검증 추가(이후 매직 바이트 방식으로 강화됨, 아래 참고). 라이브 검증 완료.
- **`uploads/product/` 폴더의 orphan 파일 8개 삭제** — DB(`PRODUCTIMAGE.PRODUCT_IMAGE_SAVE_NAME`)에 전혀 참조되지 않는(즉 어떤 화면에서도 절대 노출될 수 없는) 파일들을 디스크와 DB를 직접 대조해서 확인 후 삭제. 이번 세션의 상품 등록 테스트/삭제 과정에서 남은 것으로 추정(트랜잭션 롤백/CASCADE 삭제가 DB에만 적용되고 파일엔 적용 안 되는 구조 — 아래 "잠재적 위험 7" 참고).
  - 참고: 반대로 **DB엔 있는데 디스크엔 없는 파일명 13개**도 발견됨(`uuid_beef_main.jpg` 등) — 전부 `uuid_` 접두사가 붙은 초기 시드/샘플 데이터로 보이며, 실제 업로드된 적 없는 플레이스홀더 값으로 추정됨. 이건 "정리해야 할 orphan"이 아니라 애초에 실제 파일이 없는 시드 데이터라 별도 조치 안 함(필요하면 확인 후 정리).
    - **✅ 2026-09-01 해소 예정** — 디스크 쪽 고아 파일은 DB 초기화 후 10개를 삭제 완료(HANDOFF 3-44), DB 쪽 플레이스홀더 13개는 카테고리/태그 확정본 반영 스크립트(`sql/reset_category_tag.sql`, HANDOFF 3-46)가 `PRODUCT`를 전부 지우면서 `PRODUCTIMAGE`도 CASCADE로 함께 사라진다. **그 이후부터는 DB↔디스크가 실제로 일치하므로 `/admin/maintenance` 파일 정합성 검사가 의미 있게 동작한다.**
- **쿠폰 `couponValue` 타입을 `double` → `BigDecimal`로 변경** — `CouponDTO.couponValue`, `AdminCouponServiceImpl.registerCoupon()`. `discountPercent/100.0` 나눗셈 대신 `BigDecimal.valueOf(discountPercent, 2)`로 스케일을 직접 지정해서 나눗셈 자체를 없앰(부동소수점 이진 표현 오차 원천 차단). 스키마/API 모양은 그대로 유지. 라이브 검증 완료(쿠폰 등록/목록 정상).
- **관리자 상품 등록 + 리뷰 이미지 업로드에 매직 바이트 검증 추가** — 신규 `util.ImageValidationUtil`(JPG/PNG/WEBP 파일 시그니처 직접 확인)을 만들어 `AdminProductServiceImpl.checkImageType()`과 `ReviewServiceImpl.checkImageTypes()` 양쪽에서 재사용. 기존의 "클라이언트가 보낸 Content-Type 헤더만 확인" 방식을 대체(헤더는 조작 가능해서 신뢰 불가). 라이브 검증 완료(리뷰: 진짜 이미지가 아닌 파일을 PNG로 위장해서 올렸을 때 정상 거부, 정상 이미지+정상 리뷰 등록 성공 확인. 501자 리뷰 텍스트 거부도 함께 확인).
- **리뷰 이미지 업로드 500자/파일종류 서버 검증 라이브 재검증 완료** — 501자 텍스트 거부, 위장 파일 거부, 정상 케이스 성공 3가지 시나리오 모두 실제 API로 확인(테스트 데이터는 확인 후 삭제).
- **전체 프로젝트 낡은/오해 소지 있는 주석 정리** (2026-08-31, Java/JSP/매퍼 XML 전수 스캔 후 실제 코드와 대조 검증):
  - `productDetail.jsp:172-177` — "detailPage.xml의 getReviewList 쿼리에 조인 버그 있음"이라는 문장이 있었는데, 실제 쿼리를 직접 확인해보니 이미 `orderd.OD_ID`/`orderd.POP_ID`로 올바르게 조인되어 있어 사실이 아님 → 해당 문장만 제거(아직 유효한 TODO는 유지).
  - `productDetail.jsp:43-46` — "ProductDetailDTO에 avgScore/reviewCount/wishCount 필드 추가 필요"라는 TODO가 있었는데, 이미 세 필드 다 존재하고 바로 아래에서 실제로 쓰이고 있었음(작업 완료 후 주석 삭제를 안 한 것) → 주석 삭제.
  - `productDetail.jsp:90-92` — "OptionDTO에 popId/stock 필드 추가 필요"도 동일 패턴(이미 존재+사용 중) → 해당 문장만 제거, 나머지 설명(POP_ID 용도, 재고 표시 규칙)은 유지.
  - `searchProduct.jsp:10` — 존재하지 않는 옛 문자열 `"redirect:home/test"`를 가리키고 있었음(과거 `redirect:home/home`으로 리네임됨) → 현재 코드 기준으로 재작성.
  - `searchProduct.jsp:11` — "CategoryDTO에 categoryId 없음" TODO — 이번 세션 DTO 통합 작업 때 이미 추가됨 → 삭제.
  - `searchProduct.jsp:54` — `ProductListDTO` 필드 목록이 실제와 다름(없는 필드 `thumbnail` 언급, 실제 존재하는 `titleImage`/`categoryNames`/`tagData`는 "없다"고 서술) → 실제 필드 목록으로 재작성.
  - `searchProduct.jsp:135` — "ProductListDTO에 categoryName 없음"도 동일 패턴(`categoryNames` 필드 이미 존재) → 삭제.
  - `searchProduct.jsp:134` — 위 10번과 같은 옛 문자열(`redirect:home/test`) 참조 → 현재 코드 기준으로 재작성.
  - `wish.jsp:39-42` — "별점/리뷰수 통계 API 작업 중"이라는 표현이 오해 소지 있음(마치 백엔드에 관련 기능이 아예 없는 것처럼 읽힘) — 실제로는 상품 상세/목록에는 이미 구현되어 있고 찜 화면에만 연동이 안 된 상태 → 정확하게 재작성.
  - `MemberController.java:66,81,97,112,130` — 5곳 모두 복붙하면서 변수명/타입명을 안 고친 주석(`List<CouponDTO>`라고 적혀있지만 실제로는 각각 `MypageCouponDTO`/`MyPageWishDTO`/`MyPageCartDTO`/`MyPageDeliveryDTO`, 심지어 존재하지도 않는 `CartDTO` 언급도 있었음) → 각각 실제 타입/변수명으로 수정.
  - 나머지(admin 3종, adminPage.jsp 등 다수의 "TODO(data binding)" 주석)는 대조 검증 결과 전부 현재 상태와 일치해서 손대지 않음.
- **파일 업로드 orphan 완전 차단 + 파일 정합성 검사 기능 추가** (2026-08-31):
  - **완전 차단**: `util.FileUploadUtil`을 "UUID 파일명 즉시 생성"과 "실제 디스크 쓰기"로 분리. 상품/리뷰 이미지 등록 모두 DB insert 전엔 파일명만 만들고, 실제 바이트 쓰기는 `TransactionSynchronizationManager.registerSynchronization(...afterCommit...)`으로 등록해서 **DB 트랜잭션이 커밋된 뒤에만** 실행되도록 변경(`AdminProductServiceImpl.saveImage()`, `ReviewServiceImpl.writeReview()`). 트랜잭션이 롤백되면 파일이 애초에 안 써지므로 orphan이 원천적으로 생기지 않음. 커밋 후 디스크 쓰기 자체가 실패하는 극히 드문 경우(디스크 용량 등)는 되돌릴 방법이 없어 로그만 남기는데, 이건 아래 파일 정합성 검사가 "DB엔 있는데 파일 없음"으로 잡아줌.
  - **파일 정합성 검사(양방향 점검)**: 새 화면 `/admin/maintenance`(관리자 대시보드 "빠른 메뉴"에 버튼 추가, 포트폴리오 성격상 스케줄러 없이 관리자가 직접 누르는 방식으로 결정). `uploads/product`↔`PRODUCTIMAGE`, `uploads/review`↔`REVIEWIMAGE`를 각각 대조해서 "파일만 있음(ORPHAN_FILE, 삭제 버튼 제공)"과 "DB만 있음(MISSING_FILE, 삭제 불가·재업로드 필요 표시만)"을 리스트로 보여줌. 자동 삭제는 안 하고 목록 확인 후 사람이 버튼을 눌러야 삭제됨(오탐 방지). 삭제 API는 클릭 시점에 DB를 다시 한번 확인해서 그새 등록된 파일이면 거부하고, 파일명에 경로 순회 문자(`..`, `/`, `\`)가 섞이면 거부하는 안전장치 포함.
  - 스케줄링을 안 쓰기로 한 이유: 이 문제는 등록 흐름 실패보다는 수동 DB/파일 조작(예: 이번 세션에 jshell로 직접 DB를 지운 경우) 등 드문 원인으로 생기는 드리프트를 잡기 위한 것이라, 상시 배치보다 필요할 때 수동 실행이 이 프로젝트 규모에 더 맞는다고 판단.
  - **라이브 검증 완료**: (1) 실제 상품 등록 → 이미지 파일이 커밋 후 정상적으로 디스크에 생성됨 확인 (2) 등록 도중 태그 JSON을 일부러 깨뜨려 롤백 유도 → DB도 0건, 파일도 0건 추가(이전 같으면 이 시나리오에서 파일 2개가 orphan으로 남았을 것) (3) 정합성 검사 API가 실제 seed 데이터의 기존 불일치(placeholder 파일 13개 등)까지 포함해서 정확히 잡아내는 것 확인 (4) 임의로 만든 orphan 파일이 삭제 버튼으로 정상 삭제되는 것, DB에 있는 파일명으로 삭제 시도하면 거부되는 것, 경로 순회 문자열 시도 시 거부되는 것 확인 (5) `/admin/maintenance` 페이지 로드 및 관리자 대시보드 새 버튼 노출 확인.
  - 신규 파일: `admin/model/dto/FileIntegrityIssueDTO.java`, `admin/model/dto/DeleteOrphanFileRequestDTO.java`, `admin/model/mapper/AdminMaintenanceMapper.java`(+xml), `admin/model/service/AdminMaintenanceService.java`(+Impl), `admin/controller/AdminMaintenanceController.java`, `admin/adminMaintenance.jsp`, `style_adminMaintenance.css`, `js/admin/adminMaintenanceService.js`, `js/views/adminMaintenance.js`.
  - 수정 파일: `util/FileUploadUtil.java`(분리), `AdminProductServiceImpl.java`/`ReviewServiceImpl.java`(호출부 변경), `adminPage.jsp`(퀵메뉴 5번째 타일 추가), `style_admin_mypage.css`(4열→5열 그리드), `header.jsp`(신규 CSS 링크).
- **매퍼가 이름으로 참조 중인 DTO 4개에 `@Alias` 명시 추가** — `SearchDTO`, `MyPageWishDTO`, `MyPageCartDTO`, `MyPageDeliveryDTO`. `mybatis.type-aliases-package=com.kh.sajotuna.mds`(패키지 전체 자동 스캔) 덕분에 원래도 동작은 했지만, 매퍼가 클래스명에 의존한다는 걸 코드에서 바로 보이게 하려고 명시. **참고: 이 자동 스캔 때문에 `com.kh.sajotuna.mds` 하위 전체에서 클래스명이 유일해야 함(패키지가 달라도 충돌) — 새 DTO 작성 시 이름 겹침 주의.**
- **최종 코드리뷰(`/code-review high`)로 이번 세션 diff 재검증** — `FileUploadUtil.saveFile()`이 위 orphan 차단 리팩토링 이후 호출부 0건인 죽은 메서드로 남아있던 것 발견, 삭제. 그 외 문제 없음. 컴파일 + 서버 재기동 + admin/member 주요 엔드포인트 스모크 테스트 전부 통과, 파일 정합성 검사로 이번 세션 테스트 흔적이 DB/디스크에 없는 것까지 확인.
- **DTO 통합(3-28) 재검증 + 신규 브랜치 병합이 가져온 중복 2건 정리 (2026-08-31)**:
  - **`coupon.model.dto.MyPageCouponDTO` 재발견 + 삭제** — 3-28에서 이미 찾아 지웠던 것과 똑같은 패턴(COUPON 테이블을 가리키는 중복 DTO)이 `#BE005_260826 주문 결제 기능 추가` 커밋으로 이름만 바뀐 채 재유입됨. `coupon.*` 패키지의 나머지(컨트롤러/매퍼/서비스)가 전부 빈 껍데기라 이 DTO도 참조 0건인 것 확인 후 삭제. `coupon.*` 패키지 구조 자체는 사용자님이 별도로 직접 재구성 예정이라 그대로 둠.
  - **`wish`/`cart` 전용 패키지와 `member` 패키지의 찜/장바구니 조회 이원 구현 정리** — `#BE008_260828 찜 기능 추가`가 새로 만든 `WishController`/`CartController`(+매퍼)가, 기존 `MemberController.wishlistForm()`/`cartForm()`(`MyPageWishDTO`/`MyPageCartDTO`)과 동일한 WISH/CART 조회 기능을 완전히 별개로 구현하고 있던 것 발견. `product/wish.jsp`/`product/cart.jsp`가 실제로는 두 백엔드 어느 쪽 데이터도 안 쓰고 localStorage로만 동작 중인 것까지 확인한 뒤, 사용자님 지시로 **전용 패키지(`wish.*`/`cart.*`) 유지 + `member` 패키지 쪽 중복 기능(컨트롤러 메서드/서비스/매퍼/DTO) 삭제**로 정리. 자세한 내용은 HANDOFF.md 3-34 참고.

---

## 버그 (실제로 기능이 깨져 있음)

> 이 섹션은 전부 review/product/member 담당 영역 — 팀원 공유 후 각자 확인 필요.

1. ~~**`ProductController.java`** — `SessionConst.LOGIN_MEMBER`(세션에 저장된 적 없는 키)로 로그인 여부를 확인. 실제 세션 키는 `LOGIN_SESSION`. 결과: 로그인해도 쿠폰 발급·리뷰 좋아요가 항상 실패.~~ **✅ 조치 완료 (2026-09-02 밤, HANDOFF 3-57)**
   - "다른 브랜치에서 이미 고쳐졌을 것"으로 두고 병합 후 재확인하기로 했던 항목인데, **병합 후에도 그대로 살아있었다.** 3-53 체크리스트 C(좋아요)가 500으로 막혀서 추적하다 확인.
   - **`LOGIN_MEMBER`를 세션에 넣는 코드는 프로젝트 전체에 0건**이다(Model attribute 이름일 뿐 — 부록 A에 적혀 있던 함정). 3곳(59·79·109행) 모두 항상 null이었고, 79행(쿠폰 발급)·109행(좋아요)은 바로 역참조해 **NPE 500**이었다.
   - 조치: 3곳 `LOGIN_SESSION`으로 교체 + `user == null` 가드로 정정. 더불어 `reviewLike`가 `@ResponseBody` 없이 `"on"`/`"off"`를 반환해 **뷰 이름으로 취급**되던 것도 함께 수정.
   - **남은 것**: `/mds/coupon/{id}`, `/mds/review/like/{id}` 둘 다 아직 화면에서 호출하는 코드가 0건이다. 서버는 정상이니 버튼에 `fetch`만 붙이면 된다.
2. **`ProductServiceImpl.java:81,88-94`** — 리뷰 이미지 리스트가 반복문 밖에서 한 번만 생성되고 초기화가 안 됨 → 모든 리뷰가 같은 리스트 객체를 공유해서, 상품에 리뷰가 여러 개면 각 리뷰마다 다른 사람 사진까지 전부 섞여서 표시됨.
3. **`ProductServiceImpl.java` + `detailPage.xml:122-128`** — 리뷰 0개 상품에서 리뷰 탭 진입 시 빈 리스트로 `IN ()` 쿼리가 생성되어 Oracle `ORA-00936`으로 500.
4. **`ProductServiceImpl.detailPage()`** — 상세조회는 `STATUS='ON_SALE'`만 허용하는데 목록/검색(`product.xml`)엔 상태 필터가 없음 → 품절/숨김 상품을 목록에서 클릭하면 결과 `null`에 바로 필드 접근해 NPE.
5. **`signUp.jsp:8`** — `<form>`에 `action`/`method`가 없고, input `name`도 `MemberDTO`의 camelCase 프로퍼티와 다름(`member_name` vs `memberName` 등). 회원가입 버튼을 눌러도 아무 것도 저장 안 되고 새로고침만 됨.
6. 같은 지점 — 폼을 우회해 API를 직접 호출하면 `MemberDTO`엔 `loginId`/`loginPw` 외 필드 검증이 없어서 `memberName` 없이 요청 시 Oracle NOT NULL 위반이 처리 안 된 500으로 그대로 노출.
   - **📌 추가 확인(2026-08-31, 재검증 세션 중 테스트 계정 생성하다가 발견): `ROLE` 컬럼도 같은 방식으로 500이 남**. `MEMBER.ROLE`은 `DEFAULT 'USER' NOT NULL`이라 스키마상으로는 값을 안 넘겨도 될 것 같지만, `MemberServiceImpl.signUp()`이 `member.setRole(...)`을 전혀 안 하고 `MemberMapper.xml`의 `insertMember`가 `ROLE` 컬럼을 INSERT 목록에 항상 포함시켜서 바인딩값 `null`을 그대로 넣어버림 — Oracle은 INSERT문에 컬럼이 명시되면 바인딩값이 NULL이어도 DEFAULT를 적용하지 않고 그대로 NULL을 넣으려다가 `ORA-01400`(NOT NULL 위반)으로 막힘. 실제 브라우저 폼은 버그 5번 때문에 애초에 제출 자체가 안 되니 이 경로를 못 타지만, API를 직접 호출하는 경우(테스트 계정 생성 등)엔 `role=USER`를 명시적으로 안 보내면 항상 500. member 패키지 담당자가 버그 5/6을 고칠 때 같이 참고할 것(이번 세션 범위 밖이라 직접 수정하지 않음).
7. ~~**`MemberMapper.xml:90-97`** — `/member/orderDelivery`가 DELIVERY 테이블과 INNER JOIN인데, 관리자가 배송 상태를 처음 바꾸기 전엔 DELIVERY 행이 없음(체크아웃 미구현) → 결제 완료했지만 배송 처리 전인 주문이 목록에서 통째로 사라짐.~~
   - **✅ 조치 완료 (2026-08-30, 유저 주문 배송 확인 기능 구현 세션) — `selectDeliveriesByMemberId`를 LEFT JOIN으로 변경. `AdminOrderMapper.selectSummary`와 동일한 패턴. 자세한 내용은 HANDOFF.md 참고.**
8. ~~**`MemberMapper.xml:67-88`** — 찜/장바구니 조회가 `PRODUCT_TITLE_IMAGE=0`(대표이미지)과 INNER JOIN. 대표이미지 등록을 빠뜨린 상품은 찜/장바구니에 담겨 있어도 목록에서 안 보임.~~
   - **조치 완료가 아니라 "쿼리 이전"에 가까움 (2026-08-31) — `member` 패키지 쪽 쿼리(`selectWishesByMemberId`/`selectCartsByMemberId`) 자체는 wish/cart 기능이 전용 `wish.*`/`cart.*` 패키지로 일원화되면서 삭제됨(HANDOFF.md 3-34). 다만 대체된 `wish.xml`의 `getWishList`가 똑같이 `pi.PRODUCT_TITLE_IMAGE = 0`과 INNER JOIN이라 이 버그는 그대로 살아있음(위치만 `wish.xml:19-24`로 이동) — 아직 미해결. `cart.xml`의 `getCartList`는 애초에 PRODUCTIMAGE를 조인 안 해서(이미지 필드 자체가 `CartListDTO`에 없음) 이 버그 대상은 아니지만, 그만큼 장바구니 목록에 상품 이미지가 안 나온다는 뜻 — wish/cart 담당자 확인 필요.**
   - **📌 2026-08-31: 사용자님이 wish/cart 담당 팀원에게 직접 전달함.** 다음 브랜치 병합 때 반영될 예정 — 병합 후 `wish.xml`의 `getWishList`가 LEFT JOIN(+ 기본값 처리)으로 고쳐졌는지, `cart.xml`의 `getCartList`에 상품 이미지 필드가 추가됐는지 재확인 필요.
9. ~~**뷰 이름 불일치**~~ — `/member/wish`,`/member/cart`,`/member/orderDelivery`가 리턴하는 뷰 이름에 실제 파일이 없음(진짜 파일은 `product/wish.jsp`, `order/userOderDelivery.jsp` 등) → 접근 시 뷰 리졸브 실패로 500.
   - **✅ `/member/orderDelivery` 부분만 조치 완료 (2026-08-30) — `MemberController.userOrderDeliveryForm()`이 반환하는 뷰 이름을 `order/userOderDelivery`로 수정. `/member/wish`,`/member/cart`는 이번 범위 밖(product 패키지 담당)이라 그대로 남아있음.**
   - **참고(2026-08-30): 실제로는 500이 아니라 404로 남(Spring Boot 3.x JSP 뷰 리졸버가 파일 없음을 404로 처리) — `{"status":404,"message":"JSP file [/WEB-INF/views/member/cart.jsp] not found"}` 형태로 확인됨.** 마이페이지 UI 개편(`member/myPage.jsp`) 중 "나의 장바구니"/"나의 찜 목록"을 실제 라우트로 연결하려다 이 버그를 직접 재현함. 이후 사용자님이 제공한 디자인 시안에 따라 "주문관리" 섹션을 주문·배송조회/주문취소환불 2개 항목만 있는 리스트 형식으로 다시 짜면서 장바구니/찜 항목 자체가 화면에서 빠짐(헤더의 장바구니/찜 아이콘으로 이미 접근 가능해서 중복 제거) — 그래서 지금은 `myPage.jsp`에 `/member/cart`,`/member/wish` 링크 자체가 없음. product 패키지 담당자가 이 버그를 고친 뒤 마이페이지에도 다시 노출하고 싶다면 새로 추가하면 됨.
   - **✅ `/member/wish`,`/member/cart` 부분도 조치 완료 (2026-08-31, KGH_works 브랜치 병합) — `wishlistForm()`/`cartForm()`이 반환하는 뷰 이름을 각각 `product/wish`/`product/cart`로 수정. `KGH_works`를 `server_for_merge`(BJY_works 기반 병합용 브랜치)에 병합해서 반영됨 — 브랜치 병합 전 diff 검토 시 KGH_works 쪽 커밋 초반에 `product/cart.jsp`/관련 CSS(`style_cart.css` 등)가 실수로 삭제된 채 푸시됐던 것을 발견해서 작업자에게 복구 요청 → 재푸시 후 병합, 병합 결과물 실제 서버 기동 + curl 스모크테스트까지 확인 완료.**
10. **깨진 내부 링크 여러 개** — 마이페이지 링크가 소문자 `mypage`로 되어있어 실제 매핑(`myPage`)과 안 맞아 404. `/member/updateInfo`,`/member/userWithdraw`,`/member/addAddress`는 대응하는 컨트롤러 매핑 자체가 없음.
    - **참고(2026-08-31): `/member/updateInfo`는 이후 KGH_works 브랜치에서 매핑 자체는 신규 구현됨(BE014, 멤버 정보 수정 기능) — 다만 새로운 문제가 생김, 아래 18번 참고.**
    - **✅ `order/userOderDelivery.jsp`의 "마이페이지로 돌아가기" 링크 1곳만 조치 완료 (2026-08-30)** — 사용자님이 리뷰 작성 후 이 버튼을 눌러서 직접 404(스택트레이스의 줄 번호 "527"을 에러 코드로 오인해서 리포트됨)를 재현 → `/member/mypage` → `/member/myPage`로 수정. 이 페이지가 이번 세션에서 직접 작성한 파일이라 범위 내로 판단해서 수정함. **다른 페이지들의 동일 오타(예: `member/myPage.jsp` 자체 등 나머지 위치)는 그대로 남아있음** — 전체 사이트 스캔해서 한 번에 고치는 건 여전히 필요.
11. **`MyPageWishDTO.reviewAvg`가 `Long`** — 쿼리는 소수점 1자리 평균(`4.5`)을 계산하는데 `Long`으로 받아서 소수부가 잘림.
12. ~~**이미지 경로 오타**~~ — `MemberServiceImpl.java:134`와 `productDetail.jsp`(3곳)에 `/upload/product/`(s 빠짐)로 하드코딩. 실제 정적 리소스 경로는 `/uploads/**`.
    - **✅ `MemberServiceImpl.java:134` 부분만 조치 완료 (2026-08-30) — 대표 상품이 없을 때의 기본값 자체를 SQL의 `NVL(..., '/uploads/product/')`로 옮기면서 오타 제거(N+1 제거 리팩토링과 함께 처리). `productDetail.jsp`(3곳)는 이번 범위 밖(product 패키지 담당)이라 그대로 남아있음. 참고로 기존 시드 데이터의 `PRODUCTIMAGE.PRODUCT_IMAGE_PATH` 컬럼값 자체도 `/upload/product/`(오타 포함)로 저장되어 있는 게 확인됨 — 다만 이 값들은 이미 알려진 대로 `uuid_` 접두사의 플레이스홀더(실파일 없음)라 실질적 영향은 없음.**

---

## 정책적 고려가 필요한 부분

1. **`MEMBER_STATUS` 컬럼이 로그인 로직에서 전혀 안 쓰임** — 지금은 탈퇴/정지 기능이 없어서 괜찮지만, 나중에 이 컬럼으로 탈퇴/정지를 구현하면서 로그인 체크 추가를 깜빡하면 정지 계정도 로그인되는 구멍이 생길 수 있음.
2. **쿠폰 도메인이 두 군데로 쪼개져 있음** — `coupon.*` 패키지는 완전히 빈 스캐폴딩인데, 실제 동작하는 "보유 쿠폰 조회"는 `member.*` 쪽에 있음.
   - **📌 사용자 방향성: 리뷰(review 패키지)처럼 쿠폰도 하나의 독립된 기능으로 보고, 관련 코드를 전용 쿠폰 폴더로 모으는 게 맞다는 판단. 실제로 `Coupon_branch`라는 별도 기능 브랜치도 존재함. 지금 당장 리팩토링하진 않았고, 팀 논의 후 진행할 방향.**
   - **✅ 2026-08-30 부수 발견 + 조치 완료: `coupon.*` 패키지에 남아있던 `MypageCouponDTO`가 실제로는 안 쓰이는 죽은 클래스였고, `MemberMapper.selectCouponsByMemberId`는 SQL에서 `resultType="CouponDTO"`(product 패키지의 통합 DTO, admin 쿠폰 기능과 공유)를 반환하면서 Java 인터페이스는 `List<MypageCouponDTO>`로 선언해놓은 **타입 불일치 버그**가 있었음. 제네릭 타입 소거 때문에 컴파일은 되고 Java 코드에서 캐스팅 에러도 안 났지만(모델에 그냥 통째로 넘기기만 함), 필드명이 서로 다름(`deadLine`/`deadLineStr` vs 실제로는 `deadline`/`deadlineStr`)해서 JSP가 이 데이터를 EL로 바인딩하려 했으면 값이 계속 비어 나왔을 것 — `/member/couponView` 화면이 실데이터 연동 없이 완전 정적 목업으로 방치됐던 이유 중 하나로 추정됨. `MemberMapper`/`MemberService`/`MemberController`를 `CouponDTO` 기준으로 통일하고 `MypageCouponDTO.java` 삭제(사용처 없음 확인 후).**
   - **⚠️ 2026-08-30 정정: `/member/couponView`의 CSS 원인 진단이 처음에 틀렸었음.** 처음엔 "CSS 파일 자체가 프로젝트에 없다"고 판단해서 `style_coupon.css`를 새로 만들었는데, 사용자님이 확인해보니 **`style_usercouponView.css`라는, 이 화면 전용으로 이미 제대로 디자인된 CSS 파일이 실제로 존재하고 있었음**(`.coupon-page`, `#CouponSummary`, `.coupon-card` 등 원래 정적 목업 마크업과 정확히 맞는 선택자로 작성됨) — 다만 이 파일이 (a) `usercouponView.jsp` 자신의 `<link>` 태그에서도 참조되지 않고(그 태그는 존재하지도 않는 `style_coupon.css`를 가리키고 있었음) (b) `header.jsp`의 전역 CSS 목록에도 등록되지 않아서 **완전히 고아 상태(어디서도 안 불러와짐)** 였던 것. 파일명이 이 프로젝트 관례(`style_<JSP파일명>.css`)를 따르는데 검색을 좁게(`style_coupon.css`만) 해서 못 찾은 게 원인 — 죄송함, 다음엔 `style_<파일명>.css` 패턴부터 먼저 확인할 것.
   - **✅ 2026-08-30 결정 완료: `style_coupon.css`(신규 작성분) 유지 + admin 쿠폰 뷰(`admincouponView.jsp`/`style_admincouponView.css`) 형식으로 통일하는 방향으로 확정.** 추가로 "만료 쿠폰은 유저에게 안 보여주고 사용 가능한 보유 쿠폰만 노출"로 범위도 축소(요약 박스도 "보유쿠폰" 하나로 단순화) + 페이징 적용. `style_usercouponView.css`(고아 파일)는 그대로 안 쓰고 남겨둠 — 자세한 내용은 HANDOFF.md 3-30-15 참고.
   - **⚠️ 2026-08-31 재발: `coupon.model.dto.MyPageCouponDTO`가 `#BE005_260826 주문 결제 기능 추가` 브랜치를 통해 다시 들어옴.** 바로 위에서 이미 한 번 지웠던 것과 완전히 동일한 문제(이름만 `Mypage`→`MyPage`)가, 이번엔 다른 브랜치(주문/결제 기능)가 가져온 `coupon.*` 빈 스캐폴딩(컨트롤러 1개/빈 매퍼/빈 서비스)에 딸려서 재유입된 것 — **여러 팀원이 각자 `coupon.*` 패키지를 손대면서 같은 실수가 반복될 수 있는 구조라는 뜻이라, 사용자님이 직접 진행할 `coupon.*` 패키지 재구성 때 이 패턴(다른 패키지의 기존 DTO와 중복되는 새 DTO를 만들지 않기) 참고할 것.** 이번엔 참조 0건 확인 후 `MyPageCouponDTO.java`만 삭제, `coupon.*` 패키지 구조 자체는 손대지 않음. 자세한 내용은 HANDOFF.md 3-34 참고.
   - **✅ 2026-08-31 진행/검증: 사용자님이 직접 `product.model.dto.coupon.CouponDTO`/`CouponHistoryDTO`/`getCouponDTO`를 `coupon.model` 패키지로 이동**(참조하던 12개 파일 import 경로도 함께 갱신). Claude Code가 검증 — 옛 경로 참조 0건, `@Alias` 충돌 없음, `mvnw compile` 정상. 낡은 주석 1곳(`AdminCouponMapper.xml`)만 옛 경로를 가리키고 있어서 수정. 자세한 내용은 HANDOFF.md 3-35 참고.
   - **⚠️ 신규 발견(2026-08-31 저녁, 브랜치 다이버전스): 현재 `frontfix` 브랜치는 위 3-34/3-35/3-36에서 정리했던 내용을 아직 안 받은 상태.** `coupon.controller.CouponController`/`coupon.mapper.CouponMapper`/`coupon.service.CouponServiceImpl`/`CouponServiece`(삭제됐어야 함), `coupon.model.dto.MyPageCouponDTO`(삭제됐어야 함), `product.model.dto.coupon.CouponDTO`(→`coupon.model`로 이동됐어야 함)가 전부 옛 상태 그대로 이 브랜치에 살아있음을 실제 소스에서 확인(2026-08-31 CSS/JS 규격화 검증 세션). 마찬가지로 아래 8번(wish/cart 대표이미지 INNER JOIN) 관련 `member` 패키지의 `wishlistForm`/`cartForm`/`selectWishesByMemberId`/`selectCartsByMemberId`(삭제됐어야 함, 3-34)도 그대로 남아있음. **기능이 깨진 건 아니고(중복 코드가 살아있을 뿐) 코드 수정은 안 함** — 다만 이 브랜치가 `BJY_works`의 최신 정리 작업을 포함한 브랜치와 나중에 합쳐질 때 병합 충돌/재발 가능성이 있어 기록만 해둠. 병합 시점에 이 문서와 HANDOFF.md 3-34~3-36을 참고해서 어느 쪽 상태로 정리할지 팀 판단 필요.
     - **✅ 2026-09-01 사용자 확인으로 판단 종결: `frontfix`는 프론트 담당자에게 넘겨주려고 만든 로컬 전용 임시 브랜치이고, 사용자(팀장)의 실제 작업 브랜치인 `BJY_works`엔 wish/cart/쿠폰 정리가 전부 반영돼 있음.** 즉 위 다이버전스는 **버그가 아니라 브랜치 시차**이며, 합칠 때 `BJY_works` 쪽 상태가 기준이 된다 — `frontfix`에서 같은 것을 다시 지우거나 되돌리는 작업은 하지 말 것.
   - **✅ 2026-08-31 완료: 죽은 `coupon.controller.CouponController`/`coupon.mapper.CouponMapper`/`coupon.service.CouponServiceImpl`/`CouponServiece` 삭제.** 유저용 쿠폰 조회는 이미 `member.*`(`MemberController.userCouponViewForm()`)가, 관리는 `admin.*`(`AdminCouponController`)가 전담하고 있어서 이 4개가 담당할 몫이 없다는 것을 재확인(뷰 리졸브 대상 파일 자체가 없어 접속하면 404, 참조하는 곳도 0건, `@Mapper`/`@Service` 미부착으로 빈 등록도 안 됨) — 사용자님 승인 후 삭제. `coupon.model`(DTO 3개)만 남기고 정리 완료. **즉 "유저는 쿠폰 조회만, 관리는 admin이 전담"이라는 방향성이 이제 패키지 구조에도 그대로 반영됨** — `coupon.*`는 더 이상 별도 컨트롤러 없이 DTO 전용 패키지. 자세한 내용은 HANDOFF.md 3-36 참고.
3. **`MemberDTO` 필드별 검증 강도가 들쭉날쭉** — `loginId`/`loginPw`만 정규식 검증, 나머지(이름/닉네임/이메일/전화)는 중복 체크만 있고 형식 검증이 없음.
4. **상품 목록/검색에 STATUS 필터가 없음** — 상세조회는 판매중인 것만 허용하면서 목록/검색은 숨김·품절·판매중지 상품까지 노출(버그 4번과 동일 지점, 의도인지 확인 필요).
5. **만료된 쿠폰도 발급(수령) 가능** — `getCoupons`/`insertCoupon`에 마감일 검증이 없음.
6. 관리자 주문/배송의 `VALID_COMPANIES`(허용 택배사 목록)가 프론트 `<select>` 옵션과 별개로 백엔드에 하드코딩 — 하나만 바뀌면 조용히 어긋남.
7. ~~쿠폰 `couponValue`를 `discountPercent/100.0`처럼 double 소수로 저장~~
   - **✅ 조치 완료 — `BigDecimal.valueOf(discountPercent, 2)`로 변경(위 "조치 완료" 섹션 참고), 스키마/API 모양은 그대로 유지.**
8. 상품 가격/재고에 상한선이 없음(음수만 막음).
9. **`application.properties`에 죽어있는 `spring.security.user.*`(테스트용 계정) 설정이 남아있음** — `httpBasic`이 지금은 꺼져있어 안 쓰이지만, 나중에 누가 실수로 다시 켜면 약한 기본 계정(admin/1234)이 부활함.
   - **⚠️ 잊지 말 것: 나중에 반드시 정리하거나 최소한 비밀번호를 강화할 것. (사용자가 인지했고, 까먹지 않도록 강조 표시 요청)**
10. 아이디/닉네임/이메일/전화번호 중복확인 API에 rate-limit이 없어 계정 존재 여부 대량 확인(enumeration) 가능(학교 프로젝트 규모에선 낮은 우선순위).
11. ~~**신규(2026-08-30): "내가 쓴 리뷰" 삭제 후 재작성 허용 여부 — 팀 논의 대기, 스키마 변경 보류.**~~ **✅ 조치 완료 (2026-09-01, HANDOFF 3-45)**
    - **팀 논의 결과 "삭제 후 재작성 불가"로 결정됨.** 다만 구현 방식은 아래 검토안 1번(`REVIEW.IS_DELETED` 소프트 삭제)이 아니라 **별도 `REVIEWHISTORY` 테이블 + 하드 삭제 유지**로 변경했다.
    - **방식을 바꾼 이유**: 소프트 삭제로 가면 `REVIEW`를 읽는 모든 쿼리에 `IS_DELETED='N'` 필터를 빠짐없이 넣어야 하는데, 거기엔 평균 별점/리뷰 개수 집계 3곳(`product/detailPage.xml` 2곳, `product/product.xml` 1곳)이 포함된다. **이 3곳은 product 담당자 영역**이라 손대야 하고, 한 곳이라도 빠뜨리면 삭제된 리뷰가 별점에 계속 잡히는 부작용(아래 방식 2번의 문제와 동일)이 그대로 재현된다. 별도 테이블 방식은 `REVIEW` 행이 실제로 사라지므로 **집계 쿼리 3곳을 아예 안 건드려도 정확**하다.
    - **구현**: `REVIEWHISTORY(RHIST_ID, OD_ID, MEMBER_ID, REVIEW_ID, SCORE_FIX, WRITTEN_AT, DELETED_AT)` 신설. **`UK_RHIST_OD`(OD_ID unique)가 재작성을 DB 레벨에서 영구 차단**한다. `REVIEW_ID`는 하드 삭제되는 행을 가리키므로 **FK를 걸지 않고** 참고값으로만 두고, 삭제 시 `NULL` + `DELETED_AT` 기록으로 행 자체는 보존한다. 판정 쿼리(`checkReviewExists`, 마이페이지 `HAS_REVIEW`/리뷰가능 건수)를 전부 `REVIEWHISTORY` 기준으로 교체.
    - **라이브 검증 완료**: 삭제 → 이력 행 보존 확인 → 작성 화면 진입 302 차단 → 화면 우회 POST 직접 호출도 차단(리뷰 생성 0건) → 리뷰가능 건수 안 늘어남. 정상 작성 경로도 동작 확인(작성 시 이력 자동 생성).
    - **⚠️ 2026-09-01 재변경 (HANDOFF 3-47): 위 `REVIEWHISTORY` 방식은 폐기되고 `REVIEW.REVIEW_STATUS`(0/1) 소프트 삭제로 최종 확정됨.** 팀 피드백 — "단순 리뷰 작성 중복 체크라면 이력 테이블은 과하다, 컬럼으로 해결된다". 즉 **원래 검토안 1번(`IS_DELETED`)과 같은 방식**으로 돌아왔고, 재작성 차단은 기존 `UK_REVIEW(MEMBER_ID, OD_ID)`가 그대로 담당한다.
      - **그래서 위 "방식을 바꾼 이유"에서 피하려 했던 부담이 그대로 발생한다** — 평균 별점/리뷰 개수 집계 3곳(`product/detailPage.xml` 2곳, `product/product.xml` 1곳)에 `REVIEW_STATUS = 1` 필터를 **반드시** 넣어야 하고, 한 곳만 빠져도 삭제된 리뷰가 별점에 계속 잡힌다. **전부 product 담당 영역이라 담당자 수정분 병합이 필요**하다(2026-09-01 기준 미반영).
      - **반대로 권한 판정 쿼리(`checkReviewExists`, 마이페이지 `HAS_REVIEW`/리뷰가능 건수)는 `REVIEW_STATUS`를 보면 안 된다** — 필터를 넣으면 삭제한 주문상세가 "미작성"으로 되살아나 재작성이 열린다. 표시·집계는 필터 O / 권한 판정은 필터 X, 이 구분이 핵심.
      - 리뷰·멤버 영역 코드는 2026-09-01에 선반영 완료. **DB 반영은 product 코드 병합 후로 미뤄둔 상태**라, 그 전까지는 코드와 DB 스키마가 서로 어긋나 있다.
    - 아래는 결정 이전의 검토 기록(이력 보존용):
    - **현재 동작**: `ReviewServiceImpl.deleteReview()`가 `REVIEW` 행을 실제로 DELETE함 → `UK_REVIEW(MEMBER_ID, OD_ID)` 제약이 사라져서 같은 주문상품에 리뷰를 다시 쓸 수 있음(쿠팡/아마존 등 대부분의 쇼핑몰과 동일한 방식).
    - **사용자님 의견**: 삭제 후 재작성이 가능한 게 버그처럼 느껴진다 — 삭제하면 해당 주문상품엔 영구히 리뷰를 다시 못 쓰게 막고 싶음.
    - **검토 결과**: 스키마(또는 최소한 REVIEW 테이블에 어떤 형태로든 흔적)를 전혀 안 남기고는 논리적으로 불가능함(행을 완전히 지우면 "예전에 썼었다"는 사실 자체가 사라짐). 두 가지 방식을 제시함:
      1. `REVIEW`에 `IS_DELETED CHAR(1) DEFAULT 'N'` 컬럼 추가 + 삭제 시 실제 DELETE 대신 `UPDATE ... SET IS_DELETED='Y'`로 변경(행은 유지되므로 UNIQUE 제약이 계속 재작성을 막아줌). `checkReviewExists`는 그대로 둬도 됨(행 존재 자체로 이미 차단됨), `selectMyReviews`같은 "보여주는" 쿼리에만 `WHERE IS_DELETED='N'` 필터 추가.
      2. 스키마 변경 없이 `REVIEW_TEXT`만 비워서 "삭제됨"을 표시 — 재작성은 잘 막히지만, **상품 상세 페이지의 평균 별점/리뷰 개수 집계 쿼리(`ProductServiceImpl`, `product/detailPage.xml`·`product/product.xml`, product 패키지 담당 영역)가 이 "빈 리뷰"를 그대로 카운트해버려서 평균 별점에 부작용이 생김.**
    - **결정: 1번 방식(새 컬럼 추가)으로 하기로 했으나, 실제 스키마 변경은 보류 — 사용자님이 월요일에 팀원들과 논의 후 진행 여부/방식을 다시 결정하기로 함. 그때까지 이번 세션에서 만든 "내가 쓴 리뷰" 삭제 기능은 원래 방식(실제 DELETE, 재작성 허용)으로 그대로 둠 — 코드/스키마 둘 다 변경하지 않음.**
    - **참고**: 사용자님은 방식 2(스키마 무변경)를 선택하더라도 그 부작용(상품 페이지에 빈 리뷰가 별점으로 카운트되는 것)은 일단 인지하고 넘어가겠다고 하셨음 — 즉 스키마 변경이 결국 불발되면 이 부작용을 감수하고 방식 2로 갈 수도 있다는 뜻으로 남겨둠. 팀 논의 후 다시 이어서 진행할 것.

---

## 잠재적 위험 요소

### 심각도 높음

1. **비밀번호 해시 포함 개인정보가 서버 로그에 평문으로 찍힘** — `MemberController.java`의 여러 지점(`System.out.println(...member...)`)이 `MemberDTO`를 통째로 출력. Lombok `@ToString`이 필드 제외 없이 걸려있어 비밀번호 해시·이메일·전화번호·생년월일까지 로그에 그대로 남음. 마이페이지 접속할 때마다 발생하는 현재 살아있는 문제. (member 담당 영역)
2. **`productDetail.jsp:186,195` — 리뷰 닉네임/본문 미이스케이프 출력**
   - **📌 사용자 의견(중요, 팀 논의 필요): 이 프로젝트에서 실제로 배우고 쓰는 이스케이프 방식은 JSTL `<c:out>` 태그(기본적으로 escapeXml=true 동작)이고, `fn:escapeXml`(이번 세션에 login.jsp의 redirectURL에 적용한 방식)은 교육과정 범위를 벗어난 것일 수 있음. 즉 "프로젝트 전체에 이스케이프 습관이 없다"는 진단은 반은 맞고 반은 틀림 — 정확히는 "배우지 않은 예외적 케이스에 과하게 방어적인 방식을 적용한 것"에 가까움. 나중에 이 부분을 고칠 때는 `fn:escapeXml`이 아니라 프로젝트에서 이미 쓰는 `<c:out value="${review.reviewText}"/>` 방식으로 통일하는 걸 우선 검토할 것. login.jsp의 `fn:escapeXml` 적용도 이 논의 결과에 따라 재검토 여지 있음. 지금은 수정하지 않고 논의 대기.**
3. **리뷰 좋아요가 GET 요청 + 전역 CSRF 비활성화** — `@GetMapping("/review/like/{reviewId}")`에 `SecurytiConfig`가 CSRF를 꺼둬서, 외부 페이지의 이미지 태그 하나만으로도 로그인된 사용자의 좋아요가 본인 의지와 무관하게 토글될 수 있음. (review 담당 영역)
4. **리뷰 좋아요 경쟁 조건** — check-then-act 방식 + `REVIEWLIKE`에 (리뷰,회원) 유니크 제약 없음 → 동시 요청 시 중복 좋아요 생성, 이후 해당 리뷰의 좋아요 조회가 `TooManyResultsException`으로 500. (review 담당 영역)

### 프로젝트 전체에 걸친 구조적 위험

5. **전역 예외 처리기(`@ControllerAdvice`)가 프로젝트에 하나도 없음** — 위 3,4번을 포함해 예상 못 한 예외가 전부 스프링 기본 에러 페이지/스택트레이스로 그대로 노출됨. `@RequestParam int`류 필수 파라미터 누락도 마찬가지.
   - **📌 사용자 의견: 이것도 교육과정 범위 밖일 수 있어 애매함 — 팀 논의 대기, 지금은 수정하지 않음.**
6. ~~관리자 상품 등록의 이미지 검증이 클라이언트가 보낸 `Content-Type` 헤더만 신뢰함~~
   - **✅ 조치 완료 — `util.ImageValidationUtil`(매직 바이트 검증)로 대체, 리뷰 이미지 업로드에도 동일 적용(위 "조치 완료" 참고).**
7. ~~상품 등록 도중 태그 JSON 파싱처럼 뒷단에서 실패하면 DB는 롤백되지만 이미 디스크에 저장된 이미지 파일은 그대로 남아 orphan 파일로 누적됨~~ (admin 자체 검토)
   - **✅ 조치 완료 — 아래 "조치 완료" 섹션의 "파일 업로드 orphan 완전 차단 + 파일 정합성 검사 기능" 참고.**
   - 참고로 이 논의 과정에서, 초기 프로젝트 설정 문서의 "@Transactional 어노테이션 사용으로 무결성 확보" 항목이 이 문제와 관련 있는지 확인 요청이 있었음 → 조사 결과 `@Transactional` 자체는 프로젝트 전체 write 메서드(`MemberServiceImpl.signUp`, `ProductServiceImpl`(클래스 레벨), `ReviewServiceImpl.writeReview`, admin 3종 서비스 전부)에 이미 잘 적용돼 있었음(정책 자체는 잘 지켜지고 있었음). 다만 `@Transactional`은 DB 커넥션의 커밋/롤백만 관리할 뿐 파일 시스템 쓰기에는 전혀 관여하지 않아서, 완벽하게 적용해도 이미 디스크에 쓰인 파일까지 되돌리지는 못함 — DB와 파일은 서로 다른 자원이라 트랜잭션 하나로 묶을 수 없는 구조적 한계이고, 이 문제 해결과는 별개 사안이었음(그래서 아래처럼 `TransactionSynchronizationManager`로 별도 처리).
   - 부수 발견: `ProductController`(컨트롤러 계층)에도 클래스 레벨 `@Transactional`이 걸려있는데, `ProductServiceImpl`에도 이미 클래스 레벨로 걸려있어 중복임. "트랜잭션 경계는 서비스 계층에 둔다"는 일반적인 설계 관례에서 벗어난 지점이라 참고로 남김(동작 오류는 아님, 나중에 레이어링 정리할 때 참고).
8. 리뷰 이미지 업로드에 콘텐츠타입 검증이 없었음 — **이번에 조치 완료** (위 "조치 완료" 참고).
9. ~~`/member/orderDelivery` 배송 목록 조회가 N+1 쿼리(주문 건수만큼 개별 쿼리) — 주문이 쌓일수록 느려짐.~~
   - **✅ 조치 완료 (2026-08-30) — 대표 상품 조회를 `AdminOrderMapper.selectOrderList`와 동일한 `ROW_NUMBER() OVER (PARTITION BY ...)` 패턴으로 `selectDeliveriesByMemberId` 쿼리 하나에 통합. `MemberServiceImpl.listDelivery()`의 반복 조회 루프 제거.**
10. `login.jsp`에서 `${error}`는 이스케이프 안 하면서 바로 아래 `redirectURL`은 이스케이프하는 등 같은 파일 안에서도 처리가 불일치 — 지금은 `error`가 전부 고정 문구라 안전하지만, 나중에 사용자 입력을 반영한 에러 메시지를 추가하면 XSS 함정이 됨. (위 2번 논의와 연결됨)
11. `CouponController`의 `/coupon/couponview`에 인증 검사가 전혀 없음(지금은 정적 목업이라 무해).
12. `/uploads/**`가 접근 제어 없이 전체 공개 — 지금 저장되는 상품/리뷰 이미지는 원래 공개용이라 문제없지만, 나중에 같은 업로드 유틸/디렉터리에 비공개성 파일을 저장하게 되면 그대로 공개돼버리는 구조.
13. `DELIVERY_STATUS_RANK.get(currentDeliveryStatus)`가 DB CHECK 제약이 항상 5개 값 중 하나임을 암묵적으로 신뢰(admin 자체 검토, 우선순위 낮음) — 제약이 느슨해지거나 다른 경로로 예외값이 들어가면 NPE 가능.

### 인증 가드 / 설정 관련 (교차점검)

14. **`WebConfig.java`의 `LoginInterceptor` 적용 경로 vs admin 인라인 가드** — 결론: **현재 구조(admin은 인터셉터 미적용, `AdminAuthUtil.pageGuard()`/`apiGuard()`를 각 컨트롤러 메서드에서 호출) 유지 권장.** 이유는 채팅 답변 참고 — `LoginInterceptor`는 "로그인 여부"만 확인하고 5개 경로 전부 페이지(리다이렉트) 응답인 반면, admin은 "ADMIN 역할"까지 확인해야 하고 같은 URL prefix 아래 페이지 응답과 JSON API 응답이 섞여있어(`/admin/coupon` vs `/admin/coupon/list` 등) 인터셉터 하나로 두 응답 형태를 우아하게 분기하기 어려움. 실제 유지보수 부담이 되는 부분(체크 로직 중복)은 이번 세션에 `AdminAuthUtil`로 이미 통합됐음 — 메커니즘(인터셉터 vs 인라인 호출)이 다를 뿐 로직 자체는 단일 소스.
15. **Config/Secrets(하드코딩된 DB 접속정보, `httpBasic` 비활성화, `BCryptPasswordEncoder` 사용, CORS 미설정 등) 전반**
    - **📌 사용자 의견: 이 부분 전반이 프로젝트 제작 시 배운 범위를 그대로 적용한 공통 규약에 가까움. 임의로 바꾸면 오히려 팀 코드리뷰 때 서로 이해 못 하는 범위 밖 변경이 될 수 있음. 내용 자체는 지우지 말고 "알아는 둬야 할 사항"으로 계속 남겨둘 것.**
    - (참고로 `application.properties`는 `.gitignore`에 등록되어 있어 실제로 git에는 커밋되지 않음 — 저장소 유출 위험 자체는 없음. 위 정책 항목 9번의 죽은 `spring.security.user.*` 설정과는 별개 사항.)

### 이후 세션에서 추가로 발견된 것 (16~19)

16. **신규 발견 (2026-08-30, 유저 주문 배송 확인 기능 세션): `header.jsp:30`의 `data-logged-in="${not empty sessionScope.loginMemberId}"`가 항상 `false`로 나옴** — 프로젝트 전체에서 `loginMemberId`라는 세션 키가 저장되는 곳이 한 군데도 없음(실제 로그인 시 저장되는 키는 `SessionConst.LOGIN_SESSION`, 값은 `MemberDTO` 객체). 실제로 로그인한 상태로 `/member/orderDelivery`를 확인하던 중 응답 HTML에서 `data-logged-in="false"`로 찍히는 것을 발견함(세션 쿠키 정상 전달, 컨트롤러 레벨 로그인 체크는 별도로 정상 동작 — `header.jsp`의 이 표시만 항상 틀림).
    - **영향**: `static/js/views/header.js`가 이 값을 `isLoggedIn`으로 읽어서, 홈(`/`) 방문 시 "비회원이면 장바구니/찜 localStorage 초기화" 로직을 로그인 여부와 무관하게 항상 실행함 → **로그인한 회원이 홈 화면에 올 때마다 담아둔 장바구니/찜 데이터가 매번 조용히 삭제됨.** 장바구니/찜이 아직 localStorage 임시 구현(실제 DB 연동 전)이라 지금 당장 서버 데이터가 날아가는 건 아니지만, 사용자 입장에서는 "장바구니에 담았는데 홈에 갔다 오면 사라진다"로 체감되는 실질적 버그.
    - `common/header.jsp`/`static/js/views/header.js`는 이번 세션 범위(member 패키지의 order/delivery) 밖이라 수정하지 않음 — header/cartWish 담당자 확인 필요.
17. **신규 발견 + 부분 조치 (2026-08-30): 세션은 유효한데 실제 회원 행이 없어진 경우(탈퇴/관리자 삭제 등) 처리가 컨트롤러마다 들쭉날쭉함.** 로그인 후 세션은 서버 메모리에 그대로 남아있어서 `WebConfig.LoginInterceptor`(로그인 여부만 확인)는 통과되는데, 그 이후 회원 데이터를 다시 조회하는 지점에서 `null` 처리를 안 해두면 화면이 깨짐 — `MemberController.myPageForm()`에서 실제로 재현됨(회원 상세를 통째로 다시 조회해서 필드 전부가 빈 값으로 렌더링됨). ✅ `myPageForm()`은 조치 완료(`getMemberByMemberId()`가 null이면 `session.invalidate()` + 로그인 페이지로 리다이렉트, HANDOFF.md 3-30-18 참고). **`wishlistForm`/`cartForm`/`userOrderDeliveryForm`/`userCouponViewForm`은 회원 상세를 다시 조회하지 않고 memberId만 사용해서 목록 쿼리가 빈 결과를 반환할 뿐 이 정도로 눈에 띄게 깨지진 않지만, 근본적으로는 같은 종류의 gap이 남아있음** — 실제 탈퇴 기능이 생기면 (정책 항목 1번과 연결) 이 메서드들도 전부 같은 패턴으로 점검 필요.
18. **신규 발견 (2026-08-31, KGH_works→server_for_merge 병합 검토 세션): `/member/updateInfo`가 `WebConfig.LoginInterceptor` 보호 경로 목록에서 빠져있어 비로그인 접근 시 500(NPE)** — `addPathPatterns`에 `/member/myPage`,`/member/couponView`,`/member/wish`,`/member/cart`,`/member/orderDelivery`,`/order/**`는 있는데 KGH_works가 새로 추가한 `/member/updateInfo`(BE014, 멤버 정보 수정 기능)만 빠짐. 로그인 인터셉터를 그냥 통과해버려서 `MemberController.updateInfoForm()`이 세션 없이 `member.getRole()`을 호출 → `NullPointerException`이 그대로 500 스택트레이스로 노출됨(실제 병합 결과물 서버 기동 후 `curl`로 재현 확인). 같은 패턴이 `updateNickname`/`updatePhone`/`updateEmail`/`updateName`/`updateBirth`/`updateGender`/`updatePassword`(전부 `member.getMemberId()`를 null 체크 없이 호출) POST API에도 있음 — 정상 플로우에선 updateInfo 화면에서만 호출되니 괜찮지만 세션 만료 후 탭을 열어둔 채로 호출하면 동일하게 500. member 패키지 담당자(KGH) 확인 필요, 이번 세션 범위 밖이라 직접 수정하지 않음. 고치는 방법은 간단: `addPathPatterns`에 `"/member/updateInfo"` 추가(GET 페이지는 해결) + POST API들은 와일드카드 패턴 추가 또는 각 메서드에 null 체크 추가.
19. **신규 발견 + 조치 완료 (2026-08-31 저녁, 홈페이지 CSS 마무리 세션): `href="#"` placeholder 링크 + 전역 `a:visited` 규칙의 명시도 함정.** `default.css:22`에 `a:visited { color: #333; }`가 있는데(타입+가상클래스 조합이라 명시도 `(0,1,1)`), `href="#"`(현재 페이지 자기 자신을 가리킴)는 브라우저가 클릭 없이도 바로 `:visited`로 취급함 — 그래서 이런 링크의 글자색을 **순수 클래스 선택자 하나**(명시도 `(0,1,0)`)로만 입히면 `a:visited`한테 밀려서 의도한 색 대신 `#333`(거의 검정)으로 보임. 사용자님이 홈페이지에서 실제로 겪고 Chrome DevTools로 직접 원인 특정(취소선 규칙 확인). **조치 완료**: 홈페이지의 `.product-rating`(별점, 리뷰 링크화)과 `.section-more`("전체 상품 보기")는 각각 `#product-list .product-rating`/`#product .section-more`로 스코프해서 ID+클래스 조합(명시도 `(1,1,0)`)으로 `a:visited`를 이기게 수정함(HANDOFF.md 3-38-10 참고). **이 사이트에는 아직 실제 라우트가 없어 `href="#"`로 남겨둔 placeholder 링크가 많음(`TODO(placeholder route)` 주석들) — 다른 페이지 작업 때 이 링크들에 색을 입히면서 순수 클래스 선택자만 쓰면 같은 문제가 재발할 수 있으니, 항상 `a:visited`보다 명시도가 높은 선택자(ID 스코프 등)를 쓰거나 `:visited`를 명시적으로 함께 오버라이드할 것.**

---

## 클린으로 판단된 항목 (참고용, 문제 없음)

- **SQL Injection**: 전체 매퍼 XML(`${}` 패턴) 전수 조사 결과 0건 — 전부 `#{}` 안전 바인딩.
- **CORS**: 별도 설정 없음(와이드오픈 아님, 브라우저 기본 동일-출처 정책 적용).
- **PasswordEncoder**: `BCryptPasswordEncoder` 정상 사용 중.
- **파일 업로드 경로 순회**: 저장 파일명이 UUID 기반이라 `../` 경로 순회/파일명 충돌 위험 없음.
- **IDOR**: 리뷰 작성 시 소유권 확인이 DB 조인 단계에서 강제되어 있어 다른 사람 주문번호로 리뷰 작성 시도 시 안전하게 차단됨. Admin 컨트롤러들도 전부 가드가 걸려있음(누락 없음 확인).
- 이번 세션에 다룬 admin 3종 기능·로그인 리다이렉트·DTO 통합 부분은 세 조사 모두 "이미 하드닝돼 있음"으로 확인.
- **`JWC_works`(홈페이지 리디자인) → `front_for_merge` 병합 (2026-08-31)** — 병합 전/후 코드 리뷰 + 실제 빌드/기동/스모크테스트로 검증, 신규 버그 없음. KGH_works 병합 때와 달리 조용한 파일 삭제도 없었음. `style.css` 충돌 9곳은 두 브랜치가 독립적으로 같은 스타일가이드 팔레트를 반영하다 생긴 것으로, JWC_works 쪽 채택 후 `header.js`/`cartWishService.js` 등 기존 JS와의 id/data-속성 계약이 전부 유지되는 것까지 확인함. 자세한 내용은 HANDOFF.md 3-33 참고.
  - 사소한 참고: `style_home.css`의 주석이 "HomeController가 `bodyClass` 모델 속성을 내려준다"고 설명하는데, 실제 구현은 Java 변경 없이 `header.jsp`의 EL 삼항연산자(`jakarta.servlet.forward.servlet_path` 확인)만으로 처리됨 — 기능상 문제는 없고 주석만 실제 코드보다 앞서있는 상태(추후 나머지 8개 페이지 작업 재작업 시 자연히 갱신될 것으로 예상, 지금은 손대지 않음).

---

## 추가 제안 (검토 결과)

1. ~~couponValue 부동소수점 정밀도 개선안~~ → **적용 완료** (BigDecimal, 위 참고)
2. ~~관리자 이미지 Content-Type 스푸핑 대응 개선안~~ → **적용 완료** (매직 바이트 검증, 위 참고)
3. ~~업로드 파일 트랜잭션 롤백 시 orphan 방지 개선안~~ → **적용 완료** (2026-08-31, 아래 "조치 완료" 및 상세 설명 참고)
