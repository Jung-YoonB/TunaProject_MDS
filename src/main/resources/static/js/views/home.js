// 홈 "인기 선물" 카드 렌더링 + 더보기/무한스크롤 인터랙션.
// 데이터 자체(목업 배열, 페이지 나누기)는 static/js/product/homeProductService.js가 담당하고,
// 이 파일은 그 결과를 받아 DOM에 그리는 것과 버튼/스크롤 이벤트만 다룬다.
(function () {

    var listEl = document.getElementById('product-list');
    var loadMoreBtn = document.getElementById('productLoadMore');

    if (!listEl || !loadMoreBtn || !window.HomeProductService) return;

    var PAGE_SIZE = window.HomeProductService.PAGE_SIZE;
    var offset = 0;
    var loading = false;
    var infiniteScrollArmed = false;

    function buildCard(p) {
        var card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML =
            '<div class="product-img' + (p.alt ? ' product-img-alt' : '') + '">' +
                '<span class="product-badge">BEST</span>' +
                '<button type="button" class="product-cart-quick" aria-label="장바구니 담기">' +
                    '<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                        '<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"></path>' +
                        '<path d="M3 6h18"></path>' +
                        '<path d="M16 10a4 4 0 0 1-8 0"></path>' +
                    '</svg>' +
                '</button>' +
            '</div>' +
            '<div class="product-info">' +
                '<h3 class="product-name"></h3>' +
                '<p class="product-description"></p>' +
                '<div class="product-price-row"><strong class="product-price"></strong></div>' +
                '<div class="product-meta">' +
                    '<a href="#" class="product-rating" aria-label="리뷰 보기">' +
                        '<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                            '<path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"></path>' +
                        '</svg>' +
                        '<span class="product-rating-score"></span>' +
                    '</a>' +
                    '<button type="button" class="product-wish-toggle" aria-label="찜하기">' +
                        '<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                            '<path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"></path>' +
                        '</svg>' +
                        '<span class="product-wish-count-num"></span>' +
                    '</button>' +
                '</div>' +
            '</div>';

        card.querySelector('.product-name').textContent = p.name;
        card.querySelector('.product-description').textContent = p.desc;
        card.querySelector('.product-price').textContent = p.price;
        card.querySelector('.product-rating-score').textContent = p.rating + ' (' + p.reviewCount + ')';
        card.querySelector('.product-wish-count-num').textContent = p.wishCount;
        return card;
    }

    function renderBatch(items) {
        var fragment = document.createDocumentFragment();
        items.forEach(function (p) {
            fragment.appendChild(buildCard(p));
        });
        listEl.appendChild(fragment);
    }

    function loadNext(count) {
        if (loading) return;
        loading = true;
        window.HomeProductService.fetchProducts(offset, count).then(function (items) {
            renderBatch(items);
            offset += count;
            loading = false;
        });
    }

    function isNearBottom() {
        return document.documentElement.scrollHeight - (window.scrollY + window.innerHeight) < 400;
    }

    function onScroll() {
        if (infiniteScrollArmed && isNearBottom()) {
            loadNext(PAGE_SIZE);
        }
    }

    loadMoreBtn.addEventListener('click', function () {
        loadNext(PAGE_SIZE);
        // 첫 클릭 이후로는 버튼 숨기고 스크롤로 자동 로드
        loadMoreBtn.hidden = true;
        infiniteScrollArmed = true;
        window.addEventListener('scroll', onScroll);
    });

    // 기본 노출: 한 줄에 4개 x 2줄 = 8개
    loadNext(PAGE_SIZE);

})();
