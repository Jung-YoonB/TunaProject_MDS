// 메인 페이지 인터랙션 - 상품 카드의 찜/장바구니 퀵버튼.
// 찜/장바구니의 실제 저장은 static/js/common/cartWishService.js(window.addToCart/toggleWish)가
// 담당한다. 이 파일은 그 함수를 부르고 버튼 상태만 반영한다(views/searchProduct.js와 같은 패턴 -
// 카드 마크업/클래스가 동일해서 셀렉터도 그대로 맞춘다).
// 찜 초기 상태는 서버가 카드 렌더링 시점에 class="...is-active"를 직접 찍어준다
// (ProductListDTO.wished) - searchProduct.js와 동일한 이유로 여기서 localStorage로
// 다시 판단하지 않는다
(function () {

    var productList = document.getElementById('product-list');
    if (!productList) return;

    function readProduct(card) {
        return {
            productId: card.dataset.productId,
            name: card.querySelector('.product-name').textContent.trim(),
            price: parseInt(card.dataset.price, 10) || 0,
            // 장바구니 담기 전용 - 옵션 선택 UI가 없는 카드라 상세 페이지 기준 대표 옵션을 그대로 쓴다.
            popId: card.dataset.popId
        };
    }

    productList.querySelectorAll('.product-wish-toggle').forEach(function (btn) {
        var card = btn.closest('.product-card');

        btn.addEventListener('click', function () {
            if (typeof window.toggleWish !== 'function') return;
            var wasWished = btn.classList.contains('is-active');
            window.toggleWish(readProduct(card), wasWished).then(function (active) {
                // 하트 채움과 옆의 찜 개수를 같이 맞춘다(common/cartWishService.js)
                window.applyWishState(btn, wasWished, active);
            });
        });
    });

    productList.querySelectorAll('.product-cart-quick').forEach(function (btn) {
        btn.addEventListener('click', function () {
            if (typeof window.addToCart !== 'function') return;
            var product = readProduct(btn.closest('.product-card'));
            product.qty = 1;
            window.addToCart(product);
        });
    });

})();
