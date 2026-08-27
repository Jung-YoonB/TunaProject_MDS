<%-- TODO(data binding): 장바구니/찜은 localStorage 임시 구현, 실제로는 Cart(pop_id 기준)·Wish 테이블과 서버 동기화 필요 --%>
<%--  header.jsp 의 장바구니/찜 notice 뱃지(알람) 기능 --%>
(function () {
	var isLoggedIn = ${not empty sessionScope.loginMemberId};
	var cartBadge = document.getElementById('cartBadge');
	var wishBadge = document.getElementById('wishBadge');

	function getCartItems() {
		try {
			var items = JSON.parse(localStorage.getItem('cartItems') || '[]');
			return Array.isArray(items) ? items : [];
		} catch (e) {
			return [];
		}
	}

	function getWishList() {
		try {
			return JSON.parse(localStorage.getItem('wishItems') || '[]');
		} catch (e) {
			return [];
		}
	}

	function renderBadges() {
		var cartCount = getCartItems().reduce(function (sum, item) { return sum + (item.qty || 0); }, 0);
		cartBadge.textContent = cartCount;
		cartBadge.hidden = cartCount <= 0;

		var wishCount = getWishList().length;
		wishBadge.textContent = wishCount;
		wishBadge.hidden = wishCount <= 0;
	}

	// 비회원이 메인 화면으로 돌아오면 담아둔 장바구니/찜 정보를 초기화 (테스트/초기화용)
	if (!isLoggedIn && window.location.pathname === '<c:url value="/"/>') {
		localStorage.removeItem('cartItems');
		localStorage.removeItem('wishItems');
	}

	// TODO(data binding): 실제로는 Cart가 pop_id(옵션 단위) 기준이라 상품+옵션 조합마다 별도 행이어야 함.
	// 현재는 productId+optionName 조합을 임시 키로 사용해 같은 상품이라도 옵션이 다르면 합치지 않음.
	window.addToCart = function (item) {
		var items = getCartItems();
		var optionName = item.optionName || '기본 옵션';
		var existing = items.filter(function (i) {
			return i.productId === item.productId && (i.optionName || '기본 옵션') === optionName;
		})[0];
		if (existing) {
			existing.qty += (item.qty || 1);
		} else {
			items.push({ productId: item.productId, name: item.name, optionName: optionName, price: item.price, qty: item.qty || 1 });
		}
		localStorage.setItem('cartItems', JSON.stringify(items));
		renderBadges();
	};

	window.toggleWish = function (item) {
		var list = getWishList();
		var key = String(item.productId);
		var idx = -1;
		for (var i = 0; i < list.length; i++) {
			if (list[i].productId === key) { idx = i; break; }
		}
		var active;
		if (idx === -1) {
			list.push({ productId: key, name: item.name, price: item.price, addedAt: Date.now() });
			active = true;
		} else {
			list.splice(idx, 1);
			active = false;
		}
		localStorage.setItem('wishItems', JSON.stringify(list));
		renderBadges();
		return active;
	};

	window.isWished = function (productId) {
		var list = getWishList();
		var key = String(productId);
		for (var i = 0; i < list.length; i++) {
			if (list[i].productId === key) return true;
		}
		return false;
	};

	// cart.jsp/wish.jsp 등 다른 페이지가 cartItems/wishItems를 직접 수정한 뒤 뱃지 갱신을 요청할 때 사용
	window.refreshCartBadge = renderBadges;

	renderBadges();
})();