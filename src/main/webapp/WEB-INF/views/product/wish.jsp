<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- data-detail-base-url: views/wish.js가 상품 상세 링크를 만들 때 쓴다. JS를 외부 파일로
	 분리하면서 <c:url>을 스크립트 안에 쓸 수 없게 되어 data 속성으로 넘긴다.
	 data-remove-url: 찜 해제를 서버(WishController.removeWish)에 반영할 때 쓴다. --%>
<section class="wishlist-container" id="wishlist-container"
		 data-detail-base-url="<c:url value='/mds/detail'/>"
		 data-remove-url="<c:url value='/wish/remove-wish'/>">
	<div class="wishlist-header">
		<h1>찜</h1>
		<p>마음에 드는 상품을 모아두었어요</p>
	</div>

	<%-- 체크박스는 평소엔 숨겨두고 "상품 선택"을 눌렀을 때만 보인다(admin/admincouponView.jsp의
	     선택 모드와 동일한 로직) - 예전엔 항상 노출돼 있었다. --%>
	<div class="wishlist-controls" id="wishlist-controls">
		<div class="select-menu" id="wishSelectionControls" hidden>
			<label class="checkbox-label">
				<input type="checkbox" id="wish-check-all">
				<span>전체 선택</span>
			</label>
		</div>
		<%-- 선택 모드에서만 보이는 버튼들(views/wish.js가 토글). 카드 낱개 퀵버튼과 같은 API를 쓴다 --%>
		<div class="list-control-actions">
			<button type="button" id="wish-cart-btn" hidden>선택 상품 장바구니 담기</button>
			<button type="button" id="wish-delete-btn" hidden>선택 상품 삭제</button>
			<button type="button" id="toggleWishSelectButton">상품 선택</button>
		</div>
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

	<%-- 이미 서버에서 다 받아온 목록을 화면에서만 자르는 클라이언트 페이징(wish.js) - 검색 결과
	     화면과 같은 .sp-pagination 스타일을 재사용한다. --%>
	<nav class="sp-pagination" id="wish-pagination" aria-label="페이지 탐색" hidden></nav>

	<div class="wishlist-empty" id="wishlist-empty" hidden>
		<p class="wishlist-empty-title">찜한 상품이 없습니다.</p>
		<p class="wishlist-empty-desc">마음에 드는 상품을 찜해보세요.</p>
		<a class="btn-solid" href="<c:url value='/'/>">상품 보러가기</a>
	</div>
</section>

<%-- 서버(WishController.myWish)가 넘겨준 실제 찜 목록. cart.jsp의 serverCartItems와 같은 방식으로
	 넘기고, 화면 렌더링은 wishService.js가 이걸 읽어서 처리한다. --%>
<script>
	window.serverWishItems = [
		<c:forEach items="${list}" var="item" varStatus="status">
		{
			productId: "${item.productId}",
			name: "<c:out value='${item.productName}'/>",
			imageUrl: "<c:out value='${item.imagePath}'/><c:out value='${item.titleImage}'/>",
			price: ${item.price},
			rating: ${item.score},
			reviewCount: ${item.reviewCount},
			popId: ${item.popId != null ? item.popId : 'null'}
		}<c:if test="${!status.last}">,</c:if>
		</c:forEach>
	];
</script>

<script src="<c:url value='/js/product/wishService.js'/>"></script>
<script src="<c:url value='/js/views/wish.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
