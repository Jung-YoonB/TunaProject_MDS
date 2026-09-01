// 유저 - 내 쿠폰: 이름 검색 필터만 담당하는 순수 DOM 스크립트.
// 쿠폰 데이터 자체는 서버(JSTL)가 이미 렌더링해서 내려주므로, 여기서는 이미 렌더링된
// 카드를 이름 기준으로 보이거나 숨기기만 한다(서버 통신/데이터 가공 없음). 검색은 현재
// 페이지에 로드된 카드에만 적용됨(페이지 넘기면 초기화) - 데이터 양이 적어 이 정도로 충분하다고 판단.
(function () {
    var input = document.getElementById('coupon-search');
    var button = document.getElementById('search-button');
    var list = document.getElementById('couponCardList');
    var empty = document.getElementById('coupon-empty');
    if (!input || !button || !list) return;

    var originalEmptyText = empty ? empty.textContent : '';

    function applyFilter() {
        var keyword = input.value.trim().toLowerCase();
        var cards = list.querySelectorAll('.coupon-card');
        var visibleCount = 0;

        cards.forEach(function (card) {
            var matches = !keyword || (card.dataset.couponName || '').toLowerCase().indexOf(keyword) !== -1;
            card.hidden = !matches;
            if (matches) visibleCount += 1;
        });

        if (empty) {
            var hasAnyCard = cards.length > 0;
            empty.hidden = !hasAnyCard || visibleCount > 0;
            empty.textContent = (hasAnyCard && visibleCount === 0) ? '검색 결과가 없습니다.' : originalEmptyText;
        }
    }

    button.addEventListener('click', applyFilter);
    input.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            applyFilter();
        }
    });
    input.addEventListener('input', applyFilter);
})();
