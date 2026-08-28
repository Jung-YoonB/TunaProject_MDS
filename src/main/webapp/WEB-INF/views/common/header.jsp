<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<!DOCTYPE html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>메종 드 사조</title>
	
	 <link rel="stylesheet" href="/css/common.css">
	<link rel="stylesheet" href="/css/style.css">
	<link rel="stylesheet" href="/css/style_member.css">
	<link rel="stylesheet" href="/css/style_order.css">
	<link rel="stylesheet" href="/css/style_home.css">
	<link rel="stylesheet" href="/css/style_myPage.css">
</head>
<body>
	<header id="site-header">
	
		<div id="logo_img">
			<a href="<c:url value='/'/>">Masion De Sajo</a>
		</div>
	
		<div id="search_box">
			<input type="text" id="search_input" class="search-input"
				   placeholder="상품을 검색해주세요" aria-label="상품 검색" autocomplete="off">
		</div>
	
		<div class="icon">
			<a class="icon-item" href="<c:url value='/member/myPage'/>">
				<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
					<path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/>
				</svg>
				<span class="icon-label">마이페이지</span>
			</a>
	
			<%-- TODO(placeholder route): 찜 컨트롤러 미구현, 담당 브랜치 확정 시 경로 조정 --%>
			<a class="icon-item" href="<c:url value='/wish'/>">
				<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
					<path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/>
				</svg>
				<span class="icon-label">찜</span>
			</a>
	
			<%-- TODO(placeholder route): 장바구니 컨트롤러 미구현, 담당 브랜치 확정 시 경로 조정 --%>
			<a class="icon-item" href="<c:url value='/cart'/>">
				<svg class="icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
					<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/>
					<path d="M3 6h18"/>
					<path d="M16 10a4 4 0 0 1-8 0"/>
				</svg>
				<span class="icon-label">장바구니</span>
			</a>
		</div>
	
		<div class="sign">
			<a href="<c:url value='/member/login'/>">로그인</a>
			<span class="sign-divider" aria-hidden="true">|</span>
			<a href="<c:url value='/member/signUp'/>">회원가입</a>
		</div>
	
	</header>

	<script src="/js/common/header.js"></script>
	<main>