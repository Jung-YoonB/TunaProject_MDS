// 찜 화면 데이터 계층 - 목록 로드/시딩, 삭제, 정렬.
// localStorage 접근과 헤더 배지 갱신은 공용 common/cartWishService.js가 담당하고,
// 이 파일은 "찜 화면에만 필요한" 규칙(예시 데이터, 정렬 기준)만 갖는다.
//
// TODO(server binding): 실제로는 Wish 테이블 및 회원 세션과 연동해야 한다. 별점(rating)/
// 리뷰수(reviewCount) 집계 자체는 상품 상세·목록(detailPage.xml, product.xml)에 이미 구현돼
// 있고 이 화면에만 연동이 안 된 상태라 테스트용 임의값을 쓰는 중이다. 연동 시 load()/save()
// 내부만 실제 호출로 바꾸면 되고, 호출부(views/wish.js)는 안 건드려도 된다.
(function () {

    // 새로고침해도 화면이 비어 보이지 않도록, 저장된 찜 목록이 없을 때만 채워넣는 예시 상품.
    var DEFAULT_ITEMS = [
        { productId: '1', name: '프리미엄 한우 선물세트', price: 129000, rating: 4.8, reviewCount: 245 },
        { productId: '2', name: '전통 과일 선물세트', price: 59000, rating: 4.3, reviewCount: 89 },
        { productId: '3', name: '프리미엄 견과 선물세트', price: 75000, rating: 4.6, reviewCount: 156 },
        { productId: '4', name: '고급 한과 선물세트', price: 45000, rating: 4.1, reviewCount: 67 },
        { productId: '5', name: '홍삼 건강 선물세트', price: 89000, rating: 4.9, reviewCount: 312 },
        { productId: '6', name: '프리미엄 차 선물세트', price: 52000, rating: 4.4, reviewCount: 98 },
        { productId: '7', name: '수제 디저트 선물세트', price: 39000, rating: 4.2, reviewCount: 54 },
        { productId: '8', name: '명품 생활용품 선물세트', price: 68000, rating: 4.7, reviewCount: 203 }
    ];

    function save(items) {
        window.CartWishService.saveWishList(items);
    }

    // 저장된 목록을 돌려주되, 비어 있으면 예시 상품으로 채운 뒤 저장한다.
    // addedAt은 "최신순" 정렬이 의미를 갖도록 순서대로 1초씩 벌려 넣는다.
    function load() {
        var items = window.CartWishService.getWishList();
        if (items.length === 0) {
            items = DEFAULT_ITEMS.map(function (item, idx) {
                return {
                    productId: item.productId, name: item.name, price: item.price,
                    rating: item.rating, reviewCount: item.reviewCount,
                    addedAt: Date.now() - (DEFAULT_ITEMS.length - idx) * 1000
                };
            });
            save(items);
        }
        return items;
    }

    // TODO(data binding): "인기순"은 실제 인기 지표가 없어 담긴 순서를 그대로 쓴다.
    function sortItems(items, sortKey) {
        var list = items.slice();
        if (sortKey === 'rating-asc') {
            list.sort(function (a, b) { return a.rating - b.rating; });
        } else if (sortKey === 'rating-desc') {
            list.sort(function (a, b) { return b.rating - a.rating; });
        } else if (sortKey === 'recent') {
            list.sort(function (a, b) { return (b.addedAt || 0) - (a.addedAt || 0); });
        }
        return list;
    }

    function removeById(items, productId) {
        return items.filter(function (i) { return i.productId !== productId; });
    }

    function keepByIds(items, idsToKeep) {
        return items.filter(function (i) { return idsToKeep.indexOf(i.productId) !== -1; });
    }

    window.WishService = {
        load: load,
        save: save,
        sortItems: sortItems,
        removeById: removeById,
        keepByIds: keepByIds
    };

})();
