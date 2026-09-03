// 찜 화면 데이터 계층 - 목록 로드, 서버 반영, 정렬.
// localStorage 접근과 헤더 배지 갱신은 공용 common/cartWishService.js가 담당하고,
// 이 파일은 "찜 화면에만 필요한" 규칙(서버 목록 변환, 정렬 기준)만 갖는다.
//
// 서버 연동 완료(2026-09-02): wish.jsp가 WishController.myWish의 결과를 window.serverWishItems로
// 내려주고 load()가 그걸 화면용 모양으로 바꾼다. 예전 localStorage 예시 상품 8건은 제거했다 -
// 실데이터가 안 내려오는데도 가짜 상품이 보이면 장애를 알아챌 수 없기 때문.
(function () {

    function save(items) {
        window.CartWishService.saveWishList(items);
    }

    // 서버 목록을 화면(views/wish.js의 buildCard)이 쓰는 모양으로 바꾼다.
    // addedAt은 "최신순" 정렬이 의미를 갖도록 순서대로 1초씩 벌려 넣는다(쿼리가 이미 최신순).
    function fromServer(rows) {
        return rows.map(function (row, idx) {
            return {
                productId: String(row.productId),
                name: row.name,
                imageUrl: row.imageUrl,
                price: row.price,
                rating: row.rating,
                reviewCount: row.reviewCount,
                popId: row.popId,
                addedAt: Date.now() - idx * 1000
            };
        });
    }

    // 서버 목록이 있으면 그게 곧 진실이다(빈 배열이면 빈 화면이 맞다).
    // localStorage는 헤더 배지가 같은 값을 보도록 서버 목록으로 덮어써 둔다.
    function load() {
        if (Array.isArray(window.serverWishItems)) {
            var items = fromServer(window.serverWishItems);
            save(items);
            return items;
        }
        return window.CartWishService.getWishList();
    }

    // 찜 해제를 서버(WishController.removeWish)에 반영한다. 서버가 productId를 하나씩 받으므로
    // 선택 삭제는 여러 번 호출한 뒤 한꺼번에 기다린다. 끝나면 호출부가 화면을 새로고침해서
    // 서버 상태를 다시 읽는다 - 로컬만 지워지고 서버엔 남는 상태를 만들지 않기 위함.
    function removeOnServer(productIds, removeUrl) {
        return Promise.all(productIds.map(function (id) {
            return fetch(removeUrl + '?productId=' + encodeURIComponent(id), { credentials: 'same-origin' });
        }));
    }

    // 정렬 기준은 wish.jsp의 data-sort 값과 짝이다(popular / rating-asc / rating-desc / recent).
    // "인기순"은 리뷰 수를 지표로 쓴다 - 서버(wish.xml getWishList)가 REVIEW_COUNT를 같이 내려준다.
    // 같은 리뷰 수면 평점이 높은 쪽을 앞에 둔다.
    function sortItems(items, sortKey) {
        var list = items.slice();
        if (sortKey === 'popular') {
            list.sort(function (a, b) {
                var diff = (b.reviewCount || 0) - (a.reviewCount || 0);
                return diff !== 0 ? diff : (b.rating || 0) - (a.rating || 0);
            });
        } else if (sortKey === 'rating-asc') {
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
        removeOnServer: removeOnServer,
        save: save,
        sortItems: sortItems,
        removeById: removeById,
        keepByIds: keepByIds
    };

})();
