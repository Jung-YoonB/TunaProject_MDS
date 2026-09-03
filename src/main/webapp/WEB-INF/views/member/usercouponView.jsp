<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다.
     admin/admincouponView.jsp와 동일한 "바깥 배경 + 안쪽 흰 카드" 2단 구조로 통일.
     만료 쿠폰은 서버 쿼리에서 이미 제외되므로(사용 가능한 것만 조회) 화면엔 사용 가능한
     보유 쿠폰만 나온다 --%>
<div class="coupon-view-page">
<div class="coupon-view-page-card">

    <div id="title">내 쿠폰</div>

    <div id="SearchCoupons">
        <input type="text" id="coupon-search" placeholder="쿠폰 이름을 검색해주세요">
        <button type="button" id="search-button">검색</button>
    </div>

    <div id="CouponList">
        <div class="coupon-list-header">
            <h2>보유 쿠폰 <span class="coupon-count">(${couponCount})</span></h2>
        </div>

        <div id="couponCardList">
            <c:forEach items="${couponList}" var="coupon">
            <article class="coupon-card" data-coupon-name="<c:out value='${coupon.couponName}'/>">
                <div class="coupon-info">
                    <div class="coupon-name"><c:out value="${coupon.couponName}"/></div>
                    <div class="coupon-description"><c:out value="${coupon.couponText}"/></div>
                    <div class="coupon-deadline">사용기한 : <c:out value="${coupon.deadlineStr}"/></div>
                </div>
                <div class="coupon-discount"><fmt:formatNumber value="${coupon.couponValue * 100}" pattern="#0"/>%</div>
            </article>
            </c:forEach>
        </div>

        <p class="coupon-empty" id="coupon-empty" ${empty couponList ? '' : 'hidden'}>사용 가능한 쿠폰이 없습니다.</p>

        <c:if test="${totalPages > 1}">
        <nav class="pagination" aria-label="페이지 이동">
            <c:if test="${currentPage > 1}">
            <a class="page-link page-prev" href="<c:url value='/member/couponView'><c:param name='page' value='${currentPage - 1}'/></c:url>#title">이전</a>
            </c:if>
            <c:forEach begin="${pageWindowStart}" end="${pageWindowEnd}" var="p">
            <a class="page-link ${p == currentPage ? 'is-active' : ''}" href="<c:url value='/member/couponView'><c:param name='page' value='${p}'/></c:url>#title">${p}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
            <a class="page-link page-next" href="<c:url value='/member/couponView'><c:param name='page' value='${currentPage + 1}'/></c:url>#title">다음</a>
            </c:if>
        </nav>
        </c:if>
    </div>

    <div class="coupon-back">
        <a class="btn-back-mypage" href="<c:url value='/member/myPage'/>">마이페이지로 돌아가기</a>
    </div>

</div>
</div>

<script src="<c:url value='/js/views/usercouponView.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
