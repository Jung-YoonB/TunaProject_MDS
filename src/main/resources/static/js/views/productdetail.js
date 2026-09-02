document.addEventListener('DOMContentLoaded', function () {

    const priceInfo      = document.getElementById('price-info');
    const optionSelect   = document.getElementById('product-option');
    const quantityInput  = document.getElementById('product-quantity');
    const originalPrice  = document.getElementById('original-price'); // 비로그인 화면에서는 null
    const salePrice      = document.getElementById('sale-price');
    const totalPriceText = document.getElementById('total-product-price');
    const cartButton     = document.getElementById('cart-button');
    const buyButton      = document.getElementById('buy-button');

    const wonFormat = new Intl.NumberFormat('ko-KR');

    // 등급 할인율 (0.02 형태). 비로그인이면 0
    const discountRate = Number(priceInfo.dataset.discountRate) || 0;

    function won(n) {
        return wonFormat.format(n) + '원';
    }

    // 등급 할인 적용가
    // TODO: 절사 단위 확정 시 이 함수만 수정 (10원 단위: Math.floor(x / 10) * 10)
    function applyDiscount(price) {
        return Math.floor(price * (1 - discountRate));
    }

    // 선택된 옵션 정보
    function getSelectedOption() {
        const opt = optionSelect.options[optionSelect.selectedIndex];
        if (!opt || !opt.value) return null;
        return {
            popId: opt.value,
            price: Number(opt.dataset.price),
            stock: Number(opt.dataset.stock)
        };
    }

    // clamp = true 일 때만 입력값 보정 (타이핑 중 방해 방지)
    function update(clamp) {
        const selected = getSelectedOption();

        // 선택 가능한 옵션이 없음 (전 옵션 품절 등)
        if (!selected) {
            quantityInput.value = 1;
            quantityInput.disabled = true;
            quantityInput.removeAttribute('max');
            cartButton.disabled = true;
            buyButton.disabled = true;

            if (originalPrice) originalPrice.textContent = '0원';
            salePrice.textContent = '0원';
            totalPriceText.textContent = '0원';
            return;
        }

        const soldOut = selected.stock === 0;
        quantityInput.disabled = soldOut;
        quantityInput.max = selected.stock;
        cartButton.disabled = soldOut;
        buyButton.disabled = soldOut;

        let qty = parseInt(quantityInput.value, 10);
        if (isNaN(qty) || qty < 1) qty = 1;
        if (qty > selected.stock) qty = selected.stock;
        if (clamp) quantityInput.value = qty;

        // 단가 (수량 미반영)
        const unitSale = applyDiscount(selected.price);

        if (originalPrice) originalPrice.textContent = won(selected.price);
        salePrice.textContent = won(unitSale);

        // 총액 (수량 반영)
        totalPriceText.textContent = won(unitSale * qty);
    }

    optionSelect.addEventListener('change', function () {
        quantityInput.value = 1;   // 옵션 변경 시 수량 초기화
        update(true);
    });

    quantityInput.addEventListener('input',  function () { update(false); });
    quantityInput.addEventListener('change', function () { update(true);  });
    quantityInput.addEventListener('blur',   function () { update(true);  });

    update(true);

    // 상품 상세 탭 (상품 상세 / 배송안내 / 교환·환불안내 / 리뷰)
    const tabButtons = document.querySelectorAll('.tab-menu-item');
    const tabPanels  = document.querySelectorAll('.tab-panel');

    tabButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            const target = button.dataset.tabTarget;

            tabButtons.forEach(function (btn) {
                const isActive = btn === button;
                btn.classList.toggle('is-active', isActive);
                btn.setAttribute('aria-selected', isActive);
            });

            tabPanels.forEach(function (panel) {
                panel.classList.toggle('is-active', panel.dataset.tabPanel === target);
            });
        });
    });

    // 찜 버튼
    // TODO: 백엔드 연동 후 서버 응답(찜 여부)에 따라 초기 is-active 상태 반영 + 클릭 시 찜 등록/삭제 API 연동
    // 지금은 서버 반영 전까지 화면에서만 개수를 낙관적으로 +-1 (새로고침하면 서버 값으로 원복됨)
    const wishButton = document.getElementById('wish-button');
    const wishCount  = document.getElementById('wish-count');

    wishButton.addEventListener('click', function () {
        const liked = wishButton.classList.toggle('is-active');
        // 원래는 textContent를 ♥/♡ 글리프로 갈아끼웠는데, 아이콘을 SVG로 바꾸면서
        // 같은 path의 채움 여부만 토글하는 방식으로 변경(2026-09-01 규격화).
        const heart = wishButton.querySelector('.icon-heart');
        if (heart) heart.classList.toggle('is-filled', liked);
        wishButton.setAttribute('aria-label', liked ? '찜 해제' : '찜하기');

        if (wishCount) {
            const count = parseInt(wishCount.textContent, 10) || 0;
            wishCount.textContent = liked ? count + 1 : count - 1;
        }
    });

    // 서브 이미지 클릭 -> 메인 이미지 교체
    const mainImage = document.getElementById('product-main-image');
    const subImages  = document.querySelectorAll('.product-sub-image');

    subImages.forEach(function (subImage) {
        subImage.addEventListener('click', function () {
            mainImage.src = subImage.src;
            mainImage.alt = subImage.alt;

            subImages.forEach(function (img) { img.classList.remove('is-active'); });
            subImage.classList.add('is-active');
        });
    });
});

buyButton.addEventListener('click', function () {
    const selected = getSelectedOption();

    if (!selected || selected.stock <= 0) {
        alert('품절된 상품입니다.');
        return;
    }

    let qty = parseInt(quantityInput.value, 10);

    if (isNaN(qty) || qty < 1) {
        qty = 1;
    }

    if (qty > selected.stock) {
        alert('재고 수량을 초과했습니다.');
        quantityInput.value = selected.stock;
        update(true);
        return;
    }

    const form = document.createElement('form');
    form.method = 'post';
    form.action = '/order/payment';

    const popIdInput = document.createElement('input');
    popIdInput.type = 'hidden';
    popIdInput.name = 'popId';
    popIdInput.value = selected.popId;

    const qtyInput = document.createElement('input');
    qtyInput.type = 'hidden';
    qtyInput.name = 'qty';
    qtyInput.value = qty;

    form.appendChild(popIdInput);
    form.appendChild(qtyInput);

    document.body.appendChild(form);
    form.submit();
});