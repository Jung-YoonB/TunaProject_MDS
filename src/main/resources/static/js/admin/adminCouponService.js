// 관리자 - 쿠폰: 서버 통신 + 데이터 가공을 담당하는 비즈니스 로직.
// DOM을 직접 건드리지 않고, addCoupon.jsp/admincouponView.jsp가 쓰는 인터랙션 스크립트에서
// window.AdminCouponService를 통해 호출한다.
(function () {

    function formatDeadline(deadline) {
        if (!deadline) return '';
        return '사용기한 : ' + deadline.replace(/-/g, '.');
    }

    function formatPercent(couponValue) {
        return Math.round(couponValue * 100) + '%';
    }

    // Date를 로컬 기준 YYYY-MM-DD 문자열로 변환.
    // toISOString()은 UTC로 변환해버려서 UTC+9(한국) 기준으로는 자정~오전 9시 사이에
    // "오늘"이 하루 전으로 잘못 계산되는 버그가 있었음 - 반드시 로컬 필드로 직접 조립할 것
    function toDateString(d) {
        var y = d.getFullYear();
        var m = String(d.getMonth() + 1).padStart(2, '0');
        var day = String(d.getDate()).padStart(2, '0');
        return y + '-' + m + '-' + day;
    }

    function getTodayString() {
        return toDateString(new Date());
    }

    // dateStr(YYYY-MM-DD)의 다음 날짜를 같은 형식으로 반환
    function getNextDayString(dateStr) {
        var parts = dateStr.split('-').map(Number);
        var d = new Date(parts[0], parts[1] - 1, parts[2]);
        d.setDate(d.getDate() + 1);
        return toDateString(d);
    }

    // deadline(YYYY-MM-DD)이 오늘보다 이전이면 만료. 문자열 그대로 비교해도
    // ISO 8601(YYYY-MM-DD) 형식은 사전식 정렬이 날짜 순서와 같아서 안전하다.
    // today를 생략하면 매번 새로 계산하지만, 목록 필터/정렬처럼 여러 건을 한 번에 처리할 때는
    // 호출부에서 한 번만 구한 today를 넘겨 반복 계산을 피할 수 있다
    function isExpired(deadline, today) {
        if (!deadline) return false;
        return deadline < (today || getTodayString());
    }

    // 만료 여부 x 발급 이력 여부 4가지 조합을 하나의 상태 키로 합침
    function stateFromParts(expired, hasHistory) {
        return (expired ? 'expired' : 'active') + '-' + (hasHistory ? 'history' : 'no-history');
    }

    // 카드 색 구분(CSS의 state-* 클래스), 필터, 정렬에서 공용으로 씀
    function getCouponState(coupon, today) {
        return stateFromParts(isExpired(coupon.deadline, today), coupon.hasHistory);
    }

    // 기본 노출 순서: 진행중·미사용(신규) > 진행중·사용이력 > 만료·미사용 > 만료·사용이력
    // (사용 이력은 삭제 골칫거리가 아니라 "누가 언제 어떻게 할인받았는지" 기록 보존 목적으로 일부러 안 지우는 것 -
    //  다만 화면에서 우선순위는 가장 낮게 둬서 당장 신경 쓸 필요 있는 쿠폰이 위로 오게 함)
    var STATE_PRIORITY = {
        'active-no-history': 0,
        'active-history': 1,
        'expired-no-history': 2,
        'expired-history': 3
    };

    function getStatePriority(coupon, today) {
        return STATE_PRIORITY[getCouponState(coupon, today)];
    }

    function registerCoupon(url, params) {
        return fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '쿠폰 등록에 실패했습니다.');
                }
                return result;
            });
    }

    function fetchCoupons(url) {
        return fetch(url)
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '쿠폰 목록을 불러오지 못했습니다.');
                }
                return result.data || [];
            });
    }

    function deleteCoupons(url, couponIds) {
        return fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ couponIds: couponIds })
        })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '삭제에 실패했습니다.');
                }
                return result;
            });
    }

    window.AdminCouponService = {
        formatDeadline: formatDeadline,
        formatPercent: formatPercent,
        isExpired: isExpired,
        getTodayString: getTodayString,
        getNextDayString: getNextDayString,
        stateFromParts: stateFromParts,
        getCouponState: getCouponState,
        getStatePriority: getStatePriority,
        registerCoupon: registerCoupon,
        fetchCoupons: fetchCoupons,
        deleteCoupons: deleteCoupons
    };

})();
