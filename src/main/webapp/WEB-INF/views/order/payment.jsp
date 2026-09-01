<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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

            <div class="product-item">

                <div class="product-name">

                    <span>상품명</span>

                    <span id="product_name">
                        상품 이름
                    </span>

                </div>

                <div class="product-quantity">

                    <span>상품 수량</span>

                    <span id="qty">
                        1
                    </span>

                </div>

            </div>

        </div>


        <!-- 상품 금액 -->
        <div id="Price">

            <div class="price-item">

                <span>상품 금액</span>

                <span id="total_price">
                    상품 금액값
                </span>

            </div>

            <div class="price-item">

                <span>배송비</span>

                <span id="delivery_price">
                    배송 금액값
                </span>

            </div>

        </div>


        <!-- 포인트 사용 -->
        <div id="point">

            <label for="used_point">
                포인트 사용
            </label>

            <input
                type="number"
                id="used_point"
                name="used_point"
                value="0"
                min="0">

            <span>
                포인트
            </span>

        </div>


        <!-- 쿠폰 사용 -->
        <div id="Coupon">

            <label for="coupon_id">
                쿠폰 사용
            </label>

            <select id="coupon_id" name="coupon_id">

                <option value="">
                    쿠폰을 선택해주세요
                </option>

                <option value="1">
                    여름 특별쿠폰 - 10%
                </option>

                <option value="2">
                    신규회원 환영 쿠폰 - 15%
                </option>

                <option value="3">
                    주말할인쿠폰 - 20%
                </option>

            </select>

        </div>


        <!-- 회원 등급 할인 -->
        <div id="MembershipTier">

            <span>
                회원 등급 할인
            </span>

            <span id="grade_discount">
                등급별 할인율
            </span>

        </div>


        <!-- 최종 결제 금액 -->
        <div id="TotalPayment">

            <span>
                총 결제금액
            </span>

            <strong id="final_price">
                총 결제금액값
            </strong>

        </div>


        <!-- 배송지 정보 -->
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
                        집
                    </span>

                </div>


                <!-- 배송지 주소 -->
                <div class="address-detail">

                    <span>
                        배송지 주소
                    </span>

                    <span id="detail_address">
                        서울특별시 강남구 테헤란로 14길
                    </span>

                </div>


                <!-- 기본 배송지 -->
                <span id="is_default">
                    기본 배송지
                </span>

            </div>


            <!-- 배송지 추가 -->
            <button
                type="button"
                id="add-address">

                + 배송지 추가

            </button>

        </div>


        <!-- 결제 수단 -->
        <div id="PaymentMethod">

            <h2>
                결제수단 선택
            </h2>

            <div class="payment-method">

                <input
                    type="radio"
                    id="apple_pay"
                    name="payment_id"
                    value="applePay">

                <label for="apple_pay">
                    애플페이
                </label>


                <input
                    type="radio"
                    id="kakao_pay"
                    name="payment_id"
                    value="kakaoPay">

                <label for="kakao_pay">
                    카카오페이
                </label>


                <input
                    type="radio"
                    id="naver_pay"
                    name="payment_id"
                    value="naverPay">

                <label for="naver_pay">
                    네이버페이
                </label>


                <input
                    type="radio"
                    id="hana_pay"
                    name="payment_id"
                    value="hanaPay">

                <label for="hana_pay">
                    하나페이
                </label>


                <input
                    type="radio"
                    id="payco"
                    name="payment_id"
                    value="payco">

                <label for="payco">
                    페이코
                </label>


                <input
                    type="radio"
                    id="toss_pay"
                    name="payment_id"
                    value="tossPay">

                <label for="toss_pay">
                    토스페이
                </label>


                <input
                    type="radio"
                    id="visa"
                    name="payment_id"
                    value="visa">

                <label for="visa">
                    비자
                </label>


                <input
                    type="radio"
                    id="mastercard"
                    name="payment_id"
                    value="mastercard">

                <label for="mastercard">
                    마스터카드
                </label>

            </div>

        </div>


        <!-- 결제 동의 -->
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


        <!-- 결제 버튼 -->
        <div id="Confirm">

            <button type="submit">
                최종 결제
            </button>

            <button type="button">
                결제 취소
            </button>

        </div>
</div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>