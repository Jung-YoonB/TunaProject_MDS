// 장바구니 화면 인터랙션 - 목록 렌더링, 체크박스/수량/삭제, 결제 예상 금액 표시.
// 데이터(목록 로드·저장, 배송비, 합계 계산)는 static/js/product/cartService.js가 담당한다.
(function () {

    var page = document.getElementById('cart-container');
    if (!page || !window.CartService) return;

    // 원래 인라인 스크립트였을 땐 <c:url>을 JS 안에 직접 썼는데, 외부 파일로 분리하면서
    // JSP가 data 속성으로 넘겨주는 방식으로 바꿨다(header.jsp의 data-home-url과 같은 방식).
    var PAYMENT_URL = page.dataset.paymentUrl;

    var cartControls = document.getElementById('cart-controls');
    var cartItemList = document.getElementById('cart-itemlist');
    var cartSummaryBox = document.getElementById('cart-summary-box');
    var cartAction = document.getElementById('cart-action');
    var cartEmpty = document.getElementById('cart-empty');
    var cartWarning = document.getElementById('cart-warning');
    var checkAll = document.getElementById('check-all');

    var items = window.CartService.load();

    // 다시 그릴 때 체크 상태가 날아가지 않도록 키 기준으로 들고 있는다. 처음엔 전부 선택.
    var checkedState = {};
    items.forEach(function (item) { checkedState[window.CartService.getKey(item)] = true; });

    function formatWon(n) {
        return n.toLocaleString('ko-KR') + '원';
    }

    function captureCheckedState() {
        cartItemList.querySelectorAll('.cart-item').forEach(function (row) {
            checkedState[row.dataset.cartKey] = row.querySelector('.item-checkbox').checked;
        });
    }

    function selectedKeys() {
        var keys = [];
        cartItemList.querySelectorAll('.cart-item').forEach(function (row) {
            if (row.querySelector('.item-checkbox').checked) keys.push(row.dataset.cartKey);
        });
        return keys;
    }

    function unselectedKeys() {
        var keys = [];
        cartItemList.querySelectorAll('.cart-item').forEach(function (row) {
            if (!row.querySelector('.item-checkbox').checked) keys.push(row.dataset.cartKey);
        });
        return keys;
    }

    function buildRow(item) {
        var key = window.CartService.getKey(item);
        var checked = checkedState[key] !== false;

        var row = document.createElement('article');
        row.className = 'cart-item';
        row.dataset.productId = item.productId;
        row.dataset.cartKey = key;
        row.innerHTML =
            '<input type="checkbox" class="item-checkbox"' + (checked ? ' checked' : '') + '>' +
            '<div class="item-thumbnail"></div>' +
            '<div class="item-info">' +
                '<h3 class="item-title"></h3>' +
                '<p class="item-option"></p>' +
                '<div class="item-price-info"><span class="price-final"></span></div>' +
            '</div>' +
            '<div class="item-control">' +
                '<div class="qty-control">' +
                    '<button type="button" class="btn-qty-decrease" aria-label="수량 감소">-</button>' +
                    '<input type="number" class="input-qty" min="1" readonly>' +
                    '<button type="button" class="btn-qty-increase" aria-label="수량 증가">+</button>' +
                '</div>' +
                '<button type="button" class="delete-item-btn">삭제</button>' +
            '</div>';

        // 사용자 입력에서 온 값이라 innerHTML이 아니라 textContent/value로 넣는다.
        row.querySelector('.item-title').textContent = item.name;
        row.querySelector('.item-option').textContent = item.optionName || '기본 옵션';
        row.querySelector('.price-final').textContent = formatWon(item.price);
        row.querySelector('.input-qty').value = item.qty;
        return row;
    }

    function render() {
        captureCheckedState();
        items = window.CartWishService.getCartItems();

        var isEmpty = items.length === 0;
        cartControls.hidden = isEmpty;
        cartItemList.hidden = isEmpty;
        cartSummaryBox.hidden = isEmpty;
        cartAction.hidden = isEmpty;
        cartWarning.hidden = true;
        cartEmpty.hidden = !isEmpty;
        if (isEmpty) return;

        cartItemList.innerHTML = '';
        items.forEach(function (item) { cartItemList.appendChild(buildRow(item)); });

        syncCheckAll();
        updateSummary();
    }

    function syncCheckAll() {
        var boxes = cartItemList.querySelectorAll('.item-checkbox');
        checkAll.checked = boxes.length > 0 && Array.prototype.every.call(boxes, function (b) { return b.checked; });
    }

    function updateSummary() {
        var totals = window.CartService.calcTotals(items, selectedKeys());
        document.getElementById('total-price').textContent = formatWon(totals.itemsTotal);
        document.getElementById('delivery-fee').textContent = formatWon(totals.fee);
        document.getElementById('summary-final').textContent = formatWon(totals.finalTotal);
    }

    cartItemList.addEventListener('click', function (e) {
        var row = e.target.closest('.cart-item');
        if (!row) return;
        var key = row.dataset.cartKey;

        if (e.target.classList.contains('btn-qty-increase') || e.target.classList.contains('btn-qty-decrease')) {
            var delta = e.target.classList.contains('btn-qty-increase') ? 1 : -1;
            items = window.CartService.changeQty(items, key, delta);
            window.CartService.save(items);
            render();
        }

        if (e.target.classList.contains('delete-item-btn')) {
            items = window.CartService.removeByKeys(items, [key]);
            window.CartService.save(items);
            render();
        }
    });

    cartItemList.addEventListener('change', function (e) {
        if (e.target.classList.contains('item-checkbox')) {
            syncCheckAll();
            updateSummary();
        }
    });

    checkAll.addEventListener('change', function () {
        cartItemList.querySelectorAll('.item-checkbox').forEach(function (b) { b.checked = checkAll.checked; });
        updateSummary();
    });

    // "선택상품 삭제" - 체크 안 된 것만 남긴다.
    document.getElementById('delete-btn').addEventListener('click', function () {
        items = window.CartService.keepByKeys(items, unselectedKeys());
        window.CartService.save(items);
        render();
    });

    document.getElementById('btn-checkout').addEventListener('click', function () {
        var anyChecked = selectedKeys().length > 0;
        cartWarning.hidden = anyChecked;
        if (anyChecked) {
            window.location.href = PAYMENT_URL;
        }
    });

    render();

})();
