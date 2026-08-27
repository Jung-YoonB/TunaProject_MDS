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

    <%-- TODO(data binding): ProductOrder/Delivery/OrderDetail/Product/Member 테이블 연동 필요.
         현재는 테스트용 예시 주문 18건을 하드코딩.
         - orderId: ProductOrder.order_id (실제 PK는 NUMBER 시퀀스. 'YYYYMMDD-NNN' 표기는
           프론트 목업 전용 표시 형식이며 실제 바인딩 시 별도 포맷팅 로직 필요)
         - orderDate: ProductOrder.order_date
         - ordererName: Member.member_name / Member.nickname
         - productName, qty: Product.product_name, OrderDetail.qty
           (한 주문에 상품이 여러 건일 수 있으나 목업은 대표 상품 1건만 표시)
         - paymentAmount: ProductOrder.total_price
         - orderStatus(주문 상태 필터): ProductOrder.order_status
           (payment_waiting/payment_completed/preparing/shipped/delivered/canceled.
            cart 상태는 아직 주문이 확정되지 않은 상태이므로 관리자 화면 필터에서 제외)
         - deliveryStatus(진행 현황 드롭다운): Delivery.delivery_status
           (preparing/shipped/out_for_delivery/delivered/canceled — order_status와는
            별개의 테이블/enum이므로 혼동하지 않도록 주의)
         - trackingNo: Delivery.tracking_no
         - paymentStatus(결제 상태 필터 + 표 내 결제 상태 배지): DB에 별도 컬럼 없음.
           order_status에서 파생한 목업 전용 값(payment_waiting→결제대기, 그 외→결제완료)이며
           실제로는 재설계 필요
         - 저장 시 확인 팝업: window.confirm()으로만 처리하는 프론트 전용 목업. 실제로는
           서버 응답/실패 처리까지 포함한 별도 확인 UX 설계 필요
         - 대시보드 요약 카운트(신규 주문/배송 준비중/배송중/취소·환불): 실제로는 상태별
           COUNT(*) 집계 쿼리 결과. 현재는 고정 목업 수치이며 표에 보이는 표본 건수와 무관
         - 저장 버튼: 현재는 시각적 확인만 수행(no-op). 실제로는 PUT/POST로
           Delivery.delivery_status, Delivery.tracking_no 갱신 필요
         - 페이지네이션: 정적 목업. 실제로는 페이징 쿼리 필요 --%>
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

        var ORDERS = [
            { orderId: '20260915-001', orderDateISO: '2026-09-15', orderDateDisplay: '2026.09.15 09:12', ordererName: '홍길동', productName: '프리미엄 한우 선물세트', qty: 1, paymentAmount: 129000, orderStatus: 'payment_completed', deliveryStatus: 'preparing', trackingNo: '' },
            { orderId: '20260914-002', orderDateISO: '2026-09-14', orderDateDisplay: '2026.09.14 14:05', ordererName: '김민지', productName: '전통 과일 선물세트', qty: 2, paymentAmount: 118000, orderStatus: 'preparing', deliveryStatus: 'preparing', trackingNo: '' },
            { orderId: '20260913-003', orderDateISO: '2026-09-13', orderDateDisplay: '2026.09.13 11:47', ordererName: '이수정', productName: '프리미엄 견과 선물세트', qty: 1, paymentAmount: 75000, orderStatus: 'shipped', deliveryStatus: 'shipped', trackingNo: '6123456789' },
            { orderId: '20260912-004', orderDateISO: '2026-09-12', orderDateDisplay: '2026.09.12 16:30', ordererName: '박지훈', productName: '코코도르 그란데 디퓨저', qty: 1, paymentAmount: 25800, orderStatus: 'shipped', deliveryStatus: 'shipped', trackingNo: '6123456790' },
            { orderId: '20260911-005', orderDateISO: '2026-09-11', orderDateDisplay: '2026.09.11 10:05', ordererName: '최윤아', productName: '놋향 방짜유기 수저세트', qty: 2, paymentAmount: 85800, orderStatus: 'shipped', deliveryStatus: 'out_for_delivery', trackingNo: '9988776655' },
            { orderId: '20260910-006', orderDateISO: '2026-09-10', orderDateDisplay: '2026.09.10 13:20', ordererName: '정하늘', productName: '프리미엄 한우 선물세트', qty: 1, paymentAmount: 129000, orderStatus: 'shipped', deliveryStatus: 'out_for_delivery', trackingNo: '9988776656' },
            { orderId: '20260909-007', orderDateISO: '2026-09-09', orderDateDisplay: '2026.09.09 09:55', ordererName: '오세훈', productName: '전통 과일 선물세트', qty: 1, paymentAmount: 59000, orderStatus: 'delivered', deliveryStatus: 'delivered', trackingNo: '5566778899' },
            { orderId: '20260908-008', orderDateISO: '2026-09-08', orderDateDisplay: '2026.09.08 15:10', ordererName: '강수진', productName: '프리미엄 견과 선물세트', qty: 2, paymentAmount: 150000, orderStatus: 'delivered', deliveryStatus: 'delivered', trackingNo: '5566778900' },
            { orderId: '20260907-009', orderDateISO: '2026-09-07', orderDateDisplay: '2026.09.07 12:00', ordererName: '윤도현', productName: '코코도르 그란데 디퓨저', qty: 1, paymentAmount: 25800, orderStatus: 'delivered', deliveryStatus: 'delivered', trackingNo: '5566778901' },
            { orderId: '20260906-010', orderDateISO: '2026-09-06', orderDateDisplay: '2026.09.06 17:42', ordererName: '한지민', productName: '놋향 방짜유기 수저세트', qty: 1, paymentAmount: 42900, orderStatus: 'delivered', deliveryStatus: 'delivered', trackingNo: '5566778902' },
            { orderId: '20260905-011', orderDateISO: '2026-09-05', orderDateDisplay: '2026.09.05 08:30', ordererName: '서동현', productName: '프리미엄 한우 선물세트', qty: 2, paymentAmount: 258000, orderStatus: 'delivered', deliveryStatus: 'delivered', trackingNo: '5566778903' },
            { orderId: '20260904-012', orderDateISO: '2026-09-04', orderDateDisplay: '2026.09.04 11:15', ordererName: '임서연', productName: '전통 과일 선물세트', qty: 1, paymentAmount: 59000, orderStatus: 'canceled', deliveryStatus: 'canceled', trackingNo: '' },
            { orderId: '20260903-013', orderDateISO: '2026-09-03', orderDateDisplay: '2026.09.03 14:48', ordererName: '조현우', productName: '프리미엄 견과 선물세트', qty: 1, paymentAmount: 75000, orderStatus: 'canceled', deliveryStatus: 'canceled', trackingNo: '' },
            { orderId: '20260902-014', orderDateISO: '2026-09-02', orderDateDisplay: '2026.09.02 10:22', ordererName: '배수아', productName: '코코도르 그란데 디퓨저', qty: 2, paymentAmount: 51600, orderStatus: 'payment_completed', deliveryStatus: 'preparing', trackingNo: '' },
            { orderId: '20260901-015', orderDateISO: '2026-09-01', orderDateDisplay: '2026.09.01 09:05', ordererName: '남궁민', productName: '놋향 방짜유기 수저세트', qty: 1, paymentAmount: 42900, orderStatus: 'preparing', deliveryStatus: 'preparing', trackingNo: '' },
            { orderId: '20260831-016', orderDateISO: '2026-08-31', orderDateDisplay: '2026.08.31 16:00', ordererName: '유지혜', productName: '프리미엄 한우 선물세트', qty: 1, paymentAmount: 129000, orderStatus: 'shipped', deliveryStatus: 'shipped', trackingNo: '6123456791' },
            { orderId: '20260830-017', orderDateISO: '2026-08-30', orderDateDisplay: '2026.08.30 13:33', ordererName: '문가영', productName: '전통 과일 선물세트', qty: 3, paymentAmount: 177000, orderStatus: 'shipped', deliveryStatus: 'out_for_delivery', trackingNo: '9988776657' },
            { orderId: '20260829-018', orderDateISO: '2026-08-29', orderDateDisplay: '2026.08.29 09:47', ordererName: '신동엽', productName: '프리미엄 견과 선물세트', qty: 1, paymentAmount: 75000, orderStatus: 'payment_waiting', deliveryStatus: 'preparing', trackingNo: '' }
        ];

        // 대시보드 요약치는 ORDERS 표본(18건)과는 독립된 전체 집계 목업 값.
        // 실제로는 상태별 COUNT(*) 집계 쿼리 결과.
        var SUMMARY_COUNTS = { newOrders: 12, preparing: 45, shipped: 128, canceled: 3 };

        var startDateInput = document.getElementById('start-date');
        var endDateInput = document.getElementById('end-date');
        var keywordInput = document.getElementById('search-keyword');
        var orderStatusSelect = document.getElementById('order-status-filter');
        var paymentStatusSelect = document.getElementById('payment-status-filter');
        var searchForm = document.getElementById('admin-order-search-form');
        var listEl = document.getElementById('order-list');

        function formatWon(n) {
            return n.toLocaleString('ko-KR') + '원';
        }

        // TODO(data binding): DB에 결제 상태 전용 컬럼이 없어 order_status에서 파생한 목업 전용 값.
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
                    o.orderId.toLowerCase().indexOf(keyword) === -1 &&
                    o.ordererName.toLowerCase().indexOf(keyword) === -1 &&
                    o.productName.toLowerCase().indexOf(keyword) === -1) return false;
                if (statusFilter !== 'all' && o.orderStatus !== statusFilter) return false;
                if (paymentFilter !== 'all' && getPaymentStatus(o) !== paymentFilter) return false;
                return true;
            });
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
                            '<td>' + o.ordererName + '</td>' +
                            '<td class="product-info-cell">' + o.productName + ' (' + o.qty + '개)</td>' +
                            '<td>' + formatWon(o.paymentAmount) + '</td>' +
                            '<td>' + buildPaymentStatusBadge(o) + '</td>' +
                            '<td><select class="delivery-status-select status-' + o.deliveryStatus + '">' + buildDeliveryStatusOptions(o.deliveryStatus) + '</select></td>' +
                            '<td><input type="text" class="tracking-input" value="' + o.trackingNo + '" placeholder="송장번호 입력"></td>' +
                            '<td><button type="button" class="btn-save-row">저장</button></td>' +
                        '</tr>';
            }).join('');
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

        // TODO(data binding): 실제로는 여기서 Delivery.delivery_status/tracking_no를
        // 갱신하는 API(PUT/POST)를 호출해야 함. 현재는 시각적 확인만 수행.
        listEl.addEventListener('click', function (e) {
            if (!e.target.classList.contains('btn-save-row')) return;
            var btn = e.target;
            var row = btn.closest('tr');
            var select = row.querySelector('.delivery-status-select');
            var newLabel = select.options[select.selectedIndex].textContent;

            if (!window.confirm("정말로 '" + newLabel + "'으로 변경하시겠습니까?")) {
                var originalStatus = row.dataset.deliveryStatus;
                select.value = originalStatus;
                STATUS_ORDER.forEach(function (status) { select.classList.remove('status-' + status); });
                select.classList.add('status-' + originalStatus);
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
        });

        renderSummary();
        render();
    })();
    </script>

</body>

</html>
