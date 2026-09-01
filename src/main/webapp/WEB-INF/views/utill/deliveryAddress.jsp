<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="delivery-page">
<div class="delivery-card">
        <!-- 제목 -->
        <div id="title">
            배송지 추가
        </div>


        <!-- 배송지 입력 -->
        <form id="deliveryForm"
              action="${pageContext.request.contextPath}/member/addAddress"
              method="post">

            <!-- 배송지 이름 -->
            <div class="form-item">

                <label for="address-name">
                    배송지 이름
                </label>

                <input
                    type="text"
                    id="address-name"
                    name="addressName"
                    placeholder="예) 집, 회사"
                    required>

            </div>


            <!-- 받는 사람 -->
            <div class="form-item">

                <label for="recipient">
                    받는 사람
                </label>

                <input
                    type="text"
                    id="recipient"
                    name="recipient"
                    placeholder="받는 분의 이름을 입력해주세요"
                    required>

            </div>


            <!-- 휴대폰 번호 -->
            <div class="form-item">

                <label for="phone">
                    휴대폰 번호
                </label>

                <input
                    type="tel"
                    id="phone"
                    name="phone"
                    placeholder="010-0000-0000"
                    required>

            </div>


            <!-- 배송지 주소 -->
            <div class="form-item">

                <label>
                    배송지 주소
                </label>

                <!-- 우편번호 + 주소 검색 -->
                <div class="address-search">

                    <input
                        type="text"
                        id="zipcode"
                        name="zipcode"
                        placeholder="우편번호"
                        readonly>

                    <button
                        type="button"
                        id="address-search-button">

                        주소 검색

                    </button>

                </div>

                <!-- 기본 주소 -->
                <input
                    type="text"
                    id="address"
                    name="address"
                    placeholder="기본 주소"
                    readonly>

                <!-- 상세 주소 -->
                <input
                    type="text"
                    id="detail-address"
                    name="detailAddress"
                    placeholder="상세 주소를 입력해주세요">

            </div>


            <!-- 기본 배송지 설정 -->
            <div id="default-address">

                <input
                    type="checkbox"
                    id="is-default"
                    name="isDefault"
                    value="Y">

                <label for="is-default">
                    기본 배송지로 설정
                </label>

            </div>


            <!-- 버튼 -->
            <div id="buttonArea">

                <button
                    type="button"
                    id="cancel-button"
                    onclick="history.back()">

                    취소

                </button>

                <button
                    type="submit"
                    id="add-button">

                    배송지 추가

                </button>

            </div>

        </form>
</div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>