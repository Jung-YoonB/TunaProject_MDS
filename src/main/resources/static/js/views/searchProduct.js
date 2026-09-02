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

    // 카드 DOM에서 찜/장바구니에 넘길 상품 정보를 읽어낸다. 가격은 홈 카드와 통일하며 화면에서
    // 안 보이게 됐고(2026-09-02), card의 data-price 속성으로만 갖고 있는다.
    function readProduct(card) {
        return {
            productId: card.dataset.productId,
            name: card.querySelector('.sp-product-name').textContent.trim(),
            price: parseInt(card.dataset.price, 10) || 0
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

    // 태그 필터 - 중복 선택이라 카테고리 칩(서버 링크)과 달리 여기서 주소를 조립한다.
    // 켜져 있는 태그를 전부 모아 tag 파라미터 여러 개로 보내면 SearchDTO.tag(List<Long>)로 바인딩된다.
    // 태그를 바꾸면 결과 개수가 달라지므로 page는 붙이지 않는다(항상 1페이지부터).
    var SEARCH_URL = page.dataset.searchUrl;
    var tagButtons = page.querySelectorAll('.sp-tag-btn');

    if (tagButtons.length > 0) {
        // 새로고침해도 선택이 유지되도록, 주소창에 실려온 tag 값으로 켜진 상태를 복원한다.
        var currentParams = new URLSearchParams(window.location.search);
        var selectedTags = currentParams.getAll('tag');

        tagButtons.forEach(function (btn) {
            if (selectedTags.indexOf(btn.dataset.tagId) !== -1) {
                btn.classList.add('is-active');
            }

            btn.addEventListener('click', function () {
                btn.classList.toggle('is-active');

                var params = new URLSearchParams();
                var keyword = currentParams.get('keyword');
                if (keyword) params.set('keyword', keyword);
                var category = currentParams.get('category');
                if (category) params.set('category', category);

                page.querySelectorAll('.sp-tag-btn.is-active').forEach(function (active) {
                    params.append('tag', active.dataset.tagId);
                });

                window.location.href = SEARCH_URL + '?' + params.toString();
            });
        });
    }

})();
