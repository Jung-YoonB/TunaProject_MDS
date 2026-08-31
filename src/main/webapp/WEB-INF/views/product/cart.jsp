<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="cart-container" id="cart-container">
	<h2 class="page-title">장바구니</h2>

	<div class="cart-controls" id="cart-controls">
		<label class="checkbox-label">
			<input type="checkbox" id="check-all">
			<span>전체 선택</span>
		</label>
		<button type="button" id="delete-btn">선택상품 삭제</button>
	</div>

	<section class="cart-itemlist" id="cart-itemlist" aria-label="장바구니 상품 목록"></section>

	<section class="cart-summary-box" id="cart-summary-box">
		<h4>결제 예상 금액</h4>
		<div class="summary-detail">
			<div class="summary-row">
				<span>상품 금액</span>
				<span id="total-price">0원</span>
			</div>
			<div class="summary-row">
				<span>배송비</span>
				<span id="delivery-fee">0원</span>
			</div>
		</div>
		<div class="summary-total">
			<span>총 결제금액</span>
			<strong id="summary-final">0원</strong>
		</div>
	</section>

	<p class="cart-warning" id="cart-warning" hidden>상품을 하나 이상 선택해 주세요.</p>

	<div class="cart-action" id="cart-action">
		<a class="btn-outline" href="<c:url value='/'/>">계속 쇼핑하기</a>
		<%-- TODO(placeholder route): "/order/payment" 컨트롤러 미구현. 담당자가 @GetMapping("/order/payment")을 추가해야 함 --%>
		<button type="button" class="btn-solid" id="btn-checkout">주문하기</button>
	</div>

	<div class="cart-empty" id="cart-empty" hidden>
		<p class="cart-empty-title">장바구니에 담긴 상품이 없습니다.</p>
		<p class="cart-empty-desc">마음에 드는 상품을 담아보세요.</p>
		<a class="btn-solid" href="<c:url value='/'/>">상품 보러가기</a>
	</div>
</div>

<%-- TODO(data binding): 장바구니는 header.jsp가 관리하는 localStorage(cartItems) 임시 구현임.
	 실제로는 Cart 테이블(pop_id 기준 OptionDetail 참조) 및 회원 세션과 연동해야 함.
	 옵션명(optionName)은 ProductOption 테이블의 option_name, 가격(price)은 같은 테이블의
	 option_price에서 가져와야 함 — 현재는 테스트용 임의값. 새로고침 시 항상 예시 상품 2개가
	 보이도록 cartItems가 비어있으면 아래 기본값으로 채움. --%>
<script>
(function () {
	var DEFAULT_ITEMS = [
		{ productId: '1', name: '프리미엄 한우 선물세트', optionName: '1++ 등급 / 1kg', price: 129000, qty: 1 },
		{ productId: '2', name: '전통 과일 선물세트', optionName: '중과 5호 / 3kg', price: 59000, qty: 2 }
	];
	var SHIPPING_FEE = 3000;

	// TODO(data binding): 실제로는 Cart.pop_id가 상품+옵션 조합의 유일키 역할을 함.
	// 현재는 productId+optionName 조합을 임시 키로 사용.
	function getKey(item) {
		return item.productId + '::' + (item.optionName || '기본 옵션');
	}

	var checkedState = {};

	function getCartItems() {
		try {
			var items = JSON.parse(localStorage.getItem('cartItems') || '[]');
			return Array.isArray(items) ? items : [];
		} catch (e) {
			return [];
		}
	}

	function saveCartItems(items) {
		localStorage.setItem('cartItems', JSON.stringify(items));
		if (typeof window.refreshCartBadge === 'function') {
			window.refreshCartBadge();
		}
	}

	var items = getCartItems();
	if (items.length === 0) {
		items = DEFAULT_ITEMS.slice();
		saveCartItems(items);
	}
	items.forEach(function (item) { checkedState[getKey(item)] = true; });

	var cartControls = document.getElementById('cart-controls');
	var cartItemList = document.getElementById('cart-itemlist');
	var cartSummaryBox = document.getElementById('cart-summary-box');
	var cartAction = document.getElementById('cart-action');
	var cartEmpty = document.getElementById('cart-empty');
	var cartWarning = document.getElementById('cart-warning');
	var checkAll = document.getElementById('check-all');

	function formatWon(n) {
		return n.toLocaleString('ko-KR') + '원';
	}

	function captureCheckedState() {
		cartItemList.querySelectorAll('.cart-item').forEach(function (row) {
			checkedState[row.dataset.cartKey] = row.querySelector('.item-checkbox').checked;
		});
	}

	function render() {
		captureCheckedState();
		items = getCartItems();

		var isEmpty = items.length === 0;
		cartControls.hidden = isEmpty;
		cartItemList.hidden = isEmpty;
		cartSummaryBox.hidden = isEmpty;
		cartAction.hidden = isEmpty;
		cartWarning.hidden = true;
		cartEmpty.hidden = !isEmpty;
		if (isEmpty) return;

		cartItemList.innerHTML = '';
		items.forEach(function (item) {
			var key = getKey(item);
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

			row.querySelector('.item-title').textContent = item.name;
			row.querySelector('.item-option').textContent = item.optionName || '기본 옵션';
			row.querySelector('.price-final').textContent = formatWon(item.price);
			row.querySelector('.input-qty').value = item.qty;

			cartItemList.appendChild(row);
		});

		syncCheckAll();
		updateSummary();
	}

	function syncCheckAll() {
		var boxes = cartItemList.querySelectorAll('.item-checkbox');
		checkAll.checked = boxes.length > 0 && Array.prototype.every.call(boxes, function (b) { return b.checked; });
	}

	function updateSummary() {
		var itemsTotal = 0;
		cartItemList.querySelectorAll('.cart-item').forEach(function (row) {
			if (!row.querySelector('.item-checkbox').checked) return;
			var item = items.filter(function (i) { return getKey(i) === row.dataset.cartKey; })[0];
			if (item) itemsTotal += item.price * item.qty;
		});
		var fee = itemsTotal > 0 ? SHIPPING_FEE : 0;
		document.getElementById('total-price').textContent = formatWon(itemsTotal);
		document.getElementById('delivery-fee').textContent = formatWon(fee);
		document.getElementById('summary-final').textContent = formatWon(itemsTotal + fee);
	}

	cartItemList.addEventListener('click', function (e) {
		var row = e.target.closest('.cart-item');
		if (!row) return;
		var key = row.dataset.cartKey;

		if (e.target.classList.contains('btn-qty-increase') || e.target.classList.contains('btn-qty-decrease')) {
			var item = items.filter(function (i) { return getKey(i) === key; })[0];
			if (!item) return;
			item.qty = e.target.classList.contains('btn-qty-increase') ? item.qty + 1 : Math.max(1, item.qty - 1);
			saveCartItems(items);
			render();
		}

		if (e.target.classList.contains('delete-item-btn')) {
			items = items.filter(function (i) { return getKey(i) !== key; });
			saveCartItems(items);
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

	document.getElementById('delete-btn').addEventListener('click', function () {
		var keepKeys = [];
		cartItemList.querySelectorAll('.cart-item').forEach(function (row) {
			if (!row.querySelector('.item-checkbox').checked) keepKeys.push(row.dataset.cartKey);
		});
		items = items.filter(function (i) { return keepKeys.indexOf(getKey(i)) !== -1; });
		saveCartItems(items);
		render();
	});

	document.getElementById('btn-checkout').addEventListener('click', function () {
		var anyChecked = Array.prototype.some.call(cartItemList.querySelectorAll('.item-checkbox'), function (b) { return b.checked; });
		cartWarning.hidden = anyChecked;
		if (anyChecked) {
			window.location.href = '<c:url value="/order/payment"/>';
		}
	});

	render();
})();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>