/* =========================================================
 * 결제 페이지
 * ========================================================= */


/* =========================================================
 * 요소
 * ========================================================= */

const usedPointInput =
    document.querySelector("#used_point");

const couponSelect =
    document.querySelector("#coupon_id");

const deliveryPrice =
    document.querySelector("#delivery_price");

const deliveryFeeInput =
    document.querySelector("#deliveryFee");

const finalPrice =
    document.querySelector("#final_price");

const clientPaidAmount =
    document.querySelector("#clientPaidAmount");

const paymentForm =
    document.querySelector("#checkoutForm");


/* =========================================================
 * 쿠폰 할인율
 * ========================================================= */

function getCouponDiscountRate() {

    if (!couponSelect || couponSelect.value === "") {
        return 0;
    }

    const selectedOption =
        couponSelect.options[couponSelect.selectedIndex];

    return Number(
        selectedOption.getAttribute("data-discount")
    ) || 0;
}


/* =========================================================
 * 최종 결제금액 계산
 * ========================================================= */

function calculateFinalPrice() {

    /* 상품 금액 */
    let price = productTotalPrice;


    /* 쿠폰 할인 */

    const couponDiscountRate =
        getCouponDiscountRate();

    if (couponDiscountRate > 0) {

        price =
            price * (1 - couponDiscountRate);
    }


    /* 회원 등급 할인 */

    price =
        price * (1 - gradeDiscountRate);


    /* 원 단위 반올림 */

    price =
        Math.round(price);


    /* 배송비 */

    price += deliveryFee;


    /* 배송비 hidden input */

    if (deliveryFeeInput) {
        deliveryFeeInput.value = deliveryFee;
    }


    /* 포인트 */

    let usedPoint =
        Number(usedPointInput.value) || 0;


    /* 보유 포인트 초과 방지 */

    if (usedPoint > memberPoint) {

        usedPoint = memberPoint;

        usedPointInput.value =
            memberPoint;
    }


    /* 음수 방지 */

    if (usedPoint < 0) {

        usedPoint = 0;

        usedPointInput.value = 0;
    }


    /* 포인트 차감 */

    price -= usedPoint;


    /* 최종 금액 음수 방지 */

    if (price < 0) {
        price = 0;
    }


    /* 최종 금액 화면 출력 */

    finalPrice.textContent =
        price.toLocaleString() + "원";


    /* 서버 전달용 금액 */

    clientPaidAmount.value =
        price;
}


/* =========================================================
 * 포인트 입력
 * ========================================================= */

if (usedPointInput) {

    usedPointInput.addEventListener(
        "input",
        calculateFinalPrice
    );
}


/* =========================================================
 * 쿠폰 선택
 * ========================================================= */

if (couponSelect) {

    couponSelect.addEventListener(
        "change",
        calculateFinalPrice
    );
}


/* =========================================================
 * 결제 제출
 * ========================================================= */

if (paymentForm) {

    paymentForm.addEventListener(
        "submit",
        function(e) {

            const usedPoint =
                Number(usedPointInput.value) || 0;


            /* 포인트 초과 */

            if (usedPoint > memberPoint) {

                e.preventDefault();

                alert(
                    "보유 포인트보다 많이 사용할 수 없습니다."
                );

                return;
            }


            /* 포인트 1000점 이상 사용 */

            if (
                usedPoint > 0 &&
                usedPoint < 1000
            ) {

                e.preventDefault();

                alert(
                    "포인트는 1000 이상부터 사용할 수 있습니다."
                );

                return;
            }


            /* 결제수단 */

            const paymentMethod =
                document.querySelector(
                    'input[name="paymentId"]:checked'
                );

            if (!paymentMethod) {

                e.preventDefault();

                alert(
                    "결제수단을 선택해주세요."
                );

                return;
            }


            /* 결제 동의 */

            const paymentAgree =
                document.querySelector(
                    "#payment_agree"
                );

            if (!paymentAgree.checked) {

                e.preventDefault();

                alert(
                    "결제에 동의해주세요."
                );

                return;
            }


            /* 개인정보 동의 */

            const privacyAgree =
                document.querySelector(
                    "#privacy_agree"
                );

            if (!privacyAgree.checked) {

                e.preventDefault();

                alert(
                    "개인정보 수집 및 이용에 동의해주세요."
                );

                return;
            }


            /* 제출 직전 금액 계산 */

            calculateFinalPrice();
        }
    );
}


/* =========================================================
 * 최초 계산
 * ========================================================= */

calculateFinalPrice();