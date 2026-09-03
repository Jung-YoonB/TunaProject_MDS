// 상품 검색 결과 페이지 인터랙션 - 카드의 찜/장바구니 버튼과 태그 필터 토글.
//
// 찜/장바구니의 실제 저장은 static/js/common/cartWishService.js(header.jsp가 전 페이지에
// 로드)가 window.toggleWish / window.addToCart로 노출하는 함수가 담당한다.
// 이 파일은 그 함수를 부르고 버튼 상태만 반영한다.
//
// 찜 초기 상태(하트 채움 여부)는 이제 서버가 카드 렌더링 시점에 실제 WISH 데이터 기준으로
// class="...is-active"를 직접 찍어준다(ProductListDTO.wished, product.xml getList) - 예전엔
// 여기서 localStorage 캐시(window.isWished)로 판단해서, 로그아웃 후 재로그인하면 캐시가 비어
// 이미 찜한 상품도 빈 하트로 보이던 문제가 있었다 클릭 시 방향(추가/해제)도
// 이 서버 렌더링 상태(버튼의 현재 is-active 클래스)를 그대로 넘긴다.
(function () {

    var page = document.querySelector('.search-result-page');
    if (!page) return;

    // 카드 DOM에서 찜/장바구니에 넘길 상품 정보를 읽어낸다. 가격은 홈 카드와 통일하며 화면에서
    // 안 보이게 됐고(2026-09-02), card의 data-price 속성으로만 갖고 있는다.
    function readProduct(card) {
        return {
            productId: card.dataset.productId,
            name: card.querySelector('.sp-product-name').textContent.trim(),
            price: parseInt(card.dataset.price, 10) || 0,
            // 장바구니 담기 전용 - 옵션 선택 UI가 없는 카드라 상세 페이지 기준 대표 옵션을 그대로 쓴다.
            popId: card.dataset.popId
        };
    }

    page.querySelectorAll('.sp-btn-wishlist').forEach(function (btn) {
        var card = btn.closest('.sp-product-card');

        btn.addEventListener('click', function () {
            if (typeof window.toggleWish !== 'function') return;
            // toggleWish는 이제 실제 서버(WishController)를 호출하고 결과(Promise<boolean>)를 준다
            // (비로그인 상태에서도 로컬에만 담기던 것 조치). 방향은 버튼의 현재
            // is-active(서버가 렌더링 시점에 채운 실제 상태)로 판단한다.
            var wasWished = btn.classList.contains('is-active');
            window.toggleWish(readProduct(card), wasWished).then(function (active) {
                // 하트 채움과 옆의 찜 개수를 같이 맞춘다(common/cartWishService.js)
                window.applyWishState(btn, wasWished, active);
            });
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
