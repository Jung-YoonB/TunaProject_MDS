// 장바구니/찜 데이터 로직 (여러 페이지에서 공유: header.jsp, cart.jsp, wish.jsp, searchProduct.jsp).
// addToCart(2026-09-03)/toggleWish(2026-09-03 추가 조치)는 둘 다 실제 서버(CartController/
// WishController)에 반영한다 - 비로그인 상태로 눌러도 그냥 로컬에 쌓이던(AUDIT 신규 버그) 것을
// 막는다. localStorage(cartItems/wishItems)는 이제 "서버 반영 성공 후"에만 갱신하는 캐시로만 쓴다
// (헤더 뱃지 표시용, isWished()의 초기 렌더 판단용) - 로그인 세션이 없으면 여전히 서버 진짜 상태와
// 어긋날 수 있다(예: 다른 브라우저에서 찜한 것은 여기서 모름). 완전한 서버 동기화(로그인 시 최초
// 로드 때 실제 WISH/CART 데이터로 캐시를 채우는 것)는 이번 조치 범위 밖 - TODO(data binding) 유지.
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

    // 검색결과/찜 카드의 "장바구니 담기" 퀵버튼용 - 옵션 선택 UI가 없으므로 상세 페이지 기준
    // 대표 옵션(popId, 서버가 product.xml/wish.xml에서 OPTION_ID가 가장 작은 옵션으로 내려줌)을
    // 그대로 실제 서버(CartController.insertCart, productDetail.jsp의 #cart-button과 동일한
    // 백엔드)에 담는다. 더 이상 localStorage 목업을 쓰지 않는다(AUDIT 버그 21번 조치).
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
            // ✅ 조치 완료(2026-09-03): 여기서 헤더 뱃지 갱신을 안 부르고 있었다 - 서버엔 실제로
            // 담겼는데도 뱃지 숫자는 다음 페이지 이동/새로고침 전까지 그대로였다(메인 페이지 등
            // 퀵버튼으로 담을 때 특히 눈에 띔 - home.js/searchProduct.js/wish.js 전부 이 함수 하나를
            // 공유해서 여기 한 곳만 고치면 된다).
            if (typeof window.refreshCartBadge === 'function') window.refreshCartBadge();
            if (!silent) alert('장바구니에 담았습니다.');
            return true;
        }).catch(function () {
            if (!silent) alert('장바구니 담기에 실패했습니다.');
            return false;
        });
    }

    // 실제 WishController(POST /wish/insert-wish, GET /wish/remove-wish)를 호출한다. 어느 쪽을
    // 부를지는 호출부가 넘겨주는 wasWished(그 버튼의 현재 DOM 상태 - 서버가 최초 렌더링 때부터
    // 정확히 채워준다)로 판단한다. ✅ 2026-09-03: 예전엔 이걸 로컬 캐시(isWished, localStorage)로
    // 판단했는데, 로그아웃 후 재로그인하면 이 캐시가 비어 있어서(다른 계정/새 세션) 이미 찜한
    // 상품도 "안 찜한 것"으로 오판 - 버튼은 채워진 하트로 보이는데 클릭하면 내부적으로는 "추가"를
    // 시도하는 상태 불일치가 있었다(AUDIT 신규 버그). insertWish 자체는 이미 찜한 상품이면 에러
    // 없이 안내만 하고 넘어가서(WishServiceImpl) 데이터가 깨지진 않았지만, 그다음 클릭(진짜 해제하려는
    // 클릭)이 다시 "추가" 쪽으로 잘못 판단되는 문제가 있어 DOM 기준으로 바꿨다.
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
