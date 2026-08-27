<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>주문/배송내역</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/default.css">

    <!-- 주문 전용 CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/style_order.css">

</head>

<body class="order-delivery-page">

    <main>

        <h1 class="page-title">주문/배송내역</h1>

        <nav class="status-filter" id="order-status-filter" aria-label="주문 상태 필터">
            <button type="button" class="is-active" data-status="all">전체</button>
            <button type="button" data-status="preparing">배송준비중</button>
            <button type="button" data-status="shipped">배송중</button>
            <button type="button" data-status="delivered">배송완료</button>
        </nav>

        <section class="order-list" id="order-list" aria-label="주문 목록"></section>

        <p class="order-empty" id="order-empty" hidden>주문/배송내역이 없습니다.</p>

        <div class="order-back">
            <a class="btn-back-mypage" href="<c:url value='/member/mypage'/>">마이페이지로 돌아가기</a>
        </div>

    </main>

    <%-- TODO(data binding): Order/Delivery/OrderDetail/ProductOption 테이블 연동 필요.
         현재는 테스트용 예시 주문 3건을 하드코딩. 배송 상태(status)는 Delivery 테이블의
         배송 상태 값과 매핑해야 하며, 진행 단계(주문완료/배송준비중/배송중/배송완료)도
         실제 Delivery 이력 데이터를 기준으로 계산해야 함.
         수량(qty)은 OrderDetail 테이블의 qty, 옵션명(optionName)과 금액(price)은
         ProductOption 테이블의 option_name, option_price에서 가져와야 함 — 현재는 테스트용 임의값. --%>
    <script>
    (function () {
        var STEP_LABELS = ['주문완료', '배송준비중', '배송중', '배송완료'];
        var STATUS_STEP_INDEX = { preparing: 1, shipped: 2, delivered: 3, canceled: 1 };
        var STATUS_BADGE_LABEL = { preparing: '배송준비중', shipped: '배송중', delivered: '배송완료', canceled: '주문취소' };

        var ORDERS = [
            { orderId: '20260815-001', orderDate: '2026.08.15', productName: '프리미엄 한우 선물세트', optionName: '1++ 등급 / 1kg', qty: 1, price: 129000, status: 'preparing' },
            { orderId: '20260812-003', orderDate: '2026.08.12', productName: '전통 과일 선물세트', optionName: '중과 5호 / 3kg', qty: 2, price: 118000, status: 'shipped' },
            { orderId: '20260805-007', orderDate: '2026.08.05', productName: '프리미엄 견과 선물세트', optionName: '혼합 선물세트 / 1.5kg', qty: 1, price: 75000, status: 'delivered' }
        ];

        var REVIEW_WRITER_URL = '<c:url value="/temp/reviewWriter.html"/>';

        var filterBar = document.getElementById('order-status-filter');
        var listEl = document.getElementById('order-list');
        var emptyEl = document.getElementById('order-empty');
        var currentFilter = 'all';

        function formatWon(n) {
            return n.toLocaleString('ko-KR') + '원';
        }

        function buildProgress(status) {
            var currentIndex = STATUS_STEP_INDEX[status];
            var html = '';
            STEP_LABELS.forEach(function (label, i) {
                var isTerminalComplete = (i === currentIndex && currentIndex === STEP_LABELS.length - 1);
                var stepClass;
                if (i < currentIndex || isTerminalComplete) {
                    stepClass = 'is-complete';
                } else if (i === currentIndex) {
                    stepClass = 'is-current status-' + status;
                } else {
                    stepClass = 'is-upcoming';
                }
                html += '<div class="progress-step ' + stepClass + '">' +
                            '<span class="step-icon">' + (stepClass.indexOf('is-complete') === 0 ? '✓' : '') + '</span>' +
                            '<span class="step-label">' + label + '</span>' +
                        '</div>';
                if (i < STEP_LABELS.length - 1) {
                    var lineClass = i < currentIndex ? 'is-complete' : '';
                    html += '<div class="progress-line ' + lineClass + '"></div>';
                }
            });
            return html;
        }

        function render() {
            var filtered = currentFilter === 'all' ? ORDERS : ORDERS.filter(function (o) { return o.status === currentFilter; });
            var isEmpty = filtered.length === 0;
            listEl.hidden = isEmpty;
            emptyEl.hidden = !isEmpty;
            if (isEmpty) return;

            listEl.innerHTML = '';
            filtered.forEach(function (order) {
                var card = document.createElement('article');
                card.className = 'order-card';
                card.innerHTML =
                    '<div class="order-header">' +
                        '<span class="order-number">주문번호 <strong>' + order.orderId + '</strong></span>' +
                        '<span class="order-date">주문일 ' + order.orderDate + '</span>' +
                    '</div>' +
                    '<div class="order-body">' +
                        '<div class="item-thumb"></div>' +
                        '<div class="order-info">' +
                            '<h3 class="product-name">' + order.productName + '</h3>' +
                            '<p class="product-option">' + order.optionName + '</p>' +
                            '<p class="product-detail">수량: ' + order.qty + '개 | 금액: ' + formatWon(order.price) + '</p>' +
                        '</div>' +
                        '<span class="status-badge status-' + order.status + '">' + STATUS_BADGE_LABEL[order.status] + '</span>' +
                    '</div>' +
                    '<div class="order-progress">' + buildProgress(order.status) + '</div>' +
                    '<div class="order-actions">' +
                        '<button type="button" class="btn-track">배송조회</button>' +
                        (order.status === 'preparing' ? '<button type="button" class="btn-cancel">주문취소</button>' : '') +
                        (order.status === 'delivered' ? '<a class="btn-review" href="' + REVIEW_WRITER_URL + '">리뷰작성</a>' : '') +
                    '</div>';
                listEl.appendChild(card);
            });
        }

        filterBar.addEventListener('click', function (e) {
            var btn = e.target.closest('button[data-status]');
            if (!btn) return;
            currentFilter = btn.dataset.status;
            filterBar.querySelectorAll('button').forEach(function (b) { b.classList.remove('is-active'); });
            btn.classList.add('is-active');
            render();
        });

        render();
    })();
    </script>

</body>

</html>
