<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="product-detail-page">
<div class="product-detail-page-card">

    <%-- ✅ 조치 완료(2026-09-03): 카테고리/이동경로가 실제 상품과 무관하게 항상 "결혼·집들이 /
         코토나 타월 핸드타월 세트"로 고정돼 있었다(어느 상품을 봐도 똑같이 나옴) - 카테고리를
         전혀 조회하지 않던 detailPage 쿼리에 product.xml getList의 CAT_AGG와 같은 방식으로
         추가해서 실데이터로 교체. 카테고리가 없는 상품이면 빈 문자열로 보인다. --%>
    <!-- 상품 카테고리 -->
    <div id="product-category">${detail.product.categoryNames}</div>

    <!-- 상품 이동 경로 -->
    <div id="breadcrumb">홈 &gt; ${detail.product.categoryNames} &gt; ${detail.product.productTitle}</div>

    <!-- 상품 이미지 + 상품 정보 -->
    <div id="product-area">

        <!-- 상품 이미지 -->
        <div id="product-images">
            <img id="product-main-image" src="<c:url value='/uploads/product/'/>${detail.product.thumbnail}" alt="${detail.product.productTitle}">

            <%-- 서브 이미지는 개수가 고정이 아니라 등록된 만큼 나와야 해서 forEach 로 처리 (0개~N개 전부 가능) --%>
            <div id="product-sub-images">
                <c:forEach items="${detail.product.image}" var="img">
                    <img class="product-sub-image" src="<c:url value='/uploads/product/'/>${img}" alt="상품 이미지">
                </c:forEach>
            </div>
        </div>

        <!-- 상품 상세 정보 -->
        <div id="product-info">

            <h1 class="product-title">${detail.product.productTitle}</h1>

            <%-- ✅ 조치 완료(2026-09-03): "집들이 수건 선물 세트"가 모든 상품에 고정으로 박혀
                 있었다 - productDetail 쿼리가 이미 조회해서 DTO에 담고 있던 productName(짧은
                 부제 성격 필드)이 화면 어디에도 안 쓰이고 있었을 뿐이라 그걸로 교체. --%>
            <div class="product-description">
                ${detail.product.productName}
            </div>

            <!-- 리뷰 / 찜 -->
            <div id="product-stats">
                <%-- 별/하트는 원래 유니코드 글리프(★/♡)였으나 환경에 따라 컬러 이모지로
                     렌더링돼 CSS color를 무시하는 문제가 있어 SVG로 통일함(2026-09-01). --%>
                <div class="product-stat">
                    <svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
                    ${detail.product.avgScore}
                </div>
                <div class="product-stat">리뷰 ${detail.product.reviewCount}개</div>
                <div class="product-stat">
                    <svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
                    찜 <span id="wish-count">${detail.product.wishCount}</span>
                </div>
            </div>

            <!-- 가격 -->
            <%-- ✅ 조치 완료(2026-09-03): 등급 할인이 로그인 여부/실제 등급과 무관하게 항상
                 "BRONZE / 2%"로 고정돼 있었다(예: PLATINUM 15% 회원이 봐도 2%로 표시, 비로그인도
                 노출됨). ProductController가 세션 회원의 실제 GRADE.DISCOUNT_RATE를 memberGrade로
                 담아주도록 수정 - 비로그인이면 memberGrade 자체가 모델에 없어서(EL이 empty로 처리)
                 할인 줄이 안 보이고 data-discount-rate도 0으로 떨어져 productdetail.js의
                 applyDiscount()가 자연히 할인 없이 계산한다. --%>
            <div id="price-info" data-discount-rate="${not empty memberGrade ? memberGrade.discountRate : 0}">

                <div class="price-row">
                    <span class="price-label">정상가</span>
                    <span class="original-price" id="original-price">0원</span>
                </div>

                <c:if test="${not empty memberGrade and memberGrade.discountRate > 0}">
                <div class="price-row">
                    <span class="price-label">
                        할인가
                        <span class="grade-badge">${memberGrade.gradeName}</span>
                    </span>
                    <div>
                        <span class="discount-rate"><fmt:formatNumber value="${memberGrade.discountRate * 100}" maxFractionDigits="0"/>%</span>
                        <span class="sale-price" id="sale-price">0원</span>
                    </div>
                </div>
                </c:if>

            </div>

            <!-- 상품 옵션 -->
            <div id="option-area">
                <label class="field-title" for="product-option">상품 옵션</label>
                <%--
                     value = POP_ID (장바구니 / 주문이 참조하는 값)
                     재고 표시 규칙: 50개 미만일 때만 "N개 남음", 0개면 "품절" + disabled
                --%>
                <select id="product-option">
                    <c:forEach items="${detail.option}" var="opt" varStatus="status">
                        <option value="${opt.popId}"
                                data-price="${opt.price}"
                                data-stock="${opt.stock}"
                                <c:if test="${status.first}">selected</c:if>
                                <c:if test="${opt.stock == 0}">disabled</c:if>>
                            ${opt.optionName} (${opt.price}원<c:if test="${opt.stock == 0}"> / 품절</c:if><c:if test="${opt.stock > 0 and opt.stock < 50}"> / ${opt.stock}개 남음</c:if>)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <!-- 상품 수량 -->
            <div id="quantity-area">
                <label class="field-title" for="product-quantity">상품 수량</label>
                <%-- max 는 선택된 옵션의 재고로 JS 에서 설정 --%>
                <input type="number" id="product-quantity" value="1" min="1" step="1">
            </div>

            <!-- 배송 안내 -->
            <div id="delivery-info">
                <strong>배송 안내</strong>
                <br>주문 후 2~3일 이내 배송됩니다.
                <br>제주 및 도서산간 지역은 추가 배송비가 발생할 수 있습니다.
            </div>

            <!-- 총 상품 금액 -->
            <div id="total-price">
                <span class="total-label">총 상품 금액</span>
                <strong id="total-product-price">0원</strong>
            </div>

            <!-- 상품 버튼 -->
            <%--
                 ✅ 조치 완료(2026-09-03): 클릭 시 common/cartWishService.js의 window.toggleWish()가
                 실제 WishController(POST /wish/insert-wish, GET /wish/remove-wish)를 호출한다
                 (비로그인이면 /member/login으로 리다이렉트, cart-button과 동일 패턴).
                 로그인 + 이미 찜한 상품이면 최초 렌더링부터 is-active를 붙인다(detail.product.wished,
                 detailPage.xml의 WISHED 서브쿼리) - 예전엔 항상 "찜 안 한" 상태로 시작해서, 로그아웃 후
                 재로그인하면 이미 찜한 상품도 다시 찜할 수 있는 것처럼 보였다(AUDIT 신규 버그).
            --%>
            <div id="product-buttons">
                <%-- 하트는 SVG 한 개만 두고, 찜 on/off는 views/productdetail.js가
                     .is-filled 클래스로 채움 여부만 바꾼다(글리프 교체 방식에서 변경). --%>
                <button type="button" class="product-btn${detail.product.wished ? ' is-active' : ''}" id="wish-button" aria-label="${detail.product.wished ? '찜 해제' : '찜하기'}" data-product-id="${detail.product.productId}">
                    <svg class="icon-heart${detail.product.wished ? ' is-filled' : ''}" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
                </button>
                <button type="button" class="product-btn" id="cart-button">장바구니</button>
                <button type="button" class="product-btn" id="buy-button">바로 구매</button>
            </div>

        </div>
    </div>

    <!-- 상품 상세 탭 -->
    <div id="product-detail-tabs">
        <div class="tab-menu" role="tablist">
            <button type="button" class="tab-menu-item is-active" data-tab-target="info" role="tab" aria-selected="true">상품 상세</button>
            <button type="button" class="tab-menu-item" data-tab-target="delivery" role="tab" aria-selected="false">배송안내</button>
            <button type="button" class="tab-menu-item" data-tab-target="refund" role="tab" aria-selected="false">교환/환불안내</button>
            <button type="button" class="tab-menu-item" data-tab-target="review" role="tab" aria-selected="false">리뷰</button>
        </div>

        <%-- 상품 상세: 등록 시 입력한 content 텍스트 먼저, 그 다음 상세 이미지(PRODUCT_TITLE_IMAGE = 2) 출력 --%>
        <div class="tab-panel is-active" data-tab-panel="info">
            <p class="tab-content-text">${detail.product.productContent}</p>
            <c:forEach items="${detail.product.detailContents}" var="img">
                <img class="tab-content-image" src="<c:url value='/uploads/product/'/>${img}" alt="상품 상세 이미지">
            </c:forEach>
        </div>

        <div class="tab-panel" data-tab-panel="delivery">
            <p class="tab-content-text">주문 후 2~3일 이내 배송됩니다.</p>
            <p class="tab-content-text">제주 및 도서산간 지역은 추가 배송비가 발생할 수 있습니다.</p>
            <p class="tab-content-text">배송 조회는 마이페이지 &gt; 주문내역에서 확인하실 수 있습니다.</p>
        </div>

        <div class="tab-panel" data-tab-panel="refund">
            <p class="tab-content-text">단순 변심으로 인한 교환/환불은 상품 수령 후 7일 이내 신청 가능합니다.</p>
            <p class="tab-content-text">상품 하자 또는 오배송의 경우 수령 후 30일 이내 무료로 교환/환불이 가능합니다.</p>
            <p class="tab-content-text">고객 부주의로 인한 상품 훼손 시 교환/환불이 제한될 수 있습니다.</p>
        </div>

        <%--
             백엔드 확인 필요: detailPage() 컨트롤러에서 이미 있는 ProductServiceImpl.getReviewList(productId, memberId)를
             한 번 더 호출해서 model.addAttribute("reviewList", ...) 로 얹어주면 됨 (DetailPageDTO에 새 필드 추가할 필요 없음,
             /mds/review/{productId} 에서 이미 하는 것과 동일한 패턴).
        --%>
        <div class="tab-panel" data-tab-panel="review">
            <c:if test="${empty reviewList}">
                <p class="tab-content-text">아직 작성된 리뷰가 없습니다.</p>
            </c:if>
            <c:forEach items="${reviewList}" var="review">
                <div class="review-item">
                    <div class="review-item-header">
                        <span class="review-writer">${review.nickname}</span>
                        <span class="review-score">
                            <svg class="icon-star icon-inline" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
                            ${review.score}
                        </span>
                        <span class="review-date">${review.writeDate}</span>
                        <%-- ✅ 조치 완료(2026-09-03, 사용자 보고): 리뷰 좋아요 버튼이 화면에 아예
                             없었다 - 백엔드(ProductController.reviewLike, GET /mds/review/like/{id})와
                             집계(ReviewDTO.likeCount/liked)는 이미 있었는데 호출하는 UI가 없었다.
                             비로그인이면 클릭 시 로그인으로 안내(productdetail.js). --%>
                        <button type="button" class="review-like-btn${review.liked ? ' is-active' : ''}"
                                data-review-id="${review.reviewId}"
                                aria-label="${review.liked ? '좋아요 취소' : '좋아요'}">
                            <svg class="icon-heart-small" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
                            <span class="review-like-count">${review.likeCount}</span>
                        </button>
                    </div>
                    <div class="review-images">
                        <%-- ✅ 조치 완료(2026-09-03, 사용자 보고): reviewImagePath가 서버에서 비어
                             내려와 상대경로로 깨졌었다 - detailPage.xml의 getReviewImages 쿼리 수정 --%>
                        <c:forEach items="${review.reviewImages}" var="reviewImg">
                            <img class="review-image" src="${reviewImg.reviewImagePath}${reviewImg.reviewImage}" alt="리뷰 이미지">
                        </c:forEach>
                    </div>
                    <p class="review-text">${review.reviewText}</p>
                </div>
            </c:forEach>

            <%-- 리뷰 페이지 번호. 한 페이지 5개(ProductServiceImpl.REVIEWS_PAGE_SIZE)라 리뷰가 많으면
                 여기서 넘겨본다. 검색 결과 화면과 같은 .sp-pagination 스타일을 그대로 재사용한다.
                 #review 해시는 페이지를 넘겨도 리뷰 탭이 열린 채로 돌아오게 하려는 것(productdetail.js가 처리). --%>
            <c:if test="${totalPages > 1}">
                <nav class="sp-pagination" aria-label="리뷰 페이지 탐색">
                    <c:if test="${currentPage > 1}">
                        <a class="sp-btn-prev" href="<c:url value='/mds/review/${productId}'/>?page=${currentPage - 1}#review">이전</a>
                    </c:if>
                    <ol>
                        <c:forEach begin="${pageWindowStart}" end="${pageWindowEnd}" var="p">
                            <li>
                                <a class="sp-page-btn ${p == currentPage ? 'is-current' : ''}"
                                   <c:if test="${p == currentPage}">aria-current="page"</c:if>
                                   href="<c:url value='/mds/review/${productId}'/>?page=${p}#review">${p}</a>
                            </li>
                        </c:forEach>
                    </ol>
                    <c:if test="${currentPage < totalPages}">
                        <a class="sp-btn-next" href="<c:url value='/mds/review/${productId}'/>?page=${currentPage + 1}#review">다음</a>
                    </c:if>
                </nav>
            </c:if>
        </div>
    </div>

</div>
</div>

<script src="<c:url value='/js/views/productdetail.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>