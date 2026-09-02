document.addEventListener('DOMContentLoaded', function () {

    const form = document.getElementById('checkoutForm');

    const usedPointInput =
        document.getElementById('used_point');

    const couponSelect =
        document.getElementById('coupon_id');

    const couponDiscountText =
        document.getElementById('coupon_discount');

    const gradeDiscountText =
        document.getElementById('grade_discount_amount');

    const pointDiscountText =
        document.getElementById('point_discount');

    const finalPriceText =
        document.getElementById('final_price');

    const clientPaidAmount =
        document.getElementById('clientPaidAmount');


    // 요소가 없으면 실행 중단
    if (!form || !usedPointInput || !couponSelect) {
        return;
    }


    // =========================================
    // 서버에서 전달받은 기본 정보
    // =========================================

    const productPrice =
        Number(window.productTotalPrice) || 0;

    const memberPoint =
        Number(window.memberPoint) || 0;

    const gradeDiscountRate =
        Number(window.gradeDiscountRate) || 0;

    const deliveryFee =
        Number(window.deliveryFee) || 0;


    // =========================================
    // 원화 표시
    // =========================================

    function won(value) {
        return Math.max(0, value).toLocaleString('ko-KR') + '원';
    }


    // =========================================
    // 선택한 쿠폰 할인율 가져오기
    // =========================================

    function getCouponDiscountRate() {

        if (!couponSelect.value) {
            return 0;
        }

        const selectedOption =
            couponSelect.options[couponSelect.selectedIndex];

        return Number(
            selectedOption.dataset.discount
        ) || 0;
    }


    // =========================================
    // 금액 계산
    // =========================================

    function calculate() {

        // -------------------------------------
        // 1. 쿠폰 할인
        // -------------------------------------

        const couponRate =
            getCouponDiscountRate();

        const couponDiscount =
            Math.floor(
                productPrice * couponRate
            );


        // 쿠폰 적용 후 금액
        const priceAfterCoupon =
            productPrice - couponDiscount;


        // -------------------------------------
        // 2. 회원 등급 할인
        // -------------------------------------

        const gradeDiscount =
            Math.floor(
                priceAfterCoupon * gradeDiscountRate
            );


        // 등급 할인 후 상품 금액
        const discountedProductPrice =
            priceAfterCoupon - gradeDiscount;


        // -------------------------------------
        // 3. 포인트 사용
        // -------------------------------------

        let usedPoint =
            Number(usedPointInput.value) || 0;

        if (usedPoint < 0) {
            usedPoint = 0;
        }

        if (usedPoint > memberPoint) {
            usedPoint = memberPoint;
            usedPointInput.value = usedPoint;
        }


        // -------------------------------------
        // 4. 최종 결제 금액
        // -------------------------------------

        let finalPrice =
            discountedProductPrice
            + deliveryFee
            - usedPoint;

        if (finalPrice < 0) {
            finalPrice = 0;
        }


        // -------------------------------------
        // 5. 화면 표시
        // -------------------------------------

        // 쿠폰 할인 금액
        if (couponDiscountText) {
            couponDiscountText.textContent =
                won(couponDiscount);
        }


        // 등급 할인 금액
        if (gradeDiscountText) {
            gradeDiscountText.textContent =
                won(gradeDiscount);
        }


        // 포인트 사용 금액
        if (pointDiscountText) {
            pointDiscountText.textContent =
                won(usedPoint);
        }


        // 최종 결제 금액
        if (finalPriceText) {
            finalPriceText.textContent =
                won(finalPrice);
        }


        // 서버 전달용
        if (clientPaidAmount) {
            clientPaidAmount.value =
                finalPrice;
        }
    }


    // =========================================
    // 포인트 입력
    // =========================================

    usedPointInput.addEventListener(
        'input',
        function () {

            let value =
                Number(usedPointInput.value) || 0;


            if (value < 0) {
                value = 0;
            }


            if (value > memberPoint) {
                value = memberPoint;
            }


            usedPointInput.value = value;

            calculate();
        }
    );


    // =========================================
    // 포인트 입력 완료
    // =========================================

    usedPointInput.addEventListener(
        'change',
        function () {

            let value =
                Number(usedPointInput.value) || 0;


            // 포인트를 사용하지 않는 경우
            if (value === 0) {
                calculate();
                return;
            }


            // 최소 1,000P
            if (value < 1000) {

                alert(
                    '포인트는 1,000P 이상부터 사용할 수 있습니다.'
                );

                usedPointInput.value = 0;

                calculate();

                return;
            }


            calculate();
        }
    );


    // =========================================
    // 쿠폰 변경
    // =========================================

    couponSelect.addEventListener(
        'change',
        function () {

            calculate();

        }
    );


    // =========================================
    // 최종 결제
    // =========================================

    form.addEventListener(
        'submit',
        function (event) {

            const usedPoint =
                Number(usedPointInput.value) || 0;


            // ---------------------------------
            // 포인트 최소 사용 금액
            // ---------------------------------

            if (
                usedPoint > 0 &&
                usedPoint < 1000
            ) {

                event.preventDefault();

                alert(
                    '포인트는 1,000P 이상부터 사용할 수 있습니다.'
                );

                usedPointInput.focus();

                return;
            }


            // ---------------------------------
            // 보유 포인트 초과
            // ---------------------------------

            if (usedPoint > memberPoint) {

                event.preventDefault();

                alert(
                    '보유 포인트를 초과하여 사용할 수 없습니다.'
                );

                usedPointInput.focus();

                return;
            }


            // ---------------------------------
            // 결제수단 선택
            // ---------------------------------

            const paymentMethod =
                document.querySelector(
                    'input[name="paymentId"]:checked'
                );


            if (!paymentMethod) {

                event.preventDefault();

                alert(
                    '결제수단을 선택해주세요.'
                );

                return;
            }


            // ---------------------------------
            // 결제 동의
            // ---------------------------------

            const paymentAgree =
                document.getElementById('payment_agree');

            const privacyAgree =
                document.getElementById('privacy_agree');


            if (!paymentAgree.checked) {

                event.preventDefault();

                alert(
                    '결제 동의가 필요합니다.'
                );

                return;
            }


            if (!privacyAgree.checked) {

                event.preventDefault();

                alert(
                    '개인정보 수집 및 이용 동의가 필요합니다.'
                );

                return;
            }


            // 최종 계산
            calculate();

        }
    );


    // =========================================
    // 최초 화면 계산
    // =========================================

    calculate();

});
