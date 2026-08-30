<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="home-page">

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

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>