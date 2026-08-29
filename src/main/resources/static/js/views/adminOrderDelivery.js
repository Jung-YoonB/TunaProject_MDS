// 관리자 - 주문/배송(adminOrderDelivery.jsp) 화면 인터랙션.
// 서버 통신/데이터 가공은 전부 window.AdminOrderService(business/adminOrderService.js)에 위임하고,
// 여기서는 DOM 조회/렌더링/이벤트 바인딩만 담당한다.
//
// "진행 현황"은 읽기 전용 배지로만 보여주고("결제 상태" 칸과 동일한 패턴), 실제 상태 변경은
// "관리" 칸의 액션 버튼(다음 단계로 / 주문 취소/환불)으로만 한다. 드롭다운으로 아무 상태나 고를 수
// 있게 했던 예전 방식은 역행/건너뛰기/자기자신 재선택 같은 걸 프론트에서 하나하나 막아야 해서
// 계속 새는 구조였음 - 애초에 유효한 다음 단계 하나만 버튼으로 보여주면 그런 문제 자체가 없다.
(function () {
    var Service = window.AdminOrderService;
    var STATUS_LABEL = Service.STATUS_LABEL;

    var root = document.querySelector('.admin-order-delivery-page');
    var ORDER_LIST_URL = root.dataset.orderListUrl;
    var ORDER_DELIVERY_URL_PREFIX = root.dataset.orderDeliveryUrlPrefix;
    var ORDER_PAYMENT_URL_PREFIX = root.dataset.orderPaymentUrlPrefix;
    var ORDER_CANCEL_COMPLETE_URL_PREFIX = root.dataset.orderCancelCompleteUrlPrefix;

    var ORDERS = [];
    var SUMMARY_COUNTS = { newOrders: 0, preparing: 0, shipped: 0, canceled: 0 };

    var startDateInput = document.getElementById('start-date');
    var endDateInput = document.getElementById('end-date');
    var keywordInput = document.getElementById('search-keyword');
    var orderStatusSelect = document.getElementById('order-status-filter');
    var paymentStatusSelect = document.getElementById('payment-status-filter');
    var searchForm = document.getElementById('admin-order-search-form');
    var listEl = document.getElementById('order-list');
    var sortOrderIdBtn = document.getElementById('sort-order-id');
    var sortArrowEl = sortOrderIdBtn.querySelector('.sort-arrow');

    // 주문번호 정렬 방향. 서버가 기본으로 오름차순(ASC)으로 내려주므로 초기값도 그에 맞춘다
    var sortDirection = 'asc';

    // 페이지네이션(공용 로직은 static/js/common/pagination.js) - onPageChange는 아래 render를
    // 참조하는데, 함수 선언은 호이스팅되므로 이 시점에 먼저 참조해도 문제없다
    var paginator = Pagination.create({
        pageSize: 10,
        prevButton: document.getElementById('pagination-prev'),
        nextButton: document.getElementById('pagination-next'),
        listElement: document.getElementById('pagination-list'),
        onPageChange: render
    });

    var modal = document.getElementById('delivery-info-modal');
    var modalStatusLabel = document.getElementById('modal-target-status-label');
    var modalCompanyInput = document.getElementById('modal-company');
    var modalTrackingInput = document.getElementById('modal-tracking-no');
    var modalCancelBtn = document.getElementById('modal-cancel-btn');
    var modalConfirmBtn = document.getElementById('modal-confirm-btn');

    var pendingRow = null; // 모달이 열려있는 동안, 대상 <tr>을 기억해둔다

    function formatWon(n) {
        return (n || 0).toLocaleString('ko-KR') + '원';
    }

    // 회원 이름/상품명은 실제 사용자 입력값이라 innerHTML에 그대로 넣으면 XSS 위험이 있어 이스케이프한다
    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    // "결제 상태" 칸도 취소/환불이 시작되면 그 사실을 보여줘야 하므로(계속 "결제완료"로 남아있으면
    // 헷갈림) cancelStage를 우선 확인하고, 아니면 기존처럼 결제대기/결제완료로 표시한다
    function buildPaymentStatusBadge(order) {
        if (order.cancelStage) {
            var cancelLabel = order.cancelStage === 'complete' ? '취소/환불 완료' : '취소/환불 대기중';
            var cancelCls = order.cancelStage === 'complete' ? 'cancel-complete' : 'cancel-pending';
            return '<span class="payment-badge ' + cancelCls + '">' + cancelLabel + '</span>';
        }
        var status = Service.getPaymentStatus(order);
        var label = status === 'payment_waiting' ? '결제대기' : '결제완료';
        var cls = status === 'payment_waiting' ? 'payment-waiting' : 'payment-completed';
        return '<span class="payment-badge ' + cls + '">' + label + '</span>';
    }

    // "진행 현황" 배지. statusKey는 deliveryStatus 값 그대로거나(preparing/shipped/...),
    // 취소/환불 단계 구분이 필요할 땐 'cancel_pending'/'cancel_complete'를 넘겨받는다
    function buildDeliveryStatusBadge(statusKey) {
        if (!statusKey) return '-';
        return '<span class="delivery-status-badge status-' + statusKey + '">' + STATUS_LABEL[statusKey] + '</span>';
    }

    function buildDeliveryInfoText(o) {
        if (!o.company && !o.trackingNo) return '-';
        return escapeHtml(o.company || '-') + ' / ' + escapeHtml(o.trackingNo || '-');
    }

    // ORDERDETAIL이 없는(대표 상품 조인이 안 된) 주문이면 productName/qty가 null로 오므로 방어
    function buildProductInfoText(o) {
        if (!o.productName) return '-';
        return escapeHtml(o.productName) + ' (' + o.qty + '개)' +
            (o.productCount > 1 ? ' 외 ' + (o.productCount - 1) + '건' : '');
    }

    function currentFilters() {
        return {
            startDate: startDateInput.value,
            endDate: endDateInput.value,
            keyword: keywordInput.value,
            orderStatus: orderStatusSelect.value,
            paymentStatus: paymentStatusSelect.value
        };
    }

    function renderSummary() {
        document.getElementById('count-new').textContent = SUMMARY_COUNTS.newOrders;
        document.getElementById('count-preparing').textContent = SUMMARY_COUNTS.preparing;
        document.getElementById('count-shipped').textContent = SUMMARY_COUNTS.shipped;
        document.getElementById('count-canceled').textContent = SUMMARY_COUNTS.canceled;
    }

    // 결제 대기: 배송 관련 항목은 아직 의미가 없으므로 "결제 완료 처리" 버튼만 제공
    function buildPaymentWaitingCells(o) {
        return '<td>-</td>' +
               '<td class="delivery-info-cell">-</td>' +
               '<td><button type="button" class="btn-confirm-payment">결제 완료 처리</button></td>';
    }

    // 취소/환불 처리 완료: 진짜 종료 상태라 더 이상 변경 불가, 읽기 전용으로만 표시
    function buildTerminalCells(o) {
        return '<td>' + buildDeliveryStatusBadge('cancel_complete') + '</td>' +
               '<td class="delivery-info-cell">' + buildDeliveryInfoText(o) + '</td>' +
               '<td>-</td>';
    }

    // 취소/환불 대기중: DELIVERY_STATUS만 canceled로 바뀐 상태. "처리 완료" 버튼으로 ORDER_STATUS까지
    // 맞춰야 진짜로 끝남 (updateDeliveryStatus가 아니라 별도의 completeCancel 엔드포인트를 씀)
    function buildCancelPendingCells(o) {
        return '<td>' + buildDeliveryStatusBadge('cancel_pending') + '</td>' +
               '<td class="delivery-info-cell">' + buildDeliveryInfoText(o) + '</td>' +
               '<td class="action-cell"><button type="button" class="btn-complete-cancel">처리 완료</button></td>';
    }

    // 배송준비중 전(행 없음)/배송준비중/배송중/배송출발/배송완료: "다음 단계로" 버튼(있으면) + "주문 취소/환불" 버튼.
    // 배송완료는 다음 단계가 없어서 nextStatus()가 null을 반환하므로 취소/환불 버튼만 남는다
    function buildEditableCells(o) {
        var next = Service.nextStatus(o.deliveryStatus);
        var actions = '';
        if (next) {
            actions += '<button type="button" class="btn-next-status" data-target-status="' + next + '">' +
                Service.NEXT_ACTION_LABEL[next] + '</button>';
        }
        actions += '<button type="button" class="btn-cancel-order">주문 취소/환불</button>';

        return '<td>' + buildDeliveryStatusBadge(o.deliveryStatus) + '</td>' +
               '<td class="delivery-info-cell">' + buildDeliveryInfoText(o) + '</td>' +
               '<td class="action-cell">' + actions + '</td>';
    }

    function buildRowCells(o) {
        if (o.orderStatus === 'payment_waiting') return buildPaymentWaitingCells(o);
        if (o.cancelStage === 'complete') return buildTerminalCells(o);
        if (o.cancelStage === 'pending') return buildCancelPendingCells(o);
        return buildEditableCells(o);
    }

    function render() {
        var filtered = Service.filterOrders(ORDERS, currentFilters());

        filtered = filtered.slice().sort(function (a, b) {
            return sortDirection === 'asc' ? a.orderId - b.orderId : b.orderId - a.orderId;
        });

        var paged = paginator.paginate(filtered);
        paginator.render(paged.totalPages);

        if (paged.pageItems.length === 0) {
            listEl.innerHTML = '<tr class="no-result"><td colspan="9">조건에 맞는 주문이 없습니다.</td></tr>';
            return;
        }

        listEl.innerHTML = paged.pageItems.map(function (o) {
            return '<tr data-order-id="' + o.orderId + '">' +
                        '<td>' + o.orderId + '</td>' +
                        '<td>' + o.orderDateDisplay + '</td>' +
                        '<td>' + escapeHtml(o.ordererName) + '</td>' +
                        '<td class="product-info-cell">' + buildProductInfoText(o) + '</td>' +
                        '<td>' + formatWon(o.paymentAmount) + '</td>' +
                        '<td>' + buildPaymentStatusBadge(o) + '</td>' +
                        buildRowCells(o) +
                    '</tr>';
        }).join('');
    }

    // 검색/필터/정렬이 바뀌면 지금 보던 페이지 번호는 더 이상 의미가 없으므로 1페이지로 되돌린다
    function renderFromFirstPage() {
        paginator.resetToFirstPage();
        render();
    }

    function loadOrders() {
        return Service.fetchOrders(ORDER_LIST_URL)
            .then(function (result) {
                ORDERS = result.orders;
                SUMMARY_COUNTS = result.summary;
                renderSummary();
                render();
            })
            .catch(function (err) {
                alert(err.message || '주문 목록을 불러오는 중 오류가 발생했습니다.');
            });
    }

    function closeModal() {
        modal.hidden = true;
        pendingRow = null;
    }

    function openModalFor(row, newStatus) {
        var order = ORDERS.filter(function (o) { return String(o.orderId) === row.dataset.orderId; })[0];
        pendingRow = row;
        pendingRow.dataset.pendingStatus = newStatus;
        modalStatusLabel.textContent = STATUS_LABEL[newStatus];
        modalCompanyInput.value = (order && order.company) || '';
        modalTrackingInput.value = (order && order.trackingNo) || '';
        modal.hidden = false;
        modalCompanyInput.focus();
    }

    function findOrder(row) {
        return ORDERS.filter(function (o) { return String(o.orderId) === row.dataset.orderId; })[0];
    }

    searchForm.addEventListener('submit', function (e) {
        e.preventDefault();
        renderFromFirstPage();
    });

    orderStatusSelect.addEventListener('change', renderFromFirstPage);
    paymentStatusSelect.addEventListener('change', renderFromFirstPage);

    sortOrderIdBtn.addEventListener('click', function () {
        sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
        sortArrowEl.textContent = sortDirection === 'asc' ? '▲' : '▼';
        renderFromFirstPage();
    });

    listEl.addEventListener('click', function (e) {
        if (e.target.classList.contains('btn-confirm-payment')) {
            var payBtn = e.target;
            var payRow = payBtn.closest('tr');

            if (!window.confirm('결제를 완료 처리하시겠습니까?')) return;

            payBtn.disabled = true;
            Service.confirmPayment(ORDER_PAYMENT_URL_PREFIX + payRow.dataset.orderId)
                .then(function () { return loadOrders(); })
                .catch(function (err) {
                    alert(err.message || '결제 완료 처리 중 오류가 발생했습니다.');
                    payBtn.disabled = false;
                });
            return;
        }

        if (e.target.classList.contains('btn-next-status')) {
            var btn = e.target;
            var row = btn.closest('tr');
            var newStatus = btn.dataset.targetStatus;
            var order = findOrder(row);

            // 배송중 계열 상태는 택배사/송장번호가 필요하지만, 이미 입력돼 있으면(예: 배송중 -> 배송출발처럼
            // 같은 배송 건 안에서 더 진행되는 경우) 다시 물어볼 필요 없이 있는 값 그대로 저장한다.
            // 아직 값이 없거나(처음 배송중 계열로 넘어갈 때), 기존 값이 지금 기준 택배사 목록에
            // 없을 때(드롭다운 도입 전에 자유 입력으로 저장된 값 등)는 모달을 다시 띄워 고르게 한다
            var hasCourierInfo = order && order.company && order.trackingNo && Service.isValidCompany(order.company);
            if (Service.requiresCourierInfo(newStatus) && !hasCourierInfo) {
                openModalFor(row, newStatus);
                return;
            }

            if (!window.confirm("정말로 '" + Service.NEXT_ACTION_LABEL[newStatus] + "'을(를) 진행하시겠습니까?")) return;

            btn.disabled = true;
            Service.saveDelivery(ORDER_DELIVERY_URL_PREFIX + row.dataset.orderId, {
                deliveryStatus: newStatus,
                trackingNo: order && order.trackingNo,
                company: order && order.company
            })
                .then(function () { return loadOrders(); })
                .catch(function (err) {
                    alert(err.message || '저장 중 오류가 발생했습니다.');
                    btn.disabled = false;
                });
            return;
        }

        if (e.target.classList.contains('btn-cancel-order')) {
            var cancelBtn = e.target;
            var cancelRow = cancelBtn.closest('tr');
            var cancelOrder = findOrder(cancelRow);

            if (!window.confirm('정말로 이 주문을 취소/환불 처리하시겠습니까?')) return;

            cancelBtn.disabled = true;
            Service.saveDelivery(ORDER_DELIVERY_URL_PREFIX + cancelRow.dataset.orderId, {
                deliveryStatus: 'canceled',
                trackingNo: cancelOrder && cancelOrder.trackingNo,
                company: cancelOrder && cancelOrder.company
            })
                .then(function () { return loadOrders(); })
                .catch(function (err) {
                    alert(err.message || '주문 취소/환불 처리 중 오류가 발생했습니다.');
                    cancelBtn.disabled = false;
                });
            return;
        }

        if (e.target.classList.contains('btn-complete-cancel')) {
            var completeBtn = e.target;
            var completeRow = completeBtn.closest('tr');

            if (!window.confirm('취소/환불 처리를 완료하시겠습니까? 완료 후에는 되돌릴 수 없습니다.')) return;

            completeBtn.disabled = true;
            Service.completeCancel(ORDER_CANCEL_COMPLETE_URL_PREFIX + completeRow.dataset.orderId)
                .then(function () { return loadOrders(); })
                .catch(function (err) {
                    alert(err.message || '취소/환불 처리 완료 중 오류가 발생했습니다.');
                    completeBtn.disabled = false;
                });
        }
    });

    modalCancelBtn.addEventListener('click', closeModal);

    modal.addEventListener('click', function (e) {
        if (e.target === modal) closeModal();
    });

    modalConfirmBtn.addEventListener('click', function () {
        if (!pendingRow) return;
        var row = pendingRow;
        var newStatus = row.dataset.pendingStatus;
        var company = modalCompanyInput.value.trim();
        var trackingNo = modalTrackingInput.value.trim();

        if (!company || !trackingNo) {
            alert('택배사와 송장번호를 모두 입력해주세요.');
            return;
        }

        modalConfirmBtn.disabled = true;
        Service.saveDelivery(ORDER_DELIVERY_URL_PREFIX + row.dataset.orderId, {
            deliveryStatus: newStatus,
            trackingNo: trackingNo,
            company: company
        })
            .then(function () {
                closeModal();
                return loadOrders();
            })
            .catch(function (err) {
                alert(err.message || '저장 중 오류가 발생했습니다.');
            })
            .finally(function () {
                modalConfirmBtn.disabled = false;
            });
    });

    loadOrders();
})();
