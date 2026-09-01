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

    // 저장은 항상 헤더 배지 갱신과 짝이라 한 곳에 묶어둔다. cart.jsp/wish.jsp가 각자
    // 갖고 있던 saveCartItems/saveWishItems가 이것과 똑같은 코드였어서 여기로 합쳤다.
    function saveCartItems(items) {
        localStorage.setItem('cartItems', JSON.stringify(items));
        if (typeof window.refreshCartBadge === 'function') window.refreshCartBadge();
    }

    function saveWishList(items) {
        localStorage.setItem('wishItems', JSON.stringify(items));
        if (typeof window.refreshCartBadge === 'function') window.refreshCartBadge();
    }

    // 상품+옵션 조합의 임시 유일키. addToCart와 장바구니 화면이 같은 규칙을 써야 해서 공용으로 둔다.
    // TODO(data binding): 실제로는 Cart.pop_id(옵션 단위)가 이 역할을 함.
    function getCartKey(item) {
        return item.productId + '::' + (item.optionName || '기본 옵션');
    }

    // 같은 상품이라도 옵션이 다르면 합치지 않는다(위 getCartKey 규칙).
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
        saveCartItems(items);
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
        saveWishList(list);
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
        saveCartItems: saveCartItems,
        saveWishList: saveWishList,
        getCartKey: getCartKey,
        addToCart: addToCart,
        toggleWish: toggleWish,
        isWished: isWished
    };

    // cart.jsp/wish.jsp/searchProduct.jsp가 쓰는 기존 전역 함수 이름 유지 (하위 호환)
    window.addToCart = addToCart;
    window.toggleWish = toggleWish;
    window.isWished = isWished;
})();
