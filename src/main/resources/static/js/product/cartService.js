// 장바구니 화면 데이터 계층 - 목록 로드, 서버 반영(삭제), 금액 계산.
// localStorage 접근과 헤더 배지 갱신은 공용 common/cartWishService.js가 담당하고,
// 이 파일은 "장바구니 화면에만 필요한" 규칙(배송비, 합계, 서버 삭제 호출)만 갖는다.
//
// 서버 연동 완료(2026-09-03): cart.jsp가 CartController.getCartList의 결과를 window.serverCartItems로
// 내려주고 load()가 그걸 그대로 쓴다. 예전엔 save()가 빈 함수(주석 처리)라 삭제/수량 변경이 화면에서만
// 바뀌고 render()가 다시 load()하면서 즉시 원래대로 되돌아갔다(AUDIT: 개별 삭제 버튼이 안 먹던 원인) -
// 실제 삭제는 이제 removeFromServer()가 CartController.removeCart를 호출한다(wishService.js의
// removeOnServer와 동일한 패턴).
(function () {

    // 서버 OrderServiceImpl 의 SHIPPING_FEE / FREE_SHIPPING_THRESHOLD 와 같은 값이어야 한다
    var SHIPPING_FEE = 3000;
    var FREE_SHIPPING_THRESHOLD = 50000;

	function getKey(item) {
	    return String(item.cartId);
	}

	function load() {
	    return window.serverCartItems || [];
	}

    // 장바구니 삭제(개별/선택 삭제 공통)를 서버(CartController.removeCart)에 반영한다. 서버가
    // popId를 하나씩 받으므로 여러 개면 전부 기다린 뒤 호출부가 화면을 새로고침해서 서버 상태를
    // 다시 읽는다 - 로컬만 지워지고 서버엔 남는 상태를 만들지 않기 위함(wishService.js와 동일 이유).
    function removeFromServer(popIds, removeUrl) {
        return Promise.all(popIds.map(function (popId) {
            return fetch(removeUrl + '?popId=' + encodeURIComponent(popId), { credentials: 'same-origin' });
        }));
    }

    // 수량 변경을 서버(CartController.updateQty)에 반영한다. 성공/실패(boolean)를 그대로 돌려줘서
    // 호출부가 실패 시 화면 값을 원래대로 되돌릴 수 있게 한다.
    function updateQtyOnServer(popId, qty, updateUrl) {
        return fetch(updateUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            credentials: 'same-origin',
            body: 'popId=' + encodeURIComponent(popId) + '&qty=' + encodeURIComponent(qty)
        }).then(function (res) {
            return res.ok ? res.text() : Promise.resolve('false');
        }).then(function (text) {
            return text.trim() === 'true';
        });
    }

    // 선택된 항목만 합산한다. 상품 금액이 0이면 배송비도 0.
    //
    // 배송비 기준은 서버(OrderServiceImpl.calcDeliveryFee)와 같아야 한다 -
    // "할인 전" 상품금액이 FREE_SHIPPING_THRESHOLD 이상이면 무료.
    // 한쪽만 바꾸면 장바구니에 보이던 배송비와 결제 금액이 어긋난다.
	function calcTotals(items, selectedKeys) {
	    var itemsTotal = 0;

	    items.forEach(function (i) {
	        if (selectedKeys.indexOf(getKey(i)) !== -1) {
	            itemsTotal += i.optionPrice * i.qty;
	        }
	    });

		var fee = itemsTotal >= FREE_SHIPPING_THRESHOLD ? 0 : (itemsTotal > 0 ? SHIPPING_FEE : 0);

	    return {
	        itemsTotal: itemsTotal,
	        fee: fee,
	        finalTotal: itemsTotal + fee
	    };
	}


    window.CartService = {
        getKey: getKey,
        load: load,
        removeFromServer: removeFromServer,
        updateQtyOnServer: updateQtyOnServer,
        calcTotals: calcTotals
    };

})();
