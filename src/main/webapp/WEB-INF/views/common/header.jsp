<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>메종 드 사조</title>

	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Hahmlet:wght@600;700&display=swap" rel="stylesheet">

	<link rel="stylesheet" href="/css/default.css">
	<link rel="stylesheet" href="/css/style.css">
	<link rel="stylesheet" href="/css/style_member.css">
	<link rel="stylesheet" href="/css/style_order.css">
	<link rel="stylesheet" href="/css/style_myReviews.css">
	<link rel="stylesheet" href="/css/style_coupon.css">
	<link rel="stylesheet" href="/css/style_home.css">
	<link rel="stylesheet" href="/css/style_myPage.css">
	<link rel="stylesheet" href="/css/style_search.css">
	<link rel="stylesheet" href="/css/style_cart.css">
	<link rel="stylesheet" href="/css/style_wish.css">
	<link rel="stylesheet" href="/css/style_addreview.css">
	<link rel="stylesheet" href="/css/style_productdetail.css">
	<link rel="stylesheet" href="/css/style_addCoupon.css">
	<link rel="stylesheet" href="/css/style_addProduct.css">
	<link rel="stylesheet" href="/css/style_admin_mypage.css">
	<link rel="stylesheet" href="/css/style_admin_order.css">
	<link rel="stylesheet" href="/css/style_admincouponView.css">
	<link rel="stylesheet" href="/css/style_adminMaintenance.css">
</head>
<%-- 컨트롤러(.java) 수정 없이, 홈페이지 배경(산수화 이미지)을 홈 화면에서만 적용하기 위해
     현재 요청 경로를 JSP EL에서 직접 확인해 body 클래스를 결정한다 --%>
<body class="${pageContext.request.getAttribute('jakarta.servlet.forward.servlet_path') == '/' ? 'home-hero' : ''}" data-logged-in="${not empty sessionScope.loginMemberId}" data-home-url="<c:url value='/'/>">
	<header id="site-header">

		<div id="logo_img">
			<a href="<c:url value='/'/>">Masion De SAJO</a>
		</div>

		<div id="search_box">
			<%-- TODO(placeholder route): "/search" 컨트롤러 미구현 --%>
			<form id="headerSearchForm" action="<c:url value='/search'/>" method="get">
				<input type="search" id="headerSearchInput" name="keyword" class="search-input"
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
				<%-- TODO(placeholder route): 찜 컨트롤러 미구현, 담당 브랜치 확정 시 경로 조정 --%>
				<a class="icon-item" href="<c:url value='/wish'/>">
					<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/>
					</svg>
					<span class="icon-badge" id="wishBadge" hidden>0</span>
					<span class="icon-label">찜</span>
				</a>

				<%-- TODO(placeholder route): 장바구니 컨트롤러 미구현, 담당 브랜치 확정 시 경로 조정 --%>
				<a class="icon-item" href="<c:url value='/cart'/>">
					<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/>
						<path d="M3 6h18"/>
						<path d="M16 10a4 4 0 0 1-8 0"/>
					</svg>
					<span class="icon-badge" id="cartBadge" hidden>0</span>
					<span class="icon-label">장바구니</span>
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
				<a href="<c:url value='/member/login'/>">로그인</a>
				<span class="sign-divider" aria-hidden="true">|</span>
				<a href="<c:url value='/member/signUp'/>">회원가입</a>
			</div>
		</div>

	</header>

	<script src="<c:url value='/js/common/cartWishService.js'/>"></script>
	<script src="<c:url value='/js/views/header.js'/>"></script>

	<main>