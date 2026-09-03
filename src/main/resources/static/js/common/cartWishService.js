// 장바구니/찜 데이터 로직. header.jsp, cart.jsp, wish.jsp, searchProduct.jsp가 공유한다.
//
// addToCart/toggleWish는 실제 서버(CartController/WishController)에 반영한다.
// localStorage(cartItems/wishItems)는 서버 반영에 성공한 뒤에만 갱신하는 캐시일 뿐이다
// (헤더 뱃지 표시, isWished()의 초기 렌더 판단용). 캐시라서 서버 진짜 상태와 어긋날 수 있다
// - 다른 브라우저에서 찜한 것은 여기서 알지 못한다. 로그인 시 서버 값으로 캐시를 채우는
// 완전한 동기화는 아직 없다.
//
// 호출부가 window.addToCart / window.toggleWish / window.isWished / window.refreshCartBadge를
// 전역 함수로 직접 부르고 있어 이름을 바꾸면 안 된다.
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
    // 서버는 pop_id(옵션 단위)로 식별한다. 이건 localStorage 캐시에서만 쓰는 임시 키.
    function getCartKey(item) {
        return item.productId + '::' + (item.optionName || '기본 옵션');
    }

    // 검색결과/찜 카드의 "장바구니 담기" 퀵버튼용 - 옵션 선택 UI가 없으므로 상세 페이지 기준
    // 대표 옵션(popId, 서버가 product.xml/wish.xml에서 OPTION_ID가 가장 작은 옵션으로 내려줌)을
    // 그대로 실제 서버(CartController.insertCart, productDetail.jsp의 #cart-button과 동일한
    // 백엔드)에 담는다. localStorage 목업은 쓰지 않는다.
    // silent: true면 성공/실패 알림을 안 띄운다(찜 목록의 "선택 상품 장바구니 담기"처럼 여러 건을
    // 한 번에 부르고 호출부가 결과를 모아서 요약 안내를 하나만 띄울 때 씀). 반환값은 성공 여부(boolean).
    function addToCart(item, silent) {
        if (!item.popId) {
            if (!silent) alert('상품 옵션 정보를 불러오지 못해 장바구니에 담을 수 없습니다. 상품 상세 페이지에서 담아주세요.');
            return Promise.resolve(false);
        }
        return fetch('/cart/add-cart', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            credentials: 'same-origin',
            body: 'popId=' + encodeURIComponent(item.popId) + '&qty=' + encodeURIComponent(item.qty || 1)
        }).then(function (res) {
            // CartController는 항상 redirect라 응답 본문 대신 최종 도착 URL로 로그인 필요 여부를 구분한다.
            if (res.url && res.url.indexOf('/member/login') !== -1) {
                if (!silent) {
                    alert('로그인이 필요합니다.');
                    window.location.href = '/member/login';
                }
                return false;
            }
            // 담고 나면 헤더 뱃지도 바로 갱신한다(안 하면 다음 페이지 이동 전까지 숫자가 그대로다).
            if (typeof window.refreshCartBadge === 'function') window.refreshCartBadge();
            if (!silent) alert('장바구니에 담았습니다.');
            return true;
        }).catch(function () {
            if (!silent) alert('장바구니 담기에 실패했습니다.');
            return false;
        });
    }

    // WishController(POST /wish/insert-wish, GET /wish/remove-wish)를 호출한다.
    //
    // 추가/해제 판단은 반드시 호출부가 넘겨주는 wasWished(버튼의 현재 DOM 상태)로 한다.
    // 로컬 캐시(isWished)로 판단하면 안 된다 - 로그아웃 후 재로그인하면 캐시가 비어 있어서
    // 이미 찜한 상품을 "안 찜한 것"으로 오판하고, 해제하려는 클릭이 추가로 처리된다.
    // 서버가 최초 렌더링부터 하트 상태를 정확히 채워주므로 DOM이 더 믿을 만한 기준이다.
    function toggleWish(item, wasWished) {
        var request = wasWished
            ? fetch('/wish/remove-wish?productId=' + encodeURIComponent(item.productId), { credentials: 'same-origin' })
            : fetch('/wish/insert-wish', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                credentials: 'same-origin',
                body: 'productId=' + encodeURIComponent(item.productId)
            });

        return request.then(function (res) {
            // 두 엔드포인트 다 항상 redirect라 최종 도착 URL로 로그인 필요 여부를 구분한다(addToCart와 동일 패턴).
            if (res.url && res.url.indexOf('/member/login') !== -1) {
                alert('로그인이 필요합니다.');
                window.location.href = '/member/login';
                return wasWished; // 실패했으니 상태 그대로
            }

            var list = getWishList();
            var key = String(item.productId);
            var idx = -1;
            for (var i = 0; i < list.length; i++) {
                if (list[i].productId === key) { idx = i; break; }
            }
            var nowWished = !wasWished;
            if (nowWished && idx === -1) {
                list.push({ productId: key, name: item.name, price: item.price, addedAt: Date.now() });
            } else if (!nowWished && idx !== -1) {
                list.splice(idx, 1);
            }
            saveWishList(list);
            return nowWished;
        }).catch(function () {
            alert('찜 처리에 실패했습니다.');
            return wasWished;
        });
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
