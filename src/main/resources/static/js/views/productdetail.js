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


    function activateTab(target) {
        tabButtons.forEach(function (btn) {
            const isActive = btn.dataset.tabTarget === target;
            btn.classList.toggle('is-active', isActive);
            btn.setAttribute('aria-selected', isActive);
        });

        tabPanels.forEach(function (panel) {
            panel.classList.toggle('is-active', panel.dataset.tabPanel === target);
        });
    }

    tabButtons.forEach(function (button) {

        button.addEventListener('click', function () {
            activateTab(button.dataset.tabTarget);
        });
    });


    // 리뷰 페이지 번호를 누르면 /mds/review/{id}?page=N#review 로 다시 들어온다.
    // 기본이 "상품 상세" 탭이라, 해시가 있으면 리뷰 탭을 열어둔 채로 시작한다.
    if (window.location.hash === '#review') {
        activateTab('review');
    }

    /* =========================
       찜 버튼
    ========================= */

    if (wishButton) {

        wishButton.addEventListener('click', function () {

            if (typeof window.toggleWish !== 'function') return;

            const productId = wishButton.dataset.productId;

            // common/cartWishService.js가 실제 WishController(POST /wish/insert-wish,
            // GET /wish/remove-wish)를 호출한다. 비로그인이면 /member/login으로 이동하고
            // 버튼 상태는 그대로 둔다(cart-button과 동일 패턴). 방향은 버튼의 현재 is-active
            // (서버가 최초 렌더링 때 실제 WISH 데이터 기준으로 채워준 상태)로 판단한다 -
            // 로그아웃 후 재로그인해도 이미 찜한 상품을 정확히 "찜 해제" 방향으로 처리한다.
            const wasWished = wishButton.classList.contains('is-active');

            window.toggleWish({ productId: productId }, wasWished).then(function (liked) {

                wishButton.classList.toggle('is-active', liked);

                const heart =
                    wishButton.querySelector('.icon-heart');

                if (heart) {
                    heart.classList.toggle('is-filled', liked);
                }

                wishButton.setAttribute(
                    'aria-label',
                    liked ? '찜 해제' : '찜하기'
                );

                if (wishCount) {

                    const count =
                        parseInt(wishCount.textContent, 10) || 0;

                    wishCount.textContent =
                        liked
                            ? count + 1
                            : Math.max(0, count - 1);
                }
            });
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

       CartController
       @PostMapping("/cart/add-cart")
       CartDTO cart (popId, qty - memberId는 세션에서 서버가 채운다)

       "바로 구매"와 완전히 같은 패턴(hidden form + submit)으로 실제 서버에 담는다.
       예전엔 여기 아무 핸들러도 없어서(주석만 남아있었음), 로그인 여부와 무관하게
       header.jsp의 localStorage 목업 뱃지만 눈에 보이는 채로 남는 문제가 있었다.
       CartController가 이미 로그인 가드를 갖고 있어(비로그인 시 /member/login으로
       리다이렉트) 여기서 따로 로그인 체크를 하지 않아도 서버가 막아준다.
    ========================= */

    if (cartButton) {

        cartButton.addEventListener('click', function () {

            const selected =
                getSelectedOption();

            if (!selected || selected.stock <= 0) {

                alert('품절된 상품입니다.');
                return;
            }

            let qty =
                parseInt(
                    quantityInput.value,
                    10
                );

            if (isNaN(qty) || qty < 1) {
                qty = 1;
            }

            if (qty > selected.stock) {

                alert('재고 수량을 초과했습니다.');

                quantityInput.value =
                    selected.stock;

                update(true);

                return;
            }

            const form =
                document.createElement('form');

            form.method = 'post';

            form.action =
                '/cart/add-cart';

            const popIdInput =
                document.createElement('input');

            popIdInput.type = 'hidden';
            popIdInput.name = 'popId';
            popIdInput.value =
                selected.popId;

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
       리뷰 좋아요

       ProductController
       @GetMapping("/mds/review/like/{reviewId}")

       응답은 "on"/"off"(토글 결과) 또는 "login-required"(비로그인) 텍스트다.
       ========================= */

    document.querySelectorAll('.review-like-btn').forEach(function (likeButton) {

        likeButton.addEventListener('click', function () {

            const reviewId =
                likeButton.dataset.reviewId;

            fetch('/mds/review/like/' + reviewId, { credentials: 'same-origin' })
                .then(function (res) { return res.text(); })
                .then(function (result) {

                    if (result === 'login-required') {
                        alert('로그인이 필요합니다.');
                        window.location.href = '/member/login';
                        return;
                    }

                    const liked = result === 'on';

                    likeButton.classList.toggle('is-active', liked);

                    likeButton.setAttribute(
                        'aria-label',
                        liked ? '좋아요 취소' : '좋아요'
                    );

                    const countEl =
                        likeButton.querySelector('.review-like-count');

                    if (countEl) {

                        const count =
                            parseInt(countEl.textContent, 10) || 0;

                        countEl.textContent =
                            liked
                                ? count + 1
                                : Math.max(0, count - 1);
                    }
                })
                .catch(function () {
                    alert('좋아요 처리에 실패했습니다.');
                });
        });
    });

});
