<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<section class="wishlist-container" id="wishlist-container">
	<div class="wishlist-header">
		<h1>찜</h1>
		<p>마음에 드는 상품을 모아두었어요</p>
	</div>

	<div class="wishlist-controls" id="wishlist-controls">
		<label class="checkbox-label">
			<input type="checkbox" id="wish-check-all">
			<span>전체 선택</span>
		</label>
		<button type="button" id="wish-delete-btn">선택 상품 삭제</button>
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

	<div class="wishlist-empty" id="wishlist-empty" hidden>
		<p class="wishlist-empty-title">찜한 상품이 없습니다.</p>
		<p class="wishlist-empty-desc">마음에 드는 상품을 찜해보세요.</p>
		<a class="btn-solid" href="<c:url value='/'/>">상품 보러가기</a>
	</div>
</section>

<%-- TODO(data binding): 찜 목록은 header.jsp가 관리하는 localStorage(wishItems) 임시 구현임.
	 실제로는 Wish 테이블 및 회원 세션과 연동해야 함. 정렬 중 "인기순"은 실제 인기 지표가 없어
	 현재는 담긴 순서를 그대로 사용함. 별점(rating/reviewCount) 집계 자체는 상품 상세/목록(detailPage.xml,
	 product.xml)에 이미 구현되어 있음 - 이 화면엔 아직 연동만 안 돼서 테스트용 임의값을 쓰는 중이며,
	 연동되면 실제 값으로 교체 필요. 비어있으면 예시 8개로 채워 테스트 가능하게 함. --%>
<script>
(function () {
	var DEFAULT_ITEMS = [
		{ productId: '1', name: '프리미엄 한우 선물세트', price: 129000, rating: 4.8, reviewCount: 245 },
		{ productId: '2', name: '전통 과일 선물세트', price: 59000, rating: 4.3, reviewCount: 89 },
		{ productId: '3', name: '프리미엄 견과 선물세트', price: 75000, rating: 4.6, reviewCount: 156 },
		{ productId: '4', name: '고급 한과 선물세트', price: 45000, rating: 4.1, reviewCount: 67 },
		{ productId: '5', name: '홍삼 건강 선물세트', price: 89000, rating: 4.9, reviewCount: 312 },
		{ productId: '6', name: '프리미엄 차 선물세트', price: 52000, rating: 4.4, reviewCount: 98 },
		{ productId: '7', name: '수제 디저트 선물세트', price: 39000, rating: 4.2, reviewCount: 54 },
		{ productId: '8', name: '명품 생활용품 선물세트', price: 68000, rating: 4.7, reviewCount: 203 }
	];

	var currentSort = 'popular';
	var DETAIL_BASE_URL = '<c:url value="/mds/detail"/>';
	var checkedState = {};

	function getWishItems() {
		try {
			var items = JSON.parse(localStorage.getItem('wishItems') || '[]');
			return Array.isArray(items) ? items : [];
		} catch (e) {
			return [];
		}
	}

	function saveWishItems(items) {
		localStorage.setItem('wishItems', JSON.stringify(items));
		if (typeof window.refreshCartBadge === 'function') {
			window.refreshCartBadge();
		}
	}

	var items = getWishItems();
	if (items.length === 0) {
		items = DEFAULT_ITEMS.map(function (item, idx) {
			return {
				productId: item.productId, name: item.name, price: item.price,
				rating: item.rating, reviewCount: item.reviewCount,
				addedAt: Date.now() - (DEFAULT_ITEMS.length - idx) * 1000
			};
		});
		saveWishItems(items);
	}

	var controls = document.getElementById('wishlist-controls');
	var checkAll = document.getElementById('wish-check-all');
	var filterBar = document.getElementById('wishlist-filter');
	var grid = document.getElementById('wish-product-grid');
	var emptyBlock = document.getElementById('wishlist-empty');
	var totalCount = document.getElementById('wish-total-count');
	var sortOptions = document.getElementById('wish-short-options');

	function getSortedItems() {
		var list = items.slice();
		if (currentSort === 'rating-asc') {
			list.sort(function (a, b) { return a.rating - b.rating; });
		} else if (currentSort === 'rating-desc') {
			list.sort(function (a, b) { return b.rating - a.rating; });
		} else if (currentSort === 'recent') {
			list.sort(function (a, b) { return (b.addedAt || 0) - (a.addedAt || 0); });
		}
		return list;
	}

	function captureCheckedState() {
		grid.querySelectorAll('.product-card').forEach(function (card) {
			checkedState[card.dataset.productId] = card.querySelector('.item-checkbox').checked;
		});
	}

	function syncCheckAll() {
		var boxes = grid.querySelectorAll('.item-checkbox');
		checkAll.checked = boxes.length > 0 && Array.prototype.every.call(boxes, function (b) { return b.checked; });
	}

	function render() {
		captureCheckedState();
		items = getWishItems();
		var isEmpty = items.length === 0;

		controls.hidden = isEmpty;
		filterBar.hidden = isEmpty;
		grid.hidden = isEmpty;
		emptyBlock.hidden = !isEmpty;
		if (isEmpty) return;

		totalCount.textContent = '찜한 상품 ' + items.length + '개';

		grid.innerHTML = '';
		getSortedItems().forEach(function (item) {
			var checked = checkedState[item.productId] === true;
			var card = document.createElement('article');
			card.className = 'product-card';
			card.dataset.productId = item.productId;
			card.innerHTML =
				'<input type="checkbox" class="item-checkbox"' + (checked ? ' checked' : '') + '>' +
				'<a class="product-link" href="' + DETAIL_BASE_URL + '/' + encodeURIComponent(item.productId) + '">' +
					'<div class="product-thumbnail"></div>' +
					'<div class="product-info">' +
						'<h2 class="product-name"></h2>' +
						'<p class="product-rating"></p>' +
					'</div>' +
				'</a>' +
				'<button type="button" class="btn-wish-toggle is-active" aria-label="찜 해제">' +
					'<svg class="wish-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
						'<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>' +
					'</svg>' +
				'</button>' +
				'<div class="product-actions">' +
					'<button type="button" class="btn-cart">장바구니 담기</button>' +
				'</div>';

			card.querySelector('.product-name').textContent = item.name;
			card.querySelector('.product-rating').innerHTML =
				'★ ' + item.rating.toFixed(1) + ' <span class="rating-count">(' + item.reviewCount + ')</span>';

			grid.appendChild(card);
		});

		syncCheckAll();
	}

	grid.addEventListener('click', function (e) {
		var card = e.target.closest('.product-card');
		if (!card) return;
		var productId = card.dataset.productId;
		var item = items.filter(function (i) { return i.productId === productId; })[0];
		if (!item) return;

		if (e.target.closest('.btn-wish-toggle')) {
			card.classList.add('is-removing');
			window.setTimeout(function () {
				items = items.filter(function (i) { return i.productId !== productId; });
				saveWishItems(items);
				render();
			}, 300);
		}

		if (e.target.classList.contains('btn-cart')) {
			if (typeof window.addToCart === 'function') {
				window.addToCart({ productId: item.productId, name: item.name, price: item.price, qty: 1 });
			}
		}
	});

	grid.addEventListener('change', function (e) {
		if (e.target.classList.contains('item-checkbox')) {
			syncCheckAll();
		}
	});

	checkAll.addEventListener('change', function () {
		grid.querySelectorAll('.item-checkbox').forEach(function (b) { b.checked = checkAll.checked; });
	});

	document.getElementById('wish-delete-btn').addEventListener('click', function () {
		var keepIds = [];
		grid.querySelectorAll('.product-card').forEach(function (card) {
			if (!card.querySelector('.item-checkbox').checked) keepIds.push(card.dataset.productId);
		});
		items = items.filter(function (i) { return keepIds.indexOf(i.productId) !== -1; });
		saveWishItems(items);
		render();
	});

	sortOptions.addEventListener('click', function (e) {
		var option = e.target.closest('li[data-sort]');
		if (!option) return;
		currentSort = option.dataset.sort;
		sortOptions.querySelectorAll('li').forEach(function (li) { li.classList.remove('is-active'); });
		option.classList.add('is-active');
		render();
	});

	render();
})();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
