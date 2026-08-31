<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="admin-coupon-view-page"
     data-list-url="<c:url value='/admin/coupon/list'/>"
     data-add-url="<c:url value='/admin/coupon/add'/>"
     data-delete-url="<c:url value='/admin/coupon/delete'/>">
<div class="admin-coupon-view-page-card">

<div id="title">
            쿠폰관리
        </div>


        <!-- 쿠폰 등록 -->

        <div id="CouponRegister">

            <button
                type="button"
                class="register-button"
                id="goRegisterButton">

                <span class="register-icon">＋</span>
                쿠폰 등록

            </button>

        </div>


        <!-- 쿠폰 검색 -->

        <div id="SearchCoupons">

            <select id="coupon-state-filter">
                <option value="">전체 상태</option>
                <option value="active-no-history">진행중 · 미사용</option>
                <option value="active-history">진행중 · 사용 이력</option>
                <option value="expired-no-history">만료 · 미사용</option>
                <option value="expired-history">만료 · 사용 이력</option>
            </select>

            <input
                type="text"
                id="coupon-search"
                placeholder="쿠폰 이름을 검색해주세요">

            <button
                type="button"
                id="search-button">

                검색

            </button>

        </div>


        <!-- 등록된 쿠폰 -->

        <div id="CouponList">


            <!-- 제목 -->

            <div class="coupon-list-header">

                <h2>
                    등록된 쿠폰
                    <span class="coupon-count" id="couponCount">(0)</span>
                </h2>

            </div>

            <p class="coupon-notice">발급 이력이 있는 쿠폰은 수정 및 삭제가 불가능합니다.</p>


            <!-- 전체 선택 / 삭제 (평소엔 숨겨져 있다가 "삭제할 쿠폰 선택"을 누르면 나타남) -->

            <div class="list-control">

                <div class="select-menu" id="selectionControls" hidden>

                    <button type="button" id="toggleSelectAllButton">
                        전체선택
                    </button>

                </div>

                <div class="list-control-actions">

                    <button
                        type="button"
                        class="delete-button"
                        id="deleteSelectedButton"
                        hidden>

                        <span class="delete-icon">🗑</span>
                        선택 삭제

                    </button>

                    <button type="button" id="toggleSelectModeButton">
                        삭제할 쿠폰 선택
                    </button>

                </div>

            </div>


            <div id="couponCardList"></div>

            <nav class="pagination" aria-label="페이지 탐색">
                <button type="button" id="pagination-prev" class="btn-prev">← 이전</button>
                <ol id="pagination-list"></ol>
                <button type="button" id="pagination-next" class="btn-next">다음 →</button>
            </nav>


        </div>

</div>
</div>

<script src="<c:url value='/js/common/pagination.js'/>"></script>
<script src="<c:url value='/js/admin/adminCouponService.js'/>"></script>
<script src="<c:url value='/js/views/admincouponView.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
