<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="my-reviews-page">
<div class="page-content">

    <h1 class="page-title" id="pageTitle">내가 쓴 리뷰</h1>

    <c:if test="${not empty success}">
    <div class="flash-message flash-success">${success}</div>
    </c:if>
    <c:if test="${not empty error}">
    <div class="flash-message flash-error">${error}</div>
    </c:if>

    <section class="review-list" aria-label="내가 쓴 리뷰 목록" ${empty myReviews ? 'hidden' : ''}>
        <c:forEach items="${myReviews}" var="review">
            <article class="review-card">
                <div class="review-card-top">
                    <div class="review-thumb">
                        <c:choose>
                            <c:when test="${not empty review.productImageSaveName}">
                                <img src="<c:out value='${review.productImagePath}'/><c:out value='${review.productImageSaveName}'/>"
                                     alt="<c:out value='${review.productName}'/>">
                            </c:when>
                            <c:otherwise>
                                <span class="no-image-text">상품 이미지가<br>없습니다</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="review-card-info">
                        <p class="review-product-name"><c:out value="${review.productName}"/></p>
                        <p class="review-option-name"><c:out value="${review.optionName}"/> · ${review.qty}개</p>
                        <div class="review-stars" aria-hidden="true">
                            <c:forEach begin="1" end="5" var="i">
                                <span class="star ${i <= review.score ? 'is-filled' : ''}">&#9733;</span>
                            </c:forEach>
                        </div>
                    </div>
                    <span class="review-date">${review.writeDate}</span>
                </div>

                <p class="review-text"><c:out value="${review.reviewText}"/></p>

                <c:if test="${not empty review.reviewImages}">
                <div class="review-images">
                    <c:forEach items="${review.reviewImages}" var="img">
                        <img class="review-image" src="<c:out value='${img.reviewImagePath}'/><c:out value='${img.reviewImage}'/>" alt="리뷰 사진">
                    </c:forEach>
                </div>
                </c:if>

                <div class="review-card-actions">
                    <form method="post" action="<c:url value='/review/delete/${review.reviewId}'/>"
                          onsubmit="return confirm('이 리뷰를 삭제하시겠습니까? 삭제하면 되돌릴 수 없습니다.');">
                        <button type="submit" class="btn-delete-review">삭제</button>
                    </form>
                </div>
            </article>
        </c:forEach>
    </section>

    <p class="review-empty" ${empty myReviews ? '' : 'hidden'}>아직 작성한 리뷰가 없습니다.</p>

    <c:if test="${totalPages > 1}">
    <nav class="pagination" aria-label="페이지 이동">
        <c:if test="${currentPage > 1}">
        <a class="page-link page-prev" href="<c:url value='/review/myReviews'><c:param name='page' value='${currentPage - 1}'/></c:url>#pageTitle">이전</a>
        </c:if>
        <c:forEach begin="${pageWindowStart}" end="${pageWindowEnd}" var="p">
        <a class="page-link ${p == currentPage ? 'is-active' : ''}" href="<c:url value='/review/myReviews'><c:param name='page' value='${p}'/></c:url>#pageTitle">${p}</a>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
        <a class="page-link page-next" href="<c:url value='/review/myReviews'><c:param name='page' value='${currentPage + 1}'/></c:url>#pageTitle">다음</a>
        </c:if>
    </nav>
    </c:if>

    <div class="review-back">
        <a class="btn-back-mypage" href="<c:url value='/member/myPage'/>">마이페이지로 돌아가기</a>
    </div>

</div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
