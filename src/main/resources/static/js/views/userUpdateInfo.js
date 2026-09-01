/* 회원정보 수정 페이지 - 구글 계정 정보 화면처럼 항목을 탭하면 하위 패널에서 수정/저장한다.
   중복확인 서버 통신은 member/memberService.js(window.MemberService)가 담당하고,
   이 파일은 DOM 인터랙션만 다룬다. */

/* TODO(server binding): "저장" 버튼은 아직 화면 표시값만 갱신하는 no-op이다.
   백엔드는 이미 준비돼 있으므로(MemberController #BE014) 연동 시 각 분기에서 아래 엔드포인트를
   호출하고 성공 응답을 받은 뒤에만 collapsePanel()을 부르도록 바꾸면 된다:
     name/birth/gender/nickname/phone/email/password
       -> POST /member/updateName, /updateBirth, /updateGender, /updateNickname,
                /updatePhone, /updateEmail, /updatePassword
   배송지(address)만은 대응하는 백엔드가 없어 완전한 목업이다. */

const nicknameInput = document.querySelector("#nickname");
const phoneInput = document.querySelector("#phone");
const emailInput = document.querySelector("#email");

// 저장에 성공할 때마다 갱신되는 "현재 값" 기준점 - 중복확인 시 이 값과 같으면
// 서버의 "본인 제외" 로직 부재로 인한 오탐(중복)을 프론트에서 우회하기 위해 사용한다.
const currentValues = {
    nickname: nicknameInput.value.trim(),
    phone: phoneInput.value.trim(),
    email: emailInput.value.trim()
};

// 중복확인을 통과한 값을 담아둔다. null이면 아직 확인 안 된 상태라 저장이 막힌다.
const checked = { nickname: null, phone: null, email: null };

/* ---- 중복확인 3종(닉네임/휴대폰/이메일) ----
   셋의 흐름이 완전히 같아서(빈값 검사 -> 기존값과 동일한지 -> 형식 검사 -> 서버 조회)
   설정만 바꿔 끼우는 하나의 헬퍼로 묶었다. */
function setupDuplicateCheck(config) {
    const input = config.input;
    const msgEl = document.querySelector(config.msgSelector);

    // 값을 다시 고치면 이전 확인 결과는 무효로 되돌린다.
    input.addEventListener("input", function () {
        msgEl.textContent = "";
        checked[config.field] = null;
    });

    document.querySelector(config.buttonSelector).addEventListener("click", async function () {
        const value = input.value.trim();

        if (value.length === 0) {
            showMessage(msgEl, config.emptyMessage, false);
            checked[config.field] = null;
            return;
        }

        if (value === currentValues[config.field]) {
            showMessage(msgEl, "기존 정보와 동일합니다.", true);
            checked[config.field] = value;
            return;
        }

        if (config.regex && !config.regex.test(value)) {
            showMessage(msgEl, config.formatMessage, false);
            checked[config.field] = null;
            return;
        }

        try {
            // result.data === true 가 "이미 사용 중"(중복)을 뜻한다.
            const result = await config.check(value);
            showMessage(msgEl, result.message, !result.data);
            checked[config.field] = result.data ? null : value;
        } catch (error) {
            console.log(error);
            showMessage(msgEl, "중복 확인 중 오류가 발생했습니다.", false);
            checked[config.field] = null;
        }
    });
}

function showMessage(el, text, isSuccess) {
    el.textContent = text;
    el.className = isSuccess ? "msg-success" : "msg-error";
}

setupDuplicateCheck({
    field: "nickname",
    input: nicknameInput,
    buttonSelector: "#nicknameCheckBtn",
    msgSelector: "#nicknameCheckMsg",
    emptyMessage: "닉네임을 입력해주세요.",
    check: function (v) { return window.MemberService.checkNickname(v); }
});

setupDuplicateCheck({
    field: "phone",
    input: phoneInput,
    buttonSelector: "#phoneCheckBtn",
    msgSelector: "#phoneCheckMsg",
    emptyMessage: "연락처를 입력해주세요.",
    regex: /^01[0-9]{8,9}$/,
    formatMessage: "올바른 전화번호 형식이 아닙니다.",
    check: function (v) { return window.MemberService.checkPhone(v); }
});

setupDuplicateCheck({
    field: "email",
    input: emailInput,
    buttonSelector: "#emailCheckBtn",
    msgSelector: "#emailCheckMsg",
    emptyMessage: "이메일을 입력해주세요.",
    regex: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
    formatMessage: "올바른 이메일 형식이 아닙니다.",
    check: function (v) { return window.MemberService.checkEmail(v); }
});

// 휴대폰 번호는 숫자만 남긴다.
phoneInput.addEventListener("input", function () {
    this.value = this.value.replace(/[^0-9]/g, '');
});

/* ---- 새 비밀번호 (선택 입력 - 비워두면 변경하지 않음) ---- */
const newPassword = document.querySelector("#newPassword");
const newPasswordConfirm = document.querySelector("#newPasswordConfirm");
const pwRegCheckMsg = document.querySelector("#pwRegCheckMsg");
const pwCheckMsg = document.querySelector("#pwCheckMsg");

let checkPw = true; // 기본값: 비밀번호를 변경하지 않는 것도 통과로 간주

function validateNewPassword() {
    const pwRegex = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$/;

    pwRegCheckMsg.textContent = "";
    pwCheckMsg.textContent = "";

    if (!newPassword.value && !newPasswordConfirm.value) {
        checkPw = true;
        return;
    }

    let checkReg = false;
    if (pwRegex.test(newPassword.value)) {
        checkReg = true;
    } else {
        showMessage(pwRegCheckMsg, "영어와 숫자, 특수문자가 최소 하나씩 들어가는 8~16자로 입력해주세요.", false);
    }

    if (!newPasswordConfirm.value.trim()) {
        checkPw = false;
        return;
    }

    const checkMatch = newPassword.value === newPasswordConfirm.value;
    checkPw = checkReg && checkMatch;

    showMessage(
        pwCheckMsg,
        checkPw ? "비밀번호가 정상적으로 확인되었습니다."
                : (!checkReg ? "비밀번호의 형식을 확인해주세요." : "입력하신 비밀번호가 동일하지 않습니다."),
        checkPw
    );
}

newPassword.addEventListener("input", validateNewPassword);
newPasswordConfirm.addEventListener("input", validateNewPassword);

/* ---- 항목 펼침/접힘 (탭하면 하위에서 수정) ---- */
document.querySelectorAll(".info-edit-header[aria-expanded]").forEach(function (btn) {
    btn.addEventListener("click", function () {
        const expanded = btn.getAttribute("aria-expanded") === "true";
        btn.setAttribute("aria-expanded", String(!expanded));
        const panel = btn.nextElementSibling;
        if (panel) panel.hidden = expanded;
    });
});

function collapsePanel(panel) {
    panel.hidden = true;
    const header = panel.previousElementSibling;
    if (header) header.setAttribute("aria-expanded", "false");
}

// 취소 시 되돌릴 기준값을 각 입력창에 미리 저장해둔다.
document.querySelectorAll(".info-edit-panel input[type=text], .info-edit-panel input[type=date], .info-edit-panel input[type=tel], .info-edit-panel input[type=email]").forEach(function (input) {
    input.dataset.currentValue = input.value;
});
document.querySelectorAll(".info-edit-panel input[type=radio]").forEach(function (radio) {
    radio.dataset.currentChecked = String(radio.checked);
});

/* ---- 항목별 취소: 입력값을 현재 표시값으로 되돌리고 패널을 접는다 ---- */
document.querySelectorAll(".btn-cancel-edit").forEach(function (btn) {
    btn.addEventListener("click", function () {
        const panel = btn.closest(".info-edit-panel");

        panel.querySelectorAll("input[type=text], input[type=date], input[type=tel], input[type=email], input[type=password]").forEach(function (input) {
            if (input.type === "password") {
                input.value = "";
            } else if (input.dataset.currentValue !== undefined) {
                input.value = input.dataset.currentValue;
            }
        });
        panel.querySelectorAll("input[type=radio]").forEach(function (radio) {
            radio.checked = radio.dataset.currentChecked === "true";
        });
        panel.querySelectorAll(".msg-success, .msg-error").forEach(function (msg) {
            msg.textContent = "";
            msg.className = "";
        });

        collapsePanel(panel);
    });
});

/* ---- 항목별 저장 ----
   중복확인이 필요한 3개 항목(닉네임/휴대폰/이메일)은 흐름이 같아서 한 곳에서 처리하고,
   나머지는 항목마다 검증/표시 규칙이 달라 개별 분기로 둔다. */
const CHECKED_FIELDS = {
    nickname: { input: nicknameInput, display: "#current-nickname", alert: "닉네임 중복확인을 진행해주세요." },
    phone:    { input: phoneInput,    display: "#current-phone",    alert: "휴대폰 번호 중복확인을 진행해주세요." },
    email:    { input: emailInput,    display: "#current-email",    alert: "이메일 중복확인을 진행해주세요." }
};

document.querySelectorAll(".btn-save-field").forEach(function (btn) {
    btn.addEventListener("click", function () {
        const field = btn.dataset.field;
        const panel = btn.closest(".info-edit-panel");

        if (CHECKED_FIELDS[field]) {
            const conf = CHECKED_FIELDS[field];
            const value = checked[field];
            if (!value) { alert(conf.alert); return; }

            currentValues[field] = value;
            document.querySelector(conf.display).textContent = value;
            conf.input.dataset.currentValue = value;
            collapsePanel(panel);

        } else if (field === "name") {
            const value = document.querySelector("#member_name").value.trim();
            if (!value) { alert("이름을 입력해주세요."); return; }
            document.querySelector("#current-name").textContent = value;
            document.querySelector("#member_name").dataset.currentValue = value;
            collapsePanel(panel);

        } else if (field === "birth") {
            const value = document.querySelector("#birth").value;
            document.querySelector("#current-birth").textContent = value;
            document.querySelector("#birth").dataset.currentValue = value;
            collapsePanel(panel);

        } else if (field === "gender") {
            const male = document.querySelector("#gender-male");
            const female = document.querySelector("#gender-female");
            document.querySelector("#current-gender").textContent = male.checked ? "남성" : "여성";
            male.dataset.currentChecked = String(male.checked);
            female.dataset.currentChecked = String(female.checked);
            collapsePanel(panel);

        } else if (field === "password") {
            if (!checkPw) { alert("새 비밀번호 형식을 확인하거나 일치 여부를 확인해주세요."); return; }
            newPassword.value = "";
            newPasswordConfirm.value = "";
            pwRegCheckMsg.textContent = "";
            pwCheckMsg.textContent = "";
            collapsePanel(panel);

        } else if (field === "address") {
            const addressName = document.querySelector("#addressName").value.trim();
            const detailAddress = document.querySelector("#detailAddress").value.trim();
            const isDefault = document.querySelector("#isDefaultAddress").checked;

            if (!addressName || !detailAddress) {
                alert("배송지 이름과 상세 주소를 모두 입력해주세요.");
                return;
            }

            let summary = addressName + " · " + detailAddress;
            if (isDefault) summary += " (기본 배송지)";
            document.querySelector("#current-address").textContent = summary;

            document.querySelector("#addressName").dataset.currentValue = addressName;
            document.querySelector("#detailAddress").dataset.currentValue = detailAddress;
            collapsePanel(panel);
        }
    });
});

/* ---- 회원 탈퇴 ---- */
// TODO(server binding): 확인 후 탈퇴 완료 안내 화면(member/userWithdraw)으로 이동만 한다.
// 백엔드 POST /member/withdraw(#BE014)가 이미 있으므로, 연동 시 확인 이후 이 위치에서 먼저
// 요청을 보내고 성공 응답을 받은 뒤에만 이동하도록 바꿔야 한다.
const withdrawLink = document.querySelector("#withdrawLink");
if (withdrawLink) {
    withdrawLink.addEventListener("click", function (e) {
        e.preventDefault();
        if (confirm("정말로 회원 탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) {
            window.location.href = this.href;
        }
    });
}
