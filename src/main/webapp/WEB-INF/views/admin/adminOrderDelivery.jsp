<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 이미 모든 페이지 공통 CSS(style_admin_order.css 포함)를 로드하므로 별도 link 불필요 --%>
<div class="admin-order-delivery-page"
     data-order-list-url="<c:url value='/admin/order/list'/>"
     data-order-delivery-url-prefix="<c:url value='/admin/order/delivery/'/>"
     data-order-payment-url-prefix="<c:url value='/admin/order/payment/'/>"
     data-order-cancel-complete-url-prefix="<c:url value='/admin/order/cancel-complete/'/>">

    <%-- header.jsp가 이미 <main>을 열어서 폭 제약이 없으므로, 원래 main 태그가 담당하던
         가운데 정렬/최대폭(1100px)은 이 내부 wrapper(.page-content)가 대신 담당한다 --%>
    <div class="page-content">

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
                        <option value="canceled">취소/환불</option>
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
                        <th><button type="button" id="sort-order-id" class="th-sort-btn">주문번호 <span class="sort-arrow">▲</span></button></th>
                        <th>주문일시</th>
                        <th>주문자</th>
                        <th>상품 정보</th>
                        <th>결제금액</th>
                        <th>결제 상태</th>
                        <th>진행 현황</th>
                        <th>배송 정보</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody id="order-list"></tbody>
            </table>
        </section>

        <%-- 페이지 번호(1~5)는 이제 정적 목업이 아니라 JS(renderPagination)가 결과 개수에 맞춰 직접 채움 --%>
        <nav class="pagination" aria-label="페이지 탐색">
            <button type="button" id="pagination-prev" class="btn-prev">← 이전</button>
            <ol id="pagination-list"></ol>
            <button type="button" id="pagination-next" class="btn-next">다음 →</button>
        </nav>

    </div>

    <%-- 배송중 계열 상태(배송중/배송출발/배송완료)로 바꿀 때 택배사·송장번호를 입력받는 모달.
         한 페이지에 하나만 두고 어떤 행에서 열렸는지는 JS의 data-order-id로 추적한다 --%>
    <div id="delivery-info-modal" class="modal-overlay" hidden>
        <div class="modal-box" role="dialog" aria-modal="true" aria-labelledby="modal-title">
            <h2 id="modal-title">배송 정보 입력</h2>
            <p class="modal-desc"><span id="modal-target-status-label"></span>(으)로 변경하려면 택배사와 송장번호가 필요합니다.</p>
            <div class="modal-field">
                <label for="modal-company">택배사</label>
                <select id="modal-company">
                    <option value="">택배사를 선택해 주세요</option>
                    <option value="CJ대한통운">CJ대한통운</option>
                    <option value="한진택배">한진택배</option>
                    <option value="롯데택배">롯데택배</option>
                    <option value="로젠택배">로젠택배</option>
                    <option value="우체국택배">우체국택배</option>
                </select>
            </div>
            <div class="modal-field">
                <label for="modal-tracking-no">송장번호</label>
                <input type="text" id="modal-tracking-no" placeholder="송장번호 입력">
            </div>
            <div class="modal-actions">
                <button type="button" id="modal-cancel-btn">취소</button>
                <button type="button" id="modal-confirm-btn">저장</button>
            </div>
        </div>
    </div>

    <%-- 데이터 연동 완료: GET /admin/order/list (주문 목록 + 요약 카운트), POST /admin/order/delivery/{orderId}
         (배송 상태/택배사/송장번호 저장). 대표 상품/건수는 ORDERDETAIL 중 가장 먼저 담긴 1건 기준이며,
         orderId는 주문 PK(NUMBER)를 그대로 표시한다(목업의 'YYYYMMDD-NNN' 표기는 사용하지 않음).
         조회 기간/검색어 필터는 기존처럼 프론트에서 클라이언트 필터링한다.
         JS는 서버 통신/데이터 가공(비즈니스 로직)과 화면 조작(인터랙션)을 파일로 분리했다:
         business -> /js/admin/adminOrderService.js, interaction -> /js/views/adminOrderDelivery.js --%>
    <script src="<c:url value='/js/common/pagination.js'/>"></script>
    <script src="<c:url value='/js/admin/adminOrderService.js'/>"></script>
    <script src="<c:url value='/js/views/adminOrderDelivery.js'/>"></script>

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
