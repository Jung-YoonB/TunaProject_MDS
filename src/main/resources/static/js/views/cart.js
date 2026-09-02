// 장바구니 화면 인터랙션 - 목록 렌더링, 선택 모드, 수량/삭제, 페이징, 결제 예상 금액 표시.
// 데이터(목록 로드, 배송비, 합계 계산, 서버 삭제/수량변경 호출)는 static/js/product/cartService.js가 담당한다.
(function () {

    var page = document.getElementById('cart-container');
    if (!page || !window.CartService) return;

    // 원래 인라인 스크립트였을 땐 <c:url>을 JS 안에 직접 썼는데, 외부 파일로 분리하면서
    // JSP가 data 속성으로 넘겨주는 방식으로 바꿨다(header.jsp의 data-home-url과 같은 방식).
    var PAYMENT_URL = page.dataset.paymentUrl;
    var IMAGE_PATH = page.dataset.imagePath;
    var REMOVE_URL = page.dataset.removeUrl;
    var UPDATE_QTY_URL = page.dataset.updateQtyUrl;

    var PAGE_SIZE = 10;

    var cartControls = document.getElementById('cart-controls');
    var cartItemList = document.getElementById('cart-itemlist');
    var cartSummaryBox = document.getElementById('cart-summary-box');
    var cartAction = document.getElementById('cart-action');
    var cartEmpty = document.getElementById('cart-empty');
    var cartWarning = document.getElementById('cart-warning');
    var checkAll = document.getElementById('check-all');
    var selectionControls = document.getElementById('cartSelectionControls');
    var deleteBtn = document.getElementById('delete-btn');
    var toggleSelectButton = document.getElementById('toggleCartSelectButton');
    var pagination = document.getElementById('cart-pagination');

    var items = window.CartService.load();
    var currentPage = 1;

    // 선택 상태는 항상 checkedState(키 기준)를 단일 진실로 둔다 - 페이징 때문에 DOM에는 현재
    // 페이지 행만 있어서, "체크박스가 실제 화면에 보이는지"와 무관하게 전체 목록 기준으로 선택
    // 여부를 계산해야 "전체 선택"/합계/주문하기가 페이지를 넘겨도 정확하다.
    // 처음엔 전부 선택(체크박스는 평소엔 화면에 안 보이지만 "전부 선택된" 상태여야 "주문하기"가
    // 기본적으로 장바구니 전체를 담아 보낸다 - 상품 선택 모드는 일부를 빼거나 지울 때만 쓰면 된다).
    var checkedState = {};
    items.forEach(function (item) { checkedState[window.CartService.getKey(item)] = true; });

    function isChecked(item) {
        return checkedState[window.CartService.getKey(item)] !== false;
    }

    function formatWon(n) {
        return n.toLocaleString('ko-KR') + '원';
    }

    function selectedKeys() {
        return items.filter(isChecked).map(window.CartService.getKey);
    }

	function buildRow(item) {
	    var key = window.CartService.getKey(item);
	    var checked = isChecked(item);

	    var row = document.createElement('article');
	    row.className = 'cart-item';
	    row.dataset.cartId = item.cartId;
	    row.dataset.cartKey = key;
	    row.dataset.popId = item.popId;

	    row.innerHTML =
	        '<input type="checkbox" class="item-checkbox"' +
	            (checked ? ' checked' : '') + '>' +

	        '<div class="item-thumbnail">' +
	            (item.titleImage
	                ? '<img src="' + IMAGE_PATH + item.titleImage +
	                  '" alt="' + item.productTitle + '">'
	                : '<span>이미지 없음</span>') +
	        '</div>' +

	        '<div class="item-info">' +
	            '<h3 class="item-title"></h3>' +
	            '<p class="item-option"></p>' +
	            '<div class="item-price-info">' +
	                '<span class="price-final"></span>' +
	            '</div>' +
	        '</div>' +

	        '<div class="item-control">' +
	            '<div class="qty-control">' +
	                '<button type="button" class="btn-qty-decrease" aria-label="수량 감소">-</button>' +
	                '<input type="number" class="input-qty" min="1" readonly>' +
	                '<button type="button" class="btn-qty-increase" aria-label="수량 증가">+</button>' +
	            '</div>' +
	            '<button type="button" class="delete-item-btn">삭제</button>' +
	        '</div>';

	    row.querySelector('.item-title').textContent =
	        item.productTitle;

	    row.querySelector('.item-option').textContent =
	        item.optionName || '기본 옵션';

	    row.querySelector('.price-final').textContent =
	        formatWon(item.optionPrice * item.qty);

	    row.querySelector('.input-qty').value =
	        item.qty;

	    return row;
	}

    // 페이지 번호 nav - 검색 결과 화면(searchProduct.jsp)과 같은 .sp-pagination 스타일을 그대로
    // 쓴다. 서버 페이지가 아니라 이미 다 불러온 목록을 화면에서만 자르는 것이라 <a href>가 아니라
    // <button>으로 만든다(페이지 전체 이동이 아니므로 href="#" 같은 죽은 링크를 만들 이유가 없다).
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
        items = window.CartService.load();

        var isEmpty = items.length === 0;
        cartControls.hidden = isEmpty;
        cartItemList.hidden = isEmpty;
        cartSummaryBox.hidden = isEmpty;
        cartAction.hidden = isEmpty;
        cartWarning.hidden = true;
        cartEmpty.hidden = !isEmpty;
        pagination.hidden = isEmpty;
        if (isEmpty) return;

        var totalPages = Math.max(1, Math.ceil(items.length / PAGE_SIZE));
        currentPage = Math.min(Math.max(currentPage, 1), totalPages);
        var start = (currentPage - 1) * PAGE_SIZE;
        var pageItems = items.slice(start, start + PAGE_SIZE);

        cartItemList.innerHTML = '';
        pageItems.forEach(function (item) { cartItemList.appendChild(buildRow(item)); });

        renderPagination(totalPages);
        syncCheckAll();
        updateSummary();
    }

    // "전체 선택"은 페이지 안이 아니라 장바구니 전체 기준이다 - 다른 페이지에 있는 항목도 같이 켜고 끈다.
    function syncCheckAll() {
        checkAll.checked = items.length > 0 && items.every(isChecked);
    }

    function updateSummary() {
        var totals = window.CartService.calcTotals(items, selectedKeys());
        document.getElementById('total-price').textContent = formatWon(totals.itemsTotal);
        document.getElementById('delivery-fee').textContent = formatWon(totals.fee);
        document.getElementById('summary-final').textContent = formatWon(totals.finalTotal);
    }

    /* =========================
       상품 선택 모드 (admin/admincouponView.jsp와 동일한 로직) - 평소엔 체크박스를 숨겨두고
       "상품 선택"을 눌렀을 때만 노출한다.
    ========================= */

    function enterSelectMode() {
        cartItemList.classList.add('selecting');
        selectionControls.hidden = false;
        deleteBtn.hidden = false;
        toggleSelectButton.textContent = '선택 취소';
        toggleSelectButton.classList.add('is-selecting');
    }

    function exitSelectMode() {
        cartItemList.classList.remove('selecting');
        selectionControls.hidden = true;
        deleteBtn.hidden = true;
        toggleSelectButton.textContent = '상품 선택';
        toggleSelectButton.classList.remove('is-selecting');

        // 선택 모드에서 무엇을 체크/해제했든, 나가면 "전체 선택"으로 되돌린다 - 그래야 선택 모드를
        // 안 쓰는 평소 상태에서 "주문하기"가 장바구니 전체를 그대로 담아 보낸다.
        items.forEach(function (item) { checkedState[window.CartService.getKey(item)] = true; });
        cartItemList.querySelectorAll('.item-checkbox').forEach(function (cb) { cb.checked = true; });
        syncCheckAll();
        updateSummary();
    }

    toggleSelectButton.addEventListener('click', function () {
        if (cartItemList.classList.contains('selecting')) {
            exitSelectMode();
        } else {
            enterSelectMode();
        }
    });

    cartItemList.addEventListener('click', function (e) {
        var row = e.target.closest('.cart-item');
        if (!row) return;
        var popId = row.dataset.popId;

        if (e.target.classList.contains('btn-qty-increase') || e.target.classList.contains('btn-qty-decrease')) {
            var qtyInput = row.querySelector('.input-qty');
            var oldQty = parseInt(qtyInput.value, 10) || 1;
            var newQty = Math.max(1, oldQty + (e.target.classList.contains('btn-qty-increase') ? 1 : -1));

            if (newQty === oldQty) return;

            window.CartService.updateQtyOnServer(popId, newQty, UPDATE_QTY_URL).then(function (ok) {
                if (!ok) {
                    alert('수량 변경에 실패했습니다.');
                    return;
                }
                var item = items.filter(function (i) { return String(i.popId) === String(popId); })[0];
                if (item) item.qty = newQty;
                qtyInput.value = newQty;
                var optionPrice = item ? item.optionPrice : 0;
                row.querySelector('.price-final').textContent = formatWon(optionPrice * newQty);
                updateSummary();
            });
        }

        if (e.target.classList.contains('delete-item-btn')) {
            window.CartService.removeFromServer([popId], REMOVE_URL).then(function () {
                window.location.reload();
            });
        }
    });

    cartItemList.addEventListener('change', function (e) {
        if (e.target.classList.contains('item-checkbox')) {
            var row = e.target.closest('.cart-item');
            checkedState[row.dataset.cartKey] = e.target.checked;
            syncCheckAll();
            updateSummary();
        }
    });

    checkAll.addEventListener('change', function () {
        items.forEach(function (item) { checkedState[window.CartService.getKey(item)] = checkAll.checked; });
        cartItemList.querySelectorAll('.item-checkbox').forEach(function (b) { b.checked = checkAll.checked; });
        updateSummary();
    });

    // "선택상품 삭제" - 체크된 것(전체 목록 기준)을 서버에서 지운 뒤 새로고침해서 서버 상태를 다시 읽는다.
    deleteBtn.addEventListener('click', function () {
        var popIds = items.filter(isChecked).map(function (i) { return i.popId; });
        if (popIds.length === 0) return;

        window.CartService.removeFromServer(popIds, REMOVE_URL).then(function () {
            window.location.reload();
        });
    });

	document.getElementById('btn-checkout').addEventListener('click', function () {
	    var keys = selectedKeys();

	    if (keys.length === 0) {
	        cartWarning.hidden = false;
	        return;
	    }

	    cartWarning.hidden = true;

	    var form = document.createElement('form');
	    form.method = 'POST';
	    form.action = PAYMENT_URL;

	    items.forEach(function (item) {
	        var key = window.CartService.getKey(item);

	        if (keys.indexOf(key) !== -1) {
	            var input = document.createElement('input');

	            input.type = 'hidden';
	            input.name = 'cartId';
	            input.value = item.cartId;

	            form.appendChild(input);
	        }
	    });

	    document.body.appendChild(form);
	    form.submit();
	});


    render();

})();
