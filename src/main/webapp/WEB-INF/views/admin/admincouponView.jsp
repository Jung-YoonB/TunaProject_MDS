<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 모든 CSS를 전역으로 로드하므로, 이 페이지의 배경/폭 스타일이 다른 페이지의
     공용 <body>/<main>에 새지 않도록 이 wrapper 안에서만 적용되게 스코프한다 --%>
<div class="admin-coupon-view-page">
<div class="admin-coupon-view-page-card">

<div id="title">
            쿠폰관리
        </div>


        <!-- 쿠폰 등록 -->

        <div id="CouponRegister">

            <button
                type="button"
                class="register-button"
                id="goRegisterButton">

                <span class="register-icon">＋</span>
                쿠폰 등록

            </button>

        </div>


        <!-- 쿠폰 검색 -->

        <div id="SearchCoupons">

            <input
                type="text"
                id="coupon-search"
                placeholder="쿠폰 이름을 검색해주세요">

            <button
                type="button"
                id="search-button">

                검색

            </button>

        </div>


        <!-- 등록된 쿠폰 -->

        <div id="CouponList">


            <!-- 제목 -->

            <div class="coupon-list-header">

                <h2>
                    등록된 쿠폰
                    <span class="coupon-count" id="couponCount">(0)</span>
                </h2>

            </div>


            <!-- 전체 선택 / 삭제 -->

            <div class="list-control">


                <div class="select-menu">

                    <button type="button" id="selectAllButton">
                        전체선택
                    </button>

                    <button type="button" id="deselectAllButton">
                        전체선택취소
                    </button>

                </div>


                <button
                    type="button"
                    class="delete-button"
                    id="deleteSelectedButton">

                    <span class="delete-icon">🗑</span>
                    선택 삭제

                </button>

            </div>


            <div id="couponCardList"></div>


        </div>

</div>
</div>

<script>
(function () {

    var couponCardList = document.getElementById("couponCardList");
    var couponCount = document.getElementById("couponCount");
    var searchInput = document.getElementById("coupon-search");

    var allCoupons = [];

    function formatDeadline(deadline) {
        if (!deadline) return "";
        return "사용기한 : " + deadline.replace(/-/g, ".");
    }

    function formatPercent(couponValue) {
        return Math.round(couponValue * 100) + "%";
    }

    function buildCard(coupon) {
        var card = document.createElement("div");
        card.className = "coupon-card" + (coupon.hasHistory ? " has-history" : "");
        card.dataset.couponId = coupon.couponId;

        card.innerHTML =
            '<input type="checkbox" class="coupon-check" name="coupon" value="' + coupon.couponId + '">' +
            '<div class="coupon-info">' +
                '<div class="coupon-name-row">' +
                    '<span class="coupon-name"></span>' +
                    (coupon.hasHistory ? '<span class="history-badge" title="발급 이력이 있어 삭제할 수 없습니다">발급 이력 있음</span>' : '') +
                '</div>' +
                '<div class="coupon-description"></div>' +
                '<div class="coupon-deadline"></div>' +
            '</div>' +
            '<div class="coupon-discount"></div>' +
            '<button type="button" class="edit-button" title="쿠폰 수정">✎</button>';

        card.querySelector(".coupon-name").textContent = coupon.couponName;
        card.querySelector(".coupon-description").textContent = coupon.couponText || "";
        card.querySelector(".coupon-deadline").textContent = formatDeadline(coupon.deadline);
        card.querySelector(".coupon-discount").textContent = formatPercent(coupon.couponValue);

        return card;
    }

    function render(list) {
        couponCardList.innerHTML = "";
        couponCount.textContent = "(" + list.length + ")";

        if (list.length === 0) {
            var empty = document.createElement("p");
            empty.className = "coupon-empty";
            empty.textContent = "등록된 쿠폰이 없습니다.";
            couponCardList.appendChild(empty);
            return;
        }

        list.forEach(function (coupon) {
            couponCardList.appendChild(buildCard(coupon));
        });
    }

    function applySearch() {
        var keyword = searchInput.value.trim().toLowerCase();
        if (!keyword) {
            render(allCoupons);
            return;
        }
        var filtered = allCoupons.filter(function (coupon) {
            return coupon.couponName.toLowerCase().indexOf(keyword) !== -1;
        });
        render(filtered);
    }

    function loadCoupons() {
        fetch("<c:url value='/admin/coupon/list'/>")
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    alert(result.message || "쿠폰 목록을 불러오지 못했습니다.");
                    return;
                }
                allCoupons = result.data || [];
                applySearch();
            })
            .catch(function () {
                alert("쿠폰 목록을 불러오는 중 오류가 발생했습니다.");
            });
    }

    document.getElementById("goRegisterButton").addEventListener("click", function () {
        location.href = "<c:url value='/admin/coupon/add'/>";
    });

    document.getElementById("search-button").addEventListener("click", applySearch);
    searchInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter") applySearch();
    });

    document.getElementById("selectAllButton").addEventListener("click", function () {
        couponCardList.querySelectorAll(".coupon-check").forEach(function (cb) { cb.checked = true; });
    });

    document.getElementById("deselectAllButton").addEventListener("click", function () {
        couponCardList.querySelectorAll(".coupon-check").forEach(function (cb) { cb.checked = false; });
    });

    // 수정(✎) 버튼: 등록/삭제만 이번 범위라 별도 수정 화면은 아직 없음
    couponCardList.addEventListener("click", function (e) {
        if (e.target.classList.contains("edit-button")) {
            alert("쿠폰 수정 기능은 아직 지원하지 않습니다.");
        }
    });

    document.getElementById("deleteSelectedButton").addEventListener("click", function () {
        var checked = couponCardList.querySelectorAll(".coupon-check:checked");
        if (checked.length === 0) {
            alert("삭제할 쿠폰을 선택해 주세요.");
            return;
        }

        if (!confirm(checked.length + "개의 쿠폰을 삭제하시겠습니까?")) {
            return;
        }

        var couponIds = Array.prototype.map.call(checked, function (cb) {
            return Number(cb.value);
        });

        fetch("<c:url value='/admin/coupon/delete'/>", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ couponIds: couponIds })
        })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                alert(result.message || (result.success ? "삭제되었습니다." : "삭제에 실패했습니다."));
                loadCoupons();
            })
            .catch(function () {
                alert("쿠폰 삭제 중 오류가 발생했습니다.");
            });
    });

    loadCoupons();
})();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
