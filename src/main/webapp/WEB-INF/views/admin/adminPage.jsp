<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 이미 모든 페이지 공통 CSS(style_admin.css 포함)를 로드하므로 별도 link 불필요 --%>
<div class="admin-mypage-page">

    <%-- header.jsp가 이미 <main>을 열어서 폭 제약이 없으므로, 원래 main 태그가 담당하던
         가운데 정렬/최대폭(720px)은 이 내부 wrapper(.page-content)가 대신 담당한다 --%>
    <div class="page-content">

        <h1 class="page-title">관리자 마이페이지</h1>
        <p class="page-subtitle">관리자 계정 정보를 관리합니다.</p>

        <!-- 프로필 카드 -->
        <section class="card profile-card" aria-label="관리자 프로필">
            <div class="profile-card-top">
                <div class="profile-identity">
                    <div class="avatar-circle" aria-hidden="true">
                        <svg class="avatar-icon-svg" viewBox="0 0 24 24" focusable="false">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </div>
                    <div class="profile-name-wrap">
                        <div class="profile-name-line">
                            <span class="profile-name" id="profile-name">관리자</span>
                        </div>
                        <p class="profile-subtitle" id="profile-subtitle">관리자 (admin)</p>
                    </div>
                </div>
            </div>

            <div class="info-list">
                <div class="info-row">
                    <span class="info-label">이름</span>
                    <span class="info-value" id="val-name">관리자</span>
                </div>
                <div class="info-row">
                    <span class="info-label">아이디</span>
                    <span class="info-value" id="val-login-id">admin</span>
                </div>
            </div>
        </section>

        <!-- 빠른 메뉴 -->
        <section class="quick-menu-section" aria-label="빠른 메뉴">
            <h2 class="section-title">빠른 메뉴</h2>
            <ul class="quick-menu-grid">
                <li>
                    <a class="quick-menu-tile" href="<c:url value='/admin/product/add'/>">
                        <span class="quick-menu-icon">
                            <svg viewBox="0 0 24 24" focusable="false">
                                <path d="M4 7l8-4 8 4v10l-8 4-8-4V7z"/>
                                <path d="M4 7l8 4 8-4"/>
                                <path d="M12 11v10"/>
                            </svg>
                        </span>
                        <span class="quick-menu-label">상품 관리</span>
                    </a>
                </li>
                <li>
                    <a class="quick-menu-tile" href="<c:url value='/admin/order'/>">
                        <span class="quick-menu-icon">
                            <svg viewBox="0 0 24 24" focusable="false">
                                <path d="M3 7h11v8H3z"/>
                                <path d="M14 10h4l3 3v2h-7z"/>
                                <circle cx="7" cy="17" r="1.7"/>
                                <circle cx="17" cy="17" r="1.7"/>
                            </svg>
                        </span>
                        <span class="quick-menu-label">주문·배송 관리</span>
                    </a>
                </li>
                <li>
                    <a class="quick-menu-tile" href="<c:url value='/admin/coupon'/>">
                        <span class="quick-menu-icon">
                            <svg viewBox="0 0 24 24" focusable="false">
                                <path d="M12.59 3.41 20 10.83a2 2 0 0 1 0 2.83l-6.34 6.34a2 2 0 0 1-2.83 0L3 12.17V5a2 2 0 0 1 2-2h7.59a2 2 0 0 1 1.41.41Z"/>
                                <circle cx="7.5" cy="7.5" r="1.2"/>
                            </svg>
                        </span>
                        <span class="quick-menu-label">쿠폰 관리</span>
                    </a>
                </li>
                <li>
                    <!-- 문의내역: 대응하는 화면이 아직 없어 임시 처리 -->
                    <a class="quick-menu-tile" href="#">
                        <span class="quick-menu-icon">
                            <svg viewBox="0 0 24 24" focusable="false">
                                <path d="M21 11.5a8.38 8.38 0 0 1-4.9 7.6 8.5 8.5 0 0 1-9.4-1.7L3 21l1.9-5.7a8.38 8.38 0 0 1 3-9.4 8.5 8.5 0 0 1 13 5.1 8.48 8.48 0 0 1 .5 2.7z"/>
                            </svg>
                        </span>
                        <span class="quick-menu-label">문의 내역</span>
                    </a>
                </li>
                <li>
                    <a class="quick-menu-tile" href="<c:url value='/admin/maintenance'/>">
                        <span class="quick-menu-icon">
                            <svg viewBox="0 0 24 24" focusable="false">
                                <path d="M9 3H5a2 2 0 0 0-2 2v4"/>
                                <path d="M15 3h4a2 2 0 0 1 2 2v4"/>
                                <path d="M9 21H5a2 2 0 0 1-2-2v-4"/>
                                <path d="M15 21h4a2 2 0 0 0 2-2v-4"/>
                                <path d="M9 12l2 2 4-4"/>
                            </svg>
                        </span>
                        <span class="quick-menu-label">파일 정합성 검사</span>
                    </a>
                </li>
            </ul>
        </section>

        <!-- 일반 메뉴 -->
        <section class="general-menu-section" aria-label="일반 메뉴">
            <h2 class="section-title">일반 메뉴</h2>
            <div class="card list-card">
                <a class="list-row" href="<c:url value='/admin/product/add'/>">
                    <div class="list-row-text">
                        <span class="list-row-title">상품 등록</span>
                        <span class="list-row-desc">새로운 상품을 등록합니다.</span>
                    </div>
                    <div class="list-row-right">
                        <span class="list-row-chevron">&rsaquo;</span>
                    </div>
                </a>
                <a class="list-row" href="<c:url value='/admin/order'/>">
                    <div class="list-row-text">
                        <span class="list-row-title">주문·배송 관리</span>
                        <span class="list-row-desc">주문 및 배송 상태를 관리합니다.</span>
                    </div>
                    <div class="list-row-right">
                        <span class="list-row-chevron">&rsaquo;</span>
                    </div>
                </a>
                <a class="list-row" href="<c:url value='/admin/coupon'/>">
                    <div class="list-row-text">
                        <span class="list-row-title">쿠폰 조회 및 등록</span>
                        <span class="list-row-desc">쿠폰을 조회하고 새로 등록합니다.</span>
                    </div>
                    <div class="list-row-right">
                        <span class="list-row-chevron">&rsaquo;</span>
                    </div>
                </a>
                <%-- 문의사항 처리 / 공지 작성: 대응 화면이 아직 없어 미구현 상태(href="#") --%>
                <a class="list-row" href="#">
                    <div class="list-row-text">
                        <span class="list-row-title">문의사항 처리</span>
                        <span class="list-row-desc">고객 문의에 답변합니다.</span>
                    </div>
                    <div class="list-row-right">
                        <span class="list-row-chevron">&rsaquo;</span>
                    </div>
                </a>
                <a class="list-row" href="#">
                    <div class="list-row-text">
                        <span class="list-row-title">공지 작성</span>
                        <span class="list-row-desc">사이트 공지사항을 작성합니다.</span>
                    </div>
                    <div class="list-row-right">
                        <span class="list-row-chevron">&rsaquo;</span>
                    </div>
                </a>
            </div>
        </section>

    </div>

</div>

    <%-- TODO(data binding): Member 테이블 연동 필요.
         현재는 로그인 세션 없이 관리자 1인 목업 값을 하드코딩.
         - 프로필 카드는 "이름"과 "아이디" 2개 항목만 표시함(닉네임/이메일/휴대폰 번호는 제거).
           이름: Member.member_name, 아이디: Member.login_id
           (role='ADMIN'인 로그인 세션의 Member row 1건 기준으로 바인딩 필요).
           표시값은 실제 인물명이 아닌 "관리자"로 일반화했고, 아이디는 실제 시드 계정 값인 "admin"과
           일치시킴 — 실제 자격증명(비밀번호 등)은 화면에 노출하지 않음.
         - 빠른 메뉴(4타일): 상품 관리/주문·배송 관리/쿠폰 관리는 admin 패키지 컨트롤러(/admin/product/add,
           /admin/order, /admin/coupon)로 연결됨 — resources/static/temp/*.html 정적 프로토타입은 더 이상
           사용하지 않음. 문의 내역은 대응 화면이 없어 href="#" 처리.
         - 일반 메뉴: 원래 그룹 헤더(상품관리/쿠폰 조회 및 등록/문의내역) + 하위 항목의 2단 아코디언
           구조였는데, 유저 마이페이지(member/myPage.jsp)에 새로 만든 목록형 디자인(제목+설명+화살표,
           .list-card/.list-row)과 통일하기 위해 그룹 헤더를 없애고 5개 항목을 평평한 리스트로 재구성함
           (상품 등록/주문·배송 관리/쿠폰 조회 및 등록은 기존 화면 연결, 문의사항 처리/공지 작성은 대응
           화면이 프로젝트에 없어 href="#" 임시 처리 — 추후 실제 화면/컨트롤러 구현 필요).
         - 이전에 있던 "관리자 권한 정보"/"계정 관리"(로그아웃 포함)/"관리자 최근 활동 내역" 카드는
           사용자 요청에 따라 이번 레이아웃 개편에서 완전히 제거됨. --%>
<script src="<c:url value='/js/common/placeholderLinks.js'/>"></script>
<script src="<c:url value='/js/admin/adminMypageService.js'/>"></script>
<script src="<c:url value='/js/views/adminPage.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
