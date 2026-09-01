// 관리자 - 상품 등록 화면 인터랙션 (태그/이미지 UI, 폼 제출).
// 서버 통신은 window.AdminProductService(static/js/admin/adminProductService.js)에 위임한다.
(function () {

const productRegisterPage = document.querySelector('.product-register');
const registerUrl = productRegisterPage.dataset.registerUrl;

// 삭제(×) 버튼 아이콘. 원래 "×" 글리프를 textContent로 넣었는데, 사이트 전체 아이콘을
// SVG로 통일하면서(2026-09-01) 여기도 맞췄다. 스타일은 style.css의 공용 .icon-close.
const CLOSE_ICON_SVG =
    '<svg class="icon-close" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
        '<path d="M18 6L6 18M6 6l12 12"></path>' +
    '</svg>';

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
 * 클릭하면 선택 상태를 토글하고 현재 상품 태그에 추가/삭제한다.
 * (기존 태그는 선택 팔레트라 삭제 버튼을 따로 두지 않음 - 다시 클릭하면 선택 해제됨)
 */
document.getElementById("existingTagList").addEventListener("click", function(event){

    const tag = event.target.closest(".product-tag");

    if(!tag) return;

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
    // 원래 "×" 글리프였으나 SVG 아이콘 규격으로 통일(2026-09-01). 텍스트가 없어져서
    // 스크린리더용 이름은 aria-label로 따로 준다.
    removeButton.setAttribute("aria-label", name + " 태그 삭제");
    removeButton.innerHTML = CLOSE_ICON_SVG;

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
     * (기존 태그는 선택 팔레트라 X 버튼 없이 클릭으로만 토글)
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


    existingTag.appendChild(text);


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
   추가 이미지 / 설명 이미지 (개수 제한 없는 동적 업로드)
   ================================================== */

let subImageFiles = [];
let descImageFiles = [];

function createImageSlot(file, index, onRemove, onReorder){

    const box = document.createElement("div");
    box.className = "sub-image-box sub-image-preview";
    box.style.position = "relative";
    box.style.overflow = "hidden";

    /*
     * 여러 장을 한 번에 선택하면 브라우저/OS가 넘겨주는 순서가
     * 뒤죽박죽일 수 있어서, 드래그로 직접 순서를 바꿀 수 있게 함
     */
    box.draggable = true;
    box.dataset.index = index;

    const img = document.createElement("img");
    img.src = URL.createObjectURL(file);
    img.alt = file.name;
    img.style.width = "100%";
    img.style.height = "100%";
    img.style.objectFit = "cover";

    const removeButton = document.createElement("button");
    removeButton.type = "button";
    removeButton.className = "tag-remove sub-image-remove";
    removeButton.setAttribute("aria-label", "추가 이미지 삭제");
    removeButton.innerHTML = CLOSE_ICON_SVG;
    removeButton.style.position = "absolute";
    removeButton.style.top = "4px";
    removeButton.style.right = "4px";
    removeButton.addEventListener("click", function(event){
        event.preventDefault();
        event.stopPropagation();
        onRemove();
    });

    box.addEventListener("dragstart", function(event){
        event.dataTransfer.effectAllowed = "move";
        event.dataTransfer.setData("text/plain", String(index));
        box.classList.add("dragging");
    });

    box.addEventListener("dragend", function(){
        box.classList.remove("dragging");
    });

    box.addEventListener("dragover", function(event){
        event.preventDefault();
        event.dataTransfer.dropEffect = "move";
        box.classList.add("drag-over");
    });

    box.addEventListener("dragleave", function(){
        box.classList.remove("drag-over");
    });

    box.addEventListener("drop", function(event){
        event.preventDefault();
        box.classList.remove("drag-over");
        const fromIndex = Number(event.dataTransfer.getData("text/plain"));
        onReorder(fromIndex, index);
    });

    box.appendChild(img);
    box.appendChild(removeButton);

    return box;
}

function renderImageList(files, gridEl, addTileEl, countEl){

    gridEl.querySelectorAll(".sub-image-preview img").forEach(function(img){
        URL.revokeObjectURL(img.src);
    });

    gridEl.querySelectorAll(".sub-image-preview").forEach(function(el){
        el.remove();
    });

    files.forEach(function(file, index){
        const slot = createImageSlot(file, index, function(){
            files.splice(index, 1);
            renderImageList(files, gridEl, addTileEl, countEl);
        }, function(fromIndex, toIndex){
            if(fromIndex === toIndex || isNaN(fromIndex)) return;
            const [moved] = files.splice(fromIndex, 1);
            files.splice(toIndex, 0, moved);
            renderImageList(files, gridEl, addTileEl, countEl);
        });
        gridEl.insertBefore(slot, addTileEl);
    });

    countEl.textContent = files.length + "장";
}

function setupImageUploader(addTileId, inputId, gridId, countId, filesArray){

    const addTile = document.getElementById(addTileId);
    const input = document.getElementById(inputId);
    const grid = document.getElementById(gridId);
    const count = document.getElementById(countId);

    addTile.addEventListener("click", function(event){
        event.preventDefault();
        input.click();
    });

    input.addEventListener("change", function(event){
        for(const file of event.target.files){
            filesArray.push(file);
        }
        event.target.value = "";
        renderImageList(filesArray, grid, addTile, count);
    });
}

setupImageUploader("subImageAddTile", "subImageInput", "subImageGrid", "subImageCount", subImageFiles);
setupImageUploader("descImageAddTile", "descImageInput", "descImageGrid", "descImageCount", descImageFiles);


/* ==================================================
   대표 이미지 미리보기
   (추가/설명 이미지와 달리 칸이 1개뿐이라 그리드 방식 대신
   레이블 내용 자체를 이미지로 바꿔치기하는 방식으로 처리)
   ================================================== */

const mainImageBox = document.querySelector(".main-image-upload");
const mainImageLabel = document.querySelector(".image-label");
const mainImageInput = document.getElementById("main-image");
const mainImageLabelDefaultHTML = mainImageLabel.innerHTML;
let mainImagePreviewUrl = null;

mainImageInput.addEventListener("change", function(event){

    const file = event.target.files[0];

    if(!file) return;

    showMainImagePreview(file);
});

function showMainImagePreview(file){

    if(mainImagePreviewUrl){
        URL.revokeObjectURL(mainImagePreviewUrl);
    }

    mainImagePreviewUrl = URL.createObjectURL(file);

    mainImageLabel.innerHTML = "";

    const img = document.createElement("img");
    img.src = mainImagePreviewUrl;
    img.alt = file.name;
    img.style.width = "100%";
    img.style.height = "100%";
    img.style.objectFit = "cover";

    mainImageLabel.appendChild(img);

    if(!mainImageBox.querySelector(".main-image-remove")){

        const removeButton = document.createElement("button");
        removeButton.type = "button";
        removeButton.className = "tag-remove main-image-remove";
        removeButton.setAttribute("aria-label", "대표 이미지 삭제");
        removeButton.innerHTML = CLOSE_ICON_SVG;
        removeButton.addEventListener("click", function(event){
            event.preventDefault();
            event.stopPropagation();
            clearMainImage();
        });

        mainImageBox.appendChild(removeButton);
    }
}

function clearMainImage(){

    if(mainImagePreviewUrl){
        URL.revokeObjectURL(mainImagePreviewUrl);
        mainImagePreviewUrl = null;
    }

    mainImageInput.value = "";
    mainImageLabel.innerHTML = mainImageLabelDefaultHTML;

    const removeButton = mainImageBox.querySelector(".main-image-remove");

    if(removeButton) removeButton.remove();
}


/* ==================================================
   취소
   ================================================== */

document
    .getElementById("cancelButton")
    .addEventListener("click", function(){

        history.back();

    });


/* ==================================================
   상품 등록
   ================================================== */

document
    .getElementById("registerButton")
    .addEventListener("click", registerProduct);


function registerProduct(){

    const productName = document.getElementById("productNameInput").value.trim();
    const productTitle = document.getElementById("productTitleInput").value.trim();
    const optionName = document.getElementById("optionNameInput").value.trim();
    const price = document.getElementById("priceInput").value;
    const stock = document.getElementById("stockInput").value;
    const categoryId = document.getElementById("categorySelect").value;
    const productContent = document.getElementById("productContent").value;

    if(!productName){
        alert("상품명을 입력해 주세요.");
        return;
    }
    if(!productTitle){
        alert("상품 게시글 제목을 입력해 주세요.");
        return;
    }
    if(!optionName){
        alert("옵션명을 입력해 주세요.");
        return;
    }
    if(!price){
        alert("판매가격을 입력해 주세요.");
        return;
    }
    if(!stock){
        alert("재고를 입력해 주세요.");
        return;
    }
    if(!categoryId){
        alert("카테고리를 선택해 주세요.");
        return;
    }
    if(!mainImageInput.files[0]){
        alert("대표 이미지를 등록해 주세요.");
        return;
    }
    if(descImageFiles.length === 0){
        alert("설명 이미지를 최소 1장 이상 등록해 주세요.");
        return;
    }
    if(!productContent.trim()){
        // PRODUCT_CONTENT는 NOT NULL 컬럼이고, Oracle은 빈 문자열을 NULL로 취급해서
        // 비워둔 채 등록하면 DB 제약조건 위반으로 실패한다.
        alert("상품 설명을 입력해 주세요.");
        return;
    }

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

    const formData = new FormData();
    formData.append("productName", productName);
    formData.append("productTitle", productTitle);
    formData.append("optionName", optionName);
    formData.append("price", price);
    formData.append("stock", stock);
    formData.append("categoryId", categoryId);
    formData.append("productContent", productContent);
    formData.append("tagsJson", JSON.stringify(tagData));
    formData.append("mainImage", mainImageInput.files[0]);

    subImageFiles.forEach(function(file){
        formData.append("subImages", file);
    });

    descImageFiles.forEach(function(file){
        formData.append("descriptionImages", file);
    });

    const registerButton = document.getElementById("registerButton");
    registerButton.disabled = true;

    AdminProductService.registerProduct(registerUrl, formData)
        .then(function(result){
            alert(result.message || "상품이 등록되었습니다.");
            location.href = registerUrl;
        })
        .catch(function(error){
            alert(error.message || "상품 등록 중 오류가 발생했습니다.");
        })
        .finally(function(){
            registerButton.disabled = false;
        });
}


/* ==================================================
   초기화
   ================================================== */

updateColorPreview();

})();
