<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- data-detail-base-url: views/wish.js가 상품 상세 링크를 만들 때 쓴다. JS를 외부 파일로
	 분리하면서 <c:url>을 스크립트 안에 쓸 수 없게 되어 data 속성으로 넘긴다. --%>
<section class="wishlist-container" id="wishlist-container"
		 data-detail-base-url="<c:url value='/mds/detail'/>">
	<div class="wishlist-header">
		<h1>찜</h1>
		<p>마음에 드는 상품을 모아두었어요</p>
	</div>

	<div class="wishlist-controls" id="wishlist-controls">
		<label class="checkbox-label">
			<input type="checkbox" id="wish-check-all">
			<span>전체 선택</span>
		</label>
		<button type="button" id="wish-delete-btn">선택 상품 삭제</button>
	</div>

	<div class="wishlist-filter" id="wishlist-filter">
		<div class="total-count" id="wish-total-count">찜한 상품 0개</div>
		<ul class="short-options" id="wish-short-options">
			<li class="is-active" data-sort="popular">인기순</li>
			<li data-sort="rating-asc">낮은 별점순</li>
			<li data-sort="rating-desc">높은 별점순</li>
			<li data-sort="recent">최신순</li>
		</ul>
	</div>

	<div class="product-grid" id="wish-product-grid"></div>

	<div class="wishlist-empty" id="wishlist-empty" hidden>
		<p class="wishlist-empty-title">찜한 상품이 없습니다.</p>
		<p class="wishlist-empty-desc">마음에 드는 상품을 찜해보세요.</p>
		<a class="btn-solid" href="<c:url value='/'/>">상품 보러가기</a>
	</div>
</section>

<%-- TODO(data binding): 찜 목록은 localStorage(wishItems) 임시 구현임. 실제로는 Wish 테이블 및
	 회원 세션과 연동해야 함. 상세 내용과 연동 지점은 js/product/wishService.js 상단 주석 참고.
	 (localStorage 접근 자체는 js/common/cartWishService.js가 공용으로 담당) --%>
<script src="<c:url value='/js/product/wishService.js'/>"></script>
<script src="<c:url value='/js/views/wish.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
