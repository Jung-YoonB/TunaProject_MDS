<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- data-payment-url: views/cart.js가 "주문하기"에서 이동할 곳.
	 data-remove-url/data-update-qty-url: 삭제/수량변경을 서버(CartController)에 반영할 때 쓴다
	 (wish.jsp의 data-remove-url과 동일한 방식). JS를 외부 파일로 분리하면서 <c:url>을 스크립트
	 안에 쓸 수 없게 되어 data 속성으로 넘긴다. --%>
		<div class="cart-container"
		     id="cart-container"
		     data-payment-url="<c:url value='/order/payment'/>"
		     data-image-path="<c:url value='/uploads/product/'/>"
		     data-remove-url="<c:url value='/cart/remove-cart'/>"
		     data-update-qty-url="<c:url value='/cart/update-qty'/>">
	<h2 class="page-title">장바구니</h2>

	<%-- 체크박스는 평소엔 숨겨두고 "상품 선택"을 눌렀을 때만 보인다(admin/admincouponView.jsp의
	     선택 모드와 동일한 로직) - 예전엔 항상 노출돼 있었다. --%>
	<div class="cart-controls" id="cart-controls">
		<div class="select-menu" id="cartSelectionControls" hidden>
			<label class="checkbox-label">
				<input type="checkbox" id="check-all">
				<span>전체 선택</span>
			</label>
		</div>
		<div class="list-control-actions">
			<button type="button" id="delete-btn" hidden>선택상품 삭제</button>
			<button type="button" id="toggleCartSelectButton">상품 선택</button>
		</div>
	</div>

	<section class="cart-itemlist" id="cart-itemlist" aria-label="장바구니 상품 목록"></section>

	<%-- 이미 서버에서 다 받아온 목록을 화면에서만 자르는 클라이언트 페이징(cart.js) - 검색 결과
	     화면과 같은 .sp-pagination 스타일을 재사용한다. --%>
	<nav class="sp-pagination" id="cart-pagination" aria-label="페이지 탐색" hidden></nav>

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

<%-- 서버(CartController.getCartList)가 넘겨준 실제 장바구니 목록. wish.jsp의 serverWishItems와
	 같은 방식으로 넘기고, 화면 렌더링은 cart.js가 이걸 읽어서 처리한다. --%>
	 <script>
	     window.serverCartItems = [
	         <c:forEach items="${cartList.cartList}" var="item" varStatus="status">
	         {
	             cartId: ${item.cartId},
	             memberId: ${item.memberId},
	             popId: ${item.popId},
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