<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

	<form id="review-form" action="${pageContext.request.contextPath}/review/write" method="post" enctype="multipart/form-data">
		<input type="hidden" name="odId" value="${writeInfo.odId}">
		<c:if test="${not empty returnUrl}">
		<input type="hidden" name="returnUrl" value="<c:out value='${returnUrl}'/>">
		</c:if>

		<!-- 1. 상단 히어로 영역: 소개글 + 상품 카드가 나란히 배치 -->
		<div class="review-hero">
			<div class="intro">
				<h2>리뷰 작성</h2>
				<p class="subtitle">
					선물은 만족스러우셨나요?
					<br>
					선물 후기를 남겨주세요.
				</p>
			</div>

			<div class="gift-summary">
				<h3>구매하신 선물 내역</h3>
				<section class="review-product-card" aria-label="리뷰 작성 상품 정보">
					<div class="product-thumbnail">
						<c:if test="${not empty writeInfo.productImageSaveName}">
							<img src="${writeInfo.productImagePath}${writeInfo.productImageSaveName}" alt="${writeInfo.productName}">
						</c:if>
					</div>
					<div class="product-info">
						<strong class="product-name">${writeInfo.productName}</strong>
						<strong class="product-option-name">${writeInfo.optionName}</strong>
						<p class="product-price"><c:out value="${writeInfo.priceFix}"/>원</p>
					</div>
				</section>
			</div>
		</div>

		<!-- 2. 별점 입력 영역 (기본: 전부 빈 별 / 호버·클릭 시 JS로 채움) -->
		<section class="star-rating-section" aria-label="별점 입력">
			<h3>만족도 별점을 남겨주세요</h3>
			<div class="star-container" id="star-rating">
				<button type="button" class="star-btn" data-value="1" aria-label="1점">★</button>
				<button type="button" class="star-btn" data-value="2" aria-label="2점">★</button>
				<button type="button" class="star-btn" data-value="3" aria-label="3점">★</button>
				<button type="button" class="star-btn" data-value="4" aria-label="4점">★</button>
				<button type="button" class="star-btn" data-value="5" aria-label="5점">★</button>
			</div>
			<input type="hidden" name="score" id="review-score" value="">
		</section>

		<!-- 3. 텍스트 후기 입력 영역 -->
		<section class="review-text-section" aria-label="후기 텍스트 입력">
			<h3>소중한 후기를 남겨주세요</h3>
			<div class="textarea-wrapper">
				<textarea name="reviewText" id="review_text" placeholder="상품에 대한 솔직한 후기를 남겨주세요" maxlength="500" required></textarea>
				<div class="char-count" id="char-count-wrapper">
					<span id="current-char-count">0</span> / 500
				</div>
			</div>
		</section>

		<!-- 4. 사진 첨부 영역 (REVIEWIMAGE 테이블에 저장될 파일들) -->
		<section class="photo-upload-section" aria-label="사진 첨부">
			<h3>사진 추가<span class="text-muted">(선택, 최대 5장)</span></h3>
			<div class="upload-container">
				<label class="upload-box-btn" id="upload-box-btn" for="review_image_id">
					<span class="plus-icon">+</span>
				</label>
				<input type="file" id="review_image_id" name="reviewImages" accept="image/*" multiple hidden>
				<ul class="photo-preview-list" id="photo-preview-list"></ul>
			</div>
		</section>

		<!-- 5. 제출 버튼 -->
		<div class="form-actions-bottom">
			<button type="submit" class="solid-large-btn" id="review-submit-btn">리뷰 등록</button>
		</div>
	</form>

<script src="<c:url value='/js/views/addreview.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>