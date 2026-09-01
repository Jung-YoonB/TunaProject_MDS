// 공용 클라이언트 사이드 페이지네이션 (서버 페이징 없이, 이미 불러온 전체 목록을 잘라서 보여줄 때 씀).
// adminOrderDelivery.js/admincouponView.js 둘 다 똑같은 로직을 각자 갖고 있던 것을 여기로 합침.
(function () {

    // options:
    //   pageSize (기본 10), windowSize (페이지 번호 버튼 최대 개수, 기본 5)
    //   prevButton, nextButton, listElement (각각 이전/다음/번호 목록 DOM 요소)
    //   onPageChange() - 이전/다음/번호 클릭으로 페이지가 바뀔 때마다 호출(호출부가 다시 그리기만 하면 됨)
    function create(options) {
        var pageSize = options.pageSize || 10;
        var windowSize = options.windowSize || 5;
        var prevButton = options.prevButton;
        var nextButton = options.nextButton;
        var listElement = options.listElement;
        var onPageChange = options.onPageChange || function () {};

        var currentPage = 1;

        // 현재 페이지에 맞춰 목록을 자르고, 유효 범위를 벗어난 currentPage는 마지막 페이지로 당겨온다
        // (예: 뒷페이지 보다가 검색해서 결과가 줄어든 경우)
        function paginate(list) {
            var totalPages = Math.max(1, Math.ceil(list.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;
            var start = (currentPage - 1) * pageSize;
            return { pageItems: list.slice(start, start + pageSize), totalPages: totalPages };
        }

        // 페이지 번호 버튼을 currentPage 중심으로 최대 windowSize개까지만 보여준다
        function render(totalPages) {
            var startPage = Math.max(1, currentPage - Math.floor(windowSize / 2));
            var endPage = Math.min(totalPages, startPage + windowSize - 1);
            startPage = Math.max(1, endPage - windowSize + 1);

            var buttons = [];
            for (var p = startPage; p <= endPage; p++) {
                var isActive = p === currentPage;
                buttons.push('<li><button type="button" data-page="' + p + '"' +
                    (isActive ? ' class="is-active" aria-current="page"' : '') + '>' + p + '</button></li>');
            }
            listElement.innerHTML = buttons.join('');

            prevButton.disabled = currentPage <= 1;
            nextButton.disabled = currentPage >= totalPages;
        }

        function resetToFirstPage() {
            currentPage = 1;
        }

        function getCurrentPage() {
            return currentPage;
        }

        prevButton.addEventListener('click', function () {
            if (currentPage > 1) {
                currentPage -= 1;
                onPageChange();
            }
        });

        nextButton.addEventListener('click', function () {
            currentPage += 1;
            onPageChange();
        });

        listElement.addEventListener('click', function (e) {
            var btn = e.target.closest('button[data-page]');
            if (!btn) return;
            currentPage = Number(btn.dataset.page);
            onPageChange();
        });

        return {
            paginate: paginate,
            render: render,
            resetToFirstPage: resetToFirstPage,
            getCurrentPage: getCurrentPage
        };
    }

    window.Pagination = { create: create };

})();
