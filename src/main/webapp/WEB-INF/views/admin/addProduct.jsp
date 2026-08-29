
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 실제 헤더(아이콘/로그인/nav)를 이미 렌더링하므로,
     이 페이지가 header.jsp로 옮겨가기 전 쓰던 구버전 커스텀 헤더 마크업은 중복이라 삭제함 --%>

<!-- ================= MAIN ================= -->

<div class="product-register" data-register-url="<c:url value='/admin/product/add'/>">

    <div class="page-title">
        <span class="eyebrow">PRODUCT MANAGEMENT</span>
        <h1>상품 등록</h1>
        <p>새로운 상품 정보를 입력해 주세요.</p>
    </div>


    <!-- ================= 기본 정보 ================= -->

    <section class="register-section">

        <div class="section-title">
            <h2>기본 정보</h2>
            <p>상품의 기본 정보를 입력해 주세요.</p>
        </div>

        <div class="info-box">

            <!-- 상품명 -->

            <div class="form-row">
                <label>
                    상품명
                    <span class="required">*</span>
                </label>

                <div class="input-area">
                    <input
                        type="text"
                        name="productName"
                        id="productNameInput"
                        placeholder="상품명을 입력해 주세요"
                    >
                </div>
            </div>


            <!-- 상품 게시글 제목 (PRODUCT.PRODUCT_TITLE - 목록/검색 카드에 노출되는 제목) -->

            <div class="form-row">
                <label>
                    상품 게시글 제목
                    <span class="required">*</span>
                </label>

                <div class="input-area">
                    <input
                        type="text"
                        name="productTitle"
                        id="productTitleInput"
                        placeholder="상품 목록/검색에 노출될 제목을 입력해 주세요"
                    >
                </div>
            </div>


            <!-- 옵션명 (PRODUCTOPTION.OPTION_NAME - 이 화면은 옵션 1개만 생성하므로 그 옵션의 이름) -->

            <div class="form-row">
                <label>
                    옵션명
                    <span class="required">*</span>
                </label>

                <div class="input-area">
                    <input
                        type="text"
                        name="optionName"
                        id="optionNameInput"
                        placeholder="예: 기본, 단품"
                    >
                </div>
            </div>


            <!-- 가격 -->

            <div class="form-row">
                <label>
                    판매가격
                    <span class="required">*</span>
                </label>

                <div class="input-area">
                    <input
                        type="number"
                        name="price"
                        id="priceInput"
                        placeholder="판매가격을 입력해 주세요"
                        min="0"
                    >
                </div>
            </div>


            <!-- 재고 (PRODUCT 테이블엔 가격/재고 컬럼이 없고 PRODUCTOPTION(옵션)에 있어서,
                 상품 등록 시 이 값으로 "기본 옵션" 1개를 자동 생성해 가격/재고를 담는다) -->
            <div class="form-row">
                <label>
                    재고
                    <span class="required">*</span>
                </label>

                <div class="input-area">
                    <input
                        type="number"
                        name="stock"
                        id="stockInput"
                        placeholder="재고 수량을 입력해 주세요"
                        min="0"
                    >
                </div>
            </div>


            <!-- 카테고리 -->

            <div class="form-row">
                <label>
                    카테고리
                    <span class="required">*</span>
                </label>

                <div class="input-area">
                    <select name="category" id="categorySelect">
                        <option value="">카테고리를 선택해 주세요</option>
                        <c:forEach items="${categoryList}" var="category">
                            <option value="${category.categoryId}">${category.categoryName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>


            <!-- ================= 상품 태그 ================= -->

            <div class="form-row">

                <label>상품 태그</label>

                <div class="tag-area">

                    <p class="tag-description">
                        상품에 해당하는 태그를 선택해 주세요.
                    </p>


                    <!-- 기존 태그 -->

                    <div class="tag-group">

                        <div class="tag-group-title">
                            <strong>기존 태그</strong>
                            <span>등록된 태그</span>
                        </div>

                        <div class="tag-list" id="existingTagList">

                            <c:forEach items="${tagList}" var="tag">
                                <div
                                    class="product-tag"
                                    data-tag-name="${tag.tagName}"
                                    data-tag-color="${tag.tagColor}"
                                    style="background-color:${tag.tagColor}"
                                >
                                    <span>${tag.tagName}</span>
                                </div>
                            </c:forEach>

                        </div>
                    </div>


                    <!-- 현재 상품 태그 -->

                    <div class="tag-group tag-group-added">

                        <div class="tag-group-title">
                            <strong>현재 상품 태그</strong>
                            <span>이번 상품에 적용할 태그</span>
                        </div>

                        <div class="tag-list" id="addedTagList">

                            <button
                                type="button"
                                class="add-tag-button"
                                id="addTagButton"
                            >
                                <span class="add-icon">＋</span>
                                태그 추가
                            </button>

                        </div>

                    </div>

                </div>
            </div>

        </div>
    </section>


    <!-- ================= 상품 이미지 ================= -->

    <section class="register-section">

        <div class="section-title">
            <h2>상품 이미지</h2>
            <p>상품에 사용할 이미지를 등록해 주세요.</p>
        </div>

        <div class="image-upload-wrap">

            <!-- 대표 이미지 -->

            <div class="main-image-upload">

                <label class="image-label" for="main-image">

                    <div class="upload-icon">＋</div>

                    <strong>대표 이미지</strong>

                    <p>
                        상품 목록에 표시되는<br>
                        대표 이미지를 등록해 주세요.
                    </p>

                    <small>
                        JPG / PNG / WEBP · 최대 10MB
                    </small>

                </label>

                <input
                    type="file"
                    id="main-image"
                    name="mainImage"
                    accept="image/*"
                    hidden
                >

            </div>


            <!-- 추가 이미지 (개수 제한 없음 - "+ 이미지 추가" 타일로 계속 첨부 가능) -->

            <div class="sub-image-area">

                <div class="sub-image-title">
                    <strong>추가 이미지</strong>
                    <span id="subImageCount">0장</span>
                </div>

                <div class="sub-image-grid" id="subImageGrid">

                    <label class="sub-image-box" id="subImageAddTile">
                        <span>＋</span>
                        <small>이미지 추가</small>
                    </label>

                </div>

                <input type="file" id="subImageInput" accept="image/*" multiple hidden>

            </div>


            <!-- 설명 이미지 업로드 영역 (원래 목업엔 없었으나 기획 확인 결과 필수 항목.
                 PRODUCTIMAGE.PRODUCT_TITLE_IMAGE가 0(대표)/1(서브)/2(설명) 세 종류를 지원한다) -->

            <div class="sub-image-area">

                <div class="sub-image-title">
                    <strong>설명 이미지 <span class="required">*</span></strong>
                    <span id="descImageCount">0장</span>
                </div>

                <div class="sub-image-grid" id="descImageGrid">

                    <label class="sub-image-box" id="descImageAddTile">
                        <span>＋</span>
                        <small>이미지 추가</small>
                    </label>

                </div>

                <input type="file" id="descImageInput" accept="image/*" multiple hidden>

            </div>

        </div>
    </section>


    <!-- ================= 상품 설명 ================= -->

    <section class="register-section">

        <div class="section-title">
            <h2>상품 설명</h2>
            <p>상품에 대한 상세한 설명을 입력해 주세요.</p>
        </div>

        <div class="description-box">

            <textarea
                id="productContent"
                name="productContent"
                maxlength="2000"
                placeholder="상품의 특징, 구성, 배송 및 보관 방법 등을 입력해 주세요."
            ></textarea>

            <div class="textarea-bottom">
                <span>상품 설명을 작성해 주세요.</span>
                <span id="counter">0 / 2000</span>
            </div>

        </div>
    </section>


    <!-- ================= BUTTON ================= -->

    <div class="register-actions">

        <button
            type="button"
            class="cancel-btn"
            id="cancelButton"
        >
            취소
        </button>

        <button
            type="button"
            class="register-btn"
            id="registerButton"
        >
            상품 등록
        </button>

    </div>

</div>

<%-- footer.jsp가 실제 푸터를 파일 맨 아래에서 렌더링하므로, 구버전 커스텀 푸터 마크업은 중복이라 삭제함 --%>

<!-- ================= TAG MODAL ================= -->

<div class="modal-overlay" id="tagModal">

    <div class="tag-modal">

        <div class="modal-header">

            <h3>태그 추가</h3>

            <button
                type="button"
                class="modal-close"
                id="modalCloseButton"
            >
                ×
            </button>

        </div>


        <!-- 태그명 -->

        <div class="modal-form-group">

            <label for="newTagName">태그명</label>

            <input
                type="text"
                id="newTagName"
                placeholder="예: 부모님 추천 선물"
                maxlength="30"
            >

        </div>


        <!-- 색상 -->

        <div class="modal-form-group">

            <label>태그 색상</label>

            <div class="color-select-area">

                <input
                    type="color"
                    id="newTagColor"
                    class="modal-color-picker"
                    value="#E8D6C5"
                >

                <div
                    class="color-preview"
                    id="colorPreview"
                >
                    선택한 색상
                </div>

            </div>

        </div>


        <div class="modal-actions">

            <button
                type="button"
                class="modal-cancel"
                id="modalCancelButton"
            >
                닫기
            </button>

            <button
                type="button"
                class="modal-add"
                id="modalAddButton"
            >
                태그 추가
            </button>

        </div>

    </div>
</div>


<script src="<c:url value='/js/admin/adminProductService.js'/>"></script>
<script src="<c:url value='/js/views/addProduct.js'/>"></script>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
