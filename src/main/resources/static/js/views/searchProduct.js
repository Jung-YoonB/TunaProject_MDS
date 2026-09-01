// 상품 검색 결과 페이지 인터랙션 - 카드의 찜/장바구니 버튼과 태그 필터 토글.
//
// 찜/장바구니의 실제 저장은 static/js/common/cartWishService.js(header.jsp가 전 페이지에
// 로드)가 window.isWished / window.toggleWish / window.addToCart로 노출하는 함수가 담당한다.
// 이 파일은 그 함수를 부르고 버튼 상태만 반영한다.
//
// TODO(data binding): 찜 상태는 cartWishService의 localStorage(wishItems) 임시 구현이라
// 실제로는 /wish API 연동이 필요하다. (담당자 별도 진행 중 - 이 파일에서 건드리지 말 것)
(function () {

    var page = document.querySelector('.search-result-page');
    if (!page) return;

    // 카드 DOM에서 찜/장바구니에 넘길 상품 정보를 읽어낸다. 가격은 "12,000원" 같은
    // 표시용 문자열이라 숫자만 남겨서 정수로 바꾼다.
    function readProduct(card) {
        var priceText = card.querySelector('.sp-product-price').textContent;
        return {
            productId: card.dataset.productId,
            name: card.querySelector('.sp-product-name').textContent.trim(),
            price: parseInt(priceText.replace(/[^0-9]/g, ''), 10) || 0
        };
    }

    page.querySelectorAll('.sp-btn-wishlist').forEach(function (btn) {
        var card = btn.closest('.sp-product-card');
        var productId = card.dataset.productId;

        if (typeof window.isWished === 'function' && window.isWished(productId)) {
            btn.classList.add('is-active');
        }

        btn.addEventListener('click', function () {
            if (typeof window.toggleWish !== 'function') return;
            var active = window.toggleWish(readProduct(card));
            btn.classList.toggle('is-active', active);
        });
    });

    page.querySelectorAll('.sp-btn-cart').forEach(function (btn) {
        btn.addEventListener('click', function () {
            if (typeof window.addToCart !== 'function') return;
            var product = readProduct(btn.closest('.sp-product-card'));
            product.qty = 1;
            window.addToCart(product);
        });
    });

    // TODO(data binding): 태그 선택은 아직 실제 검색/필터 요청과 연결되어 있지 않음, UI 토글만 동작
    page.querySelectorAll('.sp-tag-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            btn.classList.toggle('is-active');
        });
    });

})();
