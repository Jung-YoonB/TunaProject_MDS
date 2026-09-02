<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="order-page">
<div class="order-card">

    <!-- 결제하기 제목 -->
    <div id="title">
        결제하기
    </div>


    <!-- 결제 처리 -->
    <form id="checkoutForm"
          action="${pageContext.request.contextPath}/order/checkout"
          method="post">


        <!-- =====================================================
             주문 상품 정보
        ====================================================== -->

        <div id="ProductInfo">

            <h2>주문 상품정보</h2>

            <c:forEach var="item" items="${pvData.itemList}" varStatus="status">

                <div class="product-item">

                    <div class="product-name">

                        <span>상품명</span>

                        <span>
                            ${item.productName}
                            <c:if test="${not empty item.optionName}">
                                (${item.optionName})
                            </c:if>
                        </span>

                    </div>

                    <div class="product-quantity">

                        <span>상품 수량</span>

                        <span>
                            ${item.qty}
                        </span>

                    </div>

                </div>


                <!-- 주문할 상품 정보 -->
                <input type="hidden"
                       name="itemList[${status.index}].popId"
                       value="${item.popId}">

                <input type="hidden"
                       name="itemList[${status.index}].qty"
                       value="${item.qty}">

            </c:forEach>

        </div>


        <!-- =====================================================
             장바구니 ID
             장바구니 결제일 때만 전달
        ====================================================== -->

        <c:forEach var="cartId" items="${pvData.cartIds}">
            <input type="hidden"
                   name="cartIds"
                   value="${cartId}">
        </c:forEach>


        <!-- =====================================================
             상품 금액
        ====================================================== -->

        <div id="Price">

            <div class="price-item">

                <span>상품 금액</span>

                <span id="total_price">
                    ${pvData.totalPrice}원
                </span>

            </div>

            <div class="price-item">

                <span>배송비</span>

				<span id="delivery_price">
				       ${pvData.deliveryFee}원
				</span>

            </div>
			
			<input type="hidden"
			       id="deliveryFee"
			       name="deliveryFee"
			       value="0">

        </div>


        <!-- =====================================================
             포인트 사용
        ====================================================== -->

        <div id="point">

            <label for="used_point">
                포인트 사용
            </label>

            <input
                type="number"
                id="used_point"
                name="usedPoint"
                value="0"
                min="0"
                max="${pvData.point}">

            <span>
                포인트
            </span>

            <p>
                보유 포인트 : ${pvData.point}P
            </p>

        </div>


        <!-- =====================================================
             쿠폰 사용
        ====================================================== -->

        <div id="Coupon">

            <label for="coupon_id">
                쿠폰 사용
            </label>

            <select id="coupon_id"
                    name="chistId">

                <option value="">
                    쿠폰을 선택해주세요
                </option>

                <c:forEach var="coupon" items="${pvData.couponList}">

				<option value="${coupon.chistId}"
				        data-discount="${coupon.couponValue}">
				    ${coupon.couponName}
				    -
				    ${(coupon.couponValue * 100).intValue()}%
				</option>

                </c:forEach>

            </select>

        </div>


        <!-- =====================================================
             회원 등급 할인
        ====================================================== -->

        <div id="MembershipTier">

            <span>
                회원 등급 할인
            </span>

            <span id="grade_discount">

                ${pvData.gradeName}

                -
                ${(pvData.discountRate * 100).intValue()}%

            </span>

        </div>


        <!-- =====================================================
             최종 결제 금액
        ====================================================== -->

        <div id="TotalPayment">

            <span>
                총 결제금액
            </span>

            <strong id="final_price">
                ${pvData.totalPrice}원
            </strong>

        </div>

        <!-- JS에서 계산한 최종 결제 금액 -->
        <input type="hidden"
               id="clientPaidAmount"
               name="clientPaidAmount"
               value="${pvData.totalPrice}">


        <!-- =====================================================
             배송지 정보
        ====================================================== -->

        <div id="DeliveryAddress">

            <h2>
                배송지 정보
            </h2>

            <div class="address-item">

                <!-- 배송지 이름 -->

                <div class="address-name">

                    <span>
                        배송지 이름
                    </span>

                    <span id="address_name">
                        ${pvData.addressName}
                    </span>

                </div>


                <!-- 배송지 주소 -->

                <div class="address-detail">

                    <span>
                        배송지 주소
                    </span>

                    <span id="detail_address">
                        ${pvData.detailAddress}
                    </span>

                </div>


                <!-- 기본 배송지 -->

                <span id="is_default">
                    기본 배송지
                </span>

            </div>


            <!-- checkout으로 실제 배송지 전달 -->

            <input type="hidden"
                   name="addressNameFix"
                   value="${pvData.addressName}">

            <input type="hidden"
                   name="detailAddressFix"
                   value="${pvData.detailAddress}">


            <!-- 배송지 추가 -->

            <button
                type="button"
                id="add-address">

                + 배송지 추가

            </button>

        </div>


        <!-- =====================================================
             결제 수단
        ====================================================== -->

        <div id="PaymentMethod">

            <h2>
                결제수단 선택
            </h2>

            <div class="payment-method">


                <!-- KAKAOPAY = 1 -->

                <input
                    type="radio"
                    id="kakao_pay"
                    name="paymentId"
                    value="1">

                <label for="kakao_pay">
                    카카오페이
                </label>


                <!-- NAVERPAY = 2 -->

                <input
                    type="radio"
                    id="naver_pay"
                    name="paymentId"
                    value="2">

                <label for="naver_pay">
                    네이버페이
                </label>


                <!-- MASTERCARD = 3 -->

                <input
                    type="radio"
                    id="mastercard"
                    name="paymentId"
                    value="3">

                <label for="mastercard">
                    마스터카드
                </label>

            </div>

        </div>


        <!-- =====================================================
             결제 동의
        ====================================================== -->

        <div id="Checkbox">

            <div>

                <input
                    type="checkbox"
                    id="payment_agree">

                <label for="payment_agree">
                    결제에 동의합니다.
                </label>

            </div>


            <div>

                <input
                    type="checkbox"
                    id="privacy_agree">

                <label for="privacy_agree">
                    개인정보 수집 및 이용에 동의합니다.
                </label>

            </div>


            <!-- 이용약관 -->

            <div id="Terms">

                <a href="#">
                    이용약관
                </a>

            </div>


            <!-- 개인정보처리방침 -->

            <div id="PrivacyPolicy">

                <a href="#">
                    개인정보처리방침
                </a>

            </div>

        </div>


        <!-- =====================================================
             결제 버튼
        ====================================================== -->

        <div id="Confirm">

            <button
                type="submit"
                id="payment-submit">

                최종 결제

            </button>

            <button
                type="button"
                onclick="history.back()">

                결제 취소

            </button>

        </div>

    </form>

</div>
</div>

<script>
const productTotalPrice =
    Number("${pvData.totalPrice}") || 0;

const memberPoint =
    Number("${pvData.point}") || 0;

const gradeDiscountRate =
    Number("${pvData.discountRate}") || 0;

const deliveryFee =
    Number("${pvData.deliveryFee}") || 0;
</script>

<script src="<c:url value='/js/views/payment.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
