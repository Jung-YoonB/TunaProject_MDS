
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
                <%-- 글자 수 표시는 라벨 아래에 둔다. 입력칸이 있는 .input-area 안에 두면
                     그만큼 세로로 공간을 차지해서 입력칸이 위로 밀려 보인다.
                     aria-hidden: 라벨 안에 있으므로 그냥 두면 한 글자 칠 때마다 필드 이름이
                     다시 읽힌다. 시각 표시 용도라 보조기기에서는 감춘다. --%>
                <label>
                    상품명
                    <span class="required">*</span>
                    <span class="char-counter" data-for="productNameInput" aria-hidden="true"></span>
                </label>

                <%-- data-maxchars: 입력 가능한 글자 수. views/addProduct.js 가 남은 수를 표시하고
                     초과 입력을 잘라내며, AdminProductServiceImpl 이 서버에서도 같은 값으로 검증한다.
                     제한 값은 DB 컬럼이 BYTE 단위인 걸 감안해 잡았다 - 전부 한글이어도(1자=3byte)
                     컬럼 안에 들어간다. (PRODUCT_NAME VARCHAR2(150) ← 50자 x 3 = 150byte) --%>
                <div class="input-area">
                    <input
                        type="text"
                        name="productName"
                        id="productNameInput"
                        data-maxchars="50"
                        placeholder="상품명을 입력해 주세요"
                    >
                </div>
            </div>


            <!-- 상품 게시글 제목 (PRODUCT.PRODUCT_TITLE - 목록/검색 카드에 노출되는 제목) -->

            <div class="form-row">
                <label>
                    상품 게시글 제목
                    <span class="required">*</span>
                    <span class="char-counter" data-for="productTitleInput" aria-hidden="true"></span>
                </label>

                <div class="input-area">
                    <input
                        type="text"
                        name="productTitle"
                        id="productTitleInput"
                        data-maxchars="60"
                        placeholder="상품 목록/검색에 노출될 제목을 입력해 주세요"
                    >
                </div>
            </div>


            <!-- 옵션 - PRODUCT엔 가격/재고 컬럼이 없고 PRODUCTOPTION에 있어서 옵션 단위로 등록한다.
                 개수 제한 없이 추가 가능하고 최소 1개는 필수. 실제 행은 views/addProduct.js가 그린다 -->

            <div class="form-row">
                <label>
                    옵션
                    <span class="required">*</span>
                </label>

                <div class="option-area">

                    <p class="option-description">
                        옵션마다 판매가격과 재고를 따로 등록합니다. 옵션이 하나뿐이면 "기본"처럼 입력해 주세요.
                    </p>

                    <div class="option-list" id="optionList"></div>

                    <button
                        type="button"
                        class="add-tag-button add-option-button"
                        id="addOptionButton"
                    >
                        <span class="add-icon">＋</span>
                        옵션 추가
                    </button>

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

                    <strong>대표 이미지 <span class="required">*</span></strong>

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
                    <strong>추가 이미지 <span class="required">*</span></strong>
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
            <h2>상품 설명 <span class="required">*</span></h2>
            <p>상품에 대한 상세한 설명을 입력해 주세요.</p>
        </div>

        <div class="description-box">

            <%-- 기존 maxlength="2000"은 PRODUCT_CONTENT(VARCHAR2(4000 BYTE))의 실제 한계를 넘는 값이었다.
                 한글 2000자면 6000byte라 카운터가 여유 있다고 표시한 채로 등록이 터진다. → 1300자로 조정 --%>
            <textarea
                id="productContent"
                name="productContent"
                data-maxchars="1300"
                placeholder="상품의 특징, 구성, 배송 및 보관 방법 등을 입력해 주세요."
            ></textarea>

            <div class="textarea-bottom">
                <span>상품 설명을 작성해 주세요.</span>
                <%-- 기존 "0 / 2000"은 글자 수 기준이라 실제 한계(한글 1333자)와 어긋났다.
                     바이트 기준 카운터로 교체 --%>
                <span class="char-counter" data-for="productContent"></span>
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

            <%-- 원래 "×" 글리프였으나 사이트 전체 아이콘 SVG 통일에 맞춤(2026-09-01).
                 텍스트가 없어져서 스크린리더용 이름은 aria-label로 준다. --%>
            <button
                type="button"
                class="modal-close"
                id="modalCloseButton"
                aria-label="닫기"
            >
                <svg class="icon-close" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M18 6L6 18M6 6l12 12"/></svg>
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
