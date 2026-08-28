document.addEventListener('DOMContentLoaded', function () {
  initStarRating();
  initCharCount();
  initPhotoUpload();
  initSubmitValidation();
});

/* ==========================================================================
   1. 별점: 기본은 전부 빈 별. 호버 시 마우스가 올라간 별까지 채워지고,
      클릭하면 그 값으로 고정(선택)됨. hidden input(#review-score)에 값 저장.
   ========================================================================== */
function initStarRating() {
  var container = document.getElementById('star-rating');
  var scoreInput = document.getElementById('review-score');
  if (!container || !scoreInput) return;

  var starBtns = Array.prototype.slice.call(container.querySelectorAll('.star-btn'));
  var selectedValue = 0;

  function paint(value) {
    starBtns.forEach(function (btn) {
      var v = Number(btn.dataset.value);
      btn.classList.toggle('is-filled', v <= value);
    });
  }

  starBtns.forEach(function (btn) {
    btn.addEventListener('mouseenter', function () {
      paint(Number(btn.dataset.value));
    });

    btn.addEventListener('click', function () {
      selectedValue = Number(btn.dataset.value);
      scoreInput.value = String(selectedValue);
      paint(selectedValue);
    });

    // 키보드 접근성: focus 시에도 해당 값까지 미리보기
    btn.addEventListener('focus', function () {
      paint(Number(btn.dataset.value));
    });
  });

  container.addEventListener('mouseleave', function () {
    paint(selectedValue);
  });

  container.addEventListener('focusout', function (e) {
    // 포커스가 별점 영역 밖으로 완전히 벗어났을 때만 선택값으로 복귀
    if (!container.contains(e.relatedTarget)) {
      paint(selectedValue);
    }
  });
}

/* ==========================================================================
   2. 후기 텍스트 글자수 카운터 (최대 500자)
   ========================================================================== */
function initCharCount() {
  var textarea = document.getElementById('review_text');
  var countEl = document.getElementById('current-char-count');
  var wrapper = document.getElementById('char-count-wrapper');
  if (!textarea || !countEl || !wrapper) return;

  var MAX_LEN = 500;

  function update() {
    var len = textarea.value.length;
    countEl.textContent = len;
    wrapper.classList.toggle('is-limit', len >= MAX_LEN);
  }

  textarea.addEventListener('input', update);
  update();
}

/* ==========================================================================
   3. 사진 첨부: 최대 5장, 미리보기 + 개별 삭제.
      <input type="file" multiple>은 선택된 파일 목록을 직접 편집할 수 없어서
      DataTransfer로 새 FileList를 만들어 input.files에 다시 채워 넣는 방식 사용.
   ========================================================================== */
function initPhotoUpload() {
  var fileInput = document.getElementById('review_image_id');
  var previewList = document.getElementById('photo-preview-list');
  var uploadBoxBtn = document.getElementById('upload-box-btn');
  if (!fileInput || !previewList || !uploadBoxBtn) return;

  var MAX_PHOTOS = 5;
  var selectedFiles = [];

  fileInput.addEventListener('change', function (e) {
    var newFiles = Array.prototype.slice.call(e.target.files);

    for (var i = 0; i < newFiles.length; i++) {
      if (selectedFiles.length >= MAX_PHOTOS) {
        alert('사진은 최대 ' + MAX_PHOTOS + '장까지 첨부할 수 있어요.');
        break;
      }
      selectedFiles.push(newFiles[i]);
    }

    // 같은 파일을 다시 선택해도 change 이벤트가 발생하도록 초기화
    fileInput.value = '';

    render();
    sync();
  });

  function render() {
    previewList.innerHTML = '';

    selectedFiles.forEach(function (file, idx) {
      var li = document.createElement('li');

      var img = document.createElement('img');
      img.src = URL.createObjectURL(file);
      img.alt = '첨부 이미지 ' + (idx + 1);

      var removeBtn = document.createElement('button');
      removeBtn.type = 'button';
      removeBtn.className = 'remove-btn';
      removeBtn.setAttribute('aria-label', (idx + 1) + '번째 사진 삭제');
      removeBtn.textContent = '×';
      removeBtn.addEventListener('click', function () {
        selectedFiles.splice(idx, 1);
        render();
        sync();
      });

      li.appendChild(img);
      li.appendChild(removeBtn);
      previewList.appendChild(li);
    });

    // 5장 다 채우면 업로드 버튼 숨김
    uploadBoxBtn.style.display = selectedFiles.length >= MAX_PHOTOS ? 'none' : 'flex';
  }

  function sync() {
    var dt = new DataTransfer();
    selectedFiles.forEach(function (file) {
      dt.items.add(file);
    });
    fileInput.files = dt.files;
  }
}

/* ==========================================================================
   4. 제출 시 별점 미선택 방지
   ========================================================================== */
function initSubmitValidation() {
  var form = document.getElementById('review-form');
  var scoreInput = document.getElementById('review-score');
  if (!form || !scoreInput) return;

  form.addEventListener('submit', function (e) {
    if (!scoreInput.value) {
      e.preventDefault();
      alert('별점을 선택해주세요.');
      return;
    }
  });
}