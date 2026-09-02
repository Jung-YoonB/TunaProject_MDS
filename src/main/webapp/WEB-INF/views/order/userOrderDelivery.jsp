<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="order-delivery-page">
<div class="page-content">

    <h1 class="page-title">주문/배송내역</h1>

    <%-- 주문이 쌓여도 느려지지 않도록 상태 필터/페이징을 서버에서 처리하므로, 탭은 쿼리 파라미터를 바꿔서
         페이지를 새로 요청하는 링크로 구성한다(필터 바꿀 땐 1페이지부터 다시 보여줌) --%>
    <nav class="status-filter" aria-label="주문 상태 필터">
        <a class="${currentStatus == 'all' ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='all'/><c:param name='page' value='1'/></c:url>">전체</a>
        <a class="${currentStatus == 'preparing' ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='preparing'/><c:param name='page' value='1'/></c:url>">배송준비중</a>
        <a class="${currentStatus == 'shipped' ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='shipped'/><c:param name='page' value='1'/></c:url>">배송중</a>
        <a class="${currentStatus == 'out_for_delivery' ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='out_for_delivery'/><c:param name='page' value='1'/></c:url>">배송출발</a>
        <a class="${currentStatus == 'delivered' ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='delivered'/><c:param name='page' value='1'/></c:url>">배송완료</a>
        <a class="${currentStatus == 'canceled' ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='canceled'/><c:param name='page' value='1'/></c:url>">취소/환불</a>
    </nav>

    <section class="order-list" aria-label="주문 목록" ${empty deliveryList ? 'hidden' : ''}>
        <c:forEach items="${deliveryList}" var="item">

            <%-- 필터 탭과 매칭되는 상태: DELIVERY 행이 아직 없거나 PREPARING이면 배송준비중.
                 SHIPPED/OUT_FOR_DELIVERY/DELIVERED/CANCELED는 각각 별도 탭으로 매칭한다 --%>
            <c:choose>
                <c:when test="${item.deliveryStatus == 'CANCELED'}">
                    <c:set var="filterStatus" value="canceled"/>
                </c:when>
                <c:when test="${item.deliveryStatus == 'SHIPPED'}">
                    <c:set var="filterStatus" value="shipped"/>
                </c:when>
                <c:when test="${item.deliveryStatus == 'OUT_FOR_DELIVERY'}">
                    <c:set var="filterStatus" value="out_for_delivery"/>
                </c:when>
                <c:when test="${item.deliveryStatus == 'DELIVERED'}">
                    <c:set var="filterStatus" value="delivered"/>
                </c:when>
                <c:otherwise>
                    <c:set var="filterStatus" value="preparing"/>
                </c:otherwise>
            </c:choose>

            <%-- 진행 단계 표시용 인덱스: 배송준비중=1, 배송중=2, 배송출발=3, 배송완료=4, 아직 DELIVERY
                 행이 없으면(결제완료만 된 상태) 0 (아무 단계도 시작 전) --%>
            <c:choose>
                <c:when test="${item.deliveryStatus == 'PREPARING'}"><c:set var="stepIndex" value="1"/></c:when>
                <c:when test="${item.deliveryStatus == 'SHIPPED'}"><c:set var="stepIndex" value="2"/></c:when>
                <c:when test="${item.deliveryStatus == 'OUT_FOR_DELIVERY'}"><c:set var="stepIndex" value="3"/></c:when>
                <c:when test="${item.deliveryStatus == 'DELIVERED'}"><c:set var="stepIndex" value="4"/></c:when>
                <c:otherwise><c:set var="stepIndex" value="0"/></c:otherwise>
            </c:choose>

            <article class="order-card">
                <div class="order-header">
                    <span class="order-number">주문번호 <strong>${item.orderId}</strong></span>
                    <span class="order-date">주문일 ${item.orderDateStr}</span>
                </div>
                <div class="order-body">
                    <div class="item-thumb">
                        <c:choose>
                            <c:when test="${not empty item.productImageSaveName}">
                                <img src="<c:out value='${item.productImagePath}'/><c:out value='${item.productImageSaveName}'/>"
                                     alt="<c:out value='${item.productName}'/>">
                            </c:when>
                            <c:otherwise>
                                <span class="no-image-text">상품 이미지가<br>없습니다</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="order-info">
                        <h3 class="product-name">
                            <c:out value="${item.productName}"/>
                            <c:if test="${item.productCount > 1}"> 외 ${item.productCount - 1}건</c:if>
                        </h3>
                        <%-- 수량은 대표 상품 1건이 아니라 주문 전체 합계(totalQty). 예전엔 대표 상품의
                             수량만 보여줘서 여러 상품을 산 주문이 "수량: 2개"로 나왔다 --%>
                        <p class="product-detail">
                            <c:if test="${item.totalQty != null}">총 수량: ${item.totalQty}개 | </c:if>금액:
                            <fmt:formatNumber value="${item.totalPrice}" pattern="#,##0"/>원
                        </p>

                        <%-- 상품 2건 이상인 주문만 펼치기 버튼을 단다(1건짜리는 대표가 곧 전체).
                             배송완료 주문은 품목별 리뷰 상태를 봐야 하므로 처음부터 펼쳐둔다 (HANDOFF 3-55) --%>
                        <c:set var="itemsOpen" value="${item.deliveryStatus == 'DELIVERED'}"/>
                        <c:set var="itemsClosedLabel" value="주문 상품 ${item.productCount}건 모두 보기"/>
                        <c:set var="itemsOpenedLabel" value="주문 상품 접기"/>

                        <c:if test="${item.productCount > 1}">
                        <button type="button" class="btn-order-items"
                                aria-expanded="${itemsOpen}" aria-controls="order-items-${item.orderId}">
                            <%-- data-closed/opened 는 views/orderDelivery.js가 토글할 때 쓴다.
                                 처음 보이는 문구는 위 itemsOpen 상태와 반드시 일치해야 한다 --%>
                            <span class="btn-order-items-text"
                                  data-closed="${itemsClosedLabel}"
                                  data-opened="${itemsOpenedLabel}">${itemsOpen ? itemsOpenedLabel : itemsClosedLabel}</span>
                            <svg class="icon-chevron" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
                        </button>
                        </c:if>
                    </div>
                    <span class="status-badge status-${filterStatus}">
                        <c:choose>
                            <c:when test="${item.deliveryStatus == 'CANCELED' && item.orderStatus == 'CANCELED'}">취소/환불 완료</c:when>
                            <c:when test="${item.deliveryStatus == 'CANCELED'}">취소/환불 대기중</c:when>
                            <c:when test="${item.deliveryStatus == 'PREPARING'}">배송준비중</c:when>
                            <c:when test="${item.deliveryStatus == 'SHIPPED'}">배송중</c:when>
                            <c:when test="${item.deliveryStatus == 'OUT_FOR_DELIVERY'}">배송출발</c:when>
                            <c:when test="${item.deliveryStatus == 'DELIVERED'}">배송완료</c:when>
                            <c:when test="${item.orderStatus == 'PAYMENT_WAITING'}">결제대기</c:when>
                            <c:otherwise>결제완료</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <%-- views/orderDelivery.js가 토글. JS가 막혀도 접힌 채로 남을 뿐이라 안전하다 --%>
                <c:if test="${item.productCount > 1}">
                <div class="order-items" id="order-items-${item.orderId}" ${itemsOpen ? '' : 'hidden'}>
                    <ul class="order-item-list">
                        <c:forEach items="${item.items}" var="orderItem">
                        <li class="order-item">
                            <div class="order-item-thumb">
                                <c:choose>
                                    <c:when test="${not empty orderItem.productImageSaveName}">
                                        <img src="<c:out value='${orderItem.productImagePath}'/><c:out value='${orderItem.productImageSaveName}'/>"
                                             alt="" loading="lazy">
                                    </c:when>
                                    <c:otherwise>
                                        <span class="no-image-text">이미지<br>없음</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="order-item-info">
                                <span class="order-item-name"><c:out value="${orderItem.productName}"/></span>
                                <c:if test="${not empty orderItem.optionName}">
                                <span class="order-item-option"><c:out value="${orderItem.optionName}"/></span>
                                </c:if>
                            </div>
                            <span class="order-item-qty">${orderItem.qty}개</span>
                            <%-- 주문 시점 단가(priceFix) x 수량. 현재 상품 가격이 아니라 이 값이어야 주문서와 맞는다 --%>
                            <span class="order-item-price">
                                <fmt:formatNumber value="${orderItem.priceFix * orderItem.qty}" pattern="#,##0"/>원
                            </span>
                            <%-- 배송 전엔 리뷰를 쓸 수 없으므로(getWriteInfo) 배송완료에만 표시 --%>
                            <c:if test="${item.deliveryStatus == 'DELIVERED'}">
                            <span class="order-item-review ${orderItem.hasReview ? 'is-done' : 'is-todo'}">
                                ${orderItem.hasReview ? '리뷰 작성 완료' : '리뷰 미작성'}
                            </span>
                            </c:if>
                        </li>
                        </c:forEach>
                    </ul>
                </div>
                </c:if>

                <c:if test="${item.deliveryStatus != 'CANCELED'}">
                <div class="order-progress">

                    <%-- 체크 표시는 원래 유니코드 ✓ 글리프였으나 환경에 따라 컬러 이모지로
                         렌더링돼 CSS color를 무시하는 문제가 있어 SVG로 통일함(2026-09-01).
                         .step-icon이 미완료 단계에서 color:transparent로 감추는 구조라
                         stroke:currentColor인 SVG도 동일하게 감춰진다. --%>
                    <div class="progress-step ${stepIndex > 1 ? 'is-complete' : (stepIndex == 1 ? 'is-current status-preparing' : 'is-upcoming')}">
                        <span class="step-icon">
                            <c:if test="${stepIndex > 1}">
                                <svg class="icon-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 6L9 17l-5-5"/></svg>
                            </c:if>
                        </span>
                        <span class="step-label">배송준비중</span>
                    </div>
                    <div class="progress-line ${stepIndex > 1 ? 'is-complete' : ''}"></div>

                    <div class="progress-step ${stepIndex > 2 ? 'is-complete' : (stepIndex == 2 ? 'is-current status-shipped' : 'is-upcoming')}">
                        <span class="step-icon">
                            <c:if test="${stepIndex > 2}">
                                <svg class="icon-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 6L9 17l-5-5"/></svg>
                            </c:if>
                        </span>
                        <span class="step-label">배송중</span>
                    </div>
                    <div class="progress-line ${stepIndex > 2 ? 'is-complete' : ''}"></div>

                    <div class="progress-step ${stepIndex > 3 ? 'is-complete' : (stepIndex == 3 ? 'is-current status-out_for_delivery' : 'is-upcoming')}">
                        <span class="step-icon">
                            <c:if test="${stepIndex > 3}">
                                <svg class="icon-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 6L9 17l-5-5"/></svg>
                            </c:if>
                        </span>
                        <span class="step-label">배송출발</span>
                    </div>
                    <div class="progress-line ${stepIndex > 3 ? 'is-complete' : ''}"></div>

                    <div class="progress-step ${stepIndex == 4 ? 'is-complete' : 'is-upcoming'}">
                        <span class="step-icon">
                            <c:if test="${stepIndex == 4}">
                                <svg class="icon-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 6L9 17l-5-5"/></svg>
                            </c:if>
                        </span>
                        <span class="step-label">배송완료</span>
                    </div>

                </div>
                </c:if>

                <c:if test="${not empty item.trackingNo || not empty item.addressNameFix}">
                <div class="delivery-info">
                    <c:if test="${not empty item.trackingNo}">
                    <p class="info-row">
                        <span class="info-label">택배사</span> : <c:out value="${item.company}"/>
                        <span class="info-divider">|</span>
                        <span class="info-label">송장번호</span> : <c:out value="${item.trackingNo}"/>
                    </p>
                    </c:if>
                    <c:if test="${not empty item.addressNameFix}">
                    <p class="info-row">
                        <span class="info-label">배송지</span> : <c:out value="${item.addressNameFix}"/> - <c:out value="${item.detailAddressFix}"/>
                    </p>
                    </c:if>
                </div>
                </c:if>

                <c:if test="${item.deliveryStatus == 'DELIVERED' && item.odId != null}">
                <div class="order-actions">
                    <c:choose>
                        <%-- 품목별 상태(드롭다운 각 행의 "리뷰 작성 완료")와 층위가 다르므로 문구도 구분한다.
                             여기는 "이 주문 전체"를 다 썼다는 뜻 --%>
                        <c:when test="${item.allReviewed}">
                            <span class="review-done-badge">이 주문 리뷰 모두 완료</span>
                        </c:when>
                        <c:otherwise>
                            <%-- 리뷰 작성 완료 후 지금 보고 있던 필터/페이지로 그대로 돌아올 수 있도록 returnUrl로 넘김 --%>
                            <a class="btn-review" href="<c:url value='/review/write'><c:param name='odId' value='${item.odId}'/><c:param name='returnUrl' value='/member/orderDelivery?status=${currentStatus}&page=${currentPage}'/></c:url>">리뷰 작성</a>
                        </c:otherwise>
                    </c:choose>
                </div>
                </c:if>
            </article>
        </c:forEach>
    </section>

    <p class="order-empty" ${empty deliveryList ? '' : 'hidden'}>주문/배송내역이 없습니다.</p>

    <c:if test="${totalPages > 1}">
    <nav class="pagination" aria-label="페이지 이동">
        <c:if test="${currentPage > 1}">
        <a class="page-link page-prev" href="<c:url value='/member/orderDelivery'><c:param name='status' value='${currentStatus}'/><c:param name='page' value='${currentPage - 1}'/></c:url>">이전</a>
        </c:if>
        <c:forEach begin="${pageWindowStart}" end="${pageWindowEnd}" var="p">
        <a class="page-link ${p == currentPage ? 'is-active' : ''}" href="<c:url value='/member/orderDelivery'><c:param name='status' value='${currentStatus}'/><c:param name='page' value='${p}'/></c:url>">${p}</a>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
        <a class="page-link page-next" href="<c:url value='/member/orderDelivery'><c:param name='status' value='${currentStatus}'/><c:param name='page' value='${currentPage + 1}'/></c:url>">다음</a>
        </c:if>
    </nav>
    </c:if>

    <div class="order-back">
        <a class="btn-back-mypage" href="<c:url value='/member/myPage'/>">마이페이지로 돌아가기</a>
    </div>

</div>
</div>

<script src="<c:url value='/js/views/orderDelivery.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
