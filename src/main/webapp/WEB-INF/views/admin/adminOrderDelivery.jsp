<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>주문/배송 관리</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/default.css">

    <!-- 관리자 주문/배송 관리 전용 CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/style_admin_order.css">

</head>

<body class="admin-order-delivery-page">

    <main>

        <h1 class="page-title">주문/배송 관리</h1>

        <section class="dashboard-summary" aria-label="주문 현황 요약">
            <ul class="summary-card-list">
                <li class="summary-card">
                    <span class="label">신규 주문</span>
                    <strong class="count" id="count-new">0</strong>
                </li>
                <li class="summary-card">
                    <span class="label">배송 준비중</span>
                    <strong class="count" id="count-preparing">0</strong>
                </li>
                <li class="summary-card">
                    <span class="label">배송중</span>
                    <strong class="count" id="count-shipped">0</strong>
                </li>
                <li class="summary-card">
                    <span class="label">취소/환불</span>
                    <strong class="count" id="count-canceled">0</strong>
                </li>
            </ul>
        </section>

        <section class="filter-section" aria-label="주문 검색 필터">
            <form id="admin-order-search-form">
                <div class="filter-row filter-row-primary">
                    <div class="filter-group">
                        <label for="start-date">조회 기간</label>
                        <input type="date" id="start-date" name="startDate">
                        <span class="range-sep">~</span>
                        <input type="date" id="end-date" name="endDate">
                    </div>
                    <div class="filter-group">
                        <label for="search-keyword">검색어</label>
                        <input type="text" id="search-keyword" name="keyword" placeholder="주문번호, 주문자명, 상품명으로 검색">
                        <button type="submit" class="search-btn">검색</button>
                    </div>
                </div>
                <div class="filter-row">
                    <label for="order-status-filter">주문 상태</label>
                    <select id="order-status-filter" name="orderStatus">
                        <option value="all">전체</option>
                        <option value="payment_waiting">결제대기</option>
                        <option value="payment_completed">결제완료</option>
                        <option value="preparing">배송준비중</option>
                        <option value="shipped">배송중</option>
                        <option value="delivered">배송완료</option>
                        <option value="canceled">주문취소</option>
                    </select>

                    <label for="payment-status-filter">결제 상태</label>
                    <select id="payment-status-filter" name="paymentStatus">
                        <option value="all">전체</option>
                        <option value="payment_waiting">결제대기</option>
                        <option value="payment_completed">결제완료</option>
                    </select>
                </div>
            </form>
        </section>

        <section class="data-table" aria-label="주문 내역 목록">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>주문번호</th>
                        <th>주문일시</th>
                        <th>주문자</th>
                        <th>상품 정보</th>
                        <th>결제금액</th>
                        <th>결제 상태</th>
                        <th>진행 현황</th>
                        <th>송장번호</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody id="order-list"></tbody>
            </table>
        </section>

        <nav class="pagination" aria-label="페이지 탐색">
            <button type="button" class="btn-prev">← 이전</button>
            <ol>
                <li><button type="button" class="is-active" aria-current="page">1</button></li>
                <li><button type="button">2</button></li>
                <li><button type="button">3</button></li>
                <li><button type="button">4</button></li>
                <li><button type="button">5</button></li>
            </ol>
            <button type="button" class="btn-next">다음 →</button>
        </nav>

    </main>

    <%-- 데이터 연동 완료: GET /admin/order/list (주문 목록 + 요약 카운트), POST /admin/order/delivery/{orderId}
         (배송 상태/송장번호 저장). 대표 상품/건수는 ORDERDETAIL 중 가장 먼저 담긴 1건 기준이며,
         orderId는 주문 PK(NUMBER)를 그대로 표시한다(목업의 'YYYYMMDD-NNN' 표기는 사용하지 않음).
         조회 기간/검색어 필터는 기존처럼 프론트에서 클라이언트 필터링한다. --%>
    <script>
    (function () {
        var STATUS_LABEL = {
            preparing: '배송준비중',
            shipped: '배송중',
            out_for_delivery: '배송출발',
            delivered: '배송완료',
            canceled: '취소'
        };
        var STATUS_ORDER = ['preparing', 'shipped', 'out_for_delivery', 'delivered', 'canceled'];

        var ORDERS = [];
        var SUMMARY_COUNTS = { newOrders: 0, preparing: 0, shipped: 0, canceled: 0 };

        var startDateInput = document.getElementById('start-date');
        var endDateInput = document.getElementById('end-date');
        var keywordInput = document.getElementById('search-keyword');
        var orderStatusSelect = document.getElementById('order-status-filter');
        var paymentStatusSelect = document.getElementById('payment-status-filter');
        var searchForm = document.getElementById('admin-order-search-form');
        var listEl = document.getElementById('order-list');

        function formatWon(n) {
            return (n || 0).toLocaleString('ko-KR') + '원';
        }

        // DB에 결제 상태 전용 컬럼이 없어 order_status에서 파생
        function getPaymentStatus(order) {
            return order.orderStatus === 'payment_waiting' ? 'payment_waiting' : 'payment_completed';
        }

        function buildPaymentStatusBadge(order) {
            var status = getPaymentStatus(order);
            var label = status === 'payment_waiting' ? '결제대기' : '결제완료';
            var cls = status === 'payment_waiting' ? 'payment-waiting' : 'payment-completed';
            return '<span class="payment-badge ' + cls + '">' + label + '</span>';
        }

        function buildDeliveryStatusOptions(current) {
            return STATUS_ORDER.map(function (status) {
                var selected = status === current ? ' selected' : '';
                return '<option value="' + status + '"' + selected + '>' + STATUS_LABEL[status] + '</option>';
            }).join('');
        }

        function applyFilters() {
            var start = startDateInput.value;
            var end = endDateInput.value;
            var keyword = keywordInput.value.trim().toLowerCase();
            var statusFilter = orderStatusSelect.value;
            var paymentFilter = paymentStatusSelect.value;

            return ORDERS.filter(function (o) {
                if (start && o.orderDateISO < start) return false;
                if (end && o.orderDateISO > end) return false;
                if (keyword &&
                    String(o.orderId).toLowerCase().indexOf(keyword) === -1 &&
                    (o.ordererName || '').toLowerCase().indexOf(keyword) === -1 &&
                    (o.productName || '').toLowerCase().indexOf(keyword) === -1) return false;
                if (statusFilter !== 'all' && o.orderStatus !== statusFilter) return false;
                if (paymentFilter !== 'all' && getPaymentStatus(o) !== paymentFilter) return false;
                return true;
            });
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

        function renderSummary() {
            document.getElementById('count-new').textContent = SUMMARY_COUNTS.newOrders;
            document.getElementById('count-preparing').textContent = SUMMARY_COUNTS.preparing;
            document.getElementById('count-shipped').textContent = SUMMARY_COUNTS.shipped;
            document.getElementById('count-canceled').textContent = SUMMARY_COUNTS.canceled;
        }

        function render() {
            var filtered = applyFilters();

            if (filtered.length === 0) {
                listEl.innerHTML = '<tr class="no-result"><td colspan="9">조건에 맞는 주문이 없습니다.</td></tr>';
                return;
            }

            listEl.innerHTML = filtered.map(function (o) {
                return '<tr data-order-id="' + o.orderId + '" data-delivery-status="' + o.deliveryStatus + '">' +
                            '<td>' + o.orderId + '</td>' +
                            '<td>' + o.orderDateDisplay + '</td>' +
                            '<td>' + escapeHtml(o.ordererName) + '</td>' +
                            '<td class="product-info-cell">' + escapeHtml(o.productName) + ' (' + o.qty + '개)' +
                                (o.productCount > 1 ? ' 외 ' + (o.productCount - 1) + '건' : '') + '</td>' +
                            '<td>' + formatWon(o.paymentAmount) + '</td>' +
                            '<td>' + buildPaymentStatusBadge(o) + '</td>' +
                            '<td><select class="delivery-status-select status-' + o.deliveryStatus + '">' + buildDeliveryStatusOptions(o.deliveryStatus) + '</select></td>' +
                            '<td><input type="text" class="tracking-input" value="' + escapeHtml(o.trackingNo || '') + '" placeholder="송장번호 입력"></td>' +
                            '<td><button type="button" class="btn-save-row">저장</button></td>' +
                        '</tr>';
            }).join('');
        }

        // 서버에서 받은 주문 목록(DB 값은 대문자: PAYMENT_COMPLETED 등)을
        // 기존 필터/렌더 로직이 기대하는 소문자 키 값으로 변환
        function normalizeOrder(o) {
            return {
                orderId: o.orderId,
                orderDateISO: o.orderDateISO,
                orderDateDisplay: o.orderDateDisplay,
                ordererName: o.ordererName,
                productName: o.productName,
                qty: o.qty,
                productCount: o.productCount,
                paymentAmount: o.paymentAmount,
                orderStatus: (o.orderStatus || '').toLowerCase(),
                deliveryStatus: (o.deliveryStatus || 'preparing').toLowerCase(),
                trackingNo: o.trackingNo
            };
        }

        function loadOrders() {
            fetch('<c:url value="/admin/order/list"/>')
                .then(function (response) { return response.json(); })
                .then(function (result) {
                    if (!result.success) {
                        alert(result.message || '주문 목록을 불러오지 못했습니다.');
                        return;
                    }
                    ORDERS = (result.data.orders || []).map(normalizeOrder);
                    SUMMARY_COUNTS = result.data.summary || SUMMARY_COUNTS;
                    renderSummary();
                    render();
                })
                .catch(function () {
                    alert('주문 목록을 불러오는 중 오류가 발생했습니다.');
                });
        }

        searchForm.addEventListener('submit', function (e) {
            e.preventDefault();
            render();
        });

        orderStatusSelect.addEventListener('change', render);
        paymentStatusSelect.addEventListener('change', render);

        listEl.addEventListener('change', function (e) {
            if (e.target.classList.contains('delivery-status-select')) {
                STATUS_ORDER.forEach(function (status) {
                    e.target.classList.remove('status-' + status);
                });
                e.target.classList.add('status-' + e.target.value);
            }
        });

        listEl.addEventListener('click', function (e) {
            if (!e.target.classList.contains('btn-save-row')) return;
            var btn = e.target;
            var row = btn.closest('tr');
            var orderId = row.dataset.orderId;
            var select = row.querySelector('.delivery-status-select');
            var trackingInput = row.querySelector('.tracking-input');
            var newLabel = select.options[select.selectedIndex].textContent;
            var originalStatus = row.dataset.deliveryStatus;

            function revertSelect() {
                select.value = originalStatus;
                STATUS_ORDER.forEach(function (status) { select.classList.remove('status-' + status); });
                select.classList.add('status-' + originalStatus);
            }

            if (!window.confirm("정말로 '" + newLabel + "'으로 변경하시겠습니까?")) {
                revertSelect();
                return;
            }

            btn.disabled = true;

            fetch('<c:url value="/admin/order/delivery/"/>' + orderId, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    deliveryStatus: select.value.toUpperCase(),
                    trackingNo: trackingInput.value
                })
            })
                .then(function (response) { return response.json(); })
                .then(function (result) {
                    if (!result.success) {
                        alert(result.message || '저장에 실패했습니다.');
                        revertSelect();
                        return;
                    }

                    row.dataset.deliveryStatus = select.value;
                    var originalText = btn.textContent;
                    btn.textContent = '저장완료';
                    btn.classList.add('is-saved');
                    setTimeout(function () {
                        btn.textContent = originalText;
                        btn.classList.remove('is-saved');
                    }, 1000);
                })
                .catch(function () {
                    alert('저장 중 오류가 발생했습니다.');
                    revertSelect();
                })
                .finally(function () {
                    btn.disabled = false;
                });
        });

        loadOrders();
    })();
    </script>

</body>

</html>
