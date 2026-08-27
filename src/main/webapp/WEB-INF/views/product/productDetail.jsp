<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <!-- 상품 카테고리 -->
    <div id="product-category">결혼·집들이</div>

    <!-- 상품 이동 경로 -->
    <div id="breadcrumb">홈 &gt; 결혼·집들이 &gt; 코토나 타월 핸드타월 세트</div>

    <!-- 상품 이미지 + 상품 정보 -->
    <div id="product-area">

        <!-- 상품 이미지 -->
        <div id="product-images">
            <img id="product-main-image" src="/upload/product/${detail.product.thumbnail}" alt="${detail.product.productTitle}">

            <%-- 서브 이미지는 개수가 고정이 아니라 등록된 만큼 나와야 해서 forEach 로 처리 (0개~N개 전부 가능) --%>
            <div id="product-sub-images">
                <c:forEach items="${detail.product.image}" var="img">
                    <img class="product-sub-image" src="/upload/product/${img}" alt="상품 이미지">
                </c:forEach>
            </div>
        </div>

        <!-- 상품 상세 정보 -->
        <div id="product-info">

            <h1 class="product-title">코토나 타월 핸드타월 세트</h1>

            <div class="product-description">
                집들이 수건 선물 세트
            </div>

            <!-- 리뷰 / 찜 -->
            <%--
                 백엔드 확인 필요: ProductDetailDTO 에 아래 필드 추가돼야 함
                   - avgScore    (평균 평점, Double)
                   - reviewCount (리뷰 개수, Long)
                   - wishCount   (찜 개수, Long)
            --%>
            <div id="product-stats">
                <div class="product-stat">★ ${detail.product.avgScore}</div>
                <div class="product-stat">리뷰 ${detail.product.reviewCount}개</div>
                <div class="product-stat">♡ 찜 <span id="wish-count">${detail.product.wishCount}</span></div>
            </div>

            <!-- 가격 -->
            <%--
                 등급 할인은 로그인 시에만 노출.
                 data-discount-rate: 0.02 형태의 소수. 비로그인이면 0
                 TODO: 세션 연동 후 아래 두 줄을 EL 로 교체
                       data-discount-rate="${not empty sessionScope.loginMember ? discountRate : 0}"
                       <c:if test="${not empty sessionScope.loginMember and discountRate > 0}">
            --%>
            <div id="price-info" data-discount-rate="0.02">

                <%-- 로그인 + 등급 할인 있을 때만 노출되는 줄 --%>
                <div class="price-row">
                    <span class="price-label">정상가</span>
                    <span class="original-price" id="original-price">0원</span>
                </div>

                <div class="price-row">
                    <span class="price-label">
                        할인가
                        <span class="grade-badge">BRONZE</span>
                    </span>
                    <div>
                        <span class="discount-rate">2%</span>
                        <span class="sale-price" id="sale-price">0원</span>
                    </div>
                </div>

            </div>

            <!-- 상품 옵션 -->
            <div id="option-area">
                <label class="field-title" for="product-option">상품 옵션</label>
                <%--
                     value = POP_ID (장바구니 / 주문이 참조하는 값)
                     재고 표시 규칙: 50개 미만일 때만 "N개 남음", 0개면 "품절" + disabled

                     백엔드 확인 필요: OptionDTO 에 아래 필드 추가돼야 함
                       - popId (OPTIONDETAIL.POP_ID, Long) -- 지금은 optionId만 있음
                       - stock (PRODUCTOPTION.OPTION_STOCK, int) -- 지금은 없음
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
                 백엔드 확인 필요: 찜 버튼 클릭 시 등록/삭제 API 연동 필요 (지금은 productdetail.js 에서
                 버튼 색/찜 개수(#wish-count)를 클라이언트에서만 낙관적으로 +-1, 새로고침하면 원복됨)
                   - 로그인 + 이미 찜한 상품이면 최초 렌더링부터 wish-button 에 is-active 클래스 필요
                   - 클릭 시 찜 등록/삭제 API 호출 후 서버 응답으로 #wish-count 값 갱신
            --%>
            <div id="product-buttons">
                <button type="button" class="product-btn" id="wish-button" aria-label="찜하기">♡</button>
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
                <img class="tab-content-image" src="/upload/product/${img}" alt="상품 상세 이미지">
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
             단, detailPage.xml의 getReviewList 쿼리 자체에 조인 버그 있음 (r.OD_ID = od.OPTION_ID 비교, member의 전체
             주문/주문상세를 다 끌어옴) - 이건 리뷰탭 데이터 정확도에 영향을 주니 같이 확인 필요.
        --%>
        <div class="tab-panel" data-tab-panel="review">
            <c:if test="${empty reviewList}">
                <p class="tab-content-text">아직 작성된 리뷰가 없습니다.</p>
            </c:if>
            <c:forEach items="${reviewList}" var="review">
                <div class="review-item">
                    <div class="review-item-header">
                        <span class="review-writer">${review.nickname}</span>
                        <span class="review-score">★ ${review.score}</span>
                        <span class="review-date">${review.writeDate}</span>
                    </div>
                    <div class="review-images">
                        <c:forEach items="${review.reviewImages}" var="reviewImg">
                            <img class="review-image" src="${reviewImg.reviewImagePath}${reviewImg.reviewImage}" alt="리뷰 이미지">
                        </c:forEach>
                    </div>
                    <p class="review-text">${review.reviewText}</p>
                </div>
            </c:forEach>
        </div>
    </div>

<script src="/js/product/productdetail.js"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>