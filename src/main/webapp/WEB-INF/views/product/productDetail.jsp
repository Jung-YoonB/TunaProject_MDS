<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="product-detail-page">
<div class="product-detail-page-card">

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

            <%-- 이 상품 전용이 아니라 매장 전체 쿠폰 버튼(COUPON 테이블에 PRODUCT_ID가 없다) -
                 구매 버튼 줄과 분리해 뒀고, 누르면 모달에서 "모두 받기"로 발급한다. --%>
            <button type="button" id="coupon-issue-banner">쿠폰 받기</button>
        </div>

        <!-- 상품 상세 정보 -->
        <div id="product-info">

            <h1 class="product-title">${detail.product.productTitle}</h1>

            <div class="product-description">
                ${detail.product.productName}
            </div>

            <!-- 리뷰 / 찜 -->
            <div id="product-stats">
                <%-- 별/하트는 유니코드 글리프를 쓰면 환경에 따라 컬러 이모지로 렌더링돼
                     CSS color를 무시한다. 그래서 아이콘은 전부 SVG. --%>
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
            <%-- 비로그인이면 memberGrade가 모델에 없어 할인 줄이 숨겨지고,
                 data-discount-rate도 0이 되어 productdetail.js가 할인 없이 계산한다. --%>
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
                            <c:out value="${opt.optionName}"/> (${opt.price}원<c:if test="${opt.stock == 0}"> / 품절</c:if><c:if test="${opt.stock > 0 and opt.stock < 50}"> / ${opt.stock}개 남음</c:if>)
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

        <div class="tab-panel" data-tab-panel="review">
            <c:if test="${empty reviewList}">
                <p class="tab-content-text">아직 작성된 리뷰가 없습니다.</p>
            </c:if>
            <c:forEach items="${reviewList}" var="review">
                <div class="review-item">
                    <div class="review-item-header">
                        <%-- 사용자가 직접 쓴 값은 반드시 <c:out>으로 이스케이프한다.
                             특히 아래 review-text는 자유 입력이라 그대로 찍으면 저장형 XSS가 된다. --%>
                        <span class="review-writer"><c:out value="${review.nickname}"/></span>
                        <span class="review-score">
                            <svg class="icon-star icon-inline" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
                            ${review.score}
                        </span>
                        <span class="review-date">${review.writeDate}</span>
                        <button type="button" class="review-like-btn${review.liked ? ' is-active' : ''}"
                                data-review-id="${review.reviewId}"
                                aria-label="${review.liked ? '좋아요 취소' : '좋아요'}">
                            <svg class="icon-heart-small" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
                            <span class="review-like-count">${review.likeCount}</span>
                        </button>
                    </div>
                    <div class="review-images">
                        <c:forEach items="${review.reviewImages}" var="reviewImg">
                            <img class="review-image" src="${reviewImg.reviewImagePath}${reviewImg.reviewImage}" alt="리뷰 이미지">
                        </c:forEach>
                    </div>
                    <p class="review-text"><c:out value="${review.reviewText}"/></p>
                </div>
            </c:forEach>

            <%-- 한 페이지 5개(ProductServiceImpl.REVIEWS_PAGE_SIZE).
                 #review 해시는 페이지를 넘겨도 리뷰 탭이 열린 채로 돌아오게 한다. --%>
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

    <%-- "쿠폰 받기" 모달 - 목록은 서버가 채우지 않고 버튼 클릭 시 JS가 GET /mds/coupon/issuable로
         받아온다(페이지 로드 시점과 클릭 시점 사이에 이미 다른 상품 상세에서 받아갔을 수 있어서). --%>
    <div id="coupon-modal" class="coupon-modal-overlay" hidden>
        <div class="coupon-modal-box" role="dialog" aria-modal="true" aria-labelledby="coupon-modal-title">
            <button type="button" class="modal-close" id="coupon-modal-close" aria-label="닫기">×</button>
            <h2 id="coupon-modal-title">지금 받을 수 있는 쿠폰</h2>
            <ul id="coupon-modal-list" class="coupon-modal-list"></ul>
            <p id="coupon-modal-empty" class="coupon-modal-empty" hidden>지금 받을 수 있는 쿠폰이 없습니다.</p>
            <div class="modal-actions">
                <button type="button" id="coupon-modal-cancel">닫기</button>
                <button type="button" id="coupon-modal-claim-all">모두 받기</button>
            </div>
        </div>
    </div>

</div>
</div>

<script src="<c:url value='/js/views/productdetail.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
