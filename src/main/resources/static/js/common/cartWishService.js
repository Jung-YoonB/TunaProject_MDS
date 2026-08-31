// 장바구니/찜 데이터 로직 (여러 페이지에서 공유: header.jsp, cart.jsp, wish.jsp, searchProduct.jsp).
// TODO(data binding): 지금은 localStorage 임시 구현. 실제로는 Cart(pop_id 기준)·Wish 테이블과 서버 동기화 필요.
//
// cart.jsp/wish.jsp/searchProduct.jsp가 이미 window.addToCart / window.toggleWish / window.isWished /
// window.refreshCartBadge를 전역 함수로 직접 호출하고 있어서, 기존 이름을 그대로 유지한다.
(function () {

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

    // TODO(data binding): 실제로는 Cart가 pop_id(옵션 단위) 기준이라 상품+옵션 조합마다 별도 행이어야 함.
    // 현재는 productId+optionName 조합을 임시 키로 사용해 같은 상품이라도 옵션이 다르면 합치지 않음.
    function addToCart(item) {
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
        if (typeof window.refreshCartBadge === 'function') window.refreshCartBadge();
    }

    function toggleWish(item) {
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
        if (typeof window.refreshCartBadge === 'function') window.refreshCartBadge();
        return active;
    }

    function isWished(productId) {
        var list = getWishList();
        var key = String(productId);
        for (var i = 0; i < list.length; i++) {
            if (list[i].productId === key) return true;
        }
        return false;
    }

    window.CartWishService = {
        getCartItems: getCartItems,
        getWishList: getWishList,
        addToCart: addToCart,
        toggleWish: toggleWish,
        isWished: isWished
    };

    // cart.jsp/wish.jsp/searchProduct.jsp가 쓰는 기존 전역 함수 이름 유지 (하위 호환)
    window.addToCart = addToCart;
    window.toggleWish = toggleWish;
    window.isWished = isWished;
})();
