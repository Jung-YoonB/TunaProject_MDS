// header.jsp 의 장바구니/찜 notice 뱃지(알람) 인터랙션.
// 장바구니/찜 데이터 로직은 common/cartWishService.js(window.CartWishService)에 있음.
(function () {
    var Cart = window.CartWishService;

    var isLoggedIn = document.body.dataset.loggedIn === 'true';
    var homeUrl = document.body.dataset.homeUrl;
    var cartBadge = document.getElementById('cartBadge');
    var wishBadge = document.getElementById('wishBadge');

    function renderBadges() {
        var cartCount = Cart.getCartItems().reduce(function (sum, item) { return sum + (item.qty || 0); }, 0);
        cartBadge.textContent = cartCount;
        cartBadge.hidden = cartCount <= 0;

        var wishCount = Cart.getWishList().length;
        wishBadge.textContent = wishCount;
        wishBadge.hidden = wishCount <= 0;
    }

    // 비회원이 메인 화면으로 돌아오면 담아둔 장바구니/찜 정보를 초기화 (테스트/초기화용)
    if (!isLoggedIn && window.location.pathname === homeUrl) {
        localStorage.removeItem('cartItems');
        localStorage.removeItem('wishItems');
    }

    // cart.jsp/wish.jsp 등 다른 페이지가 cartItems/wishItems를 직접 수정한 뒤 뱃지 갱신을 요청할 때 사용
    window.refreshCartBadge = renderBadges;

    renderBadges();
})();
