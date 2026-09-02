<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- data-payment-url: views/cart.js가 "주문하기"에서 이동할 곳. JS를 외부 파일로 분리하면서
	 <c:url>을 스크립트 안에 쓸 수 없게 되어 data 속성으로 넘긴다. --%>
		<div class="cart-container"
		     id="cart-container"
		     data-payment-url="<c:url value='/order/payment'/>"
		     data-image-path="<c:url value='/uploads/product/'/>">
	<h2 class="page-title">장바구니</h2>

	<div class="cart-controls" id="cart-controls">
		<label class="checkbox-label">
			<input type="checkbox" id="check-all">
			<span>전체 선택</span>
		</label>
		<button type="button" id="delete-btn">선택상품 삭제</button>
	</div>

	<section class="cart-itemlist" id="cart-itemlist" aria-label="장바구니 상품 목록"></section>

	<section class="cart-summary-box" id="cart-summary-box">
		<h4>결제 예상 금액</h4>
		<div class="summary-detail">
			<div class="summary-row">
				<span>상품 금액</span>
				<span id="total-price">0원</span>
			</div>
			<div class="summary-row">
				<span>배송비</span>
				<span id="delivery-fee">0원</span>
			</div>
		</div>
		<div class="summary-total">
			<span>총 결제금액</span>
			<strong id="summary-final">0원</strong>
		</div>
	</section>

	<p class="cart-warning" id="cart-warning" hidden>상품을 하나 이상 선택해 주세요.</p>

	<div class="cart-action" id="cart-action">
		<a class="btn-outline" href="<c:url value='/'/>">계속 쇼핑하기</a>
		<%-- views/cart.js가 선택한 cartId들을 담아 POST /order/payment 로 보낸다 --%>
		<button type="button" class="btn-solid" id="btn-checkout">주문하기</button>
	</div>

	<div class="cart-empty" id="cart-empty" hidden>
		<p class="cart-empty-title">장바구니에 담긴 상품이 없습니다.</p>
		<p class="cart-empty-desc">마음에 드는 상품을 담아보세요.</p>
		<a class="btn-solid" href="<c:url value='/'/>">상품 보러가기</a>
	</div>
</div>

<%-- TODO(data binding): 장바구니는 localStorage(cartItems) 임시 구현임. 실제로는 Cart 테이블
	 (pop_id 기준 OptionDetail 참조) 및 회원 세션과 연동해야 함. 상세 내용과 연동 지점은
	 js/product/cartService.js 상단 주석 참고.
	 (localStorage 접근 자체는 js/common/cartWishService.js가 공용으로 담당) --%>

	 <script>
	     window.serverCartItems = [
	         <c:forEach items="${cartList.cartList}" var="item" varStatus="status">
	         {
	             cartId: ${item.cartId},
	             memberId: ${item.memberId},
	             productTitle: "<c:out value='${item.productTitle}'/>",
	             optionName: "<c:out value='${item.optionName}'/>",
	             optionPrice: ${item.optionPrice},
	             qty: ${item.qty},
	             titleImage: "<c:out value='${item.titleImage}'/>"
	         }<c:if test="${!status.last}">,</c:if>
	         </c:forEach>
	     ];
	 </script>
	 
<script src="<c:url value='/js/product/cartService.js'/>"></script>
<script src="<c:url value='/js/views/cart.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>