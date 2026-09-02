/* 회원정보 수정 페이지 - 구글 계정 정보 화면처럼 항목을 탭하면 하위 패널에서 수정/저장한다.
   중복확인 및 회원정보 수정 서버 통신은 member/memberService.js(window.MemberService)가 담당하고,
   이 파일은 DOM 인터랙션과 입력값 검증을 담당한다.

   이름/생년월일/성별/닉네임/휴대폰/이메일/비밀번호는 저장 시 실제 서버 API를 호출한다.
   서버 저장 성공 후에만 화면의 현재값을 갱신하고 패널을 닫는다.

   배송지(address)는 아직 대응하는 백엔드가 없어 화면에서만 처리한다.
*/


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

function setupDuplicateCheck(config) {
    const input = config.input;
    const msgEl = document.querySelector(config.msgSelector);

    input.addEventListener("input", function () {
        msgEl.textContent = "";
        checked[config.field] = null;
    });

    document.querySelector(config.buttonSelector).addEventListener("click", async function () {
        const value = input.value.trim();

        // 이메일처럼 빈 값을 허용하는 항목
        if (value.length === 0 && config.allowEmpty) {
            showMessage(msgEl, "이메일을 입력하지 않고 비워둘 수 있습니다.", true);
            checked[config.field] = "";
            return;
        }

        // 일반적인 필수 항목
		if (value.length === 0 && config.allowEmpty) {
		    showMessage(msgEl, "이메일을 입력하지 않고 비워둘 수 있습니다.", true);
		    checked[config.field] = "";
		    return;
		}

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
    allowEmpty: true,
    regex: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
    formatMessage: "올바른 이메일 형식이 아닙니다.",
    check: function (v) {
        return window.MemberService.checkEmail(v);
    }
});

// 휴대폰 번호는 숫자만 남긴다.
phoneInput.addEventListener("input", function () {
    this.value = this.value.replace(/[^0-9]/g, '');
});

/* ---- 새 비밀번호 (선택 입력 - 비워두면 변경하지 않음) ---- */
const currentPassword = document.querySelector("#currentPassword");
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
   저장 버튼을 누르면 해당 API를 호출하고,
   서버 저장에 성공한 경우에만 화면의 현재값을 갱신하고 패널을 닫는다.

   닉네임/휴대폰/이메일은 저장 전에 중복확인이 필요하다.
*/
const CHECKED_FIELDS = {
    nickname: {
        input: nicknameInput,
        display: "#current-nickname",
        alert: "닉네임 중복확인을 진행해주세요.",
        update: function (value) {
            return window.MemberService.updateNickname(value);
        }
    },

    phone: {
        input: phoneInput,
        display: "#current-phone",
        alert: "휴대폰 번호 중복확인을 진행해주세요.",
        update: function (value) {
            return window.MemberService.updatePhone(value);
        }
    },

	email: {
	        input: emailInput,
	        display: "#current-email",
	        alert: "이메일 중복확인을 진행해주세요.",
	        allowEmpty: true,
	        update: function (value) {
	            return window.MemberService.updateEmail(value);
	        }
	    }
};

document.querySelectorAll(".btn-save-field").forEach(function (btn) {

    btn.addEventListener("click", async function () {

        const field = btn.dataset.field;
        const panel = btn.closest(".info-edit-panel");

        /* --------------------------------
           닉네임 / 휴대폰 / 이메일
           -------------------------------- */
        if (CHECKED_FIELDS[field]) {

            const conf = CHECKED_FIELDS[field];
			const value = checked[field];

			if (!value && !conf.allowEmpty) {
			    alert(conf.alert);
			    return;
			}

            try {

                const result = await conf.update(value);

                if (!result.data) {
                    alert(result.message || "정보 변경에 실패했습니다.");
                    return;
                }
				
				alert(result.message || "정보가 변경되었습니다.");

                // 서버 저장 성공 후 화면 갱신
                currentValues[field] = value;
				document.querySelector(conf.display).textContent =
				    field === "email" && !value ? "등록된 이메일 없음" : value;
                conf.input.dataset.currentValue = value;

                collapsePanel(panel);

            } catch (error) {

                console.error(error);
                alert("정보 변경 중 오류가 발생했습니다.");
            }

        /* --------------------------------
           이름
           -------------------------------- */
        } else if (field === "name") {

            const input = document.querySelector("#member_name");
            const value = input.value.trim();

            if (!value) {
                alert("이름을 입력해주세요.");
                return;
            }

            try {

                const result = await window.MemberService.updateName(value);

                if (!result.data) {
                    alert(result.message || "정보 변경에 실패했습니다.");
                    return;
                }
				
				alert(result.message || "정보가 변경되었습니다.");

                document.querySelector("#current-name").textContent = value;
                input.dataset.currentValue = value;

                collapsePanel(panel);

            } catch (error) {

                console.error(error);
                alert("이름 변경 중 오류가 발생했습니다.");
            }

        /* --------------------------------
           생년월일
           -------------------------------- */
        } else if (field === "birth") {

            const input = document.querySelector("#birth");
            const value = input.value;

            if (!value) {
                alert("생년월일을 입력해주세요.");
                return;
            }

            try {

                const result = await window.MemberService.updateBirth(value);

                if (!result.data) {
                    alert(result.message || "정보 변경에 실패했습니다.");
                    return;
                }
				
				alert(result.message || "정보가 변경되었습니다.");

                document.querySelector("#current-birth").textContent = value;
                input.dataset.currentValue = value;

                collapsePanel(panel);

            } catch (error) {

                console.error(error);
                alert("생년월일 변경 중 오류가 발생했습니다.");
            }

        /* --------------------------------
           성별
           -------------------------------- */
        } else if (field === "gender") {

            const male = document.querySelector("#gender-male");
            const female = document.querySelector("#gender-female");

            const value = male.checked ? "M" : "F";

            try {

                const result = await window.MemberService.updateGender(value);

                if (!result.data) {
                    alert(result.message || "정보 변경에 실패했습니다.");
                    return;
                }
				
				alert(result.message || "정보가 변경되었습니다.");

                document.querySelector("#current-gender").textContent =
                    value === "M" ? "남성" : "여성";

                male.dataset.currentChecked = String(male.checked);
                female.dataset.currentChecked = String(female.checked);

                collapsePanel(panel);

            } catch (error) {

                console.error(error);
                alert("성별 변경 중 오류가 발생했습니다.");
            }

        /* --------------------------------
           비밀번호
           -------------------------------- */
        } else if (field === "password") {

            // 새 비밀번호를 둘 다 비워두면 변경하지 않음
            if (!newPassword.value && !newPasswordConfirm.value) {
                collapsePanel(panel);
                return;
            }

            // 새 비밀번호를 변경하는 경우 현재 비밀번호 필수
            if (!currentPassword.value.trim()) {
                alert("현재 비밀번호를 입력해주세요.");
                return;
            }

            // 새 비밀번호 형식/일치 검사
            if (!checkPw) {
                alert("새 비밀번호 형식 또는 일치 여부를 확인해주세요.");
                return;
            }

            try {

                const result = await window.MemberService.updatePassword(
                    currentPassword.value,
                    newPassword.value
                );

                if (!result.data) {
                    alert(result.message || "비밀번호 변경에 실패했습니다.");
                    return;
                }

                alert(result.message || "비밀번호가 변경되었습니다.");

                currentPassword.value = "";
                newPassword.value = "";
                newPasswordConfirm.value = "";

                pwRegCheckMsg.textContent = "";
                pwCheckMsg.textContent = "";

                collapsePanel(panel);

            } catch (error) {

                console.error(error);
                alert("비밀번호 변경 중 오류가 발생했습니다.");
            }

        /* --------------------------------
           배송지
           -------------------------------- */
        } else if (field === "address") {

            const addressName =
                document.querySelector("#addressName").value.trim();

            const detailAddress =
                document.querySelector("#detailAddress").value.trim();

            const isDefault =
                document.querySelector("#isDefaultAddress").checked;

            if (!addressName || !detailAddress) {
                alert("배송지 이름과 상세 주소를 모두 입력해주세요.");
                return;
            }

            // 배송지는 아직 백엔드가 없으므로 화면에서만 처리
            let summary = addressName + " · " + detailAddress;

            if (isDefault) {
                summary += " (기본 배송지)";
            }

            document.querySelector("#current-address").textContent = summary;

            document.querySelector("#addressName")
                .dataset.currentValue = addressName;

            document.querySelector("#detailAddress")
                .dataset.currentValue = detailAddress;

            collapsePanel(panel);
        }
    });
});


/* ---- 회원 탈퇴 ---- */
const withdrawLink = document.querySelector("#withdrawLink");

if (withdrawLink) {
    withdrawLink.addEventListener("click", async function (e) {
        e.preventDefault();

        if (!confirm("정말로 회원 탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) {
            return;
        }

        try {
            const result = await window.MemberService.withdraw();

            if (!result.data) {
                alert(result.message || "회원 탈퇴에 실패했습니다.");
                return;
            }

            alert(result.message || "회원 탈퇴가 완료되었습니다.");

            // 탈퇴 성공 후 탈퇴 완료 페이지로 이동
            window.location.href = this.href;

        } catch (error) {
            console.error(error);
            alert("회원 탈퇴 처리 중 오류가 발생했습니다.");
        }
    });

}
