<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- data-search-url: views/searchProduct.js가 태그 필터를 다시 요청할 때 쓴다.
	 JS를 외부 파일로 분리해서 <c:url>을 스크립트 안에 쓸 수 없어 data 속성으로 넘긴다
	 (wish.jsp의 data-detail-base-url과 같은 방식). --%>
<div class="search-result-page" data-search-url="<c:url value='/mds/searchList'/>">

	<!-- 사이드바 배너: 콘텐츠(1200px) 오른쪽 여백에 홈 배너와 같은 슬라이드를 축소해서 노출.
	     넓은 화면에서만 보임(좁은 화면은 여백 자체가 없음) -->
	<%-- 배너 이미지는 최근 등록된 상품의 대표 이미지 최대 5장(ProductController가 bannerList로 담아줌).
	     문구는 기존 3종을 그대로 쓰고, 이미지 장수가 3장을 넘으면 앞에서부터 다시 돌려쓴다.
	     슬라이드/도트 개수가 항상 같아야 bannerSlider.js의 인덱스가 맞으므로 같은 목록으로 돌린다.
	     이미지를 아직 못 받아온 경우(등록된 상품 이미지 0건)에는 기존 그라데이션 배경이 그대로 보인다. --%>
	<aside class="sp-sidebar-banner" aria-label="홈 배너">
		<div class="banner-slider" id="sidebarBannerSlider">
			<c:forEach items="${bannerList}" var="banner" varStatus="st">
				<%-- 문구 3종 순환: 0번째=Maison de sajo, 1번째=Best Seller, 2번째=Special Offer --%>
				<c:set var="copyIndex" value="${st.index % 3}"/>
				<div class="banner-slide ${st.first ? 'is-active' : ''}">
					<div class="banner-image"
						 style="background-image: url('<c:out value='${banner.imagePath}'/><c:out value='${banner.banner}'/>')"></div>
					<div class="banner-content">
						<c:choose>
							<c:when test="${copyIndex == 0}">
								<p class="banner-subtitle">Maison de sajo</p>
								<h2>마음을 고르는<br>가장 다정한 방법</h2>
							</c:when>
							<c:when test="${copyIndex == 1}">
								<p class="banner-subtitle">Best Seller</p>
								<h2>지금 가장 사랑받는<br>선물 이야기</h2>
							</c:when>
							<c:otherwise>
								<p class="banner-subtitle">Special Offer</p>
								<h2>명절 맞이<br>특별한 할인 혜택</h2>
							</c:otherwise>
						</c:choose>
					</div>
				</div>
			</c:forEach>
			<div class="banner-dots">
				<c:forEach items="${bannerList}" var="banner" varStatus="st">
					<button type="button" class="banner-dot ${st.first ? 'is-active' : ''}"
							aria-label="${st.count}번째 배너로 이동"></button>
				</c:forEach>
			</div>
		</div>
	</aside>

	<!-- 메인 카테고리: 헤더 바로 밑에 고정 -->
	<%-- 카테고리 칩은 CATEGORY 테이블 전체를 그대로 뿌린다(ProductController가 categoryList로 담아줌).
	     누르면 SearchDTO.category로 넘어가 서버에서 필터링된다. 검색어가 있으면 같이 들고 간다. --%>
	<section class="sp-category-section" aria-label="카테고리 선택">
		<div class="sp-category-grid">
			<c:forEach items="${categoryList}" var="category">
				<%-- 이미 선택된 칩이면 category를 빼서 링크한다 = 한 번 더 누르면 선택 해제(전체 상품).
				     태그는 중복 선택이라 JS가 토글하지만, 카테고리는 단일 선택이라 링크 자체를 바꾼다.
				     선택 중인 태그는 그대로 들고 가야 카테고리만 바꿔도 태그 필터가 풀리지 않는다. --%>
				<c:set var="isSelected" value="${category.categoryId eq param.category}"/>
				<a class="sp-category-item ${isSelected ? 'is-active' : ''}"
				   href="<c:url value='/mds/searchList'><c:param name='keyword' value='${param.keyword}'/><c:if test='${not isSelected}'><c:param name='category' value='${category.categoryId}'/></c:if><c:forEach items='${paramValues.tag}' var='t'><c:param name='tag' value='${t}'/></c:forEach></c:url>">${category.categoryName}</a>
			</c:forEach>
		</div>
	</section>

	<!-- 태그: 가격대·선호 등 상품 속성. 중복 선택 가능, 메인 카테고리 바로 아래 위치 -->
	<%-- 태그 칩은 TAG 테이블 전체를 뿌린다(ProductController가 tagList로 담아줌).
	     카테고리와 달리 중복 선택이라 링크로 만들지 않고, 켜져 있는 태그를 views/searchProduct.js가
	     모아서 tag 파라미터 여러 개(SearchDTO.tag = List<Long>)로 다시 요청한다.
	     선택 상태 표시도 같은 파일이 주소창의 tag 값을 읽어 처리한다. --%>
	<section class="sp-tag-section" aria-label="태그">
		<div class="sp-tag-selector">
			<c:forEach items="${tagList}" var="tag">
				<button type="button" class="sp-tag-btn" data-tag-id="${tag.tagId}">${tag.tagName}</button>
			</c:forEach>
		</div>
	</section>

	<!-- 검색창 및 인기/신상품/할인 필터 (상품 목록 상단 우측) -->
	<section class="sp-search-filter" aria-label="검색 및 필터">
		<form class="sp-search-form" action="<c:url value='/mds/searchList'/>" method="get">
			<label for="spSearchInput" class="sr-only">검색어</label>
			<%-- 재검색해도 입력창이 비지 않도록 현재 검색어를 그대로 채워둔다.
				 autocomplete="off"는 헤더 검색창과 맞춘 것 - 없으면 검색어를 지우고 검색해도
				 브라우저가 이전 입력값을 자동으로 되채워서 "한쪽만 지워진 것"처럼 보인다. --%>
			<input type="search" id="spSearchInput" name="keyword" class="sp-search-input"
				   value="<c:out value='${param.keyword}'/>"
				   placeholder="검색어를 입력하세요" autocomplete="off">
			<button type="submit" class="sp-search-btn">검색</button>
		</form>
		<%-- 인기/신상품/할인 퀵필터는 제거함(2026-09-02). 동작한 적이 없고, 실제 필터 역할은
		     위 태그 칩(1만원 미만/여성 인기/신상품 성격의 태그들)이 이미 하고 있어 중복이었다.
		     .sp-quick-filter / .sp-filter-btn CSS도 함께 삭제. --%>
	</section>

	<!-- 상품 카드 그리드: ProductController.getSearchList가 담은 searchList(ProductListDTO)를 반복 출력 -->
	<%-- ProductListDTO 필드 = productId, productTitle, wishCount, imagePath, titleImage, price, categoryNames, tagData, score --%>
	<section class="sp-product-section" id="searchResults" aria-label="검색 결과">
		<div class="sp-product-grid">

			<%-- 카드 구조/아이콘을 홈페이지 상품 카드(static/js/views/home.js의 buildCard)와 통일함(2026-09-02):
			     .product-img+.product-cart-quick, .product-meta(.product-rating+.product-wish-toggle).
			     가격은 홈과 마찬가지로 화면에 안 보이고, 장바구니 담기에 필요해 data-price로만 들고 있음.
			     sp-* 클래스는 views/searchProduct.js의 기존 셀렉터 호환을 위해 그대로 같이 붙여둠. --%>
			<c:forEach items="${searchList}" var="product">
				<article class="product-card sp-product-card" data-product-id="${product.productId}" data-price="${product.price}" data-pop-id="${product.popId}">
					<div class="product-img">
						<a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>" aria-label="${product.productTitle} 상세 보기">
							<%-- 이미지 주소는 경로+저장명을 이어붙인다(주문/리뷰 화면과 동일한 규칙).
							     대표 이미지가 없는 상품은 CSS 기본 배경이 그대로 보인다. --%>
							<c:if test="${not empty product.titleImage}">
								<img src="<c:out value='${product.imagePath}'/><c:out value='${product.titleImage}'/>" alt="${product.productTitle}">
							</c:if>
						</a>
						<button type="button" class="product-cart-quick sp-btn-cart" aria-label="장바구니 담기">
							<svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
								<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
								<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
							</svg>
						</button>
						<%-- 이미지 호버 시 뜨는 태그 팝업. TAG_DATA는 "이름|색상,이름|색상,..." 형태로
						     LISTAGG된 문자열이라(product.xml getList) 콤마로 자른 뒤 각 조각을 다시
						     "|"로 잘라 이름만 쓴다(색상은 .sp-tag-popup CSS가 고정 sage-pale로 그림). --%>
						<c:if test="${not empty product.tagData}">
						<div class="sp-tag-popup">
							<c:forEach items="${fn:split(product.tagData, ',')}" var="tagPair">
								<span class="sp-product-tag">${fn:split(tagPair, '|')[0]}</span>
							</c:forEach>
						</div>
						</c:if>
					</div>
					<div class="product-info">
						<a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>"><h3 class="product-name sp-product-name">${product.productTitle}</h3></a>
						<p class="product-description">${product.categoryNames}</p>
						<div class="product-meta">
							<a href="<c:url value='/mds/detail/${product.productId}'/>#review" class="product-rating" aria-label="리뷰 보기">
								<svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"/></svg>
								<span class="product-rating-score">${product.score}</span>
							</a>
							<%-- ✅ 조치 완료(2026-09-03): 로그인 회원이 이미 찜한 상품이면 최초 렌더링부터
							     하트를 채워서 보여준다(home.jsp와 동일한 조치, AUDIT 신규 버그). --%>
							<button type="button" class="product-wish-toggle sp-btn-wishlist${product.wished ? ' is-active' : ''}" aria-label="${product.wished ? '찜 해제' : '찜하기'}">
								<svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"/></svg>
								<span class="product-wish-count-num">${product.wishCount}</span>
							</button>
						</div>
					</div>
				</article>
			</c:forEach>

		</div>
	</section>

	<!-- 하단 영역: 페이지 번호. 컨트롤러(getSearchList)가 계산해 둔 현재 페이지/전체 페이지/
	     표시할 번호 구간(pageWindowStart~End)을 그대로 쓴다. 페이지를 옮겨도 검색어가 유지되도록
	     모든 링크에 keyword를 같이 실어 보낸다. #searchResults 앵커는 home.jsp 페이지네이션과
	     같은 이유(전체 페이지 이동 시 브라우저가 최상단/배너로 스크롤을 되돌리는 것 방지)로 붙임. -->
	<c:if test="${totalPages > 1}">
		<nav class="sp-pagination" aria-label="페이지 탐색">
			<c:if test="${currentPage > 1}">
				<a class="sp-btn-prev" href="<c:url value='/mds/searchList'><c:param name='keyword' value='${param.keyword}'/><c:param name='category' value='${param.category}'/><c:forEach items='${paramValues.tag}' var='t'><c:param name='tag' value='${t}'/></c:forEach><c:param name='page' value='${currentPage - 1}'/></c:url>#searchResults">이전</a>
			</c:if>
			<ol>
				<c:forEach begin="${pageWindowStart}" end="${pageWindowEnd}" var="p">
					<li>
						<a class="sp-page-btn ${p == currentPage ? 'is-current' : ''}"
						   <c:if test="${p == currentPage}">aria-current="page"</c:if>
						   href="<c:url value='/mds/searchList'><c:param name='keyword' value='${param.keyword}'/><c:param name='category' value='${param.category}'/><c:forEach items='${paramValues.tag}' var='t'><c:param name='tag' value='${t}'/></c:forEach><c:param name='page' value='${p}'/></c:url>#searchResults">${p}</a>
					</li>
				</c:forEach>
			</ol>
			<c:if test="${currentPage < totalPages}">
				<a class="sp-btn-next" href="<c:url value='/mds/searchList'><c:param name='keyword' value='${param.keyword}'/><c:param name='category' value='${param.category}'/><c:forEach items='${paramValues.tag}' var='t'><c:param name='tag' value='${t}'/></c:forEach><c:param name='page' value='${currentPage + 1}'/></c:url>#searchResults">다음</a>
			</c:if>
		</nav>
	</c:if>

</div>

<script src="<c:url value='/js/common/bannerSlider.js'/>"></script>

<script src="<c:url value='/js/views/searchProduct.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
