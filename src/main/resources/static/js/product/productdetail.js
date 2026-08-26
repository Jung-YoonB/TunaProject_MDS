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
});