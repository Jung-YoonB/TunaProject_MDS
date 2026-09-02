// 장바구니 화면 데이터 계층 - 목록 로드/시딩, 수량 변경·삭제, 금액 계산.
// localStorage 접근과 헤더 배지 갱신은 공용 common/cartWishService.js가 담당하고,
// 이 파일은 "장바구니 화면에만 필요한" 규칙(예시 데이터, 배송비, 합계)만 갖는다.
//
// TODO(server binding): 실제로는 Cart 테이블(pop_id 기준 OptionDetail 참조) 및 회원 세션과
// 연동해야 한다. 옵션명(optionName)은 ProductOption.option_name, 가격(price)은 같은 테이블의
// option_price에서 와야 하며 현재는 테스트용 임의값이다. 연동 시 load()/save() 내부만
// 실제 호출로 바꾸면 되고, 호출부(views/cart.js)는 안 건드려도 된다.
(function () {

    // 새로고침해도 화면이 비어 보이지 않도록, 저장된 장바구니가 없을 때만 채워넣는 예시 상품.
    var DEFAULT_ITEMS = [
        { productId: '1', name: '프리미엄 한우 선물세트', optionName: '1++ 등급 / 1kg', price: 129000, qty: 1 },
        { productId: '2', name: '전통 과일 선물세트', optionName: '중과 5호 / 3kg', price: 59000, qty: 2 }
    ];

    var SHIPPING_FEE = 3000;

	function getKey(item) {
	    return String(item.cartId);
	}

    function save(items) {
//        window.CartWishService.saveCartItems(items);
    }

    // 저장된 목록을 돌려주되, 비어 있으면 예시 상품으로 채운 뒤 저장한다.
	function load() {
	    return window.serverCartItems || [];
	}

    // 수량은 1 미만으로 내려가지 않는다.
    function changeQty(items, key, delta) {
        var item = items.filter(function (i) { return getKey(i) === key; })[0];
        if (item) item.qty = Math.max(1, item.qty + delta);
        return items;
    }

    function removeByKeys(items, keysToRemove) {
        return items.filter(function (i) { return keysToRemove.indexOf(getKey(i)) === -1; });
    }

    function keepByKeys(items, keysToKeep) {
        return items.filter(function (i) { return keysToKeep.indexOf(getKey(i)) !== -1; });
    }

    // 선택된 항목만 합산한다. 상품 금액이 0이면 배송비도 0.
	function calcTotals(items, selectedKeys) {
	    var itemsTotal = 0;

	    items.forEach(function (i) {
	        if (selectedKeys.indexOf(getKey(i)) !== -1) {
	            itemsTotal += i.optionPrice * i.qty;
	        }
	    });

	    var fee = itemsTotal > 0 ? SHIPPING_FEE : 0;

	    return {
	        itemsTotal: itemsTotal,
	        fee: fee,
	        finalTotal: itemsTotal + fee
	    };
	}


    window.CartService = {
        getKey: getKey,
        load: load,
        save: save,
        changeQty: changeQty,
        removeByKeys: removeByKeys,
        keepByKeys: keepByKeys,
        calcTotals: calcTotals
    };

})();
