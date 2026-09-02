<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다.
     레이아웃/컴포넌트 형식(프로필 카드 + info-row 목록 + 아이콘 타일 그리드)은
     admin/adminPage.jsp + style_admin_mypage.css의 패턴을 그대로 가져와 통일함 --%>
<div class="member-mypage-page">
<div class="page-content">

    <h1 class="page-title">마이페이지</h1>

    <!-- 회원 정보 -->
    <section class="card profile-card" aria-label="회원 정보">
        <div class="profile-card-top">
            <div class="profile-identity">
                <div class="profile-name-wrap">
                    <div class="profile-name-line">
                        <span class="profile-name"><c:out value="${loginMember.memberName}"/></span>
                        <c:if test="${not empty loginMember.gradeName}">
                        <span class="profile-grade-badge"><c:out value="${loginMember.gradeName}"/></span>
                        </c:if>
                    </div>
                    <p class="profile-subtitle">@<c:out value="${loginMember.nickname}"/></p>
                </div>
            </div>
            <a class="btn-edit-member" href="<c:url value='/member/updateInfo'/>">정보 수정</a>
        </div>

        <div class="info-list">
            <div class="info-row">
                <span class="info-label">아이디</span>
                <span class="info-value"><c:out value="${loginMember.loginId}"/></span>
            </div>
            <div class="info-row">
                <span class="info-label">휴대폰</span>
                <span class="info-value"><c:out value="${loginMember.phone}"/></span>
            </div>
            <div class="info-row">
                <span class="info-label">이메일</span>
                <span class="info-value"><c:out value="${loginMember.email}"/></span>
            </div>
            <div class="info-row">
                <span class="info-label">포인트</span>
                <span class="info-value"><fmt:formatNumber value="${loginMember.point}" pattern="#,##0"/>P</span>
            </div>
            <a class="info-row info-row-link" href="<c:url value='/member/couponView'/>">
                <span class="info-label">쿠폰</span>
                <span class="info-value">
                    보유 쿠폰 ${couponCount}장
                    <span class="info-chevron">&rsaquo;</span>
                </span>
            </a>
        </div>
    </section>

    <!-- 빠른 메뉴 -->
    <section class="quick-menu-section" aria-label="빠른 메뉴">
        <h2 class="section-title">빠른 메뉴</h2>
        <ul class="quick-menu-grid">
            <li>
                <a class="quick-menu-tile" href="<c:url value='/member/orderDelivery'/>">
                    <c:if test="${activeOrderCount > 0}">
                    <span class="quick-menu-badge">${activeOrderCount}</span>
                    </c:if>
                    <span class="quick-menu-icon">
                        <svg viewBox="0 0 24 24" focusable="false">
                            <path d="M3 7h11v8H3z"/>
                            <path d="M14 10h4l3 3v2h-7z"/>
                            <circle cx="7" cy="17" r="1.7"/>
                            <circle cx="17" cy="17" r="1.7"/>
                        </svg>
                    </span>
                    <span class="quick-menu-label">주문·배송 조회</span>
                </a>
            </li>
            <li>
                <!-- 리뷰 작성: 특정 주문(odId) 기준으로 들어가는 화면이라 목록 진입점이 없음 - 주문·배송 조회에서 개별 진입 -->
                <a class="quick-menu-tile" href="#">
                    <c:if test="${reviewableCount > 0}">
                    <span class="quick-menu-badge">${reviewableCount}</span>
                    </c:if>
                    <span class="quick-menu-icon">
                        <svg viewBox="0 0 24 24" focusable="false">
                            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 21 12 17.77 5.82 21 7 14.14 2 9.27l6.91-1.01L12 2z"/>
                        </svg>
                    </span>
                    <span class="quick-menu-label">리뷰 작성</span>
                </a>
            </li>
            <li>
                <!-- 문의사항/문의내역: 대응하는 화면이 아직 없어 임시 처리(adminPage.jsp와 동일 패턴) -->
                <a class="quick-menu-tile" href="#">
                    <span class="quick-menu-icon">
                        <svg viewBox="0 0 24 24" focusable="false">
                            <path d="M21 11.5a8.38 8.38 0 0 1-4.9 7.6 8.5 8.5 0 0 1-9.4-1.7L3 21l1.9-5.7a8.38 8.38 0 0 1 3-9.4 8.5 8.5 0 0 1 13 5.1 8.48 8.48 0 0 1 .5 2.7z"/>
                        </svg>
                    </span>
                    <span class="quick-menu-label">문의사항</span>
                </a>
            </li>
            <li>
                <a class="quick-menu-tile" href="#">
                    <span class="quick-menu-icon">
                        <svg viewBox="0 0 24 24" focusable="false">
                            <path d="M8 6h13"/><path d="M8 12h13"/><path d="M8 18h13"/>
                            <path d="M3 6h.01"/><path d="M3 12h.01"/><path d="M3 18h.01"/>
                        </svg>
                    </span>
                    <span class="quick-menu-label">문의내역</span>
                </a>
            </li>
        </ul>
    </section>

    <!-- 주문관리 -->
    <section class="quick-menu-section" aria-label="주문관리">
        <h2 class="section-title">주문관리</h2>
        <div class="card list-card">
            <a class="list-row" href="<c:url value='/member/orderDelivery'/>">
                <div class="list-row-text">
                    <span class="list-row-title">주문 / 배송 조회</span>
                    <span class="list-row-desc">이전 및 현재 주문내역과 구매하신 상품의 배송 상태를 확인합니다.</span>
                </div>
                <div class="list-row-right">
                    <c:if test="${activeOrderCount > 0}">
                    <span class="list-row-badge">${activeOrderCount}</span>
                    </c:if>
                    <span class="list-row-chevron">&rsaquo;</span>
                </div>
            </a>
            <%-- 유저가 직접 취소를 신청하는 화면은 아직 없어서, 가장 가까운 실제 화면인
                 배송 목록의 "취소/환불" 필터로 연결한다(읽기 전용 확인 용도) --%>
            <a class="list-row" href="<c:url value='/member/orderDelivery'><c:param name='status' value='canceled'/></c:url>">
                <div class="list-row-text">
                    <span class="list-row-title">주문취소 / 환불</span>
                    <span class="list-row-desc">취소 및 환불 요청을 관리합니다.</span>
                </div>
                <div class="list-row-right">
                    <span class="list-row-chevron">&rsaquo;</span>
                </div>
            </a>
        </div>
    </section>

    <!-- 리뷰 작성 -->
    <section class="quick-menu-section" aria-label="리뷰 작성">
        <h2 class="section-title">리뷰 작성</h2>
        <div class="card review-cta-card">
            <p class="review-cta-desc">구매한 상품의 리뷰를 작성해 주세요.</p>
            <%-- 리뷰 작성은 특정 주문(odId) 단위로 들어가야 해서, 배송완료 목록에서 개별 항목별로 진입한다 --%>
            <a class="review-cta-badge" href="<c:url value='/member/orderDelivery'><c:param name='status' value='delivered'/></c:url>">작성 가능한 리뷰 ${reviewableCount}개</a>
            <a class="review-cta-link" href="<c:url value='/review/myReviews'/>">내가 쓴 리뷰 조회·삭제 &rsaquo;</a>
        </div>
    </section>

    <!-- 고객센터 -->
    <section class="quick-menu-section" aria-label="고객센터">
        <h2 class="section-title">고객센터</h2>
        <div class="card list-card">
            <%-- 문의사항/문의내역/공지사항: 대응하는 화면이 아직 없어 임시 처리(adminPage.jsp와 동일 패턴) --%>
            <a class="list-row" href="#">
                <div class="list-row-text">
                    <span class="list-row-title">문의사항</span>
                    <span class="list-row-desc">상품이나 주문에 관한 질문을 남겨주세요.</span>
                </div>
                <div class="list-row-right">
                    <span class="list-row-chevron">&rsaquo;</span>
                </div>
            </a>
            <a class="list-row" href="#">
                <div class="list-row-text">
                    <span class="list-row-title">문의내역</span>
                    <span class="list-row-desc">이전에 문의한 질문과 답변을 확인합니다.</span>
                </div>
                <div class="list-row-right">
                    <span class="list-row-chevron">&rsaquo;</span>
                </div>
            </a>
            <a class="list-row" href="#">
                <div class="list-row-text">
                    <span class="list-row-title">공지사항</span>
                    <span class="list-row-desc">중요한 사이트 공지사항을 확인합니다.</span>
                </div>
                <div class="list-row-right">
                    <span class="list-row-chevron">&rsaquo;</span>
                </div>
            </a>
        </div>
    </section>

</div>
</div>

<script src="<c:url value='/js/common/placeholderLinks.js'/>"></script>
<script src="<c:url value='/js/views/myPage.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
