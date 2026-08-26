<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <!-- 상품 카테고리 -->
    <div id="product-category">결혼·집들이</div>

    <!-- 상품 이동 경로 -->
    <div id="breadcrumb">홈 &gt; 결혼·집들이 &gt; 코토나 타월 핸드타월 세트</div>

    <!-- 상품 이미지 + 상품 정보 -->
    <div id="product-area">

        <!-- 상품 이미지 -->
        <div id="product-images">
            <%-- TODO: 대표 이미지로 교체 --%>
            <div id="product-main-image">상품 메인 이미지</div>

            <%-- TODO: 서브 이미지 목록으로 교체 --%>
            <div id="product-sub-images">
                <div class="product-sub-image">이미지 1</div>
                <div class="product-sub-image">이미지 2</div>
                <div class="product-sub-image">이미지 3</div>
                <div class="product-sub-image">이미지 4</div>
            </div>
        </div>

        <!-- 상품 상세 정보 -->
        <div id="product-info">

            <h1 class="product-title">코토나 타월 핸드타월 세트</h1>

            <div class="product-description">
                집들이 수건 선물 세트
            </div>

            <!-- 리뷰 / 찜 -->
            <%-- TODO: 실제 통계값으로 교체 --%>
            <div id="product-stats">
                <div class="product-stat">★ 4.9</div>
                <div class="product-stat">리뷰 128개</div>
                <div class="product-stat">♡ 찜 56</div>
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
                --%>
                <select id="product-option">
                    <option value="1" data-price="35800" data-stock="100" selected>코지&amp;펠트바구니 (35,800원)</option>
                    <option value="2" data-price="35800" data-stock="48">비하인드&amp;펠트바구니 (35,800원 / 48개 남음)</option>
                    <option value="3" data-price="35800" data-stock="3">마일드&amp;펠트바구니 (35,800원 / 3개 남음)</option>
                    <option value="4" data-price="35800" data-stock="0" disabled>에버블루&amp;펠트바구니 (35,800원 / 품절)</option>
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
                <button type="button" class="product-btn" id="wish-button" aria-label="찜하기">♡</button>
                <button type="button" class="product-btn" id="cart-button">장바구니</button>
                <button type="button" class="product-btn" id="buy-button">바로 구매</button>
            </div>

        </div>
    </div>

<script src="/js/product/productdetail.js"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>