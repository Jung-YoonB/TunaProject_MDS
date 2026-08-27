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
                placeholder="쿠폰명을 입력하세요">
        </div>

        <!-- 할인율 -->
        <div class="form-group">
            <label>할인율</label>
            <input
                type="text"
                class="form-input"
                placeholder="할인율을 입력하세요">
        </div>

        <!-- 쿠폰 설명 -->
        <div class="form-group">
            <label>쿠폰설명</label>
            <textarea
                class="form-textarea"
                placeholder="쿠폰설명을 입력하세요"></textarea>
        </div>

        <!-- 발급일 / 종료일 -->
        <div class="date-group">

            <div class="date-box">
                <label>발급일</label>
                <input
                    type="date"
                    class="date-input"
                    id="startDate">
            </div>

            <div class="date-box">
                <label>종료일</label>
                <input
                    type="date"
                    class="date-input"
                    id="endDate">
            </div>

        </div>

        <!-- 쿠폰 발급 -->
        <button type="button" class="register-button">
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
    </script>
	<jsp:include page="/WEB-INF/views/common/footer.jsp"/>