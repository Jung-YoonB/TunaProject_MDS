// 찜 화면 인터랙션 - 목록 렌더링, 정렬 탭, 찜 해제, 선택 삭제, 장바구니 담기.
// 데이터(목록 로드·저장, 정렬 규칙)는 static/js/product/wishService.js가 담당한다.
(function () {

    var page = document.getElementById('wishlist-container');
    if (!page || !window.WishService) return;

    // 원래 인라인 스크립트였을 땐 <c:url>을 JS 안에 직접 썼는데, 외부 파일로 분리하면서
    // JSP가 data 속성으로 넘겨주는 방식으로 바꿨다(header.jsp의 data-home-url과 같은 방식).
    var DETAIL_BASE_URL = page.dataset.detailBaseUrl;

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

    function buildCard(item) {
        var checked = checkedState[item.productId] === true;
        var card = document.createElement('article');
        card.className = 'product-card';
        card.dataset.productId = item.productId;
        card.innerHTML =
            '<input type="checkbox" class="item-checkbox"' + (checked ? ' checked' : '') + '>' +
            '<a class="product-link" href="' + DETAIL_BASE_URL + '/' + encodeURIComponent(item.productId) + '">' +
                '<div class="product-thumbnail"></div>' +
                '<div class="product-info">' +
                    '<h2 class="product-name"></h2>' +
                    '<p class="product-rating"></p>' +
                '</div>' +
            '</a>' +
            '<button type="button" class="btn-wish-toggle is-active" aria-label="찜 해제">' +
                '<svg class="wish-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                    '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>' +
                '</svg>' +
            '</button>' +
            '<div class="product-actions">' +
                '<button type="button" class="btn-cart">장바구니 담기</button>' +
            '</div>';

        // 상품명은 사용자 데이터라 textContent로 넣는다.
        card.querySelector('.product-name').textContent = item.name;

        // 별은 원래 유니코드 ★ 글리프였으나 환경에 따라 컬러 이모지로 렌더링돼 CSS color를
        // 무시하는 문제가 있어 SVG로 통일함(홈 카드와 같은 path - HANDOFF 3-39-2 참고).
        var rating = card.querySelector('.product-rating');
        rating.innerHTML =
            '<svg class="icon-star icon-inline" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
                '<path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"></path>' +
            '</svg> ' +
            '<span class="rating-score"></span> ' +
            '<span class="rating-count"></span>';
        rating.querySelector('.rating-score').textContent = item.rating.toFixed(1);
        rating.querySelector('.rating-count').textContent = '(' + item.reviewCount + ')';

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

        // 찜 해제 - 카드가 사라지는 애니메이션(.is-removing)이 끝난 뒤 실제로 지운다.
        if (e.target.closest('.btn-wish-toggle')) {
            card.classList.add('is-removing');
            window.setTimeout(function () {
                items = window.WishService.removeById(items, productId);
                window.WishService.save(items);
                render();
            }, 300);
        }

        if (e.target.classList.contains('btn-cart')) {
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

    // "선택 상품 삭제" - 체크 안 된 것만 남긴다.
    document.getElementById('wish-delete-btn').addEventListener('click', function () {
        var keepIds = [];
        grid.querySelectorAll('.product-card').forEach(function (card) {
            if (!card.querySelector('.item-checkbox').checked) keepIds.push(card.dataset.productId);
        });
        items = window.WishService.keepByIds(items, keepIds);
        window.WishService.save(items);
        render();
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
