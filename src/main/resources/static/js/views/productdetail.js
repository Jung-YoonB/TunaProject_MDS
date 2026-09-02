document.addEventListener('DOMContentLoaded', function () {

    const priceInfo      = document.getElementById('price-info');
    const optionSelect   = document.getElementById('product-option');
    const quantityInput  = document.getElementById('product-quantity');
    const originalPrice  = document.getElementById('original-price');
    const salePrice      = document.getElementById('sale-price');
    const totalPriceText = document.getElementById('total-product-price');

    const cartButton     = document.getElementById('cart-button');
    const buyButton      = document.getElementById('buy-button');

    const wishButton     = document.getElementById('wish-button');
    const wishCount      = document.getElementById('wish-count');

    const mainImage      = document.getElementById('product-main-image');
    const subImages      = document.querySelectorAll('.product-sub-image');

    const wonFormat = new Intl.NumberFormat('ko-KR');


    /* =========================
       가격 관련
    ========================= */

    // 등급 할인율
    // JSP의 data-discount-rate="0.02" 기준
    const discountRate =
        priceInfo ? Number(priceInfo.dataset.discountRate) || 0 : 0;

    function won(number) {
        return wonFormat.format(number) + '원';
    }

    // 등급 할인 적용
    function applyDiscount(price) {
        return Math.floor(price * (1 - discountRate));
    }


    /* =========================
       선택 옵션
    ========================= */

    function getSelectedOption() {

        if (!optionSelect || optionSelect.options.length === 0) {
            return null;
        }

        const option =
            optionSelect.options[optionSelect.selectedIndex];

        if (!option || !option.value) {
            return null;
        }

        return {
            popId: option.value,
            price: Number(option.dataset.price) || 0,
            stock: Number(option.dataset.stock) || 0
        };
    }


    /* =========================
       화면 가격 / 재고 갱신
    ========================= */

    function update(clamp) {

        const selected = getSelectedOption();

        // 선택 가능한 옵션이 없는 경우
        if (!selected) {

            if (quantityInput) {
                quantityInput.value = 1;
                quantityInput.disabled = true;
                quantityInput.removeAttribute('max');
            }

            if (cartButton) {
                cartButton.disabled = true;
            }

            if (buyButton) {
                buyButton.disabled = true;
            }

            if (originalPrice) {
                originalPrice.textContent = '0원';
            }

            if (salePrice) {
                salePrice.textContent = '0원';
            }

            if (totalPriceText) {
                totalPriceText.textContent = '0원';
            }

            return;
        }


        const soldOut = selected.stock <= 0;


        // 수량 입력창
        if (quantityInput) {

            quantityInput.disabled = soldOut;

            if (selected.stock > 0) {
                quantityInput.max = selected.stock;
            } else {
                quantityInput.removeAttribute('max');
            }
        }


        // 버튼
        if (cartButton) {
            cartButton.disabled = soldOut;
        }

        if (buyButton) {
            buyButton.disabled = soldOut;
        }


        // 수량 계산
        let qty = parseInt(
            quantityInput ? quantityInput.value : 1,
            10
        );

        if (isNaN(qty) || qty < 1) {
            qty = 1;
        }

        if (selected.stock > 0 && qty > selected.stock) {
            qty = selected.stock;
        }

        if (clamp && quantityInput) {
            quantityInput.value = qty;
        }


        // 할인 적용 가격
        const unitSale = applyDiscount(selected.price);


        // 정상가
        if (originalPrice) {
            originalPrice.textContent = won(selected.price);
        }

        // 할인가
        if (salePrice) {
            salePrice.textContent = won(unitSale);
        }

        // 총 금액
        if (totalPriceText) {
            totalPriceText.textContent =
                won(unitSale * qty);
        }
    }


    /* =========================
       옵션 변경
    ========================= */

    if (optionSelect) {

        optionSelect.addEventListener('change', function () {

            // 옵션 변경 시 수량 1개로 초기화
            if (quantityInput) {
                quantityInput.value = 1;
            }

            update(true);
        });
    }


    /* =========================
       수량 변경
    ========================= */

    if (quantityInput) {

        // 입력 중에는 강제로 값을 고치지 않음
        quantityInput.addEventListener('input', function () {
            update(false);
        });

        // 입력 완료 후 보정
        quantityInput.addEventListener('change', function () {
            update(true);
        });

        // 포커스 빠질 때 보정
        quantityInput.addEventListener('blur', function () {
            update(true);
        });
    }


    /* =========================
       최초 가격 / 재고 세팅
    ========================= */

    update(true);


    /* =========================
       상품 상세 탭
    ========================= */

    const tabButtons =
        document.querySelectorAll('.tab-menu-item');

    const tabPanels =
        document.querySelectorAll('.tab-panel');


    tabButtons.forEach(function (button) {

        button.addEventListener('click', function () {

            const target =
                button.dataset.tabTarget;


            // 버튼 상태 변경
            tabButtons.forEach(function (btn) {

                const isActive =
                    btn === button;

                btn.classList.toggle(
                    'is-active',
                    isActive
                );

                btn.setAttribute(
                    'aria-selected',
                    isActive
                );
            });


            // 패널 변경
            tabPanels.forEach(function (panel) {

                panel.classList.toggle(
                    'is-active',
                    panel.dataset.tabPanel === target
                );
            });
        });
    });


    /* =========================
       찜 버튼
    ========================= */

    if (wishButton) {

        wishButton.addEventListener('click', function () {

            const liked =
                wishButton.classList.toggle('is-active');


            // SVG 하트 채우기
            const heart =
                wishButton.querySelector('.icon-heart');

            if (heart) {

                heart.classList.toggle(
                    'is-filled',
                    liked
                );
            }


            // 접근성
            wishButton.setAttribute(
                'aria-label',
                liked ? '찜 해제' : '찜하기'
            );


            // 현재는 화면에서만 숫자 변경
            // TODO: 찜 API 연결
            if (wishCount) {

                const count =
                    parseInt(wishCount.textContent, 10) || 0;

                wishCount.textContent =
                    liked
                        ? count + 1
                        : Math.max(0, count - 1);
            }
        });
    }


    /* =========================
       서브 이미지 → 메인 이미지
    ========================= */

    if (mainImage) {

        subImages.forEach(function (subImage) {

            subImage.addEventListener('click', function () {

                mainImage.src =
                    subImage.src;

                mainImage.alt =
                    subImage.alt;


                // 선택된 이미지 표시
                subImages.forEach(function (img) {

                    img.classList.remove(
                        'is-active'
                    );
                });

                subImage.classList.add(
                    'is-active'
                );
            });
        });
    }


    /* =========================
       바로 구매
    ========================= */

    if (buyButton) {

        buyButton.addEventListener('click', function () {

            const selected =
                getSelectedOption();


            // 옵션 없음 / 품절
            if (!selected || selected.stock <= 0) {

                alert('품절된 상품입니다.');
                return;
            }


            // 수량
            let qty =
                parseInt(
                    quantityInput.value,
                    10
                );


            if (isNaN(qty) || qty < 1) {
                qty = 1;
            }


            // 재고 초과
            if (qty > selected.stock) {

                alert('재고 수량을 초과했습니다.');

                quantityInput.value =
                    selected.stock;

                update(true);

                return;
            }


            /*
             * 바로구매
             *
             * OrderController
             * @PostMapping("/payment")
             *
             * @ModelAttribute OrderItemDTO orderItem
             *
             * 따라서 input name은
             * OrderItemDTO의 필드명과 맞아야 함.
             *
             * 현재 백엔드 코드 기준:
             * popId
             * qty
             */


            const form =
                document.createElement('form');

            form.method = 'post';

            form.action =
                '/order/payment';


            // POP_ID
            const popIdInput =
                document.createElement('input');

            popIdInput.type = 'hidden';
            popIdInput.name = 'popId';
            popIdInput.value =
                selected.popId;


            // 수량
            const qtyInput =
                document.createElement('input');

            qtyInput.type = 'hidden';
            qtyInput.name = 'qty';
            qtyInput.value = qty;


            form.appendChild(popIdInput);
            form.appendChild(qtyInput);

            document.body.appendChild(form);

            form.submit();
        });
    }


    /* =========================
       장바구니
    =========================
    
       주의:
       현재 백엔드에서 바로구매는 /order/payment로
       연결되어 있지만, 장바구니 API는 여기서 확인되지 않음.
       
       그래서 기존 cartButton 동작은 건드리지 않음.
    ========================= */

});
