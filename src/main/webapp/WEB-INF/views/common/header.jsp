<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<!DOCTYPE html>
<html lang="ko">
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
	<link rel="stylesheet" href="/css/style_search.css">
	<link rel="stylesheet" href="/css/style_cart.css">
	<link rel="stylesheet" href="/css/style_wish.css">
</head>
<body>
	<header id="site-header">
	
		<div id="logo_img">
			<a href="<c:url value='/'/>">Masion De Sajo</a>
		</div>
	
		<div id="search_box">
			<%-- TODO(placeholder route): "/search" 컨트롤러 미구현 --%>
			<form id="headerSearchForm" action="<c:url value='/search'/>" method="get">
				<input type="search" id="search_input" name="keyword" class="search-input"
					   placeholder="상품을 검색해주세요" aria-label="상품 검색" autocomplete="off">
			</form>
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
		</div>
	
		<div class="sign">
			<a href="<c:url value='/member/login'/>">로그인</a>
			<span class="sign-divider" aria-hidden="true">|</span>
			<a href="<c:url value='/member/signUp'/>">회원가입</a>
		</div>
	
	</header>

	<%-- TODO(data binding): 장바구니/찜은 localStorage 임시 구현, 실제로는 Cart(pop_id 기준)·Wish 테이블과 서버 동기화 필요 --%>
	<script>
		(function () {
			var isLoggedIn = ${not empty sessionScope.loginMemberId};
			var cartBadge = document.getElementById('cartBadge');
			var wishBadge = document.getElementById('wishBadge');

			function getCartItems() {
				try {
					var items = JSON.parse(localStorage.getItem('cartItems') || '[]');
					return Array.isArray(items) ? items : [];
				} catch (e) {
					return [];
				}
			}

			function getWishList() {
				try {
					return JSON.parse(localStorage.getItem('wishItems') || '[]');
				} catch (e) {
					return [];
				}
			}

			function renderBadges() {
				var cartCount = getCartItems().reduce(function (sum, item) { return sum + (item.qty || 0); }, 0);
				cartBadge.textContent = cartCount;
				cartBadge.hidden = cartCount <= 0;

				var wishCount = getWishList().length;
				wishBadge.textContent = wishCount;
				wishBadge.hidden = wishCount <= 0;
			}

			// 비회원이 메인 화면으로 돌아오면 담아둔 장바구니/찜 정보를 초기화 (테스트/초기화용)
			if (!isLoggedIn && window.location.pathname === '<c:url value="/"/>') {
				localStorage.removeItem('cartItems');
				localStorage.removeItem('wishItems');
			}

			// TODO(data binding): 실제로는 Cart가 pop_id(옵션 단위) 기준이라 상품+옵션 조합마다 별도 행이어야 함.
			// 현재는 productId+optionName 조합을 임시 키로 사용해 같은 상품이라도 옵션이 다르면 합치지 않음.
			window.addToCart = function (item) {
				var items = getCartItems();
				var optionName = item.optionName || '기본 옵션';
				var existing = items.filter(function (i) {
					return i.productId === item.productId && (i.optionName || '기본 옵션') === optionName;
				})[0];
				if (existing) {
					existing.qty += (item.qty || 1);
				} else {
					items.push({ productId: item.productId, name: item.name, optionName: optionName, price: item.price, qty: item.qty || 1 });
				}
				localStorage.setItem('cartItems', JSON.stringify(items));
				renderBadges();
			};

			window.toggleWish = function (item) {
				var list = getWishList();
				var key = String(item.productId);
				var idx = -1;
				for (var i = 0; i < list.length; i++) {
					if (list[i].productId === key) { idx = i; break; }
				}
				var active;
				if (idx === -1) {
					list.push({ productId: key, name: item.name, price: item.price, addedAt: Date.now() });
					active = true;
				} else {
					list.splice(idx, 1);
					active = false;
				}
				localStorage.setItem('wishItems', JSON.stringify(list));
				renderBadges();
				return active;
			};

			window.isWished = function (productId) {
				var list = getWishList();
				var key = String(productId);
				for (var i = 0; i < list.length; i++) {
					if (list[i].productId === key) return true;
				}
				return false;
			};

			// cart.jsp/wish.jsp 등 다른 페이지가 cartItems/wishItems를 직접 수정한 뒤 뱃지 갱신을 요청할 때 사용
			window.refreshCartBadge = renderBadges;

			renderBadges();
		})();
	</script>

	<main>
