// 관리자 - 쿠폰 등록(addCoupon.jsp) 화면 인터랙션.
// 서버 통신은 window.AdminCouponService(admin/adminCouponService.js)에 위임한다.
(function () {
    var root = document.querySelector('.add-coupon-page');
    var REGISTER_URL = root.dataset.registerUrl;

    var today = AdminCouponService.getTodayString();

    var startDate = document.getElementById('startDate');
    var endDate = document.getElementById('endDate');

    // 발급일은 오늘 이전 선택 불가
    startDate.min = today;

    // 종료일에는 시/분 개념이 없어서 "오늘"을 고르면 사실상 발급되자마자 만료되는 것과
    // 다름없다 - 최소 하루 뒤부터 선택 가능 (발급일을 안 고르면 이 기본값이 유지됨)
    endDate.min = AdminCouponService.getNextDayString(today);

    // 발급일을 선택하면 종료일은 그 다음날부터 선택 가능 (같은 날짜는 "즉시 만료"와 같은 문제)
    startDate.addEventListener('change', function () {
        endDate.min = AdminCouponService.getNextDayString(this.value);
    });

    // 기본 동작은 달력 아이콘을 눌러야만 날짜 선택창이 뜨는데, 입력창 어디를 눌러도 뜨게 함
    [startDate, endDate].forEach(function (input) {
        input.addEventListener('click', function () {
            if (typeof this.showPicker === 'function') {
                try {
                    this.showPicker();
                } catch (e) {
                    // showPicker가 지원 안 되거나 호출 조건이 안 맞으면 그냥 기본 동작(아이콘 클릭)에 맡김
                }
            }
        });
    });

    // 쿠폰 발급
    document.getElementById('registerCouponButton').addEventListener('click', function () {

        var couponName = document.getElementById('couponNameInput').value.trim();
        var discountPercent = document.getElementById('discountPercentInput').value;
        var couponText = document.getElementById('couponTextInput').value.trim();
        var endDateValue = endDate.value;

        if (!couponName) {
            alert('쿠폰명을 입력해 주세요.');
            return;
        }
        if (!discountPercent) {
            alert('할인율을 입력해 주세요.');
            return;
        }
        if (!endDateValue) {
            alert('종료일을 선택해 주세요.');
            return;
        }
        var effectiveStart = startDate.value || today;
        if (endDateValue <= effectiveStart) {
            alert('종료일을 발급일과 동일하게 설정할 수 없습니다.\n내일 이후를 선택해 주세요.');
            return;
        }

        var params = new URLSearchParams();
        params.append('couponName', couponName);
        params.append('discountPercent', discountPercent);
        params.append('couponText', couponText);
        if (startDate.value) {
            params.append('startDate', startDate.value);
        }
        params.append('endDate', endDateValue);

        var button = this;
        button.disabled = true;

        AdminCouponService.registerCoupon(REGISTER_URL, params)
            .then(function (result) {
                alert(result.message || '쿠폰이 등록되었습니다.');
                location.href = root.dataset.listUrl;
            })
            .catch(function (error) {
                alert(error.message || '쿠폰 등록 중 오류가 발생했습니다.');
            })
            .finally(function () {
                button.disabled = false;
            });
    });
})();
