<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="order-page"> <div class="order-card">
<!-- 결제하기 제목 -->
<div id="title">
    결제하기
</div>


<!-- =====================================================
     결제 처리
====================================================== -->

<form id="checkoutForm"
      action="${pageContext.request.contextPath}/order/checkout"
      method="post">


    <!-- =====================================================
         주문 상품 정보
    ====================================================== -->

    <div id="ProductInfo">

        <h2>주문 상품정보</h2>

        <c:forEach var="item"
                   items="${pvData.itemList}"
                   varStatus="status">

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


            <!-- 서버로 전달할 상품 정보 -->

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
         장바구니에서 결제한 경우에만 존재
    ====================================================== -->

    <c:forEach var="cartId"
               items="${pvData.cartIds}">

        <input type="hidden"
               name="cartIds"
               value="${cartId}">

    </c:forEach>


    <!-- =====================================================
         상품 금액 / 배송비
    ====================================================== -->

    <div id="Price">

        <div class="price-item">

            <span>
                상품 금액
            </span>

            <%-- 이 두 값은 JS가 다시 쓰지 않으므로 여기서 천단위 구분자를 넣어야 한다.
                 (아래 할인/최종금액은 views/payment.js가 toLocaleString으로 다시 채운다) --%>
            <span id="total_price">
                <fmt:formatNumber value="${pvData.totalPrice}" pattern="#,##0"/>원
            </span>

        </div>


        <div class="price-item">

            <span>
                배송비
            </span>

            <span id="delivery_price">
                <fmt:formatNumber value="${pvData.deliveryFee}" pattern="#,##0"/>원
            </span>

        </div>

    </div>


    <!-- =====================================================
         포인트 사용
    ====================================================== -->

    <div id="point">

        <label for="used_point">
            포인트 사용
        </label>

        <%-- 보유 포인트가 최소 단위 미만이면 입력 자체를 막는다. 입력만 받고 제출에서 튕기면
             왜 안 되는지 알 수 없다(서버도 같은 조건으로 다시 검증한다). --%>
        <input
            type="number"
            id="used_point"
            name="usedPoint"
            value="0"
            min="0"
            max="${pvData.point}"
            ${pvData.point lt pvData.pointMinUse ? 'disabled' : ''}
        >

        <span>
            포인트
        </span>


        <p>
            보유 포인트 :
            <strong><fmt:formatNumber value="${pvData.point}" pattern="#,##0"/>P</strong>
        </p>


        <%-- 최소 사용 단위는 서버 상수(OrderServiceImpl.POINT_MIN_USE)를 pvData로 받아 쓴다.
             여기에 숫자를 직접 적으면 서버 검증과 안내가 갈라진다. --%>
        <c:set var="pointMin" value="${pvData.pointMinUse}"/>

        <p class="point-guide">
            <c:choose>
                <c:when test="${pvData.point lt pointMin}">
                    <%-- 보유 포인트가 최소 단위에 못 미치면 이번 주문에선 아예 쓸 수 없다.
                         얼마가 더 있어야 하는지까지 알려준다. --%>
                    포인트는 <strong><fmt:formatNumber value="${pointMin}" pattern="#,##0"/>P 이상</strong>부터 사용할 수 있습니다.<br>
                    현재 보유 포인트가 부족해 이번 주문에서는 사용할 수 없습니다.
                    (<strong><fmt:formatNumber value="${pointMin - pvData.point}" pattern="#,##0"/>P</strong> 더 필요)
                </c:when>
                <c:otherwise>
                    포인트는 <strong><fmt:formatNumber value="${pointMin}" pattern="#,##0"/>P 이상</strong>부터 사용할 수 있습니다.<br>
                    0P는 사용하지 않는 것으로 처리됩니다.
                </c:otherwise>
            </c:choose>
        </p>


        <p id="point-warning"
           class="point-warning"
           hidden>
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


            <c:forEach var="coupon"
                       items="${pvData.couponList}">

                <option
                    value="${coupon.chistId}"
                    data-discount="${coupon.couponValue}">

                    ${coupon.couponName}
                    -
                    ${(coupon.couponValue * 100).intValue()}%

                </option>

            </c:forEach>

        </select>

    </div>


    <!-- =====================================================
         회원 등급 할인율
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
         할인 / 포인트 사용 금액
    ====================================================== -->

    <div id="DiscountInfo">

        <!-- 쿠폰 할인 -->
        <div class="price-item">

            <span>
                쿠폰 할인 금액
            </span>

            <span id="coupon_discount">
                0원
            </span>

        </div>


        <!-- 등급 할인 -->
        <div class="price-item">

            <span>
                등급 할인 금액
            </span>

            <span id="grade_discount_amount">
                0원
            </span>

        </div>


        <!-- 포인트 사용 -->
        <div class="price-item">

            <span>
                포인트 사용 금액
            </span>

            <span id="point_discount">
                0원
            </span>

        </div>

    </div>


    <!-- =====================================================
         최종 결제 금액
    ====================================================== -->

    <div id="TotalPayment">

        <span>
            총 결제금액
        </span>


        <strong id="final_price">
            <fmt:formatNumber value="${pvData.totalPrice}" pattern="#,##0"/>원
        </strong>

    </div>


    <!-- JS 계산 후 서버로 전달되는 금액 -->
    <input
        type="hidden"
        id="clientPaidAmount"
        name="clientPaidAmount"
        value="${pvData.totalPrice}"
    >


    <!-- 배송비 서버 전달 -->
    <input
        type="hidden"
        id="deliveryFee"
        name="deliveryFee"
        value="${pvData.deliveryFee}"
    >


    <!-- =====================================================
         배송지 정보
    ====================================================== -->

    <div id="DeliveryAddress">

        <h2>
            배송지 정보
        </h2>


        <div class="address-item">

            <div class="address-name">

                <span>
                    배송지 이름
                </span>

                <span id="address_name">
                    ${pvData.addressName}
                </span>

            </div>


            <div class="address-detail">

                <span>
                    배송지 주소
                </span>

                <span id="detail_address">
                    ${pvData.detailAddress}
                </span>

            </div>


            <span id="is_default">
                기본 배송지
            </span>

        </div>


        <!-- 실제 주문에 저장할 배송지 -->

        <input
            type="hidden"
            name="addressNameFix"
            value="${pvData.addressName}"
        >

        <input
            type="hidden"
            name="detailAddressFix"
            value="${pvData.detailAddress}"
        >


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

            <!-- 카카오페이 -->

            <input
                type="radio"
                id="kakao_pay"
                name="paymentId"
                value="1"
            >

            <label for="kakao_pay">
                카카오페이
            </label>


            <!-- 네이버페이 -->

            <input
                type="radio"
                id="naver_pay"
                name="paymentId"
                value="2"
            >

            <label for="naver_pay">
                네이버페이
            </label>


            <!-- 마스터카드 -->

            <input
                type="radio"
                id="mastercard"
                name="paymentId"
                value="3"
            >

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
                id="payment_agree"
            >

            <label for="payment_agree">
                결제에 동의합니다.
            </label>

        </div>


        <div>

            <input
                type="checkbox"
                id="privacy_agree"
            >

            <label for="privacy_agree">
                개인정보 수집 및 이용에 동의합니다.
            </label>

        </div>


        <div id="Terms">

            <a href="#">
                이용약관
            </a>

        </div>


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

</div> </div> <!-- ========================================================= 서버 데이터 → JavaScript 전달 ========================================================== --> <script> window.productTotalPrice = Number("${pvData.totalPrice}") || 0; window.memberPoint = Number("${pvData.point}") || 0; window.gradeDiscountRate = Number("${pvData.discountRate}") || 0; window.deliveryFee = Number("${pvData.deliveryFee}") || 0; window.pointMinUse = Number("${pvData.pointMinUse}") || 0; </script> <!-- payment.js는 반드시 한 번만 로드 --> <script src="<c:url value='/js/views/payment.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>