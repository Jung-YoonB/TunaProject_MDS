<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <!-- 제목 -->
        <div id="title">쿠폰 신규 등록</div>

        <!-- 쿠폰명 -->
        <div class="form-group">
            <label>쿠폰명</label>
            <input
                type="text"
                class="form-input"
                id="couponNameInput"
                name="couponName"
                placeholder="쿠폰명을 입력하세요">
        </div>

        <!-- 할인율 -->
        <div class="form-group">
            <label>할인율</label>
            <input
                type="number"
                class="form-input"
                id="discountPercentInput"
                name="discountPercent"
                min="1"
                max="100"
                placeholder="할인율을 입력하세요 (예: 10)">
        </div>

        <!-- 쿠폰 설명 -->
        <div class="form-group">
            <label>쿠폰설명</label>
            <textarea
                class="form-textarea"
                id="couponTextInput"
                name="couponText"
                placeholder="쿠폰설명을 입력하세요"></textarea>
        </div>

        <!-- 발급일 / 종료일 -->
        <div class="date-group">

            <div class="date-box">
                <label>발급일</label>
                <input
                    type="date"
                    class="date-input"
                    id="startDate"
                    name="startDate">
            </div>

            <div class="date-box">
                <label>종료일</label>
                <input
                    type="date"
                    class="date-input"
                    id="endDate"
                    name="endDate">
            </div>

        </div>

        <!-- 쿠폰 발급 -->
        <button type="button" class="register-button" id="registerCouponButton">
            쿠폰 발급
        </button>

    </main>


    <script>
        // 오늘 날짜
        const today = new Date().toISOString().split("T")[0];

        const startDate = document.getElementById("startDate");
        const endDate = document.getElementById("endDate");

        // 발급일은 오늘 이전 선택 불가
        startDate.min = today;

        // 발급일을 선택하면 종료일은 발급일 이전 선택 불가
        startDate.addEventListener("change", function () {
            endDate.min = this.value;
        });

        // 쿠폰 발급
        document.getElementById("registerCouponButton").addEventListener("click", function () {

            const couponName = document.getElementById("couponNameInput").value.trim();
            const discountPercent = document.getElementById("discountPercentInput").value;
            const couponText = document.getElementById("couponTextInput").value.trim();
            const endDateValue = endDate.value;

            if (!couponName) {
                alert("쿠폰명을 입력해 주세요.");
                return;
            }
            if (!discountPercent) {
                alert("할인율을 입력해 주세요.");
                return;
            }
            if (!endDateValue) {
                alert("종료일을 선택해 주세요.");
                return;
            }

            const params = new URLSearchParams();
            params.append("couponName", couponName);
            params.append("discountPercent", discountPercent);
            params.append("couponText", couponText);
            if (startDate.value) {
                params.append("startDate", startDate.value);
            }
            params.append("endDate", endDateValue);

            const button = this;
            button.disabled = true;

            fetch("<c:url value='/admin/coupon/add'/>", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            })
                .then(function (response) { return response.json(); })
                .then(function (result) {
                    alert(result.message || (result.success ? "쿠폰이 등록되었습니다." : "쿠폰 등록에 실패했습니다."));
                    if (result.success) {
                        location.href = "<c:url value='/admin/coupon'/>";
                    }
                })
                .catch(function () {
                    alert("쿠폰 등록 중 오류가 발생했습니다.");
                })
                .finally(function () {
                    button.disabled = false;
                });
        });
    </script>
	<jsp:include page="/WEB-INF/views/common/footer.jsp"/>