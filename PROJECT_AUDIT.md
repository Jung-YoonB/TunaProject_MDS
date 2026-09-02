# 프로젝트 전체 검증 결과 (버그 / 정책 검토 / 잠재적 위험)

## 이 문서 쓰는 법

- **항목 번호는 고정 ID다.** HANDOFF.md와 대화에서 "버그 5번", "정책 항목 11번", "잠재적 위험 19번"처럼 번호로 참조하는 곳이 많으므로 **재번호를 매기거나 번호를 재사용하지 말 것.** 새 항목은 항상 각 섹션의 마지막 번호 다음으로 이어 붙인다.
- **조치된 항목은 지우지 않는다** — `~~취소선~~` + `✅ 조치 완료` 표시로 남겨서, 같은 문제가 재발했을 때(실제로 여러 번 있었음) 이력을 바로 확인할 수 있게 한다.
- 담당 영역이 다른 항목(product/review/member 등)은 **기록만 하고 고치지 않는 것**이 이 프로젝트의 규칙. 팀원에게 공유해서 각자 고치도록 한다.
- **⛔ 이 문서를 갱신하는 것은 팀장(BJY) 한 사람만 한다.** 팀원(및 팀원이 쓰는 Claude)은 **읽기 전용 참고 자료로만** 쓸 것 — 항목 추가·수정·삭제, 오류 정정 모두 하지 말 것. 고칠 내용이 있으면 직접 손대지 말고 팀장에게 전달하면 팀장이 반영한다. (`HANDOFF.md` / `HANDOFF_NEXT_SESSION_PROMPT.txt`도 동일)

## 현황 요약 (2026-09-02 기준)

| 섹션 | 항목 수 | 비고 |
|---|---|---|
| 버그 (기능이 실제로 깨져 있음) | 48개 — 조치 완료 48 · 미해결 0 | **2026-09-03: 전면 재점검 6라운드.** 1라운드(1~21번): review 이미지 공유·빈 IN() 500·상품 STATUS 필터·회원가입 폼·addAddress 신설·`cart.xml` LEFT JOIN 무력화 등. 2라운드(22~28번): 홈 배너 미노출·페이지네이션 5곳 스크롤 복귀·헤더 뱃지 목업·찜 추가 전 화면 서버 미반영·배송지 추가 진입 불가·검색/찜 별점 CSS 누락. 3라운드(29~33번): **옵션 가격이 (실제가-대표가)로 계산되어 기본 옵션이 항상 "0원"**(가장 심각), 카테고리·이동경로·짧은 설명 고정 텍스트, 등급 할인 고정값, 대표이미지 중복 시 500. 4라운드(34~40번): 리뷰 링크 `href="#"`, 장바구니·찜 선택모드 전환+페이지네이션, **장바구니 개별삭제·수량변경 버튼 미반영**, 헤더 뱃지 즉시반영 누락, **로그아웃 후 재로그인 시 찜 상태 미반영**, **결제 페이지 폼 재제출 확인**(PRG 미적용). 5라운드(41~46번): **장바구니 재담기 시 수량 안 늘어나던 것**, 찜 선택모드 "장바구니 담기" 벌크 버튼 부재, 결제 페이지 포인트 안내 중복/레이아웃 붕괴, **`GET /order/checkout` 405 원인불명 에러**(사용자 직접 재현), 결제 페이지 폭·할인정보 여백 CSS. 6라운드(27번, 47~48번): **상품 상세 리뷰 이미지가 경로 컬럼 누락으로 전부 깨져 있던 것**, **리뷰 좋아요 버튼이 백엔드는 있는데 화면에 아예 없던 것**, 27번(드롭다운 화살표 위치 — `#product-option`/`#coupon_id`가 `appearance:none` 처리 없이 네이티브 화살표만 쓰던 것, 사용자 스크린샷으로 위치 특정 후 해결). **미해결 항목 없음** |
| 정책적 고려가 필요한 부분 | 11개 — 조치 완료 1 | **11번(리뷰 삭제 후 재작성)은 2026-09-01 결정·구현 완료 → 같은 날 방식 재변경**(`REVIEWHISTORY` 테이블 폐기 → `REVIEW.REVIEW_STATUS` 소프트 삭제, HANDOFF 3-47). **product 영역 집계 3곳 필터 추가가 아직 미반영** |
| 잠재적 위험 요소 | 27개 — 조치 완료 10 | 20~27번은 원래 "20~27" 그대로 순서가 맞았지만 문서 앞쪽에 잘못 끼어 있던 걸 2026-09-03에 이 레지스트리로 이동만 함(내용 변경 없음). **19·21·22번은 "브라우저가 자동으로 붙이는 상태"(`:visited`/`:focus`/`[hidden]`)를 hover처럼 다루면 안 된다는 같은 계열.** **25·26·27번은 "같은 규칙이 서버·화면 두 곳에 따로 적혀 갈라지는" 계열** — 금액 계산·정책 상수·뷰 이름. 조치 완료지만 재발하기 쉬운 유형이라 새 기능마다 확인할 것. **20번(`style_user.css` 최상위 `#id` 102개)·24번(추가 이미지 표시/검증 불일치)은 미조치** |
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
2. ~~**`ProductServiceImpl.java:81,88-94`** — 리뷰 이미지 리스트가 반복문 밖에서 한 번만 생성되고 초기화가 안 됨 → 모든 리뷰가 같은 리스트 객체를 공유해서, 상품에 리뷰가 여러 개면 각 리뷰마다 다른 사람 사진까지 전부 섞여서 표시됨.~~ **✅ 조치 완료 (2026-09-03 재확인)** — `images` 리스트가 반복문 안에서 매번 새로 생성되도록 이미 수정되어 있다.
3. ~~**`ProductServiceImpl.java` + `detailPage.xml:122-128`** — 리뷰 0개 상품에서 리뷰 탭 진입 시 빈 리스트로 `IN ()` 쿼리가 생성되어 Oracle `ORA-00936`으로 500.~~ **✅ 조치 완료 (2026-09-03 재확인)** — `reviewIds.isEmpty()`면 `getReviewImages` 호출 전에 바로 빈 리스트를 반환하는 가드가 이미 들어와 있다.
4. ~~**`ProductServiceImpl.detailPage()`** — 상세조회는 `STATUS='ON_SALE'`만 허용하는데 목록/검색(`product.xml`)엔 상태 필터가 없음 → 품절/숨김 상품을 목록에서 클릭하면 결과 `null`에 바로 필드 접근해 NPE.~~ **✅ 조치 완료 (2026-09-03)** — `product.xml`의 `getList`/`countSearchProducts` 양쪽 `<where>`에 `AND P.STATUS = 'ON_SALE'` 추가. 실서버(8798)로 재현 확인: `PRODUCT_ID=6`을 `SOLD_OUT`으로 바꾸니 목록에서 바로 빠지고(`/mds/searchList` 응답에서 `data-product-id="6"` 사라짐), 원복 후 다시 나타남. `countSearchProducts`는 애초에 필터가 없었던 별도 쿼리라 같이 안 고치면 총 개수·페이지네이션이 실제 목록과 어긋나서 함께 수정.
5. ~~**`signUp.jsp:8`** — `<form>`에 `action`/`method`가 없고, input `name`도 `MemberDTO`의 camelCase 프로퍼티와 다름(`member_name` vs `memberName` 등). 회원가입 버튼을 눌러도 아무 것도 저장 안 되고 새로고침만 됨.~~ **✅ 조치 완료 (2026-09-03 재확인 + 실서버 회원가입 테스트)** — `<form action="/member/signUp" method="post">`와 camelCase `name` 속성이 이미 들어와 있다. 실제로 8798에 회원가입 POST를 보내 302(→`/member/login`)와 DB 저장(`DUMP()`로 한글 이름 바이트까지 확인)까지 검증하고 테스트 계정 삭제.
6. ~~같은 지점 — 폼을 우회해 API를 직접 호출하면 `MemberDTO`엔 `loginId`/`loginPw` 외 필드 검증이 없어서 `memberName` 없이 요청 시 Oracle NOT NULL 위반이 처리 안 된 500으로 그대로 노출.~~ **✅ 조치 완료 (2026-09-03 재확인)** — `MemberDTO`에 `memberName`/`nickname`/`phone` 모두 `@NotBlank` + `@Pattern` 검증이 붙어 있어 `BindingResult`로 걸러진다.
   - **📌 ROLE 관련 하위 이슈(2026-08-31 발견)도 함께 재확인 완료**: `MemberServiceImpl.signUp()`이 `member.setRole(...)`을 안 해도, `signUp.jsp`에 `<input type="hidden" name="role" value="USER">`가 있어 실제 폼 제출 경로에서는 항상 값이 채워져 문제없음(위 실서버 테스트에서도 `ROLE=USER`로 정상 저장 확인). API 직접 호출 시 `role` 파라미터를 안 보내면 여전히 500이 날 수 있으나, 정상 사용자 플로우(폼 제출)에는 영향 없음.
7. ~~**`MemberMapper.xml:90-97`** — `/member/orderDelivery`가 DELIVERY 테이블과 INNER JOIN인데, 관리자가 배송 상태를 처음 바꾸기 전엔 DELIVERY 행이 없음(체크아웃 미구현) → 결제 완료했지만 배송 처리 전인 주문이 목록에서 통째로 사라짐.~~
   - **✅ 조치 완료 (2026-08-30, 유저 주문 배송 확인 기능 구현 세션) — `selectDeliveriesByMemberId`를 LEFT JOIN으로 변경. `AdminOrderMapper.selectSummary`와 동일한 패턴. 자세한 내용은 HANDOFF.md 참고.**
8. ~~**`MemberMapper.xml:67-88`** — 찜/장바구니 조회가 `PRODUCT_TITLE_IMAGE=0`(대표이미지)과 INNER JOIN. 대표이미지 등록을 빠뜨린 상품은 찜/장바구니에 담겨 있어도 목록에서 안 보임.~~
   - **✅ `wish.xml` 조치 완료 확인 (2026-09-03)** — `getWishList`가 JOIN이 아니라 스칼라 서브쿼리로 대표 이미지를 가져온다(대표 이미지가 없으면 `IMAGE_PATH`/`TITLE_IMAGE`가 NULL일 뿐, 상품 자체가 목록에서 빠지지 않음).
   - **✅ `cart.xml` 조치 완료 (2026-09-03)** — `getCartList`는 `LEFT JOIN PRODUCTIMAGE`를 쓰고 있었지만 `pi.PRODUCT_TITLE_IMAGE = 0` 조건이 `ON`이 아니라 `WHERE`에 있어서 **LEFT JOIN이 사실상 INNER JOIN으로 무력화**되는, 같은 버그의 변종이었다(대표 이미지 없는 상품은 `pi` 쪽이 전부 NULL이 되고, `WHERE pi.col = 0`은 NULL과 비교하면 항상 거짓이라 행 자체가 걸러짐). 조건을 `ON` 절로 옮겨 진짜 LEFT JOIN이 되도록 수정. 실서버(8798)로 재현: 상품 하나의 대표이미지 플래그를 임시로 치우고 장바구니에 담아보니, 수정 전 로직이었다면 통째로 빠졌을 항목이 `titleImage: ""`로 정상 노출됨을 확인, 테스트 데이터 정리(대표이미지 플래그 원복 포함) 완료.
9. ~~**뷰 이름 불일치**~~ — `/member/wish`,`/member/cart`,`/member/orderDelivery`가 리턴하는 뷰 이름에 실제 파일이 없음(진짜 파일은 `product/wish.jsp`, `order/userOderDelivery.jsp` 등) → 접근 시 뷰 리졸브 실패로 500.
   - **✅ `/member/orderDelivery` 부분만 조치 완료 (2026-08-30) — `MemberController.userOrderDeliveryForm()`이 반환하는 뷰 이름을 `order/userOderDelivery`로 수정. `/member/wish`,`/member/cart`는 이번 범위 밖(product 패키지 담당)이라 그대로 남아있음.**
   - **참고(2026-08-30): 실제로는 500이 아니라 404로 남(Spring Boot 3.x JSP 뷰 리졸버가 파일 없음을 404로 처리) — `{"status":404,"message":"JSP file [/WEB-INF/views/member/cart.jsp] not found"}` 형태로 확인됨.** 마이페이지 UI 개편(`member/myPage.jsp`) 중 "나의 장바구니"/"나의 찜 목록"을 실제 라우트로 연결하려다 이 버그를 직접 재현함. 이후 사용자님이 제공한 디자인 시안에 따라 "주문관리" 섹션을 주문·배송조회/주문취소환불 2개 항목만 있는 리스트 형식으로 다시 짜면서 장바구니/찜 항목 자체가 화면에서 빠짐(헤더의 장바구니/찜 아이콘으로 이미 접근 가능해서 중복 제거) — 그래서 지금은 `myPage.jsp`에 `/member/cart`,`/member/wish` 링크 자체가 없음. product 패키지 담당자가 이 버그를 고친 뒤 마이페이지에도 다시 노출하고 싶다면 새로 추가하면 됨.
   - **✅ `/member/wish`,`/member/cart` 부분도 조치 완료 (2026-08-31, KGH_works 브랜치 병합) — `wishlistForm()`/`cartForm()`이 반환하는 뷰 이름을 각각 `product/wish`/`product/cart`로 수정. `KGH_works`를 `server_for_merge`(BJY_works 기반 병합용 브랜치)에 병합해서 반영됨 — 브랜치 병합 전 diff 검토 시 KGH_works 쪽 커밋 초반에 `product/cart.jsp`/관련 CSS(`style_cart.css` 등)가 실수로 삭제된 채 푸시됐던 것을 발견해서 작업자에게 복구 요청 → 재푸시 후 병합, 병합 결과물 실제 서버 기동 + curl 스모크테스트까지 확인 완료.**
10. ~~**깨진 내부 링크 여러 개** — 마이페이지 링크가 소문자 `mypage`로 되어있어 실제 매핑(`myPage`)과 안 맞아 404. `/member/updateInfo`,`/member/userWithdraw`,`/member/addAddress`는 대응하는 컨트롤러 매핑 자체가 없음.~~ **✅ 전체 조치 완료 (2026-09-03)** — 아래 하위 항목 전부 해소.
    - **참고(2026-08-31): `/member/updateInfo`는 이후 KGH_works 브랜치에서 매핑 자체는 신규 구현됨(BE014, 멤버 정보 수정 기능) — 다만 새로운 문제가 생김, 아래 18번 참고.**
    - **✅ `/member/addAddress` 부분 조치 완료 (2026-09-03)** — `utill/deliveryAddress.jsp` 자체를 렌더링하는 `GET /member/deliveryAddress`도 없었어서(`header.jsp`에 "컨트롤러 미연결" TODO로 이미 표시돼 있었음) 같이 신설. 스키마(`DELIVERYADDRESS`)엔 `ADDRESS_NAME`/`DETAIL_ADDRESS`만 있고 수취인/전화번호/우편번호 컬럼이 없어서, `zipcode+address+detailAddress`를 `DETAIL_ADDRESS` 한 문자열로 합치고 `recipient`/`phone`은 저장하지 않는 방식으로 구현(`DeliveryAddressDTO` 신설, `MemberMapper`에 `clearDefaultAddress`/`insertDeliveryAddress` 추가, `MemberService.addDeliveryAddress()`가 기본 배송지 체크 시 기존 기본 배송지부터 해제). 실서버(8798)에서 로그인 후 배송지 2건 연속 등록(하나는 기본 체크)까지 실제로 테스트: 새 기본 배송지 등록 시 이전 기본이 `N`으로 바뀌는 것까지 DB로 확인, 테스트 데이터 삭제 완료.
    - **✅ 전체 조치 완료 (2026-09-03 재확인)** — `order/userOderDelivery.jsp` 1곳은 2026-08-30에 이미 수정됨(아래 참고). 남아있다던 나머지 위치도 `webapp`/`static/js` 전체를 `member/mypage`(소문자)로 재검색해보니 0건 — 그 사이 다른 병합들로 같이 정리된 것으로 보인다.
    - (2026-08-30 최초 조치 기록) 사용자님이 리뷰 작성 후 "마이페이지로 돌아가기" 버튼을 눌러서 직접 404(스택트레이스의 줄 번호 "527"을 에러 코드로 오인해서 리포트됨)를 재현 → `/member/mypage` → `/member/myPage`로 수정.
11. ~~**`MyPageWishDTO.reviewAvg`가 `Long`** — 쿼리는 소수점 1자리 평균(`4.5`)을 계산하는데 `Long`으로 받아서 소수부가 잘림.~~ **✅ 대상 클래스 자체가 없어져서 자동 해소 (2026-09-03 확인)** — `MyPageWishDTO`는 wish/cart가 전용 패키지로 분리되며(버그 8 참고) 삭제됐고, 지금 찜 목록에 쓰이는 `wish.model.dto.WishListDTO`는 처음부터 `private double score`로 되어 있어 이 버그의 대상이 아니다.
12. ~~**이미지 경로 오타**~~ — `MemberServiceImpl.java:134`와 `productDetail.jsp`(3곳)에 `/upload/product/`(s 빠짐)로 하드코딩. 실제 정적 리소스 경로는 `/uploads/**`.
    - **✅ 전체 조치 완료 (2026-09-03 재확인)** — `MemberServiceImpl.java:134`는 2026-08-30에 이미 수정됨(아래 참고). 남아있다고 적었던 `productDetail.jsp`(3곳)도 프로젝트 전체를 검색해보니 `/upload/product/`(오타)가 0건 — 그 사이 다른 병합으로 같이 정리된 것으로 보인다.
13. ~~**회원 탈퇴 링크가 404**~~ — `member/userUpdateInfo.jsp:201`이 `${contextPath}/member/userWithdraw`(GET)로 링크하는데 `MemberController`에 그 매핑이 없어서 404가 났었다.
    - **✅ 조치 완료 (2026-09-03 재확인)** — `MemberController`에 `@GetMapping("/userWithdraw")`가 생겨 200으로 뜬다. 이전에 남아있다고 적었던 하위 이슈("`POST /member/withdraw`를 호출하지 않고 그냥 이동만 함")도 재확인해보니 이미 해결돼 있었다 — `views/userUpdateInfo.js`의 탈퇴 링크 클릭 핸들러가 `window.MemberService.withdraw()`(→ `POST /member/withdraw`)를 먼저 호출하고, 응답의 `result.data`가 true일 때만 `userWithdraw.jsp`로 이동한다.
14. ~~**`product/searchProduct.jsp`를 반환하는 컨트롤러가 없음**~~ **✅ 조치 완료 (2026-09-02 밤, `JWC_works` 병합)** — `ProductController.getSearchList()`(`GET /mds/searchList`)가 `product/searchProduct`를 반환한다. 홈(`/`)의 "전체 상품 보기"/카테고리 링크도 전부 이 경로로 연결됨(HANDOFF 3-58/3-59).

15. ~~**세션 만료 상태로 `/member/updateInfo` 접근 시 500**~~ **✅ 조치 완료 (2026-09-03 재확인)** — `MemberController.updateInfoForm()`에 `member == null` 가드 + `/member/login` 리다이렉트가 이미 들어와 있다.
16. ~~**`cart`/`wish` 화면이 도달 불가 — 4개 경로 전부 404**~~ **✅ 조치 완료 (2026-09-02 밤, HANDOFF 3-57) — `JWC_works` 병합으로 컨트롤러 진입점이 붙었다.** 로그인 상태에서 `/wish/my-wish`·`/cart/my-cart` 200. 장바구니는 DB(`CART`) 기반, 찜은 `wish.jsp` → `window.serverWishItems` → `wishService.js` 경로로 서버 목록을 쓴다.
17. ~~**상품이 2건 이상인 주문에서 대표 상품 외 나머지가 리뷰 작성 경로를 잃음**~~ **✅ 조치 완료 (2026-09-01, HANDOFF 3-45)** — 리뷰 링크용 `OD_ID`를 대표 상품이 아니라 "아직 안 쓴 것 중 최소 OD_ID"로 바꿔 배지 숫자와 실제 진입 경로가 일치하게 함.
18. ~~**마이페이지 빠른메뉴의 "리뷰 작성" 타일이 클릭해도 아무 반응이 없음**~~ **✅ 조치 완료 (2026-09-02, HANDOFF 3-54-2)** — "리뷰 작성" 섹션과 같은 기준으로 분기(쓸 리뷰 있으면 작성 화면, 없으면 배송완료 목록)하는 `reviewTileUrl`을 신설해 타일과 하단 배지가 항상 같은 곳을 가리키게 함.
19. ~~**`cart` 패키지에 미사용 `import` 3건**~~ **✅ 조치 완료 (2026-09-03)** — `cart/Controller/CartController.java`의 `RequestParam`, `cart/model/service/CartService.java`의 `CartListDTO`/`List` 정리. 같은 점검에서 나온 죽은 클래스 `coupon/model/getCouponDTO.java`도 삭제 완료(HANDOFF 3-45-2).

> **참고(버그 아님): 빠른메뉴 "주문·배송 조회" 배지 숫자의 기준** — `countActiveDeliveries`는 **"아직 끝나지 않은 주문 건수"** 를 주문 단위로 센다(`ORDER_STATUS != 'CART'` + `DELIVERY_STATUS`가 `NULL`이거나 `DELIVERED`/`CANCELED`가 아님). 즉 **DELIVERY 행 없음 + 배송준비중 + 배송중 + 배송출발**이 모두 포함되고 배송완료·취소만 빠진다. 라벨이 "주문·배송 조회"라 숫자의 의미가 안 드러나므로, 뷰 작업 시 `aria-label`/툴팁에 "진행 중인 주문 N건"을 넣으면 명확해진다.

20. ~~**회원정보 수정(`/member/updateInfo`)에서 스크롤할 내용이 없는데 스크롤바가 나옴**~~ **✅ 조치 완료 (2026-09-03, 사용자님이 브라우저 devtools로 실측 제공)** — `viewport 1033px` vs `scrollHeight 1064px`로 **31px 초과** 확인, `header(68.67)+main(846.5)+footer(148.33)`가 실측 합과 정확히 일치해 원인 확정. `main:has(.update-page)`가 `padding:40px 20px 80px`(상하 120px)를 갖고 있는데 `.update-page` 자신도 `padding:40px`(상하 80px)를 또 갖고 있어 **세로 padding이 이중으로 겹쳐 있던 것** — 형제 페이지들(`cart-container`/`wishlist-container`/`search-result-page`)은 처음부터 `main`엔 좌우 padding만 주고 세로는 컨테이너가 전담하는 패턴이라 이 문제가 없었음. `main:has(.update-page)`의 padding을 `0 20px`(좌우만)로 바꿔 형제 페이지와 같은 패턴으로 통일 — 40px 이상 여유가 생겨 31px 초과분 해소. (`withdraw-page`는 `margin` 기반의 다른 레이아웃이라 이 이중 padding 패턴 자체가 없음 — 대상 아님.)
21. ~~**장바구니 담기 경로가 화면마다 다르게 동작함 — 일부는 실제 서버, 일부는 localStorage 목업**~~ **✅ 조치 완료 (2026-09-03)** — `searchProduct.jsp`/`wish.jsp` 카드의 "장바구니 담기" 퀵버튼이 이제 실제 `POST /cart/add-cart`(상품 상세 페이지의 `#cart-button`과 동일한 백엔드)를 호출한다. 옵션 선택 UI가 없는 카드라 **상세 페이지 기준 대표 옵션(OPTION_ID가 가장 작은 옵션)을 자동으로 담는다** — `product.xml`의 `getList`/`wish.xml`의 `getWishList`에 `PRICE`와 동일한 기준(`KEEP (DENSE_RANK FIRST ORDER BY OPTION_ID ASC)` 또는 그에 준하는 `ORDER BY ... FETCH FIRST 1 ROW`)으로 `POP_ID`를 추가 조회해서 `ProductListDTO`/`WishListDTO`에 실어 보내고, `common/cartWishService.js`의 `addToCart()`가 이 `popId`로 실제 서버에 담은 뒤 로그인 필요 여부(리다이렉트 최종 URL로 판별)에 따라 안내한다. 실서버(8798)로 검색결과 카드 하나(`popId=15`)·찜 카드 하나(`popId=14`, 상품 6 — 앞서 검색 목록에서 나온 값과 정확히 일치 확인)로 실제 장바구니에 담기는 것까지 검증, 테스트 데이터 정리 완료. 로그인 가드(비로그인 시 `/cart/add-cart`가 `/member/login`으로 리다이렉트)도 그대로 재사용되므로 별도 체크 불필요.
    - **헤더 뱃지 후속 조치 완료(2026-09-03, 아래 24번 참고)**: 위에서 남겨뒀던 "뱃지가 localStorage라 실제 CART와 안 맞음" 문제는 24번에서 실제 서버 값으로 교체했다.

22. ~~**메인 페이지 배너에 사진이 안 나옴**~~ — 검색 결과 페이지 사이드바 배너는 최근 등록 상품 대표이미지 5장이 잘 나오는데, 메인 배너는 문구만 있고 사진이 전혀 없었다(`<div class="banner-image">` 배경 없이 빈 채로, JSP에 "TODO(assets): 실제 배너 이미지 확보되면 추가"라고 적혀 있었음). **✅ 조치 완료 (2026-09-03)** — 원인은 `HomeController`가 `service.getList()`로 배너 목록(`MainPageDTO.banner`)을 이미 받아오고 있으면서 모델에 안 담고 있었던 것뿐(쿼리/서비스는 이미 완성돼 있었음). `model.addAttribute("bannerList", mainPage.getBanner())` 한 줄 추가 + `home.jsp`의 정적 배너 마크업을 검색 페이지 사이드바 배너와 똑같은 패턴(`<c:forEach>` + 문구 3종 순환)으로 교체. 실서버(8798)로 슬라이드 5장 전부 실제 이미지 URL로 렌더링되는 것 확인.
23. ~~**여러 목록 화면에서 페이지네이션(또는 "더보기") 클릭 시 스크롤이 항상 최상단(배너)으로 되돌아감**~~ — 전부 `<a href="...">` 전체 페이지 이동 링크라 앵커가 없으면 브라우저가 기본으로 문서 맨 위로 스크롤한다. 방금까지 보던 상품/목록 위치를 잃어버려서 페이지를 넘길 때마다 다시 스크롤해서 내려가야 했다. **✅ 조치 완료 (2026-09-03)** — 목록 섹션에 `id`를 주고 모든 페이지네이션·더보기 링크에 `#앵커`를 붙였다(상품 상세의 `#review` 탭 전환과 같은 기존 패턴). 대상 5곳: `home.jsp`(`#product`), `searchProduct.jsp`(`#searchResults`, id 신설), `usercouponView.jsp`(`#title`), `userOrderDelivery.jsp`(`#pageTitle`, id 신설), `myReviews.jsp`(`#pageTitle`, id 신설). `productDetail.jsp`는 이미 `#review`를 쓰고 있어서 대상 아님. 실서버로 각 페이지 링크의 `href`에 앵커가 붙어 나오는 것 확인.
24. ~~**헤더 찜/장바구니 뱃지 숫자가 localStorage 목업이라 실제 서버 데이터와 안 맞음**~~ — `header.js`의 `renderBadges()`가 `localStorage`(`cartItems`/`wishItems`)만 읽어서, 예를 들어 상세 페이지에서 실제로 서버 `CART`/`WISH`에 담아도 다른 화면(특히 메인 페이지 새로고침 시)에서는 뱃지 숫자가 그대로거나 0으로 보이는 등 실제 담긴/찜한 개수와 어긋났다("메인페이지에서 찜뱃지가 안 보이는" 증상의 근본 원인). **✅ 조치 완료 (2026-09-03)** — `CartController`/`WishController`에 각각 `GET /cart/count`(로그인 회원의 `CART.QTY` 합계), `GET /wish/count`(로그인 회원의 `WISH` 건수) 신설(비로그인이면 0), `header.js`가 페이지 로드마다 이 두 값을 fetch해서 뱃지에 반영하도록 교체. 실서버로 로그인 전/후 값 차이(0 → 실제 개수) 확인.
25. ~~**찜(위시) "추가"가 화면 어디에서도 서버에 반영되지 않음 — 상품 상세 페이지 포함 완전 클라이언트 전용 목업, 비로그인 상태에서도 로컬에 담김**~~ — `productDetail.jsp`의 찜 버튼은 JS에 `TODO: 찜 API 연결`이라고 적혀 있는 그대로 클래스 토글 + 숫자 표시만 바꿨고, 실제 `WishController`(`POST /wish/insert-wish`, `GET /wish/remove-wish`)는 전혀 호출하지 않았다(둘 다 서버 자체는 로그인 가드가 있는 정상 엔드포인트였음 — 호출하는 화면이 없었을 뿐). 검색결과/찜 카드의 하트 버튼도 `common/cartWishService.js`의 `toggleWish()`가 순수 `localStorage` 목업이라 마찬가지였다 — **로그인 여부와 무관하게 눌리는 것처럼 보였던 것**이 "비로그인 시에도 찜/장바구니가 담기는 것처럼 보이는" 증상의 절반(장바구니 쪽은 버그 21번에서 이미 조치). **✅ 조치 완료 (2026-09-03)** — `toggleWish()`가 로컬 상태로 추가/삭제 방향만 판단하고 실제로는 `/wish/insert-wish`(POST)·`/wish/remove-wish`(GET)를 호출하도록 교체(`addToCart()`와 동일하게 최종 도착 URL로 로그인 필요 여부 판별). `productdetail.js`의 찜 버튼·`searchProduct.js`의 하트 버튼 둘 다 이 함수를 쓰도록 연결. 실서버로 비로그인 클릭 시 `/member/login`으로 이동하는 것, 로그인 후 클릭 시 실제 `WISH` 테이블에 반영되는 것 확인.
    - **남은 제약(이번 범위 밖)**: 새로고침 시 "이미 찜한 상품"이어도 하트가 항상 빈 상태로 보인다 — 서버가 상세 조회/목록 조회 시점에 "이 회원이 이미 찜한 상품인지"를 안 내려주기 때문(`DetailPageDTO`/`ProductListDTO`에 `isWished` 같은 필드 추가가 필요한 별도 작업). 클릭 자체는 항상 정확하게 반영된다(`WishServiceImpl.insertWish`가 중복 찜을 에러 없이 걸러줌).
26. ~~**배송지 추가 기능이 실제로는 끝까지 동작하지 않음 — 진입 버튼 미연결 + 우편번호 검색 팝업 없음**~~ — 버그 10번에서 `POST /member/addAddress`와 `GET /member/deliveryAddress`(폼 화면)까지는 만들었지만, 두 가지가 빠져 있어 실제 사용자는 여전히 이 기능에 닿을 수 없었다: (1) `order/payment.jsp`의 "+ 배송지 추가" 버튼이 `type="button"`인데 JS가 전혀 안 붙어 있어 눌러도 아무 반응이 없었다(사이트 전체에서 `/member/deliveryAddress`로 가는 링크가 이 버튼 하나뿐이라, 이게 안 되면 페이지 자체에 닿을 방법이 없었음). (2) `utill/deliveryAddress.jsp`의 우편번호/주소 입력칸이 `readonly`라 "주소 검색" 버튼을 눌러야만 채워지는 구조인데, 그 버튼에도 JS가 전혀 없어서 폼을 아예 작성할 수 없었다. **✅ 조치 완료 (2026-09-03)** — `payment.jsp` 버튼에 `/member/deliveryAddress`로 이동하는 `onclick` 연결. `deliveryAddress.jsp`에 다음 우편번호 API(카카오/다음, 이 프로젝트에서 API 키 없이 쓸 수 있는 무료 위젯) 스크립트 + 신규 `views/deliveryAddress.js`를 추가해 "주소 검색" 클릭 시 실제 팝업이 뜨고 우편번호/주소가 채워지도록 구현, `zipcode`/`address` 입력에 `required` 추가(팝업 없이 빈 값으로 제출 못 하게). 실서버로 페이지 진입(200) + 스크립트 로드 + 폼 제출까지 재검증(회귀 없음 확인).
    - **📌 "배송지 이동이 안 되는 건"에 대한 해석**: 사이트 전체를 훑어봤지만 `/member/deliveryAddress`로 가는 경로가 이 `payment.jsp` 버튼 하나뿐이라(`myPage.jsp`/헤더 등 다른 곳엔 배송지 관련 링크 자체가 없음), "추가"와 "이동" 두 신고가 같은 증상(그 버튼을 눌러도 어디로도 안 움직임)을 가리키는 것으로 보고 위 조치로 같이 해소된 것으로 판단했다. 만약 다른 화면의 다른 버튼을 가리키신 거라면 알려주시면 다시 확인하겠습니다.
27. ~~**드롭다운/셀렉트 화살표 아이콘 위치가 오른쪽으로 치우쳐 보임**~~ — 사용자님이 스크린샷으로 위치를 특정(상품 상세 페이지 "상품 옵션" 드롭다운, `#product-option`). 확인해보니 `style_admin.css`의 `.input-area select`와 달리 `style_user.css`의 `#product-option`은 애초에 `appearance:none` + SVG 배경 처리가 전혀 없는 **순수 네이티브 select**였다 — `.input-area select` 규칙에 이미 달려 있던 주석("네이티브 화살표는 오른쪽 끝에 딱 붙어 그려져 위치를 못 잡으므로 appearance:none으로 끄고 SVG로 대체") 그대로의 증상. **✅ 조치 완료 (2026-09-03)** — `#product-option`에 동일 패턴(`appearance:none` + `padding-right:38px` + 커스텀 화살표 SVG, `background-position:right 14px center`) 적용. 같은 계열 점검 중 결제 페이지 쿠폰 선택(`#coupon_id`, `order/payment.jsp`)도 동일하게 네이티브 화살표만 쓰고 있던 것을 발견해 같이 수정. (admin `.input-area select`는 이미 처리돼 있어 대상 아님 — 주석의 "근사치라 확인 필요" 우려는 실측 결과 문제 없었음, `#product-option`/`#coupon_id`도 동일 수치로 적용)
28. ~~**검색 결과 페이지(그리고 찜 목록 페이지)의 별점 부분에 CSS가 안 먹음**~~ — 별/점수를 pill 스타일(둥근 배경, hover, 정렬)로 묶어주는 규칙이 `#product-list .product-rating`으로 **홈 화면에만** 스코프돼 있었다. 검색 결과 화면(`.sp-product-grid`)과 찜 목록 화면(`#wish-product-grid`)은 2026-09-02에 카드 마크업이 홈과 완전히 동일하게 통일됐는데, 이 CSS 스코프 목록이 그 통일을 못 따라가서 계속 "맨 텍스트 + `a:visited`로 인해 검게 보임"(default.css의 `a:visited{color:#333}`가 `.product-rating` 단독 규칙보다 명시도가 높아서 이김 — 예전에 홈에서 실제로 겪었던 것과 똑같은 원인) 상태로 남아 있었다. **✅ 조치 완료 (2026-09-03)** — 관련 선택자 3벌(기본/`:hover`/`:focus-visible`/`:active`) 전부에 `.sp-product-grid`·`#wish-product-grid`를 추가. 실서버로 CSS 파일에 새 규칙이 실제로 내려오는 것 확인.

> **아래 29~33번은 2026-09-03, 사용자님이 "상품 상세 페이지 쪽이 심각하다"고 지적해서 `productDetail.jsp`/`productdetail.js`/`detailPage.xml`/`ProductServiceImpl`을 처음부터 끝까지 다시 읽으며 찾은 것들. 사용자님이 나열하지 못할 정도로 여러 군데가 한꺼번에 깨져 있었다.**

29. ~~**옵션별 가격이 완전히 잘못 계산되어 표시됨 — 기본 옵션은 항상 "0원"** (가장 심각)~~ — `ProductServiceImpl.detailPage()`가 각 옵션의 실제 가격(`OptionDTO.price`)에서 대표 옵션의 가격(`dto.getPrice()`, "옵션 목록 중 OPTION_ID가 가장 작은 옵션의 가격")을 **빼는** 코드(`o.setPrice(o.getPrice() - dto.getPrice())`)가 있었다. 옵션 드롭다운·정상가·할인가·총 상품 금액이 전부 이 값을 그대로 쓰기 때문에, 기본 선택 옵션(대부분 대표 옵션과 같음)은 "정상가 0원 / 할인가 0원 / 총 상품 금액 0원"으로 보였고, 다른 옵션을 골라도 실제 가격이 아니라 대표 옵션과의 차액(대부분 0에 가까운 작은 수)만 보였다. 어떤 의도로도 설명이 안 되는 단순 계산 실수로 판단(이런 "차액 표시" UI 자체가 이 화면 어디에도 없음). **✅ 조치 완료 (2026-09-03)** — 그 한 줄을 삭제해서 옵션이 실제 `OPTION_PRICE`를 그대로 쓰게 함. 실서버로 상품 6(759,000원대 헤드폰 아님, 4,450,000원 명품백)·상품 10(759,000원, 옵션 5개 전부 동일가) 둘 다 정확한 실제 가격이 나오는 것 확인.
30. ~~**상품 카테고리/이동경로(breadcrumb)가 모든 상품에서 똑같은 고정 문자열로 표시됨**~~ — `<div id="product-category">결혼·집들이</div>`, `<div id="breadcrumb">홈 &gt; 결혼·집들이 &gt; 코토나 타월 핸드타월 세트</div>`가 EL 바인딩이 아니라 순수 하드코딩 텍스트였다. 어떤 상품을 보든 카테고리는 "결혼·집들이", 이동경로 맨 끝은 "코토나 타월 핸드타월 세트"로 고정 — 상세조회 쿼리 자체가 카테고리를 아예 조회하지도 않고 있었다. **✅ 조치 완료 (2026-09-03)** — `detailPage.xml`의 `productDetail` 쿼리에 `product.xml`의 `getList`(CAT_AGG)와 동일한 패턴의 `LISTAGG` 서브쿼리로 카테고리명을 추가, `ProductDetailDTO.categoryNames` 신설, JSP를 `${detail.product.categoryNames}`/`${detail.product.productTitle}` 기반으로 교체. 실서버로 서로 다른 두 상품이 각자 다른(실제) 카테고리·이동경로를 보여주는 것 확인.
31. ~~**상품 짧은 설명이 모든 상품에서 "집들이 수건 선물 세트"로 고정 표시됨**~~ — 상품명 아래 한 줄 설명이 하드코딩이었다(수건 상품이 아닌 상품을 봐도 항상 "집들이 수건 선물 세트"). 정작 `productDetail` 쿼리가 이미 조회해서 DTO에 담고 있던 `productName`(짧은 부제 성격 필드)은 화면 어디에도 안 쓰이고 있었다. **✅ 조치 완료 (2026-09-03)** — `${detail.product.productName}`으로 교체.
32. ~~**"등급 할인"이 로그인 여부·실제 회원 등급과 무관하게 항상 "BRONZE / 2%"로 고정 표시됨**~~ — `data-discount-rate="0.02"`와 `<span class="grade-badge">BRONZE</span>`가 둘 다 하드코딩이라, 비로그인 손님에게도 할인가가 보이고, PLATINUM(15%) 회원이 봐도 2%만 적용됐다(주문/결제 화면은 `OrderMapper`가 실제 `GRADE.DISCOUNT_RATE`를 쓰고 있어서 정상이었는데, 상세 페이지만 이 연동이 아예 빠져 있었음 — JSP 자체에 예전부터 "TODO: 세션 연동 후 EL로 교체"라고 적혀 있던 미완성 지점). **✅ 조치 완료 (2026-09-03)** — `order` 도메인과 같은 `MEMBER-GRADE` 조인 쿼리(`getMemberGrade`)를 `product` 도메인에 신설, 로그인 상태일 때만 `ProductController`가 세션 회원의 실제 등급/할인율을 모델에 담고, 비로그인이면 할인 줄 자체가 안 보이도록 `<c:if>`로 감쌈. 실서버로 비로그인 시 `data-discount-rate="0"`+뱃지 없음, `dummy_pay1`(PLATINUM) 로그인 시 `data-discount-rate="0.15"`+"PLATINUM"+"15%" 정확히 나오는 것 확인.
    - **📌 후속 조치 (2026-09-03, 사용자님이 스크린샷으로 발견)**: 위 조치로 할인가 줄을 정상적으로 숨겼더니, `.original-price`(정상가)에 항상 걸려 있던 취소선(`text-decoration: line-through`)이 비로그인 상태에서도 그대로 남아 "할인가 줄도 없는데 정상가에 줄만 그어진" 이상한 모습이 됐다(예전엔 할인 줄이 항상 보였어서 안 드러났던 부작용). `#price-info:has(.sale-price) .original-price`로 스코프를 좁혀서 할인가 줄이 실제로 있을 때만 취소선이 걸리도록 수정.
33. ~~**대표이미지가 2건 이상이면 상품 상세 페이지 전체가 500**~~ — `getThumbnail`이 "상품당 대표이미지 1건"을 전제로 `resultType="String"`(스칼라)을 쓰는데, `PRODUCT_TITLE_IMAGE=0`이 DB 제약 없이 그냥 관례로만 지켜지는 값이라(버그 8번에서 실제로 한 상품에 이 값이 중복될 뻔한 사고가 있었음) 데이터가 꼬이면 MyBatis `TooManyResultsException`으로 상세 페이지가 통째로 500이 날 수 있는 잠재 위험이었다. **✅ 조치 완료 (2026-09-03)** — `ROWNUM = 1` 추가(wish.xml의 대표이미지 서브쿼리와 동일한 방어 패턴).
34. ~~**검색 결과/찜 카드의 "리뷰 보기"(별점) 링크가 홈 카드와 달리 눌러도 이동하지 않음**~~ (2026-09-03 사용자 보고) — 홈/검색/찜 세 화면이 "같은 상품 카드"를 쓰는데, `searchProduct.jsp`와 `wish.js`(찜 목록 카드를 JS로 그림)의 별점 링크가 둘 다 `href="#"`(제자리 링크, 클릭해도 이동 없음)로 남아 있었다 — 홈(`home.jsp`)만 언젠가 `/mds/detail/{id}#review`로 고쳐졌고 나머지 두 곳은 그 수정이 안 따라간 것(버그 28번의 별점 CSS 스코프 누락과 같은 계열: "같은 카드인데 한쪽만 고쳐지고 나머지가 안 따라간" 패턴). **✅ 조치 완료 (2026-09-03)** — `searchProduct.jsp`와 `wish.js` 둘 다 홈과 동일한 `/mds/detail/{productId}#review` 링크로 교체. 실서버로 검색 결과 카드가 실제 상세 페이지 리뷰탭으로 연결되는 것 확인.
    - **같은 계열 전수 조사**: 사이트 전체의 `href="#"` 링크를 모두 훑었는데, 나머지는 전부 "대응 화면이 아직 없어서" 의도적으로 남겨둔 것들이었다(마이페이지/관리자의 문의사항·문의내역·공지사항, 이용약관·개인정보처리방침, SNS 아이콘 등 — 전부 JSP에 그 이유가 이미 주석으로 적혀 있고, `common/placeholderLinks.js`가 이런 자리들을 별도로 관리 중). 목적지가 이미 있는데 안 걸려 있던 건 이번 리뷰 링크가 유일했다.
    - **참고(버그는 아니고 기능 격차)**: 찜 카드는 홈/검색 카드에 있는 "이미지 호버 시 태그 뱃지 표시" 기능 자체가 없다 — `WishListDTO`/`wish.xml`이 태그 데이터를 아예 조회하지 않아서(마크업이 아니라 데이터 자체가 없음), 링크 하나 고치는 수준이 아니라 쿼리·DTO·JS를 다 손대야 하는 별도 작업이다. 필요하시면 별도로 진행하겠습니다.
35. ~~**장바구니/찜 화면의 체크박스(전체선택/개별선택)가 항상 노출돼 있음**~~ (2026-09-03 사용자 지시: 어드민 쿠폰 페이지와 동일한 로직으로 변경) — `admin/admincouponView.jsp`는 "삭제할 쿠폰 선택"을 눌러야만 체크박스가 나타나는데, `cart.jsp`/`wish.jsp`는 처음부터 체크박스+선택삭제 버튼이 항상 보였다. **✅ 조치 완료 (2026-09-03)** — 두 화면 다 admin과 같은 구조(`select-menu`+`list-control-actions`+토글 버튼)로 바꾸고, 체크박스는 `.selecting` 클래스가 있을 때만 CSS로 노출(`admincouponView.jsp`의 `#couponCardList.selecting .coupon-check`와 동일 패턴). 장바구니는 "전체 선택"이 곧 "주문하기 대상"이라 평소엔 전부 선택된 상태(체크박스만 숨김)로 유지해 결제 흐름은 그대로 동작하고, 찜은 삭제 전용이라 admin처럼 평소엔 전부 미선택.
36. ~~**장바구니/찜 화면에 페이지네이션이 없음**~~ (2026-09-03 사용자 지시로 확인) — 두 화면 다 서버가 내려준 전체 목록을 한 번에 다 그렸다(사이트 다른 목록 화면들은 전부 페이지네이션이 있음). **✅ 조치 완료 (2026-09-03)** — 이미 전체 목록을 한 번에 받아와 클라이언트에서 그리는 구조라, 서버 페이징 대신 검색 결과 화면과 같은 `.sp-pagination` 스타일을 재사용한 클라이언트 페이징을 추가(장바구니 10개/찜 12개씩). 페이지를 넘겨도 "전체 선택"/선택 삭제/합계 계산은 화면에 안 보이는 다른 페이지 항목까지 정확히 반영되도록 상태를 페이지 단위가 아니라 전체 목록 기준으로 계산하게 구조를 맞췄다.
37. ~~**장바구니 내 상품 개별 삭제 버튼이 실행되지 않음**~~ (2026-09-03 사용자 보고) — `cartService.js`의 `save()`가 빈 함수(주석 처리)였다. 삭제 버튼을 누르면 로컬 배열만 필터링하고 `render()`가 곧바로 `window.serverCartItems`(서버가 페이지 로드 시 내려준 원본, 안 바뀜)를 다시 읽어와 그 필터링 결과를 즉시 덮어써버려서, 화면이 잠깐 깜빡이기만 하고 상품이 그대로 남아있었다. **✅ 조치 완료 (2026-09-03)** — 실제 `GET /cart/remove-cart?popId=`(이미 있던, 로그인 가드까지 갖춘 정상 엔드포인트 — 호출하는 화면이 없었을 뿐)를 부르도록 교체. 같은 조사 중 **수량 +/- 버튼도 완전히 같은 원인으로 저장이 안 되고 있었던 것을 추가로 발견** — 애초에 수량 변경을 반영할 백엔드 자체가 없어서, `CartMapper`/`CartService`/`CartController`에 `updateQty`(`POST /cart/update-qty`)를 신설하고 연결. 개별 삭제·선택 삭제·수량 변경 전부 실서버(8798)에서 실제 DB 반영까지 확인, 테스트 데이터 정리 완료.
38. ~~**메인 페이지 등에서 퀵버튼으로 장바구니에 담았을 때 헤더 뱃지가 바로 반영되지 않음**~~ (2026-09-03 사용자 보고, 전 페이지 확인 요청) — `common/cartWishService.js`의 `addToCart()` 성공 처리에 헤더 뱃지 갱신 호출이 아예 없었다. `home.js`/`searchProduct.js`/`wish.js`의 장바구니 퀵버튼이 전부 이 함수 하나를 공유해서 세 화면 다 같은 증상이었다(상품 상세 페이지의 `#cart-button`은 폼 제출 후 전체 페이지 이동이라 이 버그 대상이 아님 - 이동한 페이지에서 헤더가 새로 그려지면서 자연히 정확한 값이 나옴). **✅ 조치 완료 (2026-09-03)** — `addToCart()` 성공 시 `window.refreshCartBadge()`(24번에서 이미 실제 서버 값을 쓰도록 고쳐둔 함수) 호출 추가. 함수가 한 곳이라 세 화면 모두 이 한 줄로 해결.
39. ~~**로그아웃 후 재로그인하면 이미 찜한 상품도 "찜 안 한 상태"로 보여 다시 찜을 누를 수 있음(모든 화면)**~~ (2026-09-03 사용자 보고) — 25번에서 찜 "추가"를 실제 서버에 반영하도록 고치면서 "새로고침하면 항상 찜 안 한 상태로 보이는" 제약을 남겨뒀었는데, 그 상태에서 클릭하면 `cartWishService.js`의 `toggleWish()`가 방향 판단을 **로컬 캐시(localStorage)** 로 했다는 게 실제 문제였다 — 로그아웃 후 재로그인(새 세션/다른 계정)하면 이 캐시가 비어서, 이미 찜한 상품도 "안 찜한 것"으로 오판해 다시 "추가"를 시도했다(데이터 자체는 `WishServiceImpl.insertWish`가 중복을 막아줘서 안 깨졌지만, 그다음 정말 해제하려는 클릭이 또 "추가" 방향으로 잘못 판단되는 등 화면-서버 상태가 계속 어긋났다). **✅ 조치 완료 (2026-09-03)** — 근본적으로 고쳤다: `product.xml`의 `getList`(홈/검색 공용)와 `detailPage.xml`의 `productDetail`에 로그인 회원 기준 `WISHED` 서브쿼리를 추가해서, 카드/상세 페이지가 **최초 렌더링 시점부터 실제 찜 여부로 하트를 채워서** 보여주도록(`ProductListDTO.wished`, `ProductDetailDTO.wished`) 바꿨다. `toggleWish()`도 로컬 캐시 대신 클릭한 버튼의 현재 `is-active`(=서버가 채워준 진짜 상태) 를 그대로 넘겨받아 방향을 판단하도록 교체(`home.js`/`searchProduct.js`/`productdetail.js` 전부). 실서버로 찜 → 홈/검색/상세 페이지 재방문 시 전부 하트가 채워진 채로 보이는 것, 해제 클릭 시 정확히 풀리는 것 확인.
40. ~~**결제 페이지에서 뒤로가기/취소 시 "양식을 다시 제출하시겠습니까?"(ERR_CACHE_MISS)가 뜸**~~ (2026-09-03 사용자 보고: 배송지 등록 후 취소하고 나오면 재현, 이번 세션 서버 작업 중 발생한 문제인지 확인 요청 — **아니었음**, 아래 설명) — `POST /order/payment`가 뷰를 직접 렌더링하고 있어서, 결제 화면 자체가 브라우저 히스토리에 "POST 응답"으로 남는 구조적 문제였다(Post-Redirect-Get 패턴 미적용). 배송지 추가 화면(버그 26번, `history.back()` 사용)이든 브라우저의 실제 뒤로가기 버튼이든, 이 POST 히스토리 항목으로 돌아오려고 하면 브라우저가 재제출 확인을 띄운다 - 오늘 만든 배송지 추가 "취소"뿐 아니라 이 화면에서 나갔다 돌아오는 모든 경로(뒤로가기 포함)에서 원래도 재현됐을 문제로, 이번 세션의 서버 재시작과는 무관. **✅ 조치 완료 (2026-09-03)** — `POST /order/payment`가 세션에 저장만 하고 `redirect:/order/payment`로 리다이렉트하도록 변경. 이미 있던 `GET /order/payment`(`paymentResume`, 헤더 결제 아이콘 복귀용으로 원래도 같은 세션 데이터를 읽어 같은 화면을 그려주던 핸들러)를 그대로 재사용해서 로직 중복 없이 히스토리 항목만 GET으로 바뀐다. 실서버로 POST가 302로 리다이렉트되고 이어지는 GET이 정상 렌더링되는 것 확인.
41. ~~**장바구니 퀵 아이콘으로 이미 담긴 상품을 다시 담아도 수량이 안 늘어남**~~ (2026-09-03 사용자 보고, 상세 페이지 경로도 같이 확인 요청) — `CartServiceImpl.insertCartInfo()`가 이미 장바구니에 있는 옵션(popId)이면 그냥 "이미 장바구니에 있는 상품입니다" 메시지만 돌려주고 끝났다 - 수량은 그대로였다. 퀵버튼(홈/검색/찜)과 상품 상세 페이지의 `#cart-button`이 전부 `POST /cart/add-cart` 하나를 공유해서, **두 경로 다 동일하게 재현됨**(사용자님이 요청하신 1-1번 확인 결과). **✅ 조치 완료 (2026-09-03)** — 이미 담겨 있으면 기존 수량에 새로 요청한 수량을 더하도록 변경(`CartMapper.incrementQty` 신설, `update cart set qty = qty + :deltaQty`). 실서버로 같은 옵션을 두 번 담아 수량이 1→2로 정확히 늘어나는 것 확인.
42. ~~**찜 목록에서 여러 상품을 선택해도 장바구니로 한 번에 담는 기능이 없음**~~ (2026-09-03 사용자 보고) — 35번에서 찜 화면에 admin 쿠폰 페이지 방식의 "선택 모드"를 만들면서 "선택 삭제"만 넣고 "선택 상품 장바구니 담기"는 빠져 있었다 - 카드 낱개 퀵버튼으로만 담을 수 있고, 체크박스로 여러 개를 골라도 할 수 있는 일이 삭제뿐이었다. **✅ 조치 완료 (2026-09-03)** — "선택 삭제" 옆에 "선택 상품 장바구니 담기" 버튼 추가, 카드 낱개 퀵버튼과 동일한 백엔드(`POST /cart/add-cart`, 대표 옵션 popId)를 선택된 항목 수만큼 한꺼번에 호출하고 결과를 요약해서 안내(`N개 담았습니다`, 옵션 정보 없는 상품은 제외 안내). `common/cartWishService.js`의 `addToCart()`에 `silent` 옵션을 추가해서 여러 건 호출 시 알림이 N번 뜨지 않고 요약 하나만 뜨도록 함.
43. ~~**결제 페이지 포인트 사용 안내 문구가 입력칸 옆에 중복되고 위치가 어색해 보임**~~ (2026-09-03 사용자 보고) — 실제 레이아웃 원인까지 확인: `#point`가 `display:flex` 한 줄이라 라벨/입력칸/안내문 6개가 전부 가로로 욱여넣어져 있었고, 그 위에 "1,000P 이상부터 사용 가능"이라는 같은 말을 정적 안내(`.point-guide`)와 동적 경고(`#point-warning`) 둘 다에서 하고 있어서 1만 입력해도 문구가 겹쳐 보였다. **✅ 조치 완료 (2026-09-03)** — 입력 행(`.point-input-row`)만 가로 정렬로 분리하고 안내문들은 그 아래 세로로 쌓이게 구조 변경, 정적 안내는 입력값과 무관한 규칙(0P 미사용 처리)만 남기고 "얼마 이상 입력하세요" 류는 입력칸 바로 아래 동적 경고 한 곳으로 합침(빨간색 강조).
44. ~~**결제 화면에서 `GET /order/checkout` 접근 시 405(Method Not Allowed) 원인 불명 오류 페이지**~~ (2026-09-03 사용자가 직접 재현·보고: 주문하기 도중 발생, `http://localhost:8797/order/checkout`) — `/order/checkout`은 원래 POST 전용이 맞다(주문 실행은 결제 버튼 클릭으로만 일어나야 하고, 새로고침/뒤로가기로 재실행되면 안 되므로 40번처럼 GET 매핑을 열어주는 건 답이 아님). 다만 새로고침이나 주소창 재입력 등으로 실수로 GET이 들어오면 지금까지는 스택트레이스가 그대로 노출되는 날것의 405 에러 페이지가 떴다. **✅ 조치 완료 (2026-09-03)** — `GET /order/checkout`을 결제 화면(`/order/payment`)으로 돌려보내는 전용 매핑 추가 - 세션에 진행 중인 결제가 남아있으면 `paymentResume`이 그대로 이어서 보여주고, 없으면 장바구니로 안내한다. 실서버로 GET 요청이 이제 405 대신 302로 정상 리다이렉트되는 것 확인.
45. ~~**결제 페이지가 좁아 상품명 등 긴 텍스트가 줄바꿈되며 라벨까지 같이 찌그러져 보임**~~ (2026-09-03 사용자 보고, "폭 조정 필요") — `.order-card`가 600px 고정폭인 데다, "상품명"/"상품 수량" 같은 라벨과 실제 값이 같은 flex 줄에서 둘 다 `flex-shrink:1`(기본값)이라 값이 길면(실제 상품명+옵션명은 40자를 넘기기도 함) 라벨까지 같이 찌그러져 "상품"/"명"처럼 글자 사이에서 줄바꿈되고 있었다. **✅ 조치 완료 (2026-09-03)** — `.order-card` 폭을 680px로 늘리고, 라벨 쪽엔 `flex-shrink:0`을 줘서 값 쪽만 줄바꿈되도록(우측 정렬) 분리.
46. ~~**결제 페이지 할인 정보(쿠폰/등급/포인트 할인 금액) 영역이 위 구분선에 바짝 붙어 여백 없이 보임**~~ (2026-09-03 사용자 보고, 스크린샷 첨부) — 각 섹션(`#ProductInfo`/`#Price`/`#point`/`#Coupon`/`#MembershipTier` 등)에 공통 padding+구분선을 주는 CSS 목록에 `#DiscountInfo`(쿠폰/등급/포인트 할인 금액 3줄을 담는 div)만 빠져 있어서 CSS가 아예 없었다 - 바로 위 "회원 등급 할인" 섹션의 구분선에 여백 없이 바로 붙어 보인 원인. **✅ 조치 완료 (2026-09-03)** — `#DiscountInfo`를 같은 공통 규칙에 추가.
47. ~~**상품 상세 페이지 리뷰 이미지가 깨진 채로 나옴**~~ (2026-09-03 사용자 보고, 스크린샷 첨부) — `detailPage.xml`의 `getReviewImages` 쿼리가 `REVIEW_ID`/파일명만 뽑고 `REVIEW_IMAGE_PATH`는 아예 안 뽑고 있었다 - `ReviewImagesDTO.reviewImagePath`가 항상 null이라 `<img src="${reviewImagePath}${reviewImage}">`가 파일명만 남아 상대경로로 깨졌다(마이페이지 "내가 쓴 리뷰"가 쓰는 `ReviewMapper.selectReviewImagesByReviewIds`는 처음부터 이 컬럼을 뽑고 있어서 그쪽은 정상). **✅ 조치 완료 (2026-09-03)** — 쿼리에 `REVIEW_IMAGE_PATH` 추가. 실서버로 실제 업로드된 리뷰 이미지(`/uploads/review/...`)가 200으로 로드되는 것 확인.
48. ~~**리뷰에 좋아요(하트) 인터랙션이 없음**~~ (2026-09-03 사용자 보고) — 좋아요 집계(`ReviewDTO.likeCount`/`liked`)와 백엔드(`GET /mds/review/like/{reviewId}`, 버그 1번에서 이미 세션 키 버그까지 고쳐진 정상 엔드포인트)는 전부 있었는데, 상품 상세 페이지의 리뷰 목록에 그걸 호출하는 버튼 자체가 없었다. **✅ 조치 완료 (2026-09-03)** — 각 리뷰에 좋아요 하트 버튼 추가(로그인 회원이 이미 누른 리뷰면 최초 렌더링부터 채워진 상태로 표시), 클릭 시 실제 엔드포인트를 호출해 좋아요 수/버튼 상태를 갱신하고 비로그인이면 로그인으로 안내한다. 실서버로 좋아요 토글 시 실제 `REVIEWLIKE` 테이블에 반영되고 새로고침해도 상태가 유지되는 것까지 확인, 테스트로 누른 좋아요 원상복구.

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
4. ~~**상품 목록/검색에 STATUS 필터가 없음**~~ **✅ 버그 4번과 동일 지점이라 그쪽 조치로 함께 해결됨 (2026-09-03)** — `product.xml`에 필터 추가.
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

### 이후 세션에서 추가로 발견된 것 (16~27)

16. **신규 발견 (2026-08-30, 유저 주문 배송 확인 기능 세션): `header.jsp:30`의 `data-logged-in="${not empty sessionScope.loginMemberId}"`가 항상 `false`로 나옴** — 프로젝트 전체에서 `loginMemberId`라는 세션 키가 저장되는 곳이 한 군데도 없음(실제 로그인 시 저장되는 키는 `SessionConst.LOGIN_SESSION`, 값은 `MemberDTO` 객체). 실제로 로그인한 상태로 `/member/orderDelivery`를 확인하던 중 응답 HTML에서 `data-logged-in="false"`로 찍히는 것을 발견함(세션 쿠키 정상 전달, 컨트롤러 레벨 로그인 체크는 별도로 정상 동작 — `header.jsp`의 이 표시만 항상 틀림).
    - **영향**: `static/js/views/header.js`가 이 값을 `isLoggedIn`으로 읽어서, 홈(`/`) 방문 시 "비회원이면 장바구니/찜 localStorage 초기화" 로직을 로그인 여부와 무관하게 항상 실행함 → **로그인한 회원이 홈 화면에 올 때마다 담아둔 장바구니/찜 데이터가 매번 조용히 삭제됨.** 장바구니/찜이 아직 localStorage 임시 구현(실제 DB 연동 전)이라 지금 당장 서버 데이터가 날아가는 건 아니지만, 사용자 입장에서는 "장바구니에 담았는데 홈에 갔다 오면 사라진다"로 체감되는 실질적 버그.
    - `common/header.jsp`/`static/js/views/header.js`는 이번 세션 범위(member 패키지의 order/delivery) 밖이라 수정하지 않음 — header/cartWish 담당자 확인 필요.
17. **신규 발견 + 부분 조치 (2026-08-30): 세션은 유효한데 실제 회원 행이 없어진 경우(탈퇴/관리자 삭제 등) 처리가 컨트롤러마다 들쭉날쭉함.** 로그인 후 세션은 서버 메모리에 그대로 남아있어서 `WebConfig.LoginInterceptor`(로그인 여부만 확인)는 통과되는데, 그 이후 회원 데이터를 다시 조회하는 지점에서 `null` 처리를 안 해두면 화면이 깨짐 — `MemberController.myPageForm()`에서 실제로 재현됨(회원 상세를 통째로 다시 조회해서 필드 전부가 빈 값으로 렌더링됨). ✅ `myPageForm()`은 조치 완료(`getMemberByMemberId()`가 null이면 `session.invalidate()` + 로그인 페이지로 리다이렉트, HANDOFF.md 3-30-18 참고). **`wishlistForm`/`cartForm`/`userOrderDeliveryForm`/`userCouponViewForm`은 회원 상세를 다시 조회하지 않고 memberId만 사용해서 목록 쿼리가 빈 결과를 반환할 뿐 이 정도로 눈에 띄게 깨지진 않지만, 근본적으로는 같은 종류의 gap이 남아있음** — 실제 탈퇴 기능이 생기면 (정책 항목 1번과 연결) 이 메서드들도 전부 같은 패턴으로 점검 필요.
18. **신규 발견 (2026-08-31, KGH_works→server_for_merge 병합 검토 세션): `/member/updateInfo`가 `WebConfig.LoginInterceptor` 보호 경로 목록에서 빠져있어 비로그인 접근 시 500(NPE)** — `addPathPatterns`에 `/member/myPage`,`/member/couponView`,`/member/wish`,`/member/cart`,`/member/orderDelivery`,`/order/**`는 있는데 KGH_works가 새로 추가한 `/member/updateInfo`(BE014, 멤버 정보 수정 기능)만 빠짐. 로그인 인터셉터를 그냥 통과해버려서 `MemberController.updateInfoForm()`이 세션 없이 `member.getRole()`을 호출 → `NullPointerException`이 그대로 500 스택트레이스로 노출됨(실제 병합 결과물 서버 기동 후 `curl`로 재현 확인). 같은 패턴이 `updateNickname`/`updatePhone`/`updateEmail`/`updateName`/`updateBirth`/`updateGender`/`updatePassword`(전부 `member.getMemberId()`를 null 체크 없이 호출) POST API에도 있음 — 정상 플로우에선 updateInfo 화면에서만 호출되니 괜찮지만 세션 만료 후 탭을 열어둔 채로 호출하면 동일하게 500. member 패키지 담당자(KGH) 확인 필요, 이번 세션 범위 밖이라 직접 수정하지 않음. 고치는 방법은 간단: `addPathPatterns`에 `"/member/updateInfo"` 추가(GET 페이지는 해결) + POST API들은 와일드카드 패턴 추가 또는 각 메서드에 null 체크 추가.
19. **신규 발견 + 조치 완료 (2026-08-31 저녁, 홈페이지 CSS 마무리 세션): `href="#"` placeholder 링크 + 전역 `a:visited` 규칙의 명시도 함정.** `default.css:22`에 `a:visited { color: #333; }`가 있는데(타입+가상클래스 조합이라 명시도 `(0,1,1)`), `href="#"`(현재 페이지 자기 자신을 가리킴)는 브라우저가 클릭 없이도 바로 `:visited`로 취급함 — 그래서 이런 링크의 글자색을 **순수 클래스 선택자 하나**(명시도 `(0,1,0)`)로만 입히면 `a:visited`한테 밀려서 의도한 색 대신 `#333`(거의 검정)으로 보임. 사용자님이 홈페이지에서 실제로 겪고 Chrome DevTools로 직접 원인 특정(취소선 규칙 확인). **조치 완료**: 홈페이지의 `.product-rating`(별점, 리뷰 링크화)과 `.section-more`("전체 상품 보기")는 각각 `#product-list .product-rating`/`#product .section-more`로 스코프해서 ID+클래스 조합(명시도 `(1,1,0)`)으로 `a:visited`를 이기게 수정함(HANDOFF.md 3-38-10 참고). **이 사이트에는 아직 실제 라우트가 없어 `href="#"`로 남겨둔 placeholder 링크가 많음(`TODO(placeholder route)` 주석들) — 다른 페이지 작업 때 이 링크들에 색을 입히면서 순수 클래스 선택자만 쓰면 같은 문제가 재발할 수 있으니, 항상 `a:visited`보다 명시도가 높은 선택자(ID 스코프 등)를 쓰거나 `:visited`를 명시적으로 함께 오버라이드할 것.**

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
