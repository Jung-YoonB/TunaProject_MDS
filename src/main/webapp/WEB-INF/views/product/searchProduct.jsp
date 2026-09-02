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
			<%-- 카드 구조/아이콘을 홈페이지 상품 카드(static/js/views/home.js의 buildCard)와 통일함(2026-09-02):
			     .product-img+.product-cart-quick, .product-meta(.product-rating+.product-wish-toggle).
			     가격은 홈과 마찬가지로 화면에 안 보이고, 장바구니 담기에 필요해 data-price로만 들고 있음.
			     sp-* 클래스는 views/searchProduct.js의 기존 셀렉터 호환을 위해 그대로 같이 붙여둠. --%>
			<article class="product-card sp-product-card" data-product-id="example-1" data-price="189000">
				<div class="product-img">
					<a class="sp-product-link" href="<c:url value='/mds/detail/1'/>" aria-label="(예시) 프리미엄 선물세트 상세 보기"></a>
					<button type="button" class="product-cart-quick sp-btn-cart" aria-label="장바구니 담기">
						<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
							<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
							<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
						</svg>
					</button>
					<div class="sp-tag-popup">
						<span class="sp-product-tag">10만원대</span>
						<span class="sp-product-tag">남성 선호</span>
					</div>
				</div>
				<div class="product-info">
					<a class="sp-product-link" href="<c:url value='/mds/detail/1'/>"><h3 class="product-name sp-product-name">(예시) 프리미엄 선물세트</h3></a>
					<p class="product-description">명품 선물</p>
					<div class="product-meta">
						<a href="#" class="product-rating" aria-label="리뷰 보기">
							<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
							<span class="product-rating-score">4.8 (245)</span>
						</a>
						<button type="button" class="product-wish-toggle sp-btn-wishlist" aria-label="찜하기">
							<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
							<span class="product-wish-count-num">342</span>
						</button>
					</div>
				</div>
			</article>

			<article class="product-card sp-product-card" data-product-id="example-2" data-price="259000">
				<div class="product-img">
					<a class="sp-product-link" href="<c:url value='/mds/detail/2'/>" aria-label="(예시) 한우 선물세트 상세 보기"></a>
					<button type="button" class="product-cart-quick sp-btn-cart" aria-label="장바구니 담기">
						<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
							<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
							<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
						</svg>
					</button>
					<div class="sp-tag-popup">
						<span class="sp-product-tag">10만원대</span>
					</div>
				</div>
				<div class="product-info">
					<a class="sp-product-link" href="<c:url value='/mds/detail/2'/>"><h3 class="product-name sp-product-name">(예시) 한우 선물세트</h3></a>
					<p class="product-description">맛있는 선물</p>
					<div class="product-meta">
						<a href="#" class="product-rating" aria-label="리뷰 보기">
							<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
							<span class="product-rating-score">4.9 (892)</span>
						</a>
						<button type="button" class="product-wish-toggle sp-btn-wishlist" aria-label="찜하기">
							<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
							<span class="product-wish-count-num">567</span>
						</button>
					</div>
				</div>
			</article>

			<article class="product-card sp-product-card" data-product-id="example-3" data-price="99000">
				<div class="product-img">
					<a class="sp-product-link" href="<c:url value='/mds/detail/3'/>" aria-label="(예시) 건강 선물세트 상세 보기"></a>
					<button type="button" class="product-cart-quick sp-btn-cart" aria-label="장바구니 담기">
						<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
							<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
							<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
						</svg>
					</button>
					<div class="sp-tag-popup">
						<span class="sp-product-tag">1만원대</span>
						<span class="sp-product-tag">여성 선호</span>
					</div>
				</div>
				<div class="product-info">
					<a class="sp-product-link" href="<c:url value='/mds/detail/3'/>"><h3 class="product-name sp-product-name">(예시) 건강 선물세트</h3></a>
					<p class="product-description">건강</p>
					<div class="product-meta">
						<a href="#" class="product-rating" aria-label="리뷰 보기">
							<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
							<span class="product-rating-score">4.8 (652)</span>
						</a>
						<button type="button" class="product-wish-toggle sp-btn-wishlist" aria-label="찜하기">
							<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
							<span class="product-wish-count-num">218</span>
						</button>
					</div>
				</div>
			</article>

			<%-- TODO(placeholder route): /mds/detail/{productId}는 ProductController가 결과를 무조건
			     redirect:home/home으로 던져서 아직 미동작 --%>
			<c:forEach items="${productList.product}" var="product">
				<article class="product-card sp-product-card" data-product-id="${product.productId}" data-price="${product.price}">
					<div class="product-img">
						<a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>" aria-label="${product.productTitle} 상세 보기">
							<c:if test="${not empty product.thumbnail}">
								<img src="${product.thumbnail}" alt="${product.productTitle}">
							</c:if>
						</a>
						<button type="button" class="product-cart-quick sp-btn-cart" aria-label="장바구니 담기">
							<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
								<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
								<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
							</svg>
						</button>
					</div>
					<div class="product-info">
						<a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>"><h3 class="product-name sp-product-name">${product.productTitle}</h3></a>
						<p class="product-description">${product.categoryNames}</p>
						<div class="product-meta">
							<a href="#" class="product-rating" aria-label="리뷰 보기">
								<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
								<span class="product-rating-score">${product.score}</span>
							</a>
							<button type="button" class="product-wish-toggle sp-btn-wishlist" aria-label="찜하기">
								<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
								<span class="product-wish-count-num">${product.wishCount}</span>
							</button>
						</div>
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

<script src="<c:url value='/js/views/searchProduct.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
