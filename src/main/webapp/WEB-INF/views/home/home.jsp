<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <!-- 배너 (상품 광고 자동 슬라이드) -->
    <%-- 배너 이미지는 검색 결과 페이지 사이드바 배너와 동일한 목록(ProductController/HomeController가
         똑같이 bannerList로 담아줌 - 최근 등록된 상품의 대표 이미지 최대 5장, product.xml의
         bannerList 쿼리). 문구 3종은 기존 그대로 두고 st.index % 3으로 순환한다(searchProduct.jsp의
         사이드바 배너와 동일한 패턴). 등록된 상품 이미지가 0건이면 bannerList가 빈 목록이라
         슬라이드/도트가 아예 안 뜬다(bannerSlider.js가 슬라이드 0개도 그냥 넘어감). --%>
    <section id="banner">
        <div class="home-container">
            <div class="banner-slider" id="bannerSlider">
                <c:forEach items="${bannerList}" var="banner" varStatus="st">
                    <c:set var="copyIndex" value="${st.index % 3}"/>
                    <div class="banner-slide ${st.first ? 'is-active' : ''}">
                        <div class="banner-content">
                            <c:choose>
                                <c:when test="${copyIndex == 0}">
                                    <p class="banner-subtitle">Maison de sajo</p>
                                    <h1>마음을 고르는<br>가장 다정한 방법</h1>
                                    <p class="banner-description">
                                        소중한 사람에게<br>
                                        취향을 담은 선물을 전해보세요.
                                    </p>
                                </c:when>
                                <c:when test="${copyIndex == 1}">
                                    <p class="banner-subtitle">Best Seller</p>
                                    <h1>지금 가장 사랑받는<br>선물 이야기</h1>
                                    <p class="banner-description">
                                        많은 분들이 선택한<br>
                                        믿을 수 있는 베스트 상품을 만나보세요.
                                    </p>
                                </c:when>
                                <c:otherwise>
                                    <p class="banner-subtitle">Special Offer</p>
                                    <h1>명절 맞이<br>특별한 할인 혜택</h1>
                                    <p class="banner-description">
                                        이 시즌에만 만나볼 수 있는<br>
                                        특별한 가격의 선물세트.
                                    </p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="banner-image"
                             style="background-image: url('<c:out value='${banner.imagePath}'/><c:out value='${banner.banner}'/>')"></div>
                    </div>
                </c:forEach>

                <div class="banner-dots">
                    <c:forEach items="${bannerList}" var="banner" varStatus="st">
                        <button type="button" class="banner-dot ${st.first ? 'is-active' : ''}"
                                aria-label="${st.count}번째 배너로 이동"></button>
                    </c:forEach>
                </div>
            </div>
        </div>
    </section>

    <!-- 선물 카테고리 -->
    <div id="category">
        <div class="home-container">
            <div class="section-header">
                <h2>선물 카테고리</h2>
            </div>
            <div id="category-list">
                <%-- DB 확정 카테고리(15개, reset_category_tag.sql 기준)를 그대로 뿌린다. 아이콘은
                     기존에 손으로 그려둔 15개 SVG를 실제 카테고리명에 맞춰 재배치했다(카테고리명은
                     자유 텍스트라 아이콘을 자동 매칭할 방법이 없어 이름으로 직접 분기함).
                     "기념일"은 예전 목업(리빙·키친)에 쓰던 아이콘을 재사용 - 안 쓰이게 된 아이콘을
                     돌려썼다(주제는 안 맞지만 화면 확인 전까지 임시). --%>
                <c:forEach items="${categoryList}" var="category">
                <a class="category-item" href="<c:url value='/mds/searchList'><c:param name='category' value='${category.categoryId}'/></c:url>">
                    <div class="category-icon">
                        <c:choose>
                        <c:when test="${category.categoryName == '생일'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="4" y="12" width="16" height="8" rx="1"/>
                            <path d="M4 16h16"/>
                            <line x1="12" y1="12" x2="12" y2="7"/>
                            <circle cx="12" cy="5" r="1.4"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '맛있는 선물'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="4" y="9" width="16" height="11" rx="1"/>
                            <path d="M4 13h16"/>
                            <path d="M12 9v11"/>
                            <path d="M12 9c-1.5-3-4-4-5.5-2.5S8 9 12 9z"/>
                            <path d="M12 9c1.5-3 4-4 5.5-2.5S16 9 12 9z"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '건강'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M5 19c0-8 5-14 14-14 0 9-6 14-14 14z"/>
                            <path d="M5 19c2-3 5-6 9-9"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '패션・주얼리'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 9l4-5h8l4 5-8 11z"/>
                            <path d="M4 9h16"/>
                            <path d="M9.5 4l2.5 5 2.5-5"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '가벼운 선물'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M6 8h12l1 12H5z"/>
                            <path d="M9 8V6a3 3 0 0 1 6 0v2"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '명품선물'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 18h16"/>
                            <path d="M4 18l-1-9 5 4 4-7 4 7 5-4-1 9z"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '출산・돌'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="9" y="9" width="6" height="12" rx="2"/>
                            <rect x="10" y="4" width="4" height="5" rx="1"/>
                            <path d="M9 13h6"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '결혼・집들이'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 11l8-7 8 7"/>
                            <path d="M6 10v10h12V10"/>
                            <path d="M10 20v-6h4v6"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '상품권'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="3" y="6" width="18" height="12" rx="2"/>
                            <path d="M3 10h18"/>
                            <path d="M7 14h4"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '합격・응원'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 20l1-5L16 4l4 4-11 11-5 1z"/>
                            <path d="M14 6l4 4"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '화장품'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="8" y="9" width="8" height="12" rx="2"/>
                            <rect x="10" y="5" width="4" height="4"/>
                            <path d="M9 13h6"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '주류'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M7 3h10l-1 7a4 4 0 0 1-8 0z"/>
                            <path d="M12 14v6"/>
                            <path d="M8 20h8"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '명절'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <circle cx="8" cy="19" r="1.5"/>
                            <circle cx="17" cy="19" r="1.5"/>
                            <path d="M4 8h3l3 9h7"/>
                            <path d="M7 8c3-3 8-3 10 1"/>
                            <path d="M17 9v8"/>
                        </svg>
                        </c:when>
                        <c:when test="${category.categoryName == '스포츠'}">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <circle cx="12" cy="12" r="8"/>
                            <path d="M4 12h16"/>
                            <path d="M12 4v16"/>
                            <path d="M6 6c3 3 3 9 0 12"/>
                            <path d="M18 6c-3 3-3 9 0 12"/>
                        </svg>
                        </c:when>
                        <c:otherwise>
                        <%-- 기념일: 남은 아이콘(리빙·키친 자리)을 재사용 --%>
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M5 11h14v4a5 5 0 0 1-5 5h-4a5 5 0 0 1-5-5z"/>
                            <path d="M3 11h18"/>
                            <path d="M8 11V8a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v3"/>
                        </svg>
                        </c:otherwise>
                        </c:choose>
                    </div>
                    <span class="category-name">${category.categoryName}</span>
                </a>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- 상품 -->
    <div id="product">
        <div class="home-container">
            <div class="section-header">
                <h2>인기 선물</h2>
                <a href="<c:url value='/mds/searchList'/>" class="section-more">전체 상품 보기 &gt;</a>
            </div>
            <%-- productList = HomeController가 잘라서 넘겨준 화면분(HOME_PAGE_SIZE=8 단위).
                 1페이지: 8개 / 2페이지: 16개(더보기 결과 - 1페이지분에 이어서 누적 표시) /
                 3페이지부터: 8개씩 번호 페이지네이션. 카드 마크업은 searchProduct.jsp와 동일.
                 필드 목록: productId, productTitle, wishCount, imagePath, titleImage, price,
                 categoryNames, tagData, score --%>
            <div id="product-list">
                <c:forEach items="${productList}" var="product" varStatus="i">
                <article class="product-card sp-product-card" data-product-id="${product.productId}" data-price="${product.price}" data-pop-id="${product.popId}">
                    <div class="product-img">
                        <a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>" aria-label="${product.productTitle} 상세 보기">
                            <c:if test="${not empty product.titleImage}">
                                <img src="<c:out value='${product.imagePath}'/><c:out value='${product.titleImage}'/>" alt="${product.productTitle}">
                            </c:if>
                        </a>
                        <button type="button" class="product-cart-quick" aria-label="장바구니 담기">
                            <svg class="product-cart-quick-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                                <circle cx="9" cy="21" r="1"></circle>
                                <circle cx="20" cy="21" r="1"></circle>
                                <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                            </svg>
                        </button>
                        <%-- 이미지 호버 시 뜨는 태그 팝업 (searchProduct.jsp와 동일 - .sp-tag-popup CSS 공유) --%>
                        <c:if test="${not empty product.tagData}">
                        <div class="sp-tag-popup">
                            <c:forEach items="${fn:split(product.tagData, ',')}" var="tagPair">
                                <span class="sp-product-tag">${fn:split(tagPair, '|')[0]}</span>
                            </c:forEach>
                        </div>
                        </c:if>
                    </div>
                    <div class="product-info">
                        <a class="sp-product-link" href="<c:url value='/mds/detail/${product.productId}'/>"><h3 class="product-name">${product.productTitle}</h3></a>
                        <p class="product-description">${product.categoryNames}</p>
                        <div class="product-meta">
                            <a href="<c:url value='/mds/detail/${product.productId}'/>#review" class="product-rating" aria-label="리뷰 보기">
                                <svg class="product-rating-star" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                                    <path d="M12 2l2.9 6.26 6.9.6-5.2 4.53 1.6 6.76L12 16.9l-6.2 3.25 1.6-6.76-5.2-4.53 6.9-.6L12 2z"></path>
                                </svg>
                                <span class="product-rating-score">${product.score}</span>
                            </a>
                            <%-- ✅ 조치 완료(2026-09-03): 로그인 회원이 이미 찜한 상품이면 최초 렌더링부터
                                 하트를 채워서 보여준다 - 예전엔 항상 빈 하트로 시작해서, 로그아웃 후 재로그인하면
                                 이미 찜한 상품도 다시 찜할 수 있는 것처럼 보였다(AUDIT 신규 버그). --%>
                            <button type="button" class="product-wish-toggle${product.wished ? ' is-active' : ''}" aria-label="${product.wished ? '찜 해제' : '찜하기'}">
                                <svg class="product-wish-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                                    <path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-3 4.5 4.5 0 0 1 8 3c0 6.5-8 11-8 11z"></path>
                                </svg>
                                <span class="product-wish-count-num">${product.wishCount}</span>
                            </button>
                        </div>
                    </div>
                </article>
                </c:forEach>
            </div>
            <%-- 8개 → 더보기(16개까지 누적) → 그 이후는 번호 페이지네이션.
                 위의 "전체 상품 보기"(검색 결과 페이지)와 기능이 겹치지 않도록, 여기 더보기는
                 실제로 상품을 더 보여준다(HomeController 참고). --%>
            <c:if test="${showLoadMore}">
            <div class="product-load-more-wrap">
                <a href="<c:url value='/'><c:param name='page' value='2'/></c:url>#product" id="productLoadMore" class="btn-load-more">
                    상품 더보기
                    <svg class="btn-load-more-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                        <path d="M6 9l6 6 6-6"/>
                    </svg>
                </a>
            </div>
            </c:if>
            <%-- 페이지 이동 링크는 전부 #product 앵커를 붙인다 - 안 붙이면 전체 페이지 이동이라
                 브라우저가 항상 최상단(배너)으로 스크롤을 되돌려서, 방금 보던 상품 목록 위치를
                 잃어버리는 문제가 있었다(리뷰 탭의 #review 해시와 같은 패턴, HANDOFF 참고). --%>
            <c:if test="${showPagination and totalPages > 1}">
            <nav class="sp-pagination" aria-label="페이지 탐색">
                <c:if test="${currentPage > 1}">
                    <a class="sp-btn-prev" href="<c:url value='/'><c:param name='page' value='${currentPage - 1}'/></c:url>#product">이전</a>
                </c:if>
                <ol>
                    <c:forEach begin="${pageWindowStart}" end="${pageWindowEnd}" var="p">
                        <li>
                            <a class="sp-page-btn ${p == currentPage ? 'is-current' : ''}"
                               <c:if test="${p == currentPage}">aria-current="page"</c:if>
                               href="<c:url value='/'><c:param name='page' value='${p}'/></c:url>#product">${p}</a>
                        </li>
                    </c:forEach>
                </ol>
                <c:if test="${currentPage < totalPages}">
                    <a class="sp-btn-next" href="<c:url value='/'><c:param name='page' value='${currentPage + 1}'/></c:url>#product">다음</a>
                </c:if>
            </nav>
            </c:if>
        </div>
    </div>


<script src="<c:url value='/js/common/bannerSlider.js'/>"></script>
<script src="<c:url value='/js/views/home.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
