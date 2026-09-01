<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <!-- 배너 (상품 광고 자동 슬라이드) -->
    <section id="banner">
        <div class="home-container">
            <div class="banner-slider" id="bannerSlider">
                <div class="banner-slide is-active">
                    <div class="banner-content">
                        <p class="banner-subtitle">Maison de sajo</p>
                        <h1>마음을 고르는<br>가장 다정한 방법</h1>
                        <p class="banner-description">
                            소중한 사람에게<br>
                            취향을 담은 선물을 전해보세요.
                        </p>
                    </div>
                    <!-- TODO(assets): 실제 배너 이미지 확보되면 이 영역에 <img> 추가 -->
                    <div class="banner-image"></div>
                </div>
                <div class="banner-slide">
                    <div class="banner-content">
                        <p class="banner-subtitle">Best Seller</p>
                        <h1>지금 가장 사랑받는<br>선물 이야기</h1>
                        <p class="banner-description">
                            많은 분들이 선택한<br>
                            믿을 수 있는 베스트 상품을 만나보세요.
                        </p>
                    </div>
                    <div class="banner-image banner-image-alt"></div>
                </div>
                <div class="banner-slide">
                    <div class="banner-content">
                        <p class="banner-subtitle">Special Offer</p>
                        <h1>명절 맞이<br>특별한 할인 혜택</h1>
                        <p class="banner-description">
                            이 시즌에만 만나볼 수 있는<br>
                            특별한 가격의 선물세트.
                        </p>
                    </div>
                    <div class="banner-image banner-image-warm"></div>
                </div>

                <div class="banner-dots">
                    <button type="button" class="banner-dot is-active" aria-label="1번째 배너로 이동"></button>
                    <button type="button" class="banner-dot" aria-label="2번째 배너로 이동"></button>
                    <button type="button" class="banner-dot" aria-label="3번째 배너로 이동"></button>
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
                <!-- 1 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="4" y="12" width="16" height="8" rx="1"/>
                            <path d="M4 16h16"/>
                            <line x1="12" y1="12" x2="12" y2="7"/>
                            <circle cx="12" cy="5" r="1.4"/>
                        </svg>
                    </div>
                    <span class="category-name">생일</span>
                </div>
                <!-- 2 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="4" y="9" width="16" height="11" rx="1"/>
                            <path d="M4 13h16"/>
                            <path d="M12 9v11"/>
                            <path d="M12 9c-1.5-3-4-4-5.5-2.5S8 9 12 9z"/>
                            <path d="M12 9c1.5-3 4-4 5.5-2.5S16 9 12 9z"/>
                        </svg>
                    </div>
                    <span class="category-name">맛있는 선물</span>
                </div>
                <!-- 3 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M5 19c0-8 5-14 14-14 0 9-6 14-14 14z"/>
                            <path d="M5 19c2-3 5-6 9-9"/>
                        </svg>
                    </div>
                    <span class="category-name">건강</span>
                </div>
                <!-- 4 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 9l4-5h8l4 5-8 11z"/>
                            <path d="M4 9h16"/>
                            <path d="M9.5 4l2.5 5 2.5-5"/>
                        </svg>
                    </div>
                    <span class="category-name">패션·쥬얼리</span>
                </div>
                <!-- 5 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M6 8h12l1 12H5z"/>
                            <path d="M9 8V6a3 3 0 0 1 6 0v2"/>
                        </svg>
                    </div>
                    <span class="category-name">가벼운 선물</span>
                </div>
                <!-- 6 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 18h16"/>
                            <path d="M4 18l-1-9 5 4 4-7 4 7 5-4-1 9z"/>
                        </svg>
                    </div>
                    <span class="category-name">명품 선물</span>
                </div>
                <!-- 7 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="9" y="9" width="6" height="12" rx="2"/>
                            <rect x="10" y="4" width="4" height="5" rx="1"/>
                            <path d="M9 13h6"/>
                        </svg>
                    </div>
                    <span class="category-name">출산·돌</span>
                </div>
                <!-- 8 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 11l8-7 8 7"/>
                            <path d="M6 10v10h12V10"/>
                            <path d="M10 20v-6h4v6"/>
                        </svg>
                    </div>
                    <span class="category-name">결혼·집들이</span>
                </div>
                <!-- 9 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="3" y="6" width="18" height="12" rx="2"/>
                            <path d="M3 10h18"/>
                            <path d="M7 14h4"/>
                        </svg>
                    </div>
                    <span class="category-name">상품권</span>
                </div>
                <!-- 10 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M4 20l1-5L16 4l4 4-11 11-5 1z"/>
                            <path d="M14 6l4 4"/>
                        </svg>
                    </div>
                    <span class="category-name">합격·응원</span>
                </div>
                <!-- 11 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <rect x="8" y="9" width="8" height="12" rx="2"/>
                            <rect x="10" y="5" width="4" height="4"/>
                            <path d="M9 13h6"/>
                        </svg>
                    </div>
                    <span class="category-name">화장품</span>
                </div>
                <!-- 12 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M7 3h10l-1 7a4 4 0 0 1-8 0z"/>
                            <path d="M12 14v6"/>
                            <path d="M8 20h8"/>
                        </svg>
                    </div>
                    <span class="category-name">주류</span>
                </div>
                <!-- 13 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <circle cx="8" cy="19" r="1.5"/>
                            <circle cx="17" cy="19" r="1.5"/>
                            <path d="M4 8h3l3 9h7"/>
                            <path d="M7 8c3-3 8-3 10 1"/>
                            <path d="M17 9v8"/>
                        </svg>
                    </div>
                    <span class="category-name">육아용품</span>
                </div>
                <!-- 14 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <circle cx="12" cy="12" r="8"/>
                            <path d="M4 12h16"/>
                            <path d="M12 4v16"/>
                            <path d="M6 6c3 3 3 9 0 12"/>
                            <path d="M18 6c-3 3-3 9 0 12"/>
                        </svg>
                    </div>
                    <span class="category-name">스포츠</span>
                </div>
                <!-- 15 -->
                <div class="category-item">
                    <div class="category-icon">
                        <svg class="category-icon-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                            <path d="M5 11h14v4a5 5 0 0 1-5 5h-4a5 5 0 0 1-5-5z"/>
                            <path d="M3 11h18"/>
                            <path d="M8 11V8a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v3"/>
                        </svg>
                    </div>
                    <span class="category-name">리빙·키친</span>
                </div>
            </div>
        </div>
    </div>

    <!-- 상품 -->
    <div id="product">
        <div class="home-container">
            <div class="section-header">
                <h2>인기 선물</h2>
                <a href="#" class="section-more">전체 상품 보기 &gt;</a>
            </div>
            <!-- TODO(assets): 실제 상품 API 연동 전까지 static/js/product/homeProductService.js의
                 목업 데이터로 채워짐(views/home.js가 렌더링) - 서버 연동 시 그 파일의
                 fetchProducts() 내부만 실제 API 호출로 교체하면 됨. -->
            <div id="product-list"></div>
            <div class="product-load-more-wrap">
                <button type="button" id="productLoadMore" class="btn-load-more">
                    상품 더보기
                    <svg class="btn-load-more-svg" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                        <path d="M6 9l6 6 6-6"/>
                    </svg>
                </button>
            </div>
        </div>
    </div>


<script src="<c:url value='/js/common/bannerSlider.js'/>"></script>
<script src="<c:url value='/js/product/homeProductService.js'/>"></script>
<script src="<c:url value='/js/views/home.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
