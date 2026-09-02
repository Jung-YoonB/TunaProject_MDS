// 찜 화면 인터랙션 - 목록 렌더링, 정렬 탭, 페이징, 선택 모드, 찜 해제, 선택 삭제, 장바구니 담기.
// 데이터(목록 로드·저장, 정렬 규칙)는 static/js/product/wishService.js가 담당한다.
(function () {

    var page = document.getElementById('wishlist-container');
    if (!page || !window.WishService) return;

    // 원래 인라인 스크립트였을 땐 <c:url>을 JS 안에 직접 썼는데, 외부 파일로 분리하면서
    // JSP가 data 속성으로 넘겨주는 방식으로 바꿨다(header.jsp의 data-home-url과 같은 방식).
    var DETAIL_BASE_URL = page.dataset.detailBaseUrl;
    var REMOVE_URL = page.dataset.removeUrl;

    var PAGE_SIZE = 12;

    var controls = document.getElementById('wishlist-controls');
    var checkAll = document.getElementById('wish-check-all');
    var filterBar = document.getElementById('wishlist-filter');
    var grid = document.getElementById('wish-product-grid');
    var emptyBlock = document.getElementById('wishlist-empty');
    var totalCount = document.getElementById('wish-total-count');
    var sortOptions = document.getElementById('wish-short-options');
    var selectionControls = document.getElementById('wishSelectionControls');
    var deleteBtn = document.getElementById('wish-delete-btn');
    var cartBtn = document.getElementById('wish-cart-btn');
    var toggleSelectButton = document.getElementById('toggleWishSelectButton');
    var pagination = document.getElementById('wish-pagination');

    var items = window.WishService.load();
    var currentSort = 'popular';
    var currentPage = 1;

    // 체크 상태는 항상 checkedState(productId 기준)를 단일 진실로 둔다 - 페이징 때문에 DOM에는
    // 현재 페이지 카드만 있어서, "전체 선택"/선택 삭제가 페이지를 넘겨도 정확히 동작하려면
    // 전체 목록 기준으로 계산해야 한다. 찜 화면 체크박스는 삭제 전용이라 기본값은 전부 미선택.
    var checkedState = {};

    function isChecked(item) {
        return checkedState[item.productId] === true;
    }

    function syncCheckAll() {
        checkAll.checked = items.length > 0 && items.every(isChecked);
    }

    /* =========================
       상품 선택 모드 (admin/admincouponView.jsp와 동일한 로직) - 평소엔 체크박스를 숨겨두고
       "상품 선택"을 눌렀을 때만 노출한다.
    ========================= */

    function enterSelectMode() {
        grid.classList.add('selecting');
        selectionControls.hidden = false;
        deleteBtn.hidden = false;
        cartBtn.hidden = false;
        toggleSelectButton.textContent = '선택 취소';
        toggleSelectButton.classList.add('is-selecting');
    }

    function exitSelectMode() {
        grid.classList.remove('selecting');
        selectionControls.hidden = true;
        deleteBtn.hidden = true;
        cartBtn.hidden = true;
        toggleSelectButton.textContent = '상품 선택';
        toggleSelectButton.classList.remove('is-selecting');

        // 나가면 선택 상태를 전부 지운다(admin과 동일) - 찜 화면 체크박스는 삭제 전용이라
        // cart.jsp처럼 "기본 전체선택"으로 되돌릴 이유가 없다.
        checkedState = {};
        grid.querySelectorAll('.item-checkbox').forEach(function (cb) { cb.checked = false; });
        syncCheckAll();
    }

    toggleSelectButton.addEventListener('click', function () {
        if (grid.classList.contains('selecting')) {
            exitSelectMode();
        } else {
            enterSelectMode();
        }
    });

    // 카드 구조/아이콘을 홈페이지 상품 카드(static/js/views/home.js의 buildCard)와
    // 통일함(2026-09-02): .product-img+.product-cart-quick, .product-meta(.product-rating+
    // .product-wish-toggle). 찜 화면 전용 기능(선택 체크박스, "장바구니 담기"였던 걸 아이콘으로
    // 통합, 찜 아이콘은 토글이 아니라 항상 채워진 채로 눌러서 찜 해제)은 그 위에 그대로 얹는다.
    // btn-wish-toggle/btn-cart 클래스는 아래 grid 클릭 위임 로직이 그대로 쓰는 훅이라 유지.
    function buildCard(item) {
        var checked = isChecked(item);
        var card = document.createElement('article');
        card.className = 'product-card';
        card.dataset.productId = item.productId;
        card.dataset.price = item.price;
        // 장바구니 담기 전용 - 옵션 선택 UI가 없는 카드라 상세 페이지 기준 대표 옵션을 그대로 쓴다.
        card.dataset.popId = item.popId;
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
                    '<a href="' + DETAIL_BASE_URL + '/' + encodeURIComponent(item.productId) + '#review" class="product-rating" aria-label="리뷰 보기">' +
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

    // 페이지 번호 nav - 검색 결과 화면(searchProduct.jsp)과 같은 .sp-pagination 스타일을 그대로
    // 쓴다. 서버 페이지가 아니라 이미 다 불러온 목록을 화면에서만 자르는 것이라 <a href>가 아니라
    // <button>으로 만든다.
    function renderPagination(totalPages) {
        pagination.innerHTML = '';
        if (totalPages <= 1) {
            pagination.hidden = true;
            return;
        }
        pagination.hidden = false;

        if (currentPage > 1) {
            var prev = document.createElement('button');
            prev.type = 'button';
            prev.className = 'sp-btn-prev';
            prev.textContent = '이전';
            prev.addEventListener('click', function () { currentPage--; render(); });
            pagination.appendChild(prev);
        }

        var ol = document.createElement('ol');
        for (var p = 1; p <= totalPages; p++) {
            (function (p) {
                var li = document.createElement('li');
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'sp-page-btn' + (p === currentPage ? ' is-current' : '');
                if (p === currentPage) btn.setAttribute('aria-current', 'page');
                btn.textContent = p;
                btn.addEventListener('click', function () { currentPage = p; render(); });
                li.appendChild(btn);
                ol.appendChild(li);
            })(p);
        }
        pagination.appendChild(ol);

        if (currentPage < totalPages) {
            var next = document.createElement('button');
            next.type = 'button';
            next.className = 'sp-btn-next';
            next.textContent = '다음';
            next.addEventListener('click', function () { currentPage++; render(); });
            pagination.appendChild(next);
        }
    }

    function render() {
        items = window.CartWishService.getWishList();
        var isEmpty = items.length === 0;

        controls.hidden = isEmpty;
        filterBar.hidden = isEmpty;
        grid.hidden = isEmpty;
        emptyBlock.hidden = !isEmpty;
        pagination.hidden = isEmpty;
        if (isEmpty) return;

        totalCount.textContent = '찜한 상품 ' + items.length + '개';

        var sorted = window.WishService.sortItems(items, currentSort);
        var totalPages = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
        currentPage = Math.min(Math.max(currentPage, 1), totalPages);
        var start = (currentPage - 1) * PAGE_SIZE;
        var pageItems = sorted.slice(start, start + PAGE_SIZE);

        grid.innerHTML = '';
        pageItems.forEach(function (item) {
            grid.appendChild(buildCard(item));
        });

        renderPagination(totalPages);
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
                window.addToCart({ productId: item.productId, name: item.name, price: item.price, popId: item.popId, qty: 1 });
            }
        }
    });

    grid.addEventListener('change', function (e) {
        if (e.target.classList.contains('item-checkbox')) {
            var card = e.target.closest('.product-card');
            checkedState[card.dataset.productId] = e.target.checked;
            syncCheckAll();
        }
    });

    checkAll.addEventListener('change', function () {
        items.forEach(function (item) { checkedState[item.productId] = checkAll.checked; });
        grid.querySelectorAll('.item-checkbox').forEach(function (b) { b.checked = checkAll.checked; });
    });

    // "선택 상품 삭제" - 체크된 것(전체 목록 기준)을 서버에서 지운 뒤 목록을 다시 읽어온다.
    deleteBtn.addEventListener('click', function () {
        var removeIds = items.filter(isChecked).map(function (i) { return i.productId; });
        if (removeIds.length === 0) return;
        window.WishService.removeOnServer(removeIds, REMOVE_URL)
            .then(function () { window.location.reload(); });
    });

    // "선택 상품 장바구니 담기" - 카드 낱개 퀵버튼(.btn-cart)과 같은 백엔드를 여러 건 한 번에 부른다.
    // 옵션 선택 UI가 없는 카드라 대표 옵션(popId)을 그대로 쓰는 것도 낱개 버튼과 동일.
    cartBtn.addEventListener('click', function () {
        var selected = items.filter(isChecked);
        if (selected.length === 0) return;

        var withPopId = selected.filter(function (i) { return i.popId; });
        var withoutPopId = selected.filter(function (i) { return !i.popId; });

        if (withPopId.length === 0) {
            alert('선택한 상품의 옵션 정보를 불러오지 못해 장바구니에 담을 수 없습니다.');
            return;
        }

        Promise.all(withPopId.map(function (i) {
            return window.addToCart(
                { productId: i.productId, name: i.name, price: i.price, popId: i.popId, qty: 1 },
                true
            );
        })).then(function (results) {
            var successCount = results.filter(Boolean).length;
            var msg = successCount + '개 상품을 장바구니에 담았습니다.';
            if (withoutPopId.length > 0) {
                msg += ' (' + withoutPopId.length + '개는 옵션 정보가 없어 제외됨)';
            }
            alert(msg);
        });
    });

    sortOptions.addEventListener('click', function (e) {
        var option = e.target.closest('li[data-sort]');
        if (!option) return;
        currentSort = option.dataset.sort;
        currentPage = 1;
        sortOptions.querySelectorAll('li').forEach(function (li) { li.classList.remove('is-active'); });
        option.classList.add('is-active');
        render();
    });

    render();

})();
