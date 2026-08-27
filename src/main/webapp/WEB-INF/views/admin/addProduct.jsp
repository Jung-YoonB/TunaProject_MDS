
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="header-right">

            <div class="icon">

                <a href="#" class="icon-item">
                    <svg class="icon-svg" viewBox="0 0 24 24">
                        <circle cx="12" cy="8" r="4"></circle>
                        <path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7"></path>
                    </svg>
                    <span>마이페이지</span>
                </a>

                <a href="#" class="icon-item">
                    <svg class="icon-svg" viewBox="0 0 24 24">
                        <path d="M20.8 8.8c0 5.5-8.8 11.2-8.8 11.2S3.2 14.3 3.2 8.8A4.8 4.8 0 0 1 12 6.1a4.8 4.8 0 0 1 8.8 2.7Z"></path>
                    </svg>
                    <span>찜</span>
                </a>

                <a href="#" class="icon-item">
                    <svg class="icon-svg" viewBox="0 0 24 24">
                        <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"></path>
                        <path d="M3 6h18"></path>
                        <path d="M16 10a4 4 0 0 1-8 0"></path>
                    </svg>
                    <span>장바구니</span>
                </a>

            </div>

            <div class="sign">
                <a href="#">로그인</a>
                <span class="sign-divider">|</span>
                <a href="#">회원가입</a>
            </div>

        </div>
    </div>

    <nav class="category-nav">
        <a href="#">전체상품</a>
        <a href="#">가격별</a>
        <a href="#">연령별</a>
        <a href="#">상황별</a>
        <a href="#">명절선물</a>
    </nav>
</header>


<!-- ================= MAIN ================= -->

<main class="product-register">

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
                        placeholder="상품명을 입력해 주세요"
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
                        placeholder="판매가격을 입력해 주세요"
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
                    <select name="category">
                        <option value="">카테고리를 선택해 주세요</option>
                        <option value="holiday">명절선물</option>
                        <option value="parents">부모님 선물</option>
                        <option value="birthday">생일 선물</option>
                        <option value="thanks">감사 선물</option>
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

                            <div
                                class="product-tag"
                                data-tag-name="1만원대 선물"
                                data-tag-color="#FFD1DC"
                                style="background-color:#FFD1DC"
                            >
                                <span>1만원대 선물</span>
                                <button type="button" class="tag-remove">×</button>
                            </div>

                            <div
                                class="product-tag"
                                data-tag-name="2만원대 선물"
                                data-tag-color="#FFE5CC"
                                style="background-color:#FFE5CC"
                            >
                                <span>2만원대 선물</span>
                                <button type="button" class="tag-remove">×</button>
                            </div>

                            <div
                                class="product-tag"
                                data-tag-name="3만원대 선물"
                                data-tag-color="#D0F0C0"
                                style="background-color:#D0F0C0"
                            >
                                <span>3만원대 선물</span>
                                <button type="button" class="tag-remove">×</button>
                            </div>

                            <div
                                class="product-tag"
                                data-tag-name="5만원대 선물"
                                data-tag-color="#D4E6F1"
                                style="background-color:#D4E6F1"
                            >
                                <span>5만원대 선물</span>
                                <button type="button" class="tag-remove">×</button>
                            </div>

                            <div
                                class="product-tag"
                                data-tag-name="20대에게 인기 선물"
                                data-tag-color="#E8DAEF"
                                style="background-color:#E8DAEF"
                            >
                                <span>20대에게 인기 선물</span>
                                <button type="button" class="tag-remove">×</button>
                            </div>

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


            <!-- 추가 이미지 -->

            <div class="sub-image-area">

                <div class="sub-image-title">
                    <strong>추가 이미지</strong>
                    <span>최대 6장</span>
                </div>

                <div class="sub-image-grid">

                    <label class="sub-image-box" for="sub-image-1">
                        <span>＋</span>
                        <small>이미지 1</small>
                    </label>
                    <input type="file" id="sub-image-1" name="subImages" accept="image/*" hidden>

                    <label class="sub-image-box" for="sub-image-2">
                        <span>＋</span>
                        <small>이미지 2</small>
                    </label>
                    <input type="file" id="sub-image-2" name="subImages" accept="image/*" hidden>

                    <label class="sub-image-box" for="sub-image-3">
                        <span>＋</span>
                        <small>이미지 3</small>
                    </label>
                    <input type="file" id="sub-image-3" name="subImages" accept="image/*" hidden>

                    <label class="sub-image-box" for="sub-image-4">
                        <span>＋</span>
                        <small>이미지 4</small>
                    </label>
                    <input type="file" id="sub-image-4" name="subImages" accept="image/*" hidden>

                    <label class="sub-image-box" for="sub-image-5">
                        <span>＋</span>
                        <small>이미지 5</small>
                    </label>
                    <input type="file" id="sub-image-5" name="subImages" accept="image/*" hidden>

                    <label class="sub-image-box" for="sub-image-6">
                        <span>＋</span>
                        <small>이미지 6</small>
                    </label>
                    <input type="file" id="sub-image-6" name="subImages" accept="image/*" hidden>

                </div>
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

</main>


<!-- ================= FOOTER ================= -->

<footer class="site-footer">

    <div class="footer-top">

        <div class="company-info">

            <h2>Masion De SAJO</h2>

            <address>
                <p>서울특별시 강남구 테헤란로 14길</p>
                <p>우편번호 06234</p>
                <p>고객센터 1544-9970</p>
            </address>

        </div>

        <nav class="footer-nav">

            <ul>
                <li><a href="#">이용약관</a></li>
                <li><a href="#">개인정보처리방침</a></li>
                <li><a href="#">사업자정보</a></li>
                <li><a href="#">고객센터</a></li>
            </ul>

        </nav>

    </div>

    <hr class="footer-divider">

    <div class="footer-bottom">
        <p>© 2026 Masion De SAJO. All rights reserved.</p>
    </div>

</footer>


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


<script>

/* ==================================================
   태그 관리
   ================================================== */

/*
 * 현재 상품에 선택된 태그
 * 태그 이름을 기준으로 관리
 */
const selectedTags = new Set();


/*
 * 기존 태그 클릭
 *
 * 클릭하면:
 * 1. 선택 상태 변경
 * 2. 현재 상품 태그에 추가/삭제
 */
document.getElementById("existingTagList").addEventListener("click", function(event){

    const tag = event.target.closest(".product-tag");

    if(!tag) return;

    /*
     * X 버튼을 누른 경우
     * 기존 태그는 삭제하지 않고 선택만 해제
     */
    if(event.target.closest(".tag-remove")){
        event.stopPropagation();

        const name = tag.dataset.tagName;

        selectedTags.delete(name);
        updateTagDisplay();

        return;
    }

    const name = tag.dataset.tagName;

    if(selectedTags.has(name)){
        selectedTags.delete(name);
    }else{
        selectedTags.add(name);
    }

    updateTagDisplay();
});


/*
 * 현재 상품 태그의 X 버튼
 *
 * 선택된 태그를 현재 상품에서 제거하고
 * 기존 태그의 선택 상태도 해제
 */
document.getElementById("addedTagList").addEventListener("click", function(event){

    const removeButton = event.target.closest(".tag-remove");

    if(!removeButton) return;

    event.stopPropagation();

    const tag = removeButton.closest(".product-tag");

    if(!tag) return;

    const name = tag.dataset.tagName;

    selectedTags.delete(name);

    /*
     * 직접 추가한 태그인지 확인
     */
    const existingTag = document.querySelector(
        '#existingTagList .product-tag[data-tag-name="' +
        CSS.escape(name) +
        '"]'
    );

    /*
     * 직접 추가한 태그는 X를 누르면
     * 기존 태그에서도 완전히 삭제
     */
    if(tag.dataset.custom === "true" && existingTag){
        existingTag.remove();
    }

    updateTagDisplay();
});


/*
 * 현재 상품 태그 표시 갱신
 */
function updateTagDisplay(){

    const existingTags =
        document.querySelectorAll("#existingTagList .product-tag");

    /*
     * 기존 태그 선택 상태 갱신
     */
    existingTags.forEach(function(tag){

        const name = tag.dataset.tagName;

        tag.classList.toggle(
            "selected",
            selectedTags.has(name)
        );
    });


    /*
     * 현재 상품 태그 영역
     */
    const addedTagList =
        document.getElementById("addedTagList");

    const addButton =
        document.getElementById("addTagButton");

    /*
     * 기존에 생성된 현재 상품 태그 제거
     */
    addedTagList
        .querySelectorAll(".product-tag")
        .forEach(function(tag){
            tag.remove();
        });


    /*
     * 선택된 태그를 현재 상품 태그로 생성
     */
    selectedTags.forEach(function(name){

        const existingTag =
            document.querySelector(
                '#existingTagList .product-tag[data-tag-name="' +
                CSS.escape(name) +
                '"]'
            );

        if(!existingTag) return;

        const tag = createCurrentTag(
            existingTag.dataset.tagName,
            existingTag.dataset.tagColor,
            existingTag.dataset.custom === "true"
        );

        addedTagList.insertBefore(tag, addButton);
    });
}


/*
 * 현재 상품 태그 생성
 */
function createCurrentTag(name, color, isCustom){

    const tag = document.createElement("div");

    tag.className = "product-tag selected";

    tag.dataset.tagName = name;
    tag.dataset.tagColor = color;

    if(isCustom){
        tag.dataset.custom = "true";
    }

    tag.style.backgroundColor = color;

    const text = document.createElement("span");
    text.textContent = name;

    const removeButton = document.createElement("button");

    removeButton.type = "button";
    removeButton.className = "tag-remove";
    removeButton.textContent = "×";

    tag.appendChild(text);
    tag.appendChild(removeButton);

    return tag;
}


/* ==================================================
   태그 모달
   ================================================== */

const tagModal =
    document.getElementById("tagModal");

const newTagName =
    document.getElementById("newTagName");

const newTagColor =
    document.getElementById("newTagColor");

const colorPreview =
    document.getElementById("colorPreview");


/*
 * 태그 추가 버튼
 */
document
    .getElementById("addTagButton")
    .addEventListener("click", openTagModal);


/*
 * 모달 열기
 */
function openTagModal(){

    tagModal.classList.add("show");

    newTagName.value = "";
    newTagColor.value = "#E8D6C5";

    updateColorPreview();

    newTagName.focus();
}


/*
 * 모달 닫기
 */
function closeTagModal(){

    tagModal.classList.remove("show");
}


document
    .getElementById("modalCloseButton")
    .addEventListener("click", closeTagModal);

document
    .getElementById("modalCancelButton")
    .addEventListener("click", closeTagModal);


/*
 * 모달 바깥 클릭
 */
tagModal.addEventListener("click", function(event){

    if(event.target === tagModal){
        closeTagModal();
    }
});


/* ==================================================
   색상 미리보기
   ================================================== */

newTagColor.addEventListener(
    "input",
    updateColorPreview
);


function updateColorPreview(){

    const color =
        newTagColor.value.toUpperCase();

    colorPreview.style.backgroundColor = color;

    colorPreview.style.color =
        getContrastColor(color);

    colorPreview.textContent =
        "선택 색상 " + color;
}


function getContrastColor(hex){

    const r =
        parseInt(hex.substring(1,3),16);

    const g =
        parseInt(hex.substring(3,5),16);

    const b =
        parseInt(hex.substring(5,7),16);

    const brightness =
        (r * 299 + g * 587 + b * 114) / 1000;

    return brightness > 160
        ? "#4b433d"
        : "#ffffff";
}


/* ==================================================
   새 태그 생성
   ================================================== */

document
    .getElementById("modalAddButton")
    .addEventListener("click", addNewTag);


function addNewTag(){

    const name =
        newTagName.value.trim();

    const color =
        newTagColor.value.toUpperCase();


    /*
     * 태그명 검사
     */
    if(!name){

        alert("태그명을 입력해주세요.");

        newTagName.focus();

        return;
    }


    /*
     * 기존 태그와 새 태그 전체 중복 검사
     */
    const allTags =
        document.querySelectorAll(".product-tag");

    for(const tag of allTags){

        if(tag.dataset.tagName === name){

            alert("이미 존재하는 태그입니다.");

            newTagName.focus();

            return;
        }
    }


    /*
     * 기존 태그 영역에 새 태그 생성
     */
    const existingTag =
        document.createElement("div");

    existingTag.className =
        "product-tag selected";

    existingTag.dataset.tagName =
        name;

    existingTag.dataset.tagColor =
        color;

    existingTag.dataset.custom =
        "true";

    existingTag.style.backgroundColor =
        color;


    const text =
        document.createElement("span");

    text.textContent = name;


    const removeButton =
        document.createElement("button");

    removeButton.type = "button";
    removeButton.className = "tag-remove";
    removeButton.textContent = "×";


    existingTag.appendChild(text);
    existingTag.appendChild(removeButton);


    document
        .getElementById("existingTagList")
        .appendChild(existingTag);


    /*
     * 현재 상품 태그에도 선택
     */
    selectedTags.add(name);

    updateTagDisplay();


    /*
     * 입력창 초기화
     */
    newTagName.value = "";
    newTagColor.value = "#E8D6C5";

    updateColorPreview();

    /*
     * 모달은 닫지 않음
     * → 여러 태그 연속 추가 가능
     */
    newTagName.focus();
}


/* ==================================================
   상품 설명 글자 수
   ================================================== */

const textarea =
    document.getElementById("productContent");

const counter =
    document.getElementById("counter");


textarea.addEventListener("input", function(){

    counter.textContent =
        this.value.length + " / 2000";
});


/* ==================================================
   취소
   ================================================== */

document
    .getElementById("cancelButton")
    .addEventListener("click", function(){

        history.back();

    });


/* ==================================================
   상품 등록 테스트
   ================================================== */

document
    .getElementById("registerButton")
    .addEventListener("click", registerProduct);


function registerProduct(){

    const tagData = [];

    selectedTags.forEach(function(name){

        const tag =
            document.querySelector(
                '#existingTagList .product-tag[data-tag-name="' +
                CSS.escape(name) +
                '"]'
            );

        if(tag){

            tagData.push({
                tagName: tag.dataset.tagName,
                tagColor: tag.dataset.tagColor
            });

        }
    });


    console.log(
        "선택된 상품 태그:",
        tagData
    );


    let result = "";

    tagData.forEach(function(tag){

        result +=
            tag.tagName +
            " (" +
            tag.tagColor +
            ")\n";
    });


    alert(
        "상품 등록 기능 테스트입니다.\n\n" +
        "선택된 태그:\n" +
        (result ? result : "없음")
    );
}


/* ==================================================
   초기화
   ================================================== */

updateColorPreview();

</script>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>