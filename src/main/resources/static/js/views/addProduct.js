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
   입력 글자 수 표시

   화면엔 아무 표시가 없고 서버 검증도 없어서, 한도를 넘기면 DB가 뱉는 ORA-12899가
   그대로 노출됐다(실제로 겪은 오류). 남은 글자 수를 보여주고 초과 입력은 잘라낸다.

   제한 값은 DB 컬럼이 BYTE 단위인 점을 감안해 잡았다 - 전부 한글로 채워도(1자=3byte)
   컬럼 안에 들어간다. AdminProductServiceImpl 의 MAX_* 상수와 반드시 같은 값이어야 한다.
     상품명    50자 (PRODUCT_NAME    VARCHAR2(150))
     제목      60자 (PRODUCT_TITLE   VARCHAR2(200))
     상품설명 1300자 (PRODUCT_CONTENT VARCHAR2(4000))
     옵션명    30자 (OPTION_NAME     VARCHAR2(100))
   대상은 data-maxchars 를 가진 input/textarea 전부 - 동적으로 추가되는 옵션 행도 포함된다.
   ================================================== */

// 이모지처럼 서로게이트 쌍으로 이뤄진 문자도 1자로 센다(String.length는 2로 셈).
// 서버의 codePointCount 와 같은 기준이라 화면 카운터와 검증 결과가 어긋나지 않는다.
function charLength(str){
    return [...str].length;
}

// 글자 단위로 잘라낸다(서로게이트 쌍 중간이 잘려 깨지지 않도록)
function truncateToChars(str, maxChars){
    return [...str].slice(0, maxChars).join("");
}

function updateCharCounter(field){
    const max = Number(field.dataset.maxchars);
    if(!max) return;

    if(charLength(field.value) > max){
        field.value = truncateToChars(field.value, max);
    }

    // 카운터 위치는 두 가지다.
    //  - id가 있으면 [data-for="<id>"] 로 찾는다(상품설명처럼 textarea와 떨어져 있는 경우)
    //  - 없으면 같은 부모 안의 .char-counter(동적으로 만든 옵션 행)
    const counter = (field.id && document.querySelector('.char-counter[data-for="' + field.id + '"]'))
        || (field.parentElement && field.parentElement.querySelector('.char-counter'));
    if(!counter) return;

    const used = charLength(field.value);
    counter.textContent = used + " / " + max + "자";
    counter.classList.toggle("is-near-limit", used >= max * 0.9);
}

// 동적으로 추가되는 옵션 행까지 받도록 문서 단위 위임
document.addEventListener("input", function(event){
    const field = event.target;
    if(field && field.dataset && field.dataset.maxchars){
        updateCharCounter(field);
    }
});

// 최초 진입 시 0 / N 을 먼저 보여준다
document.querySelectorAll("[data-maxchars]").forEach(updateCharCounter);

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
    applyTagTextColor(tag);

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


// 태그 칩의 글자색을 배경 밝기에 맞춰 칠한다.
// 배경색은 등록자가 고르는 값이라 CSS로 하나 고정하면 연한 색 아니면 진한 색 중 한쪽이 반드시
// 묻힌다. 칩을 만들거나 색을 바꾸는 모든 지점에서 이 함수를 거치게 한다.
function applyTagTextColor(tagElement){

    const color = tagElement.dataset.tagColor;

    // #RRGGBB 형태가 아니면(빈 값/DB의 예전 표기 등) CSS 기본색을 그대로 둔다
    if(!/^#[0-9a-fA-F]{6}$/.test(color || "")) return;

    tagElement.style.color = getContrastColor(color);
}


// 태그 배경 위 글자색. 단순 밝기 임계값 대신 WCAG 명암비로 고른다
const TAG_TEXT_DARK = "#1f1b18";
const TAG_TEXT_LIGHT = "#ffffff";

// WCAG 상대 휘도. sRGB 값을 감마 보정한 뒤 사람 눈의 색별 민감도로 가중합한다.
function relativeLuminance(hex){

    const channel = function(value){
        const c = value / 255;
        return c <= 0.03928
            ? c / 12.92
            : Math.pow((c + 0.055) / 1.055, 2.4);
    };

    const r = channel(parseInt(hex.substring(1,3),16));
    const g = channel(parseInt(hex.substring(3,5),16));
    const b = channel(parseInt(hex.substring(5,7),16));

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}


function contrastRatio(hexA, hexB){

    const a = relativeLuminance(hexA);
    const b = relativeLuminance(hexB);

    return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}


// 진한 글자가 이 배수 이상 앞설 때만 채택. 채도 높은 중간 톤에서 명암비가 실제 가독성을
// 과대평가해서 경계를 흰 글자 쪽으로 당겨둔 값이다.
// 올릴수록 흰 글자가 늘어난다. 팔레트 경계: 1.13(#975fff) 1.41(#f15151) 1.85(#a97aff)
const TAG_TEXT_WHITE_BIAS = 1.25;

function getContrastColor(hex){

    return contrastRatio(hex, TAG_TEXT_DARK) >= contrastRatio(hex, TAG_TEXT_LIGHT) * TAG_TEXT_WHITE_BIAS
        ? TAG_TEXT_DARK
        : TAG_TEXT_LIGHT;
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

    applyTagTextColor(existingTag);


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


/* 상품 설명 글자 수 카운터는 위 "입력 길이 표시(바이트 기준)"로 통합됐다.
   기존 구현은 this.value.length + " / 2000" 이라 글자 수를 셌는데, PRODUCT_CONTENT가
   VARCHAR2(4000 BYTE)라 한글로는 1333자가 한계여서 표시와 실제 한계가 어긋나 있었다. */

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
   옵션 (개수 제한 없는 동적 행 - 최소 1개)
   행 하나 = 옵션 하나 = PRODUCTOPTION 1건 + OPTIONDETAIL 1건
   ================================================== */

const optionList = document.getElementById("optionList");


function createOptionRow(){

    const row = document.createElement("div");
    row.className = "option-row";

    const indexBadge = document.createElement("span");
    indexBadge.className = "option-row-index";

    const nameField = document.createElement("div");
    nameField.className = "option-field option-field-name";
    // 카운터를 입력칸 아래에 두면 이 칸만 높아져서 판매가격/재고와 아래끝 정렬이 어긋난다.
    // 라벨과 같은 줄 오른쪽에 붙여 세 칸의 높이를 맞춘다.
    nameField.innerHTML =
        '<div class="option-field-head">' +
            '<span class="option-field-label">옵션명</span>' +
            '<span class="char-counter"></span>' +
        '</div>' +
        '<input type="text" class="option-name" data-maxchars="30" placeholder="예: 기본, 단품">';

    const priceField = document.createElement("div");
    priceField.className = "option-field";
    priceField.innerHTML =
        '<span class="option-field-label">판매가격</span>' +
        '<input type="number" class="option-price" placeholder="0" min="0">';

    const stockField = document.createElement("div");
    stockField.className = "option-field";
    stockField.innerHTML =
        '<span class="option-field-label">재고</span>' +
        '<input type="number" class="option-stock" placeholder="0" min="0">';

    const removeButton = document.createElement("button");
    removeButton.type = "button";
    removeButton.className = "tag-remove option-remove";
    removeButton.setAttribute("aria-label", "옵션 삭제");
    removeButton.innerHTML = CLOSE_ICON_SVG;
    removeButton.addEventListener("click", function(){

        // 옵션이 1개뿐이면 버튼을 감춰두지만, 스타일이 밀려 보이는 경우가 있어 동작으로도 막는다
        if(optionList.querySelectorAll(".option-row").length <= 1) return;

        row.remove();
        updateOptionRows();
    });

    row.appendChild(indexBadge);
    row.appendChild(nameField);
    row.appendChild(priceField);
    row.appendChild(stockField);
    row.appendChild(removeButton);

    return row;
}


function addOptionRow(){

    const row = createOptionRow();
    optionList.appendChild(row);
    // 새 행의 옵션명 카운터에도 "0 / 100 bytes"를 바로 표시한다
    row.querySelectorAll("[data-maxchars]").forEach(updateCharCounter);
    updateOptionRows();
}


// 옵션은 최소 1개가 있어야 상품이 성립하므로, 하나만 남으면 삭제 버튼을 감춘다.
// 번호는 화면에만 쓰는 값이라 매번 다시 매긴다(중간 행을 지워도 1,2,3...이 유지됨).
function updateOptionRows(){

    const rows = optionList.querySelectorAll(".option-row");

    rows.forEach(function(row, index){

        const removeButton = row.querySelector(".option-remove");
        removeButton.hidden = (rows.length === 1);

        // 검증 실패 메시지가 "옵션 2의 ..." 형태라 화면에도 같은 번호가 보여야 찾아갈 수 있다
        row.querySelector(".option-row-index").textContent = index + 1;
    });
}


document
    .getElementById("addOptionButton")
    .addEventListener("click", addOptionRow);


// 화면에서 입력한 옵션들을 서버로 보낼 형태로 모은다.
// 유효하지 않으면 alert 문구를 반환하고, 정상이면 null을 반환한다(호출부에서 판정).
function collectOptions(){

    const options = [];
    const rows = optionList.querySelectorAll(".option-row");

    for(let i = 0; i < rows.length; i++){

        const row = rows[i];
        const label = "옵션 " + (i + 1) + "의 ";

        const optionName = row.querySelector(".option-name").value.trim();
        const price = row.querySelector(".option-price").value;
        const stock = row.querySelector(".option-stock").value;

        if(!optionName){
            return { error: label + "옵션명을 입력해 주세요." };
        }
        if(price === ""){
            return { error: label + "판매가격을 입력해 주세요." };
        }
        if(stock === ""){
            return { error: label + "재고를 입력해 주세요." };
        }
        if(Number(price) < 0){
            return { error: label + "판매가격은 0 이상이어야 합니다." };
        }
        if(Number(stock) < 0){
            return { error: label + "재고는 0 이상이어야 합니다." };
        }

        // 같은 상품 안에서 옵션명이 겹치면 구매 화면에서 구분이 안 되므로 미리 막는다
        const duplicated = options.some(function(option){
            return option.optionName === optionName;
        });

        if(duplicated){
            return { error: "옵션명 \"" + optionName + "\"이(가) 중복됩니다." };
        }

        options.push({
            optionName: optionName,
            price: Number(price),
            stock: Number(stock)
        });
    }

    if(options.length === 0){
        return { error: "옵션을 최소 1개 이상 등록해 주세요." };
    }

    return { options: options };
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

    const optionResult = collectOptions();
    if(optionResult.error){
        alert(optionResult.error);
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
    formData.append("optionsJson", JSON.stringify(optionResult.options));
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
addOptionRow();

// 기존 태그 목록은 addProduct.jsp가 서버에서 그리므로 배경색만 있고 글자색이 없다.
// 여기서 한 번 훑어 배경 밝기에 맞는 글자색을 입힌다.
document
    .querySelectorAll("#existingTagList .product-tag")
    .forEach(applyTagTextColor);

})();
