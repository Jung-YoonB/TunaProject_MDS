<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>Masion De Sajo</title>
		<link rel="stylesheet" href="/css/default.css">
		<link rel="stylesheet" href="/css/style-home.css">
	</head>
	
	<body>
	    <header>
	        <!-- 로고 -->
	        <div id="logo_img">Masion De Sajo</div>
	
	        <!-- 검색창 -->
	        <div id="search_box">
	            <input type="text" id="search-box" placeholder="상품을 검색해주세요">
	        </div>
	
	        <!-- 마이페이지 / 찜 / 장바구니 -->
	        <div id="icon-menu">
	            <div class="icon-item">
	                <div class="icon-box"> ♡ </div>
				마이페이지</div>
	
	            <div class="icon-item">
	                <div class="icon-box"> ♡ </div>
				찜</div>
	
	            <div class="icon-item">
	                <div class="icon-box"> 🛒 </div>
				장바구니</div>
	        </div>
	
	        <!-- 로그인 / 회원가입 -->
	        <div id="account-menu">
	            <a href="#">로그인</a>
	            <span>|</span>
	            <a href="#">회원가입</a>
	        </div>
	    </header>
	
	    <main>
	        <!-- 배너 -->
	        <div id="banner">배너 이미지</div>
	        <!-- 선물 카테고리 -->
	        <div id="category">
	            <div id="category-title">선물 카테고리</div>
	            <div id="category-list">
	                <!-- 1 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">생일</div>
	                </div>
	                <!-- 2 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">맛있는 선물</div>
	                </div>
	                <!-- 3 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">건강</div>
	                </div>
	                <!-- 4 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">패션·쥬얼리</div>
	                </div>
	                <!-- 5 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">가벼운 선물</div>
	                </div>
	                <!-- 6 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">명품 선물</div>
	                </div>
	                <!-- 7 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">출산·돌</div>
	                </div>
	                <!-- 8 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">결혼·집들이</div>
	                </div>
	                <!-- 9 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">상품권</div>
	                </div>
	                <!-- 10 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">합격·응원</div>
	                </div>
	                <!-- 11 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">화장품</div>
	                </div>
	                <!-- 12 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">주류</div>
	                </div>
	                <!-- 13 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">육아용품</div>
	                </div>
	                <!-- 14 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">스포츠</div>
	                </div>
	                <!-- 15 -->
	                <div class="category-item">
	                    <div class="category-img">이미지</div>
	                    <div class="category-name">리빙·키친</div>
	                </div>
	            </div>
	        </div>
	
	        <!-- 상품 -->
	        <div id="product">
	            <div id="product-title">인기 선물</div>
	            <div id="product-list">
	                <div class="product-card">
	                    <div class="product-img">상품 이미지</div>
	                    <div class="product-info">
	                        <div class="product-name">프리미엄 선물세트</div>
	                        <div class="product-price">상품 가격</div>
	                    </div>
	                </div>
					
	                <div class="product-card">
	                    <div class="product-img">상품 이미지</div>
	                    <div class="product-info">
	                        <div class="product-name">한우 선물세트</div>
	                        <div class="product-price">상품 가격</div>
	                    </div>
	                </div>
	
	                <div class="product-card">
	                    <div class="product-img">상품 이미지</div>
	                    <div class="product-info">
	                        <div class="product-name">건강 선물세트</div>
	                        <div class="product-price">상품 가격</div>
	                    </div>
	                </div>
	
	                <div class="product-card">
	                    <div class="product-img">상품 이미지</div>
	                    <div class="product-info">
	                        <div class="product-name">프리미엄 디저트</div>
	                        <div class="product-price">상품 가격</div>
	                    </div>
	                </div>
	            </div>
	        </div>
	    </main>
	
		<footer class="site-footer">
			<!-- 상단: 회사 정보 및 nav -->
			<div class="footer-top">
				<!-- 좌측: 회사 정보 -->
				<div class="company-info">
					<h2>Masion De SAJO</h2>
					<address>
						<p>주소지</p>
						<p>우편번호</p>
						<p>고객센터번호</p>
					</address>
				</div>
				<!-- 우측: 약관 및 고객센터 메뉴 -->
				<nav class="footer-nav">
					<ul>
						<li><a href="#">이용약관</a></li>
						<li><a href="#">개인정보처리방침</a></li>
						<li><a href="#">사업자정보</a></li>
						<li><a href="#">고객센터</a></li>
					</ul>
				</nav>
			</div>
			<!-- 구분선 -->
			<hr class="footer-divider">
			<!-- 하단: 저작권 정보 -->
			<div class="footer-bottom">
				<p class="copyright">&copy; 2024 Masion De SAJO. All rights reserved.</p>
			</div>
		</footer>
	</body>
</html>