<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="search-result-page">

	<!-- 사이드바 배너: 콘텐츠(1200px) 오른쪽 여백에 홈 배너와 같은 슬라이드를 축소해서 노출.
	     넓은 화면에서만 보임(좁은 화면은 여백 자체가 없음) -->
	<aside class="sp-sidebar-banner" aria-label="홈 배너">
		<div class="banner-slider" id="sidebarBannerSlider">
			<div class="banner-slide is-active">
				<div class="banner-image"></div>
				<div class="banner-content">
					<p class="banner-subtitle">Maison de sajo</p>
					<h2>마음을 고르는<br>가장 다정한 방법</h2>
				</div>
			</div>
			<div class="banner-slide">
				<div class="banner-image banner-image-alt"></div>
				<div class="banner-content">
					<p class="banner-subtitle">Best Seller</p>
					<h2>지금 가장 사랑받는<br>선물 이야기</h2>
				</div>
			</div>
			<div class="banner-slide">
				<div class="banner-image banner-image-warm"></div>
				<div class="banner-content">
					<p class="banner-subtitle">Special Offer</p>
					<h2>명절 맞이<br>특별한 할인 혜택</h2>
				</div>
			</div>
			<div class="banner-dots">
				<button type="button" class="banner-dot is-active" aria-label="1번째 배너로 이동"></button>
				<button type="button" class="banner-dot" aria-label="2번째 배너로 이동"></button>
				<button type="button" class="banner-dot" aria-label="3번째 배너로 이동"></button>
			</div>
		</div>
	</aside>

	<!-- 메인 카테고리: 헤더 바로 밑에 고정 -->
	<%-- TODO(data binding): ProductController.getList()가 model에 담은 데이터를 리다이렉트(return "redirect:home/home")로
	     날려버려서 productList.category가 아직 렌더링되지 않음 --%>
	<section class="sp-category-section" aria-label="카테고리 선택">
		<div class="sp-category-grid">
			<!-- 테스트/예시용 카테고리 3개 (DB 미연동 상태에서도 항상 보이는 하드코딩 데이터) -->
			<button type="button" class="sp-category-item">(예시) 생일</button>
			<button type="button" class="sp-category-item">(예시) 맛있는 선물</button>
			<button type="button" class="sp-category-item">(예시) 건강</button>
			<c:forEach items="${productList.category}" var="category">
				<button type="button" class="sp-category-item">${category.categoryName}</button>
			</c:forEach>
		</div>
	</section>

	<!-- 태그: 가격대·선호 등 상품 속성. 중복 선택 가능, 메인 카테고리 바로 아래 위치 -->
	<%-- TODO(data binding): Tag/TagDetail 테이블 연동 필요. 현재는 테스트용 6개 하드코딩 --%>
	<section class="sp-tag-section" aria-label="태그">
		<div class="sp-tag-selector">
			<button type="button" class="sp-tag-btn">1만원대</button>
			<button type="button" class="sp-tag-btn">2만원대</button>
			<button type="button" class="sp-tag-btn">3만원대</button>
			<button type="button" class="sp-tag-btn">10만원대</button>
			<button type="button" class="sp-tag-btn">남성 선호</button>
			<button type="button" class="sp-tag-btn">여성 선호</button>
		</div>
	</section>

	<!-- 검색창 및 인기/신상품/할인 필터 (상품 목록 상단 우측) -->
	<section class="sp-search-filter" aria-label="검색 및 필터">
		<%-- TODO(placeholder route): "/search" 컨트롤러 미구현 --%>
		<form class="sp-search-form" action="<c:url value='/search'/>" method="get">
			<label for="spSearchInput" class="sr-only">검색어</label>
			<input type="search" id="spSearchInput" name="keyword" class="sp-search-input"
				   placeholder="검색어를 입력하세요">
			<button type="submit" class="sp-search-btn">검색</button>
		</form>
		<div class="sp-quick-filter">
			<button type="button" class="sp-filter-btn">인기</button>
			<button type="button" class="sp-filter-btn">신상품</button>
			<button type="button" class="sp-filter-btn">할인</button>
		</div>
	</section>

	<!-- 상품 카드 그리드: productList.product(ProductListDTO)를 반복 출력 -->
	<%-- ProductListDTO 필드 = productId, productTitle, wishCount, titleImage, price, categoryNames, tagData, score --%>
	<section class="sp-product-section" aria-label="검색 결과">
		<div class="sp-product-grid">

			<!-- 테스트/예시용 카드 3개: 실제 DB 상품이 아니므로 /mds/detail/1~3은 임시 테스트용 id (경로 연결 확인용) -->
			<%-- TODO(placeholder id): 실제 상품이 아닌 예시 카드라 productId 1~3을 고정 사용. 실제 데이터로 교체 시 제거 필요 --%>
			<article class="sp-product-card" data-product-id="example-1">
				<a class="sp-product-link" href="<c:url value='/mds/detail/1'/>">
					<figure class="sp-product-thumb">
						<div class="sp-product-img">상품 이미지</div>
						<div class="sp-tag-popup">
							<span class="sp-product-tag">10만원대</span>
							<span class="sp-product-tag">남성 선호</span>
						</div>
					</figure>
					<div class="sp-product-info">
						<h3 class="sp-product-name">(예시) 프리미엄 선물세트</h3>
						<p class="sp-product-price">₩189,000</p>
						<p class="sp-product-category">명품 선물</p>
					</div>
				</a>
				<button type="button" class="sp-btn-wishlist" aria-label="찜하기">
					<svg class="wish-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
					</svg>
				</button>
				<div class="sp-product-actions">
					<button type="button" class="sp-btn-cart">장바구니 담기</button>
				</div>
			</article>

			<article class="sp-product-card" data-product-id="example-2">
				<a class="sp-product-link" href="<c:url value='/mds/detail/2'/>">
					<figure class="sp-product-thumb">
						<div class="sp-product-img">상품 이미지</div>
						<div class="sp-tag-popup">
							<span class="sp-product-tag">10만원대</span>
						</div>
					</figure>
					<div class="sp-product-info">
						<h3 class="sp-product-name">(예시) 한우 선물세트</h3>
						<p class="sp-product-price">₩259,000</p>
						<p class="sp-product-category">맛있는 선물</p>
					</div>
				</a>
				<button type="button" class="sp-btn-wishlist" aria-label="찜하기">
					<svg class="wish-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
					</svg>
				</button>
				<div class="sp-product-actions">
					<button type="button" class="sp-btn-cart">장바구니 담기</button>
				</div>
			</article>

			<article class="sp-product-card" data-product-id="example-3">
				<a class="sp-product-link" href="<c:url value='/mds/detail/3'/>">
					<figure class="sp-product-thumb">
						<div class="sp-product-img">상품 이미지</div>
						<div class="sp-tag-popup">
							<span class="sp-product-tag">1만원대</span>
							<span class="sp-product-tag">여성 선호</span>
						</div>
					</figure>
					<div class="sp-product-info">
						<h3 class="sp-product-name">(예시) 건강 선물세트</h3>
						<p class="sp-product-price">₩99,000</p>
						<p class="sp-product-category">건강</p>
					</div>
				</a>
				<button type="button" class="sp-btn-wishlist" aria-label="찜하기">
					<svg class="wish-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
						<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
					</svg>
				</button>
				<div class="sp-product-actions">
					<button type="button" class="sp-btn-cart">장바구니 담기</button>
				</div>
			</article>

			<%-- TODO(placeholder route): /mds/detail/{productId}는 ProductController가 결과를 무조건
			     redirect:home/home으로 던져서 아직 미동작 --%>
			<c:forEach items="${productList.product}" var="product">
				<article class="sp-product-card" data-product-id="${product.productId}">
					<a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>">
						<figure class="sp-product-thumb">
							<div class="sp-product-img">
								<c:choose>
									<c:when test="${not empty product.thumbnail}">
										<img src="${product.thumbnail}" alt="${product.productTitle}">
									</c:when>
									<c:otherwise>상품 이미지</c:otherwise>
								</c:choose>
							</div>
						</figure>
						<div class="sp-product-info">
							<h3 class="sp-product-name">${product.productTitle}</h3>
							<p class="sp-product-price">₩<fmt:formatNumber value="${product.price}" pattern="#,##0"/></p>
						</div>
					</a>
					<button type="button" class="sp-btn-wishlist" aria-label="찜하기">
						<svg class="wish-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
							<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
						</svg>
					</button>
					<div class="sp-product-actions">
						<button type="button" class="sp-btn-cart">장바구니 담기</button>
					</div>
				</article>
			</c:forEach>

		</div>
	</section>

	<!-- 하단 영역: 페이지 번호 -->
	<nav class="sp-pagination" aria-label="페이지 탐색">
		<button type="button" class="sp-btn-prev">이전</button>
		<ol>
			<li><button type="button" class="sp-page-btn is-current" aria-current="page">1</button></li>
			<li><button type="button" class="sp-page-btn">2</button></li>
			<li><button type="button" class="sp-page-btn">3</button></li>
			<li><button type="button" class="sp-page-btn">4</button></li>
			<li><button type="button" class="sp-page-btn">5</button></li>
		</ol>
		<button type="button" class="sp-btn-next">다음</button>
	</nav>

</div>

<script src="<c:url value='/js/common/bannerSlider.js'/>"></script>

<%-- TODO(data binding): 찜 상태는 header.jsp의 localStorage(wishItems) 임시 구현, 실제로는 /wish API 필요 --%>
<script>
	document.querySelectorAll('.sp-btn-wishlist').forEach(function (btn) {
		var card = btn.closest('.sp-product-card');
		var productId = card.dataset.productId;

		if (typeof window.isWished === 'function' && window.isWished(productId)) {
			btn.classList.add('is-active');
		}

		btn.addEventListener('click', function () {
			if (typeof window.toggleWish !== 'function') return;
			var name = card.querySelector('.sp-product-name').textContent.trim();
			var priceText = card.querySelector('.sp-product-price').textContent;
			var price = parseInt(priceText.replace(/[^0-9]/g, ''), 10) || 0;
			var active = window.toggleWish({ productId: productId, name: name, price: price });
			btn.classList.toggle('is-active', active);
		});
	});

	document.querySelectorAll('.sp-btn-cart').forEach(function (btn) {
		btn.addEventListener('click', function () {
			if (typeof window.addToCart !== 'function') return;
			var card = btn.closest('.sp-product-card');
			var name = card.querySelector('.sp-product-name').textContent.trim();
			var priceText = card.querySelector('.sp-product-price').textContent;
			var price = parseInt(priceText.replace(/[^0-9]/g, ''), 10) || 0;
			window.addToCart({ productId: card.dataset.productId, name: name, price: price, qty: 1 });
		});
	});

	// TODO(data binding): 태그 선택은 아직 실제 검색/필터 요청과 연결되어 있지 않음, UI 토글만 동작
	document.querySelectorAll('.sp-tag-btn').forEach(function (btn) {
		btn.addEventListener('click', function () {
			btn.classList.toggle('is-active');
		});
	});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
