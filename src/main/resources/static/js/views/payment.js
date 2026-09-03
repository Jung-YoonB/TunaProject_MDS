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
    // 작성 중인 선택값 임시 저장 (TC-39)
    //
    // 포인트/쿠폰/결제수단 선택은 서버에 저장되는 값이 아니라 이 화면의 입력 상태일 뿐이다.
    // 그런데 이 화면을 완전히 새로 그리는 경로가 둘 있다 - "+배송지 추가"로 나갔다 오는 경우와,
    // 결제하기를 눌렀는데 서버 쪽 검증(재고/쿠폰 등)에 걸려 이 화면으로 다시 리다이렉트되는 경우.
    // 둘 다 서버가 fresh GET으로 새 화면을 그리므로, 여기서 sessionStorage에 잠깐 담아뒀다가
    // 다음 로드 때 복원한다. 결제가 실제로 끝나면(주문 완료 화면으로 이동) 더 이상 필요 없다.
    // =========================================

    const CHECKOUT_DRAFT_KEY = 'checkoutDraft';

    function saveDraft() {
        const checkedPayment = document.querySelector('input[name="paymentId"]:checked');
        try {
            sessionStorage.setItem(CHECKOUT_DRAFT_KEY, JSON.stringify({
                usedPoint: usedPointInput.value,
                chistId: couponSelect.value,
                paymentId: checkedPayment ? checkedPayment.value : ''
            }));
        } catch (e) {
            // 프라이빗 브라우징 등으로 sessionStorage를 못 쓰면 그냥 포기한다(치명적이지 않음)
        }
    }

    function restoreDraft() {
        let draft;
        try {
            const raw = sessionStorage.getItem(CHECKOUT_DRAFT_KEY);
            sessionStorage.removeItem(CHECKOUT_DRAFT_KEY);
            draft = raw ? JSON.parse(raw) : null;
        } catch (e) {
            return;
        }
        if (!draft) return;

        if (draft.usedPoint) {
            usedPointInput.value = draft.usedPoint;
        }
        if (draft.chistId) {
            couponSelect.value = draft.chistId; // 선택지가 더는 없으면(만료/소진) 조용히 무시됨
        }
        if (draft.paymentId) {
            const radio = document.querySelector('input[name="paymentId"][value="' + draft.paymentId + '"]');
            if (radio) radio.checked = true;
        }
    }

    const addAddressBtn = document.getElementById('add-address');
    if (addAddressBtn) {
        addAddressBtn.addEventListener('click', function () {
            saveDraft();
            location.href = addAddressBtn.dataset.href;
        });
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

    // 포인트 최소 사용 단위. 서버 상수(OrderServiceImpl.POINT_MIN_USE)를 받아 쓴다.
    // 값을 여기에 직접 적으면 서버 검증과 갈라진다.
    const pointMinUse =
        Number(window.pointMinUse) || 0;

    const pointWarning =
        document.getElementById('point-warning');


    // =========================================
    // 할인 후 상품금액 - 서버와 반드시 같은 값이어야 한다
    //
    // 서버(OrderServiceImpl)는 BigDecimal로 상품금액 x (1-쿠폰율) x (1-등급율) 을 한 번에
    // 곱한 뒤 마지막에 HALF_UP 으로 한 번만 반올림한다. 화면이 단계마다 floor 하면
    // 최대 2원까지 어긋나서, 보이는 금액과 실제 결제 금액이 달라진다.
    //
    // 할인율은 소수 둘째 자리까지만 쓰므로(쿠폰 0.1~0.3 / 등급 0.02~0.15)
    // 100 단위 정수로 바꿔 계산하면 부동소수 오차 없이 서버와 같은 값이 나온다.
    // =========================================

    function applyRates(price, rates) {

        let numerator = price;
        let scale = 1;

        rates.forEach(function (rate) {
            numerator *= Math.round((1 - rate) * 100);
            scale *= 100;
        });

        const quotient = Math.floor(numerator / scale);
        const remainder = numerator - quotient * scale;

        // HALF_UP: 나머지가 절반 이상이면 올림
        return remainder * 2 >= scale ? quotient + 1 : quotient;
    }


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
        // 1~2. 쿠폰 + 등급 할인
        //
        // 최종 금액은 서버와 똑같이 "한 번에 곱하고 한 번만 반올림"으로 구한다.
        // 화면에 나누어 보여줄 두 금액은 그 총 할인액을 쪼갠 것이라,
        // 쿠폰 + 등급 = 총 할인액이 항상 정확히 맞아떨어진다.
        // -------------------------------------

        const couponRate =
            getCouponDiscountRate();

        const discountedProductPrice =
            applyRates(productPrice, [couponRate, gradeDiscountRate]);

        const totalDiscount =
            productPrice - discountedProductPrice;

        // 쿠폰만 적용했을 때 깎이는 금액
        const couponDiscount =
            productPrice - applyRates(productPrice, [couponRate]);

        // 나머지가 등급 할인분
        const gradeDiscount =
            totalDiscount - couponDiscount;


        // -------------------------------------
        // 3. 포인트 사용
        // -------------------------------------

        // 포인트 안내는 여기 한 곳에서만 만든다(입력/쿠폰변경/최초로드 모두 calculate를 거친다).
        let warning = '';

        let usedPoint =
            Number(usedPointInput.value) || 0;

        if (usedPoint < 0) {
            usedPoint = 0;
        }

        if (usedPoint > memberPoint) {
            usedPoint = memberPoint;
            usedPointInput.value = usedPoint;
            warning = '보유 포인트('
                + memberPoint.toLocaleString('ko-KR')
                + 'P)까지만 사용할 수 있습니다.';
        }

        // 결제할 금액보다 많은 포인트는 쓸 수 없다(서버가 "사용 포인트가 결제 금액보다
        // 많습니다"로 거부한다). 제출할 때 튕기지 않도록 여기서 미리 잘라준다.
        const maxUsablePoint = discountedProductPrice + deliveryFee;

        if (usedPoint > maxUsablePoint) {
            usedPoint = maxUsablePoint;
            usedPointInput.value = usedPoint;
            warning = '이번 주문에는 최대 '
                + maxUsablePoint.toLocaleString('ko-KR')
                + 'P까지 사용할 수 있습니다.';
        }

        // 최소 단위 미만은 서버가 거부하므로 화면 금액에도 반영하지 않는다.
        // (반영해 두면 "보이던 금액"과 실제 결제가 달라진다)
        if (usedPoint > 0 && usedPoint < pointMinUse) {
            warning = pointMinUse.toLocaleString('ko-KR')
                + 'P 이상부터 사용할 수 있습니다. ('
                + (pointMinUse - usedPoint).toLocaleString('ko-KR')
                + 'P 더 필요)';
            usedPoint = 0;
        }

        showPointWarning(warning);


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

    // 상·하한 보정과 안내 문구는 calculate()가 전담한다(한 곳에만 두어야 규칙이 갈리지 않는다)
    usedPointInput.addEventListener('input', calculate);


    // =========================================
    // 포인트 입력 완료
    // =========================================

    // 입력칸 아래 인라인 안내. 값을 되돌리지 않고 "왜 안 되는지"만 알려준다
    // (alert로 막고 0으로 되돌리면 입력하던 값이 사라져 다시 치게 된다)
    function showPointWarning(message) {
        if (!pointWarning) return;
        pointWarning.textContent = message;
        pointWarning.hidden = !message;
    }


    // 안내 문구와 상·하한 보정은 전부 calculate() 안에서 처리하므로 여기선 다시 계산만 시킨다
    usedPointInput.addEventListener('change', calculate);
    usedPointInput.addEventListener('change', saveDraft);


    // =========================================
    // 쿠폰 변경
    // =========================================

    couponSelect.addEventListener(
        'change',
        function () {

            calculate();
            saveDraft();

        }
    );


    // =========================================
    // 결제수단 변경
    // =========================================

    document.querySelectorAll('input[name="paymentId"]').forEach(function (radio) {
        radio.addEventListener('change', saveDraft);
    });


    // =========================================
    // 최종 결제
    // =========================================

    form.addEventListener(
        'submit',
        function (event) {

            // 서버 검증에 걸려 이 화면으로 되돌아올 수 있으므로 시도 시점 값을 미리 담아둔다
            saveDraft();

            const usedPoint =
                Number(usedPointInput.value) || 0;


            // ---------------------------------
            // 포인트 최소 사용 금액
            // ---------------------------------

            if (
                usedPoint > 0 &&
                usedPoint < pointMinUse
            ) {

                event.preventDefault();

                alert(
                    pointMinUse.toLocaleString('ko-KR')
                    + 'P 이상부터 사용할 수 있습니다.'
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

    // 이전 작성 이력이 있으면 입력값부터 복원한 뒤 계산한다(순서가 바뀌면 복원 전 기본값으로 계산됨)
    restoreDraft();
    calculate();

});
