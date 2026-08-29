// 관리자 - 쿠폰 목록(admincouponView.jsp) 화면 인터랙션.
// 서버 통신/데이터 가공은 window.AdminCouponService(admin/adminCouponService.js)에 위임한다.
(function () {
    var root = document.querySelector('.admin-coupon-view-page');
    var LIST_URL = root.dataset.listUrl;
    var ADD_URL = root.dataset.addUrl;
    var DELETE_URL = root.dataset.deleteUrl;

    var couponCardList = document.getElementById('couponCardList');
    var couponCount = document.getElementById('couponCount');
    var searchInput = document.getElementById('coupon-search');
    var stateFilter = document.getElementById('coupon-state-filter');

    var allCoupons = [];
    var currentFilteredList = []; // applyFilters()가 매번 최신 필터링 결과를 담아둠 - 전체선택이 페이지 너머까지 미치게 하려고 필요
    var selectedIds = new Set(); // 체크된 쿠폰 id - 페이지를 넘겨도(카드가 다시 그려져도) 유지되어야 함

    // 페이지네이션(공용 로직은 static/js/common/pagination.js) - 페이지만 바뀔 때는 필터/정렬을
    // 다시 돌릴 필요 없이 이미 계산해둔 currentFilteredList로 다시 그리기만 하면 된다.
    // render는 아래에서 선언되지만 함수 선언은 호이스팅되므로 이 시점에 참조해도 문제없다
    var paginator = Pagination.create({
        pageSize: 10,
        prevButton: document.getElementById('pagination-prev'),
        nextButton: document.getElementById('pagination-next'),
        listElement: document.getElementById('pagination-list'),
        onPageChange: function () { render(currentFilteredList); }
    });

    function buildCard(coupon, today) {
        var expired = AdminCouponService.isExpired(coupon.deadline, today);
        // 만료 여부 x 발급 이력 여부 조합을 카드 왼쪽 색 띠로 구분(state-active-history 등, CSS 참고)
        var stateClass = 'state-' + AdminCouponService.stateFromParts(expired, coupon.hasHistory);

        var card = document.createElement('div');
        card.className = 'coupon-card ' + stateClass;
        card.dataset.couponId = coupon.couponId;

        card.innerHTML =
            '<input type="checkbox" class="coupon-check" name="coupon" value="' + coupon.couponId + '"' +
                (selectedIds.has(coupon.couponId) ? ' checked' : '') + '>' +
            '<div class="coupon-info">' +
                '<div class="coupon-name-row">' +
                    '<span class="coupon-name"></span>' +
                    (coupon.hasHistory ? '<span class="history-badge" title="발급 이력이 있어 삭제할 수 없습니다">발급 이력 있음</span>' : '') +
                '</div>' +
                '<div class="coupon-description"></div>' +
                '<div class="coupon-deadline"></div>' +
            '</div>' +
            '<div class="coupon-discount"></div>' +
            '<span class="coupon-status ' + (expired ? 'expired' : 'active') + '">' + (expired ? '만료' : '진행중') + '</span>' +
            '<button type="button" class="edit-button" title="쿠폰 수정">✎</button>' +
            (coupon.hasHistory
                ? '<button type="button" class="delete-icon-button" title="발급 이력이 있어 삭제할 수 없습니다" disabled>🗑</button>'
                : '<button type="button" class="delete-icon-button" title="쿠폰 삭제">🗑</button>');

        card.querySelector('.coupon-name').textContent = coupon.couponName;
        card.querySelector('.coupon-description').textContent = coupon.couponText || '';
        card.querySelector('.coupon-deadline').textContent = AdminCouponService.formatDeadline(coupon.deadline);
        card.querySelector('.coupon-discount').textContent = AdminCouponService.formatPercent(coupon.couponValue);

        return card;
    }

    function render(list) {
        couponCount.textContent = '(' + list.length + ')';

        var paged = paginator.paginate(list);
        paginator.render(paged.totalPages);

        couponCardList.innerHTML = '';

        if (paged.pageItems.length === 0) {
            var empty = document.createElement('p');
            empty.className = 'coupon-empty';
            empty.textContent = '등록된 쿠폰이 없습니다.';
            couponCardList.appendChild(empty);
            return;
        }

        // "오늘"은 이 렌더링 한 번에 대해 한 번만 구해서 카드마다 재계산하지 않는다
        var today = AdminCouponService.getTodayString();
        paged.pageItems.forEach(function (coupon) {
            couponCardList.appendChild(buildCard(coupon, today));
        });
    }

    // 검색어 + 상태 필터를 함께 적용한 뒤, 기본 노출 순서(진행중·미사용 > 진행중·사용이력 >
    // 만료·미사용 > 만료·사용이력)로 정렬해서 렌더링. 같은 상태 안에서는 원래 목록 순서 유지(안정 정렬).
    function applyFilters() {
        var keyword = searchInput.value.trim().toLowerCase();
        var state = stateFilter.value;
        // 필터링/정렬 전체에서 "오늘"을 한 번만 구해서, 대상 쿠폰 수만큼 매번 새로 계산하지 않는다
        var today = AdminCouponService.getTodayString();

        var filtered = allCoupons.filter(function (coupon) {
            var matchesKeyword = !keyword || coupon.couponName.toLowerCase().indexOf(keyword) !== -1;
            var matchesState = !state || AdminCouponService.getCouponState(coupon, today) === state;
            return matchesKeyword && matchesState;
        });

        filtered.sort(function (a, b) {
            return AdminCouponService.getStatePriority(a, today) - AdminCouponService.getStatePriority(b, today);
        });

        currentFilteredList = filtered;
        render(filtered);
    }

    // 검색/필터가 바뀌면 지금 보던 페이지 번호는 물론 이전 선택 내역도 더 이상 의미가 없으므로 초기화한다
    function applyFiltersFromFirstPage() {
        paginator.resetToFirstPage();
        selectedIds.clear();
        applyFilters();
    }

    function loadCoupons() {
        AdminCouponService.fetchCoupons(LIST_URL)
            .then(function (coupons) {
                allCoupons = coupons;
                applyFilters();
            })
            .catch(function (error) {
                alert(error.message || '쿠폰 목록을 불러오는 중 오류가 발생했습니다.');
            });
    }

    document.getElementById('goRegisterButton').addEventListener('click', function () {
        location.href = ADD_URL;
    });

    document.getElementById('search-button').addEventListener('click', applyFiltersFromFirstPage);
    searchInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') applyFiltersFromFirstPage();
    });
    stateFilter.addEventListener('change', applyFiltersFromFirstPage);

    var toggleSelectModeButton = document.getElementById('toggleSelectModeButton');
    var selectionControls = document.getElementById('selectionControls');
    var toggleSelectAllButton = document.getElementById('toggleSelectAllButton');
    var deleteSelectedButton = document.getElementById('deleteSelectedButton');

    // 평소엔 체크박스를 숨겨두고, "삭제할 쿠폰 선택"을 눌렀을 때만 선택 모드로 전환
    function enterSelectionMode() {
        couponCardList.classList.add('selecting');
        selectionControls.hidden = false;
        deleteSelectedButton.hidden = false;
        toggleSelectModeButton.textContent = '취소';
        toggleSelectModeButton.classList.add('is-selecting');
    }

    function exitSelectionMode() {
        couponCardList.classList.remove('selecting');
        selectionControls.hidden = true;
        deleteSelectedButton.hidden = true;
        toggleSelectModeButton.textContent = '삭제할 쿠폰 선택';
        toggleSelectModeButton.classList.remove('is-selecting');
        selectedIds.clear();
        couponCardList.querySelectorAll('.coupon-check').forEach(function (cb) { cb.checked = false; });
    }

    toggleSelectModeButton.addEventListener('click', function () {
        if (couponCardList.classList.contains('selecting')) {
            exitSelectionMode();
        } else {
            enterSelectionMode();
        }
    });

    // 체크박스는 페이지를 넘기면(카드가 다시 그려지면) 다시 만들어지므로, 그 시점에만 체크 상태를
    // 읽어선 안 되고 selectedIds에 반영해뒀다가 buildCard()가 그걸 보고 checked를 되살리게 한다
    couponCardList.addEventListener('change', function (e) {
        if (!e.target.classList.contains('coupon-check')) return;
        var id = Number(e.target.value);
        if (e.target.checked) {
            selectedIds.add(id);
        } else {
            selectedIds.delete(id);
        }
    });

    // 전체선택/전체선택취소를 하나로 합침 - 검색/필터를 통과한 전체 목록(현재 페이지만이 아님) 기준으로
    // 이미 다 선택돼 있으면 해제, 아니면 전체 선택
    toggleSelectAllButton.addEventListener('click', function () {
        var allSelected = currentFilteredList.length > 0 &&
            currentFilteredList.every(function (coupon) { return selectedIds.has(coupon.couponId); });

        if (allSelected) {
            selectedIds.clear();
        } else {
            currentFilteredList.forEach(function (coupon) { selectedIds.add(coupon.couponId); });
        }

        render(currentFilteredList);
    });

    function requestDelete(couponIds, confirmMessage) {
        if (!confirm(confirmMessage)) {
            return;
        }

        AdminCouponService.deleteCoupons(DELETE_URL, couponIds)
            .then(function (result) {
                alert(result.message || '삭제되었습니다.');
                exitSelectionMode();
                loadCoupons();
            })
            .catch(function (error) {
                alert(error.message || '쿠폰 삭제 중 오류가 발생했습니다.');
            });
    }

    // 수정(✎) / 개별 삭제(🗑) 버튼
    couponCardList.addEventListener('click', function (e) {
        if (e.target.classList.contains('edit-button')) {
            alert('쿠폰 수정 기능은 아직 지원하지 않습니다.');
            return;
        }

        var deleteButton = e.target.closest('.delete-icon-button');
        if (deleteButton) {
            var couponId = Number(deleteButton.closest('.coupon-card').dataset.couponId);
            requestDelete([couponId], '이 쿠폰을 삭제하시겠습니까?');
        }
    });

    deleteSelectedButton.addEventListener('click', function () {
        var couponIds = Array.from(selectedIds);
        if (couponIds.length === 0) {
            alert('삭제할 쿠폰을 선택해 주세요.');
            return;
        }

        requestDelete(couponIds, couponIds.length + '개의 쿠폰을 삭제하시겠습니까?');
    });

    loadCoupons();
})();
