<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>


<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>메종 드 사조</title>
	<!-- 파비콘 -->
	<link rel="icon" type="image/png" href="${pageContext.request.contextPath}/resources/favicon.png">
	
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Hahmlet:wght@600;700&display=swap" rel="stylesheet">

	<link rel="stylesheet" href="/css/default.css">
	<link rel="stylesheet" href="/css/style.css">
	<link rel="stylesheet" href="/css/style_user.css">
	<link rel="stylesheet" href="/css/style_admin.css">
</head>
<%-- 요청 경로별로 body에 hero 클래스를 붙인다. getServletPath()는 forward 후라 JSP
     경로가 나오므로 jakarta.servlet.forward.servlet_path를 대신 쓴다. --%>
<c:set var="__path" value="${pageContext.request.getAttribute('jakarta.servlet.forward.servlet_path')}"/>
<c:choose>
	<c:when test="${__path == '/'}">
		<c:set var="bodyClass" value="home-hero"/>
	</c:when>
	<c:when test="${__path == '/member/login'}">
		<c:set var="bodyClass" value="login-hero"/>
	</c:when>
	<c:when test="${__path == '/member/signUp'}">
		<c:set var="bodyClass" value="signup-hero"/>
	</c:when>
	<c:when test="${__path == '/order/payment'}">
		<c:set var="bodyClass" value="order-hero"/>
	</c:when>
	<c:when test="${__path == '/order/completed'}">
		<c:set var="bodyClass" value="order-complete-hero"/>
	</c:when>
	<c:when test="${fn:startsWith(__path, '/mds/detail/')}">
		<c:set var="bodyClass" value="product-detail-hero"/>
	</c:when>
	<c:when test="${__path == '/review/write'}">
		<c:set var="bodyClass" value="review-write-hero"/>
	</c:when>
	<c:when test="${__path == '/member/couponView'}">
		<c:set var="bodyClass" value="coupon-hero"/>
	</c:when>
	<c:when test="${__path == '/member/deliveryAddress'}">
		<%-- 배송지 관리(MemberController.deliveryAddress) --%>
		<c:set var="bodyClass" value="delivery-hero"/>
	</c:when>
	<c:otherwise>
		<c:set var="bodyClass" value=""/>
	</c:otherwise>
</c:choose>
<body class="${bodyClass}" data-logged-in="${not empty sessionScope.loginSession}" data-home-url="<c:url value='/'/>">
	<header id="site-header">

		<div id="logo_img">
			<a href="<c:url value='/'/>">Maison De SAJO</a>
		</div>

		<div id="search_box">
			<%-- 검색 결과 화면(ProductController.getSearchList) --%>
			<form id="headerSearchForm" action="<c:url value='/mds/searchList'/>" method="get">
				<%-- 검색 결과 화면에서 검색어가 사라지지 않도록 현재 keyword를 그대로 채워둔다
					 (검색 화면 안쪽 검색창과 동일). 다른 화면에서는 keyword가 없어 빈 값이 된다. --%>
				<input type="search" id="headerSearchInput" name="keyword" class="search-input"
					   value="<c:out value='${param.keyword}'/>"
					   placeholder="상품을 검색해보세요." aria-label="상품 검색" autocomplete="off">
				<button type="submit" class="search-submit" aria-label="검색">
					<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<circle cx="11" cy="11" r="7"/>
						<line x1="21" y1="21" x2="16.65" y2="16.65"/>
					</svg>
				</button>
			</form>
		</div>

		<div class="header-actions">
			<div class="icon">
				<%-- 찜 목록(WishController.getWishList) --%>
				<a class="icon-item" href="<c:url value='/wish/my-wish'/>">
					<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/>
					</svg>
					<span class="icon-badge" id="wishBadge" hidden>0</span>
					<span class="icon-label">찜</span>
				</a>

				<%-- 장바구니(CartController.getCartList) --%>
				<a class="icon-item" href="<c:url value='/cart/my-cart'/>">
					<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<circle cx="9" cy="21" r="1"/>
						<circle cx="20" cy="21" r="1"/>
						<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
					</svg>
					<span class="icon-badge" id="cartBadge" hidden>0</span>
					<span class="icon-label">장바구니</span>
				</a>

				<%-- 진행 중인 결제로 돌아가기. 결제 화면은 "무엇을 사는지"가 있어야 열리므로
				     GET /order/payment 가 세션(PENDING_CHECKOUT)에 남은 선택으로 다시 만들어 준다.
				     담아둔 게 없거나 시간이 지났으면 장바구니로 안내한다. --%>
				<a class="icon-item" href="<c:url value='/order/payment'/>">
					<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M7 3h10a1 1 0 0 1 1 1v17l-3-2-3 2-3-2-3 2V4a1 1 0 0 1 1-1z"/>
						<path d="M9 8h6"/>
						<path d="M9 12h6"/>
					</svg>
					<span class="icon-label">진행 중인 결제</span>
				</a>

				<a class="icon-item" href="<c:url value='/member/myPage'/>">
					<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<circle cx="12" cy="8" r="4"/>
						<path d="M4 21c0-4 3.5-7 8-7s8 3 8 7"/>
					</svg>
					<span class="icon-label">마이페이지</span>
				</a>
			</div>

			<div class="sign">

			    <c:choose>

			        <%-- 로그인 상태 --%>
			        <c:when test="${not empty sessionScope.loginSession}">
			            <%-- 헤더에 노출하는 건 이름이 아니라 닉네임(#TB006_TC-12).
			                 세션 DTO에 nickname이 담기고, 닉네임을 바꾸면 MemberController가
			                 세션 값도 같이 갱신하므로 새로고침 없이 바로 반영된다. --%>
			            <span class="welcome">
			                <span class="welcome-nickname"><c:out value="${sessionScope.loginSession.nickname}"/></span> 님
			            </span>

			            <span class="sign-divider" aria-hidden="true">|</span>

			            <a href="<c:url value='/member/logout'/>">로그아웃</a>
			        </c:when>

			        <%-- 로그아웃 상태 --%>
			        <c:otherwise>
			            <a href="<c:url value='/member/login'/>">로그인</a>
			            <span class="sign-divider" aria-hidden="true">|</span>
			            <a href="<c:url value='/member/signUp'/>">회원가입</a>
			        </c:otherwise>

			    </c:choose>

			</div>
		</div>

	</header>

	<script src="<c:url value='/js/common/cartWishService.js'/>"></script>
	<script src="<c:url value='/js/views/header.js'/>"></script>

	<main>
