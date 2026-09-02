<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="order-page">
<div class="order-card">

    <!-- 결제하기 제목 -->
    <div id="title">
        결제하기
    </div>


    <!-- 주문 상품 정보 -->
    <div id="ProductInfo">

        <h2>주문 상품정보</h2>

        <c:forEach var="item"
                   items="${pvData.itemList}"
                   varStatus="status">

            <div class="product-item">

                <div class="product-name">

                    <span>상품명</span>

                    <span id="product_name">
                        ${item.productName}

                        <c:if test="${not empty item.optionName}">
                            (${item.optionName})
                        </c:if>
                    </span>

                </div>

                <div class="product-quantity">

                    <span>상품 수량</span>

                    <span id="qty">
                        ${item.qty}
                    </span>

                </div>

                <div class="product-price">

                    <span>상품 금액</span>

                    <span>
                        <fmt:formatNumber
                            value="${item.optionPrice * item.qty}"
                            type="number"/>원
                    </span>

                </div>

            </div>

        </c:forEach>

    </div>


    <!-- 상품 금액 -->
    <div id="Price">

        <div class="price-item">

            <span>상품 금액</span>

            <span id="total_price">
                <fmt:formatNumber
                    value="${pvData.totalPrice}"
                    type="number"/>원
            </span>

        </div>

        <div class="price-item">

            <span>배송비</span>

            <span id="delivery_price">
                0원
            </span>

        </div>

    </div>


    <!-- 결제 정보 -->
    <form id="checkoutForm"
          action="${pageContext.request.contextPath}/order/checkout"
          method="post">


        <!-- =====================================================
             구매 상품 정보
             ===================================================== -->

        <c:forEach var="item"
                   items="${pvData.itemList}"
                   varStatus="status">

            <input type="hidden"
                   name="itemList[${status.index}].popId"
                   value="${item.popId}">

            <input type="hidden"
                   name="itemList[${status.index}].qty"
                   value="${item.qty}">

        </c:forEach>


        <!-- =====================================================
             장바구니 ID
             장바구니에서 결제한 경우에만 존재
             결제 완료 후 장바구니 삭제에 사용
             ===================================================== -->

        <c:forEach var="cartId" items="${pvData.cartIds}">

            <input type="hidden"
                   name="cartIds"
                   value="${cartId}">

        </c:forEach>


        <!-- =====================================================
             포인트 사용
             ===================================================== -->

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
                보유 포인트 :
                <strong>
                    <fmt:formatNumber
                        value="${pvData.point}"
                        type="number"/>P
                </strong>
            </p>

            <p id="point-message"></p>

        </div>


        <!-- =====================================================
             쿠폰 사용
             ===================================================== -->

        <div id="Coupon">

            <label for="coupon_id">
                쿠폰 사용
            </label>

            <select id="coupon_id"
                    name="chistId">

                <option value=""
                        data-discount="0">
                    쿠폰을 선택해주세요
                </option>

                <c:forEach var="coupon"
                           items="${pvData.couponList}">

                    <option
                        value="${coupon.chistId}"
                        data-discount="${coupon.couponValue}">

                        ${coupon.couponName}
                        -
                        ${coupon.couponValue * 100}%

                    </option>

                </c:forEach>

            </select>

        </div>


        <!-- =====================================================
             회원 등급 할인
             ===================================================== -->

        <div id="MembershipTier">

            <span>
                회원 등급 할인
            </span>

            <span id="grade_discount">

                ${pvData.gradeName}

                -

                ${pvData.discountRate * 100}%

            </span>

        </div>


        <!-- =====================================================
             할인 금액 표시
             ===================================================== -->

        <div id="Discount">

            <div class="price-item">

                <span>쿠폰 할인</span>

                <span id="coupon_discount">
                    0원
                </span>

            </div>

            <div class="price-item">

                <span>등급 할인</span>

                <span id="grade_discount_amount">
                    0원
                </span>

            </div>

            <div class="price-item">

                <span>포인트 사용</span>

                <span id="point_discount">
                    0원
                </span>

            </div>

        </div>


        <!-- =====================================================
             최종 결제 금액
             ===================================================== -->

        <div id="TotalPayment">

            <span>
                총 결제금액
            </span>

            <strong id="final_price">
                <fmt:formatNumber
                    value="${pvData.totalPrice}"
                    type="number"/>원
            </strong>

        </div>


        <!-- 서버에 실제 결제금액 전달 -->
        <input type="hidden"
               id="clientPaidAmount"
               name="clientPaidAmount"
               value="${pvData.totalPrice}">


        <!-- =====================================================
             배송지 정보
             ===================================================== -->

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

                        <c:choose>

                            <c:when test="${not empty pvData.addressName}">
                                ${pvData.addressName}
                            </c:when>

                            <c:otherwise>
                                기본 배송지가 없습니다.
                            </c:otherwise>

                        </c:choose>

                    </span>

                </div>


                <!-- 배송지 주소 -->
                <div class="address-detail">

                    <span>
                        배송지 주소
                    </span>

                    <span id="detail_address">

                        <c:choose>

                            <c:when test="${not empty pvData.detailAddress}">
                                ${pvData.detailAddress}
                            </c:when>

                            <c:otherwise>
                                기본 배송지가 없습니다.
                            </c:otherwise>

                        </c:choose>

                    </span>

                </div>


                <!-- 기본 배송지 -->
                <span id="is_default">
                    기본 배송지
                </span>

            </div>


            <!-- 실제 주문에 사용할 배송지 -->
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
             ===================================================== -->

        <div id="PaymentMethod">

            <h2>
                결제수단 선택
            </h2>

            <div class="payment-method">

                <!-- 1 : KAKAOPAY -->
                <input
                    type="radio"
                    id="kakao_pay"
                    name="paymentId"
                    value="1">

                <label for="kakao_pay">
                    카카오페이
                </label>


                <!-- 2 : NAVERPAY -->
                <input
                    type="radio"
                    id="naver_pay"
                    name="paymentId"
                    value="2">

                <label for="naver_pay">
                    네이버페이
                </label>


                <!-- 3 : MASTERCARD -->
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
             ===================================================== -->

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
             ===================================================== -->

        <div id="Confirm">

            <button
                type="submit"
                id="submitPayment">

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

document.addEventListener("DOMContentLoaded", function () {

    const form =
        document.querySelector("#checkoutForm");

    const usedPointInput =
        document.querySelector("#used_point");

    const couponSelect =
        document.querySelector("#coupon_id");

    const finalPrice =
        document.querySelector("#final_price");

    const clientPaidAmount =
        document.querySelector("#clientPaidAmount");

    const couponDiscount =
        document.querySelector("#coupon_discount");

    const gradeDiscountAmount =
        document.querySelector("#grade_discount_amount");

    const pointDiscount =
        document.querySelector("#point_discount");

    const pointMessage =
        document.querySelector("#point-message");


    /*
     * 서버에서 조회한 원래 상품 총액
     */
    const originalPrice =
        Number("${pvData.totalPrice}") || 0;


    /*
     * 회원 등급 할인율
     *
     * BigDecimal 값이 JSP에서 문자열로 넘어옴.
     * 예: 0.10 = 10%
     */
    const gradeRate =
        Number("${pvData.discountRate}") || 0;


    /*
     * 보유 포인트
     */
    const maxPoint =
        Number("${pvData.point}") || 0;


    /*
     * 금액 표시
     */
    function formatPrice(price) {

        return Math.round(price).toLocaleString("ko-KR") + "원";

    }


    /*
     * 최종 결제금액 계산
     *
     * 서비스의 계산 방식과 동일하게
     *
     * 상품금액
     * → 쿠폰 할인
     * → 회원 등급 할인
     * → 포인트 차감
     */
    function calculateFinalPrice() {

        let price = originalPrice;


        /*
         * 쿠폰 할인율
         */
        const selectedCoupon =
            couponSelect.options[couponSelect.selectedIndex];

        const couponRate =
            Number(
                selectedCoupon.dataset.discount
            ) || 0;


        /*
         * 쿠폰 할인
         */
        const couponAmount =
            Math.round(price * couponRate);

        price =
            price * (1 - couponRate);


        /*
         * 회원 등급 할인
         */
        const gradeAmount =
            Math.round(price * gradeRate);

        price =
            price * (1 - gradeRate);


        /*
         * 소수점 반올림
         *
         * Java 서비스의
         * setScale(0, HALF_UP)
         * 와 맞추기 위한 처리
         */
        price =
            Math.round(price);


        /*
         * 포인트
         */
        let usedPoint =
            Number(usedPointInput.value) || 0;


        /*
         * 잘못된 포인트 방어
         */
        if (usedPoint < 0) {

            usedPoint = 0;
            usedPointInput.value = 0;

        }


        if (usedPoint > maxPoint) {

            usedPoint = maxPoint;
            usedPointInput.value = maxPoint;

            pointMessage.textContent =
                "보유 포인트보다 많이 사용할 수 없습니다.";

            pointMessage.className =
                "error-message";

        } else {

            pointMessage.textContent = "";
            pointMessage.className = "";

        }


        /*
         * 최종 금액
         */
        let result =
            price - usedPoint;


        /*
         * 결제금액은 음수가 될 수 없음
         */
        if (result < 0) {

            result = 0;

        }


        /*
         * 화면 표시
         */
        finalPrice.textContent =
            formatPrice(result);


        couponDiscount.textContent =
            formatPrice(couponAmount);


        gradeDiscountAmount.textContent =
            formatPrice(gradeAmount);


        pointDiscount.textContent =
            formatPrice(usedPoint);


        /*
         * 서버 검증용 금액
         */
        clientPaidAmount.value =
            Math.round(result);

    }


    /*
     * 포인트 입력
     */
    usedPointInput.addEventListener(
        "input",
        calculateFinalPrice
    );


    /*
     * 쿠폰 변경
     */
    couponSelect.addEventListener(
        "change",
        calculateFinalPrice
    );


    /*
     * 최종 제출 전 검사
     */
    form.addEventListener("submit", function (e) {


        /*
         * 결제수단 검사
         */
        const paymentMethod =
            document.querySelector(
                'input[name="paymentId"]:checked'
            );


        if (!paymentMethod) {

            e.preventDefault();

            alert("결제수단을 선택해주세요.");

            return;

        }


        /*
         * 개인정보 동의
         */
        const privacyAgree =
            document.querySelector("#privacy_agree");


        if (!privacyAgree.checked) {

            e.preventDefault();

            alert(
                "개인정보 수집 및 이용에 동의해주세요."
            );

            return;

        }


        /*
         * 결제 동의
         */
        const paymentAgree =
            document.querySelector("#payment_agree");


        if (!paymentAgree.checked) {

            e.preventDefault();

            alert(
                "결제에 동의해주세요."
            );

            return;

        }


        /*
         * 포인트 최소 사용금액
         *
         * 서비스에서 1000P 미만 사용을 막고 있으므로
         * 프론트에서도 동일하게 안내
         */
        const usedPoint =
            Number(usedPointInput.value) || 0;


        if (
            usedPoint > 0 &&
            usedPoint < 1000
        ) {

            e.preventDefault();

            alert(
                "포인트는 1000P 이상부터 사용할 수 있습니다."
            );

            return;

        }


        /*
         * 마지막으로 금액 재계산
         */
        calculateFinalPrice();

    });


    /*
     * 최초 화면 계산
     */
    calculateFinalPrice();

});

</script>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
