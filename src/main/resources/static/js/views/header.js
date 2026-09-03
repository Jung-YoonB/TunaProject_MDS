// header.jsp 의 장바구니/찜 notice 뱃지(알람) 인터랙션.
// 2026-09-03부로 실제 서버 값을 쓴다(GET /cart/count, /wish/count) - 이전엔 localStorage 합계만
// 보여줘서, 예를 들어 상세 페이지에서 담고 메인으로 돌아오면 그 브라우저의 localStorage가 아직
// 안 갱신된 페이지에서는 뱃지가 실제 담긴 수량과 안 맞는 문제가 있었다
(function () {
    var isLoggedIn = document.body.dataset.loggedIn === 'true';
    var homeUrl = document.body.dataset.homeUrl;
    var cartBadge = document.getElementById('cartBadge');
    var wishBadge = document.getElementById('wishBadge');

    function setBadge(el, count) {
        el.textContent = count;
        el.hidden = count <= 0;
    }

    function renderBadges() {
        if (!isLoggedIn) {
            setBadge(cartBadge, 0);
            setBadge(wishBadge, 0);
            return;
        }
        fetch('/cart/count', { credentials: 'same-origin' })
            .then(function (res) { return res.ok ? res.text() : '0'; })
            .then(function (count) { setBadge(cartBadge, parseInt(count, 10) || 0); })
            .catch(function () {});

        fetch('/wish/count', { credentials: 'same-origin' })
            .then(function (res) { return res.ok ? res.text() : '0'; })
            .then(function (count) { setBadge(wishBadge, parseInt(count, 10) || 0); })
            .catch(function () {});
    }

    // 비회원이 메인 화면으로 돌아오면 옛 목업 시절에 쌓인 로컬 데이터를 정리 (테스트/초기화용)
    if (!isLoggedIn && window.location.pathname === homeUrl) {
        localStorage.removeItem('cartItems');
        localStorage.removeItem('wishItems');
    }

    // cart.jsp/wish.jsp 등 다른 페이지가 담기/찜하기 이후 뱃지 갱신을 요청할 때 사용
    window.refreshCartBadge = renderBadges;

    renderBadges();
})();
