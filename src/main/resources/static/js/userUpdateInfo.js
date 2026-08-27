/* 회원정보 수정 페이지 — 구글 계정 정보 화면처럼 항목을 탭하면 하위에서 수정/저장한다. */

// TODO(data binding): 실제 저장(UPDATE) 백엔드가 없어 "저장" 버튼은 화면 표시값만 갱신하는
// no-op이다. 배송지는 대응하는 테이블(DeliveryAddress) 백엔드 자체가 없어 완전히 목업이다.

const nicknameInput = document.querySelector("#nickname");
const phoneInput = document.querySelector("#phone");
const emailInput = document.querySelector("#email");

// 저장에 성공할 때마다 갱신되는 "현재 값" 기준점 — 중복확인 시 이 값과 같으면
// 서버의 "본인 제외" 로직 부재로 인한 오탐(중복)을 프론트에서 우회하기 위해 사용한다.
const currentValues = {
    nickname: nicknameInput.value.trim(),
    phone: phoneInput.value.trim(),
    email: emailInput.value.trim()
};

let checkNickname = null;
let checkPhone = null;
let checkEmail = null;

function resetCheckOnInput(input, msgEl, resetter) {
    input.addEventListener("input", function () {
        msgEl.textContent = "";
        resetter(null);
    });
}

const nicknameCheckResult = document.querySelector("#nicknameCheckMsg");
resetCheckOnInput(nicknameInput, nicknameCheckResult, function (v) { checkNickname = v; });

const phoneCheckResult = document.querySelector("#phoneCheckMsg");
resetCheckOnInput(phoneInput, phoneCheckResult, function (v) { checkPhone = v; });

const emailCheckResult = document.querySelector("#emailCheckMsg");
resetCheckOnInput(emailInput, emailCheckResult, function (v) { checkEmail = v; });

phoneInput.addEventListener("input", function () {
    this.value = this.value.replace(/[^0-9]/g, '');
});

// 닉네임 중복확인
document.querySelector("#nicknameCheckBtn").addEventListener("click", async function () {
    const nickname = nicknameInput.value.trim();

    if (nickname.length === 0) {
        nicknameCheckResult.textContent = "닉네임을 입력해주세요.";
        nicknameCheckResult.className = "msg-error";
        checkNickname = null;
        return;
    }

    if (nickname === currentValues.nickname) {
        nicknameCheckResult.textContent = "기존 정보와 동일합니다.";
        nicknameCheckResult.className = "msg-success";
        checkNickname = nickname;
        return;
    }

    try {
        const response = await fetch("/member/checkNickname?nickname=" + encodeURIComponent(nickname), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });
        const result = await response.json();

        nicknameCheckResult.textContent = result.message;
        nicknameCheckResult.className = result.data ? "msg-error" : "msg-success";
        checkNickname = result.data ? null : nickname;
    } catch (error) {
        console.log(error);
        nicknameCheckResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        nicknameCheckResult.className = "msg-error";
        checkNickname = null;
    }
});

// 휴대폰 번호 중복확인
document.querySelector("#phoneCheckBtn").addEventListener("click", async function () {
    const phone = phoneInput.value.trim();

    if (phone.length === 0) {
        phoneCheckResult.textContent = "연락처를 입력해주세요.";
        phoneCheckResult.className = "msg-error";
        checkPhone = null;
        return;
    }

    if (phone === currentValues.phone) {
        phoneCheckResult.textContent = "기존 정보와 동일합니다.";
        phoneCheckResult.className = "msg-success";
        checkPhone = phone;
        return;
    }

    const phoneRegex = /^01[0-9]{8,9}$/;
    if (!phoneRegex.test(phone)) {
        phoneCheckResult.textContent = "올바른 전화번호 형식이 아닙니다.";
        phoneCheckResult.className = "msg-error";
        checkPhone = null;
        return;
    }

    try {
        const response = await fetch("/member/checkPhone?phone=" + encodeURIComponent(phone), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });
        const result = await response.json();

        phoneCheckResult.textContent = result.message;
        phoneCheckResult.className = result.data ? "msg-error" : "msg-success";
        checkPhone = result.data ? null : phone;
    } catch (error) {
        console.log(error);
        phoneCheckResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        phoneCheckResult.className = "msg-error";
        checkPhone = null;
    }
});

// 이메일 중복확인
document.querySelector("#emailCheckBtn").addEventListener("click", async function () {
    const email = emailInput.value.trim();

    if (email.length === 0) {
        emailCheckResult.textContent = "이메일을 입력해주세요.";
        emailCheckResult.className = "msg-error";
        checkEmail = null;
        return;
    }

    if (email === currentValues.email) {
        emailCheckResult.textContent = "기존 정보와 동일합니다.";
        emailCheckResult.className = "msg-success";
        checkEmail = email;
        return;
    }

    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
        emailCheckResult.textContent = "올바른 이메일 형식이 아닙니다.";
        emailCheckResult.className = "msg-error";
        checkEmail = null;
        return;
    }

    try {
        const response = await fetch("/member/checkEmail?email=" + encodeURIComponent(email), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });
        const result = await response.json();

        emailCheckResult.textContent = result.message;
        emailCheckResult.className = result.data ? "msg-error" : "msg-success";
        checkEmail = result.data ? null : email;
    } catch (error) {
        console.log(error);
        emailCheckResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        emailCheckResult.className = "msg-error";
        checkEmail = null;
    }
});

// 새 비밀번호 (선택 입력 — 비워두면 변경하지 않음)
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
        pwRegCheckMsg.textContent = "영어와 숫자, 특수문자가 최소 하나씩 들어가는 8~16자로 입력해주세요.";
        pwRegCheckMsg.className = "msg-error";
    }

    if (!newPasswordConfirm.value.trim()) {
        checkPw = false;
        return;
    }

    const checkMatch = newPassword.value === newPasswordConfirm.value;
    checkPw = checkReg && checkMatch;

    pwCheckMsg.textContent = checkPw ? "비밀번호가 정상적으로 확인되었습니다." : (!checkReg ? "비밀번호의 형식을 확인해주세요." : "입력하신 비밀번호가 동일하지 않습니다.");
    pwCheckMsg.className = checkPw ? "msg-success" : "msg-error";
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

// 취소 시 되돌릴 기준값을 각 입력창에 저장해둔다.
document.querySelectorAll(".info-edit-panel input[type=text], .info-edit-panel input[type=date], .info-edit-panel input[type=tel], .info-edit-panel input[type=email]").forEach(function (input) {
    input.dataset.currentValue = input.value;
});
document.querySelectorAll(".info-edit-panel input[type=radio]").forEach(function (radio) {
    radio.dataset.currentChecked = String(radio.checked);
});

/* ---- 항목별 저장 ---- */
document.querySelectorAll(".btn-save-field").forEach(function (btn) {
    btn.addEventListener("click", function () {
        const field = btn.dataset.field;
        const panel = btn.closest(".info-edit-panel");

        if (field === "name") {
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

        } else if (field === "nickname") {
            if (!checkNickname) { alert("닉네임 중복확인을 진행해주세요."); return; }
            currentValues.nickname = checkNickname;
            document.querySelector("#current-nickname").textContent = checkNickname;
            nicknameInput.dataset.currentValue = checkNickname;
            collapsePanel(panel);

        } else if (field === "password") {
            if (!checkPw) { alert("새 비밀번호 형식을 확인하거나 일치 여부를 확인해주세요."); return; }
            newPassword.value = "";
            newPasswordConfirm.value = "";
            pwRegCheckMsg.textContent = "";
            pwCheckMsg.textContent = "";
            collapsePanel(panel);

        } else if (field === "phone") {
            if (!checkPhone) { alert("휴대폰 번호 중복확인을 진행해주세요."); return; }
            currentValues.phone = checkPhone;
            document.querySelector("#current-phone").textContent = checkPhone;
            phoneInput.dataset.currentValue = checkPhone;
            collapsePanel(panel);

        } else if (field === "email") {
            if (!checkEmail) { alert("이메일 중복확인을 진행해주세요."); return; }
            currentValues.email = checkEmail;
            document.querySelector("#current-email").textContent = checkEmail;
            emailInput.dataset.currentValue = checkEmail;
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
// TODO(data binding): 실제 탈퇴(회원 삭제/비활성화 + 세션 무효화) 백엔드가 없어, 확인 후 바로
// 탈퇴 완료 안내 화면(member/userWithdraw)으로 이동만 한다. 실제 구현 시 확인 이후 이 위치에서
// POST /member/withdraw 요청을 먼저 보내고, 성공 응답을 받은 뒤에만 이동하도록 바꿔야 한다.
const withdrawLink = document.querySelector("#withdrawLink");
if (withdrawLink) {
    withdrawLink.addEventListener("click", function (e) {
        e.preventDefault();
        if (confirm("정말로 회원 탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) {
            window.location.href = this.href;
        }
    });
}
