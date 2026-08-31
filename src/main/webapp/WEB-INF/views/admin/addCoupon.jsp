<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="add-coupon-page"
     data-register-url="<c:url value='/admin/coupon/add'/>"
     data-list-url="<c:url value='/admin/coupon'/>">
<div class="add-coupon-page-card">

        <!-- 제목 -->
        <div id="title">쿠폰 신규 등록</div>

        <!-- 쿠폰명 -->
        <div class="form-group">
            <label>쿠폰명</label>
            <input
                type="text"
                class="form-input"
                id="couponNameInput"
                name="couponName"
                maxlength="50"
                placeholder="쿠폰명을 입력하세요">
        </div>

        <!-- 할인율 -->
        <div class="form-group">
            <label>할인율</label>
            <input
                type="number"
                class="form-input"
                id="discountPercentInput"
                name="discountPercent"
                min="1"
                max="100"
                placeholder="할인율을 입력하세요 (예: 10)">
        </div>

        <!-- 쿠폰 설명 -->
        <div class="form-group">
            <label>쿠폰설명</label>
            <textarea
                class="form-textarea"
                id="couponTextInput"
                name="couponText"
                maxlength="300"
                placeholder="쿠폰설명을 입력하세요"></textarea>
        </div>

        <!-- 발급일 / 종료일 -->
        <div class="date-group">

            <div class="date-box">
                <label>발급일</label>
                <input
                    type="date"
                    class="date-input"
                    id="startDate"
                    name="startDate">
            </div>

            <div class="date-box">
                <label>종료일</label>
                <input
                    type="date"
                    class="date-input"
                    id="endDate"
                    name="endDate">
            </div>

        </div>

        <!-- 쿠폰 발급 -->
        <button type="button" class="register-button" id="registerCouponButton">
            쿠폰 발급
        </button>

</div>
</div>

    <%-- header.jsp가 연 <main>은 여기서 안 닫음 — footer.jsp의 </main>이 닫아준다 --%>

    <script src="<c:url value='/js/admin/adminCouponService.js'/>"></script>
    <script src="<c:url value='/js/views/addCoupon.js'/>"></script>
	<jsp:include page="/WEB-INF/views/common/footer.jsp"/>