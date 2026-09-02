// 찜 화면 인터랙션 - 목록 렌더링, 정렬 탭, 찜 해제, 선택 삭제, 장바구니 담기.
// 데이터(목록 로드·저장, 정렬 규칙)는 static/js/product/wishService.js가 담당한다.
(function () {

    var page = document.getElementById('wishlist-container');
    if (!page || !window.WishService) return;

    // 원래 인라인 스크립트였을 땐 <c:url>을 JS 안에 직접 썼는데, 외부 파일로 분리하면서
    // JSP가 data 속성으로 넘겨주는 방식으로 바꿨다(header.jsp의 data-home-url과 같은 방식).
    var DETAIL_BASE_URL = page.dataset.detailBaseUrl;
    var REMOVE_URL = page.dataset.removeUrl;

    var controls = document.getElementById('wishlist-controls');
    var checkAll = document.getElementById('wish-check-all');
    var filterBar = document.getElementById('wishlist-filter');
    var grid = document.getElementById('wish-product-grid');
    var emptyBlock = document.getElementById('wishlist-empty');
    var totalCount = document.getElementById('wish-total-count');
    var sortOptions = document.getElementById('wish-short-options');

    var items = window.WishService.load();
    var currentSort = 'popular';

    // 다시 그릴 때 체크 상태가 날아가지 않도록 productId 기준으로 들고 있는다.
    var checkedState = {};

    function captureCheckedState() {
        grid.querySelectorAll('.product-card').forEach(function (card) {
            checkedState[card.dataset.productId] = card.querySelector('.item-checkbox').checked;
        });
    }

    function syncCheckAll() {
        var boxes = grid.querySelectorAll('.item-checkbox');
        checkAll.checked = boxes.length > 0 && Array.prototype.every.call(boxes, function (b) { return b.checked; });
    }

    // 카드 구조/아이콘을 홈페이지 상품 카드(static/js/views/home.js의 buildCard)와
    // 통일함(2026-09-02): .product-img+.product-cart-quick, .product-meta(.product-rating+
    // .product-wish-toggle). 찜 화면 전용 기능(선택 체크박스, "장바구니 담기"였던 걸 아이콘으로
    // 통합, 찜 아이콘은 토글이 아니라 항상 채워진 채로 눌러서 찜 해제)은 그 위에 그대로 얹는다.
    // btn-wish-toggle/btn-cart 클래스는 아래 grid 클릭 위임 로직이 그대로 쓰는 훅이라 유지.
    function buildCard(item) {
        var checked = checkedState[item.productId] === true;
        var card = document.createElement('article');
        card.className = 'product-card';
        card.dataset.productId = item.productId;
        card.dataset.price = item.price;
        card.innerHTML =
            '<div class="product-img">' +
                '<input type="checkbox" class="item-checkbox"' + (checked ? ' checked' : '') + '>' +
                '<a class="product-link" href="' + DETAIL_BASE_URL + '/' + encodeURIComponent(item.productId) + '"></a>' +
                '<button type="button" class="product-cart-quick btn-cart" aria-label="장바구니 담기">' +
                    '<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                        '<circle cx="9" cy="21" r="1"></circle>' +
                        '<circle cx="20" cy="21" r="1"></circle>' +
                        '<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>' +
                    '</svg>' +
                '</button>' +
            '</div>' +
            '<div class="product-info">' +
                '<a class="product-link" href="' + DETAIL_BASE_URL + '/' + encodeURIComponent(item.productId) + '">' +
                    '<h2 class="product-name"></h2>' +
                '</a>' +
                '<p class="product-option"></p>' +
                '<p class="product-description"></p>' +
                '<div class="product-meta">' +
                    '<a href="#" class="product-rating" aria-label="리뷰 보기">' +
                        '<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                            '<path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"></path>' +
                        '</svg>' +
                        '<span class="product-rating-score"></span>' +
                    '</a>' +
                    '<button type="button" class="product-wish-toggle btn-wish-toggle is-active" aria-label="찜 해제">' +
                        '<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                            '<path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"></path>' +
                        '</svg>' +
                    '</button>' +
                '</div>' +
            '</div>';

        // 상품명은 사용자 데이터라 textContent로 넣는다.
        card.querySelector('.product-name').textContent = item.name;
        // 대표 이미지도 서버에서 온 값이라 innerHTML 대신 DOM으로 붙인다.
        // 등록된 대표 이미지가 없는 상품이면 CSS 기본 배경이 그대로 보인다.
        if (item.imageUrl) {
            var img = document.createElement('img');
            img.src = item.imageUrl;
            img.alt = item.name;
            card.querySelector('.product-img .product-link').appendChild(img);
        }
        // optionName은 cartService.js와 동일하게 실제 연동 전까지 기본값으로 대체(cart.js의 item-option과 같은 패턴).
        card.querySelector('.product-option').textContent = item.optionName || '기본 옵션';
        // item.rating/reviewCount는 WishService의 예시 데이터에만 있고, 실제 toggleWish()로
        // 담긴 항목(cartWishService.js)에는 없어 렌더링이 통째로 죽는 기존 버그가 있었음 - 방어
        card.querySelector('.product-rating-score').textContent = (item.rating || 0).toFixed(1) + ' (' + (item.reviewCount || 0) + ')';

        return card;
    }

    function render() {
        captureCheckedState();
        items = window.CartWishService.getWishList();
        var isEmpty = items.length === 0;

        controls.hidden = isEmpty;
        filterBar.hidden = isEmpty;
        grid.hidden = isEmpty;
        emptyBlock.hidden = !isEmpty;
        if (isEmpty) return;

        totalCount.textContent = '찜한 상품 ' + items.length + '개';

        grid.innerHTML = '';
        window.WishService.sortItems(items, currentSort).forEach(function (item) {
            grid.appendChild(buildCard(item));
        });

        syncCheckAll();
    }

    grid.addEventListener('click', function (e) {
        var card = e.target.closest('.product-card');
        if (!card) return;
        var productId = card.dataset.productId;
        var item = items.filter(function (i) { return i.productId === productId; })[0];
        if (!item) return;

        // 찜 해제 - 카드가 사라지는 애니메이션(.is-removing)이 끝난 뒤 서버에 반영한다.
        // 로컬만 지우면 새로고침했을 때 되살아나므로, 서버 반영 후 다시 읽어온다.
        if (e.target.closest('.btn-wish-toggle')) {
            card.classList.add('is-removing');
            window.setTimeout(function () {
                window.WishService.removeOnServer([productId], REMOVE_URL)
                    .then(function () { window.location.reload(); });
            }, 300);
        }

        if (e.target.closest('.btn-cart')) {
            if (typeof window.addToCart === 'function') {
                window.addToCart({ productId: item.productId, name: item.name, price: item.price, qty: 1 });
            }
        }
    });

    grid.addEventListener('change', function (e) {
        if (e.target.classList.contains('item-checkbox')) {
            syncCheckAll();
        }
    });

    checkAll.addEventListener('change', function () {
        grid.querySelectorAll('.item-checkbox').forEach(function (b) { b.checked = checkAll.checked; });
    });

    // "선택 상품 삭제" - 체크된 것을 서버에서 지운 뒤 목록을 다시 읽어온다.
    document.getElementById('wish-delete-btn').addEventListener('click', function () {
        var removeIds = [];
        grid.querySelectorAll('.product-card').forEach(function (card) {
            if (card.querySelector('.item-checkbox').checked) removeIds.push(card.dataset.productId);
        });
        if (removeIds.length === 0) return;
        window.WishService.removeOnServer(removeIds, REMOVE_URL)
            .then(function () { window.location.reload(); });
    });

    sortOptions.addEventListener('click', function (e) {
        var option = e.target.closest('li[data-sort]');
        if (!option) return;
        currentSort = option.dataset.sort;
        sortOptions.querySelectorAll('li').forEach(function (li) { li.classList.remove('is-active'); });
        option.classList.add('is-active');
        render();
    });

    render();

})();
