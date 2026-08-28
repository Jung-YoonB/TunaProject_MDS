// 관리자 - 주문/배송: 서버 통신 + 데이터 가공을 담당하는 비즈니스 로직.
// DOM을 직접 건드리지 않고, adminOrderDelivery.jsp가 쓰는 인터랙션 스크립트(views/adminOrderDelivery.js)에서
// window.AdminOrderService를 통해 호출한다.
(function () {

    var STATUS_LABEL = {
        preparing: '배송준비중',
        shipped: '배송중',
        out_for_delivery: '배송출발',
        delivered: '배송완료',
        canceled: '취소/환불',
        // 취소/환불은 2단계라 화면 표시용으로 세분화된 라벨이 따로 필요함 (아래 cancelStage 참고)
        cancel_pending: '취소/환불 대기중',
        cancel_complete: '취소/환불 완료'
    };
    var STATUS_ORDER = ['preparing', 'shipped', 'out_for_delivery', 'delivered', 'canceled'];

    // 정상 진행 순서 (취소 제외). "다음 단계로" 버튼 하나로 이 순서를 그대로 따라가게 한다 -
    // 드롭다운으로 아무 상태나 고를 수 있던 예전 방식은 역행/건너뛰기/자기자신 재선택 같은 것들을
    // 하나하나 막아야 해서 계속 새는 구조였음. 애초에 "다음 단계" 버튼 하나만 보여주면 그런 문제 자체가 없음
    var STATUS_SEQUENCE = ['preparing', 'shipped', 'out_for_delivery', 'delivered'];

    // 각 상태로 넘어가는 액션 버튼에 쓸 문구
    var NEXT_ACTION_LABEL = {
        preparing: '배송 준비 시작',
        shipped: '배송 시작',
        out_for_delivery: '배송 출발 처리',
        delivered: '배송 완료 처리'
    };

    // '주문 상태' 필터 옵션 중 배송 진행 단계는 deliveryStatus로, 결제 단계는 orderStatus로 판단
    // (관리자가 배송상태를 바꿔도 결제 단계 자체를 나타내는 orderStatus는 그대로 유지되기 때문)
    var DELIVERY_LEVEL_STATUSES = ['preparing', 'shipped', 'delivered', 'canceled'];

    // 택배사에 실제로 넘긴 이후 상태 -> 택배사/송장번호 입력이 필수 (서버 검증과 동일한 기준)
    var COURIER_INFO_REQUIRED_STATUSES = ['shipped', 'out_for_delivery', 'delivered'];

    // DELIVERY.COMPANY엔 DB CHECK 제약이 없어서 애플리케이션(서버 + 이 목록)에서 값을 제한함.
    // 모달의 <select> 옵션, 서버의 VALID_COMPANIES와 동일하게 유지할 것
    var VALID_COMPANIES = ['CJ대한통운', '한진택배', '롯데택배', '로젠택배', '우체국택배'];

    function isValidCompany(company) {
        return VALID_COMPANIES.indexOf(company) !== -1;
    }

    function requiresCourierInfo(deliveryStatus) {
        return COURIER_INFO_REQUIRED_STATUSES.indexOf(deliveryStatus) !== -1;
    }

    // 현재 상태 다음으로 진행할 단 하나의 상태. currentStatus가 없으면(DELIVERY 행이 아직 없는 주문)
    // 배송준비중이 첫 단계. 이미 마지막 단계(배송완료)면 null - 더 진행할 게 없다는 뜻
    function nextStatus(currentStatus) {
        if (!currentStatus) return 'preparing';
        var idx = STATUS_SEQUENCE.indexOf(currentStatus);
        if (idx === -1 || idx === STATUS_SEQUENCE.length - 1) return null;
        return STATUS_SEQUENCE[idx + 1];
    }

    // DB에 결제 상태 전용 컬럼이 없어 order_status에서 파생
    function getPaymentStatus(order) {
        return order.orderStatus === 'payment_waiting' ? 'payment_waiting' : 'payment_completed';
    }

    // 서버에서 받은 주문 목록(DB 값은 대문자: PAYMENT_COMPLETED 등)을
    // 화면 로직이 기대하는 소문자 키 값으로 변환
    function normalizeOrder(o) {
        var orderStatus = (o.orderStatus || '').toLowerCase();
        // deliveryStatus는 DB에 DELIVERY 행이 실제로 있을 때만 값이 옴. null이면 "아직 행이 없음"을 그대로
        // 의미하도록 유지한다(예전엔 'preparing'으로 기본값 처리했는데, 그러면 실제로 배송준비중 처리된
        // 주문과 구분이 안 돼서 관리자가 아무 상태나 바로 선택할 수 있는 것처럼 보이는 문제가 있었음).
        // 결제 대기 중인 주문도 배송이 시작 전이므로 마찬가지로 null 취급.
        var deliveryStatus = orderStatus === 'payment_waiting' || !o.deliveryStatus
            ? null
            : o.deliveryStatus.toLowerCase();

        // 취소/환불은 2단계: DELIVERY_STATUS만 canceled면 "대기중"(ORDER_STATUS는 아직 이전 값 그대로),
        // ORDER_STATUS까지 canceled면 "완료"(진짜 종료). 스키마 변경 없이 기존 두 컬럼으로 표현함
        var cancelStage = null;
        if (deliveryStatus === 'canceled') {
            cancelStage = orderStatus === 'canceled' ? 'complete' : 'pending';
        }

        return {
            orderId: o.orderId,
            orderDateISO: o.orderDateISO,
            orderDateDisplay: o.orderDateDisplay,
            ordererName: o.ordererName,
            productName: o.productName,
            qty: o.qty,
            productCount: o.productCount,
            paymentAmount: o.paymentAmount,
            orderStatus: orderStatus,
            deliveryStatus: deliveryStatus,
            cancelStage: cancelStage,
            trackingNo: o.trackingNo,
            company: o.company
        };
    }

    function filterOrders(orders, filters) {
        var start = filters.startDate;
        var end = filters.endDate;
        var keyword = (filters.keyword || '').trim().toLowerCase();
        var statusFilter = filters.orderStatus || 'all';
        var paymentFilter = filters.paymentStatus || 'all';

        return orders.filter(function (o) {
            if (start && o.orderDateISO < start) return false;
            if (end && o.orderDateISO > end) return false;
            if (keyword &&
                String(o.orderId).toLowerCase().indexOf(keyword) === -1 &&
                (o.ordererName || '').toLowerCase().indexOf(keyword) === -1 &&
                (o.productName || '').toLowerCase().indexOf(keyword) === -1) return false;
            if (statusFilter !== 'all') {
                var matchesStatus = DELIVERY_LEVEL_STATUSES.indexOf(statusFilter) !== -1
                    ? o.deliveryStatus === statusFilter
                    : o.orderStatus === statusFilter;
                if (!matchesStatus) return false;
            }
            if (paymentFilter !== 'all' && getPaymentStatus(o) !== paymentFilter) return false;
            return true;
        });
    }

    function fetchOrders(url) {
        return fetch(url)
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '주문 목록을 불러오지 못했습니다.');
                }
                return {
                    orders: (result.data.orders || []).map(normalizeOrder),
                    summary: result.data.summary || { newOrders: 0, preparing: 0, shipped: 0, canceled: 0 }
                };
            });
    }

    // deliveryInfo: { deliveryStatus, trackingNo, company } (deliveryStatus는 대문자로 변환해서 전송)
    function saveDelivery(url, deliveryInfo) {
        return fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                deliveryStatus: (deliveryInfo.deliveryStatus || '').toUpperCase(),
                trackingNo: deliveryInfo.trackingNo,
                company: deliveryInfo.company
            })
        })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '저장에 실패했습니다.');
                }
                return result;
            });
    }

    function confirmPayment(url) {
        return fetch(url, { method: 'POST' })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '결제 완료 처리에 실패했습니다.');
                }
                return result;
            });
    }

    function completeCancel(url) {
        return fetch(url, { method: 'POST' })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '취소/환불 완료 처리에 실패했습니다.');
                }
                return result;
            });
    }

    window.AdminOrderService = {
        STATUS_LABEL: STATUS_LABEL,
        STATUS_ORDER: STATUS_ORDER,
        NEXT_ACTION_LABEL: NEXT_ACTION_LABEL,
        requiresCourierInfo: requiresCourierInfo,
        isValidCompany: isValidCompany,
        nextStatus: nextStatus,
        getPaymentStatus: getPaymentStatus,
        filterOrders: filterOrders,
        fetchOrders: fetchOrders,
        saveDelivery: saveDelivery,
        confirmPayment: confirmPayment,
        completeCancel: completeCancel
    };
})();
