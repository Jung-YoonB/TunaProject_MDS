/* 회원가입 페이지 인터랙션 - 중복확인 서버 통신은 member/memberService.js에 위임 */

// 비밀번호 일치 여부 확인
const loginPw = document.querySelector("#login_pw");  // 비밀번호 입력창
const loginPwConfirm = document.querySelector("#login_pw_confirm"); // 비밀번호 확인 입력창

let checkReg = false; // 정규식 일치 여부 확인용
let checkPw = false; // 비밀번호 일치 여부 확인용

function validatePassword() {
    const confirmRegResult = document.querySelector("#pw-reg-check-notice");
    confirmRegResult.textContent = "";
    const pwRegex = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$/;

    // 1. 비밀번호 입력 여부 및 정규식 검사
    if (loginPw.value.length === 0) {
        confirmRegResult.textContent = "";
        checkReg = false;
    } else if (pwRegex.test(loginPw.value)) {
        checkReg = true;
    } else {
        confirmRegResult.textContent = "영어와 숫자, 특수문자가 최소 하나씩 들어가는 8~16자로 입력해주세요.";
        confirmRegResult.className = "error-message";
        checkReg = false;
    }

    const confirmResult = document.querySelector("#pw-check-notice");
    confirmResult.textContent = "";

    // 비밀번호 확인 입력창이 비어있을 경우 검사 x
    if (!loginPwConfirm.value.trim()) {
        checkPw = false;
		confirmResult.textContent = "";
        return;
    }

    let checkMatch = loginPw.value === loginPwConfirm.value;
    checkPw = checkReg && checkMatch;

    // 2. 삼항 연산자 문구 유지 및 클래스 동기화
    confirmResult.textContent = checkPw ? "비밀번호가 정상적으로 확인되었습니다." : (!checkReg ? "비밀번호의 형식을 확인해주세요." : "입력하신 비밀번호가 동일하지 않습니다.");
    // checkPw(최종 성공)일 때만 초록색(msg-success) 부여
    confirmResult.className = checkPw ? "success-message" : "error-message";
}

loginPw.addEventListener('input', validatePassword);
loginPwConfirm.addEventListener('input', validatePassword);

let checkId = null;   // 아이디 중복체크 값
const checkIdResult = document.querySelector("#id-message");
const loginIdInput = document.querySelector("#login_id");
loginIdInput.addEventListener("input", function() {
    checkIdResult.textContent = "";
    checkId = null;
});

// 아이디 중복확인 버튼의 클릭 이벤트 리스너 추가
const idCheckBtn = document.querySelector("#CheckId");
idCheckBtn.addEventListener("click", async function() {
    const loginId = loginIdInput.value.trim();
    // 아이디 값이 입력되지 않았을 경우, 요청 x
    if (loginId.length === 0) {
        checkIdResult.textContent = "아이디를 입력해주세요.";
        checkIdResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용
        checkId = null;
        return;
    }

    const idRegex = /^[a-z][a-z0-9]{5,19}$/;
    if (!idRegex.test(loginId)) {
        checkIdResult.textContent = "첫글자를 영어로 하는 6~20자로 입력해주세요.";
        checkIdResult.className = "error-message";
        checkId = null;
        return;
    }

    // 입력된 아이디값이 중복되는 지 서버로 요청
    try {
        const result = await MemberService.checkId(loginId);

        checkIdResult.textContent = result.message;
        checkIdResult.className = result.data ? "error-message" : "success-message"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용

        checkId = result.data ? null : loginId;
    } catch (error) {
        console.log(error);

        checkIdResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkIdResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용

        checkId = null;
    }

});

let checkNickname = null;   // 닉네임 중복체크 값
const checkNicknameResult = document.querySelector("#nickname-message");
const nicknameInput = document.querySelector("#nickname");
nicknameInput.addEventListener("input", function() {
    checkNicknameResult.textContent = "";
    checkNickname = null;
});

// 닉네임 중복확인 버튼의 클릭 이벤트 리스너 추가
const nicknameCheckBtn = document.querySelector("#CheckNickname");
nicknameCheckBtn.addEventListener("click", async function() {
    const nickname = nicknameInput.value.trim();
    // 닉네임 값이 입력되지 않았을 경우, 요청 x
    if (nickname.length === 0) {
        checkNicknameResult.textContent = "닉네임을 입력해주세요.";
        checkNicknameResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용
        checkNickname = null;
        return;
    }

    // 입력된 닉네임값이 중복되는 지 서버로 요청
    try {
        const result = await MemberService.checkNickname(nickname);

        checkNicknameResult.textContent = result.message;
        checkNicknameResult.className = result.data ? "error-message" : "success-message"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용

        checkNickname = result.data ? null : nickname;
    } catch (error) {
        console.log(error);

        checkNicknameResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkNicknameResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용

        checkNickname = null;
    }

});

let checkEmail = null;   // 이메일 중복체크 값
const checkEmailResult = document.querySelector("#email-message");
const emailInput = document.querySelector("#email");
emailInput.addEventListener("input", function() {
    checkEmailResult.textContent = "";
    checkEmail = null;
});

const emailCheckBtn = document.querySelector("#CheckEmail");
emailCheckBtn.addEventListener("click", async function() {
    const email = emailInput.value.trim();

    if (email.length === 0) {
        checkEmailResult.textContent = "이메일을 입력해주세요.";
        checkEmailResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용
        checkEmail = null;
        return;
    }

    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
        checkEmailResult.textContent = "올바른 이메일 형식이 아닙니다.";
        checkEmailResult.className = "error-message";
        checkEmail = null;
        return;
    }

    try {
        const result = await MemberService.checkEmail(email);

        checkEmailResult.textContent = result.message;
        checkEmailResult.className = result.data ? "error-message" : "success-message"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용

        checkEmail = result.data ? null : email;
    } catch (error) {
        console.log(error);

        checkEmailResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkEmailResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용

        checkEmail = null;
    }

});

let checkPhone = null;   // 연락처 중복체크 값
const checkPhoneResult = document.querySelector("#phone-message");
const phoneInput = document.querySelector("#phone");
phoneInput.addEventListener("input", function() {
    this.value = this.value.replace(/[^0-9]/g, '');  // 숫자 이외의 입력 막기
    checkPhoneResult.textContent = "";
    checkPhone = null;
});

const phoneCheckBtn = document.querySelector("#CheckPhone");
phoneCheckBtn.addEventListener("click", async function() {
    const phone = phoneInput.value.trim();

    if (phone.length === 0) {
        checkPhoneResult.textContent = "연락처를 입력해주세요.";
        checkPhoneResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용
        checkPhone = null;
        return;
    }

    const phoneRegex = /^01[0-9]{8,9}$/;
    if (!phoneRegex.test(phone)) {
        checkPhoneResult.textContent = "올바른 전화번호 형식이 아닙니다.";
        checkPhoneResult.className = "error-message";
        checkPhone = null;
        return;
    }

    try {
        const result = await MemberService.checkPhone(phone);

        checkPhoneResult.textContent = result.message;
        checkPhoneResult.className = result.data ? "error-message" : "success-message"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용

        checkPhone = result.data ? null : phone;
    } catch (error) {
        console.log(error);

        checkPhoneResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkPhoneResult.className = "error-message"; // 오류용 css 적용을 위한 클래스 추가용

        checkPhone = null;
    }

});


const signUpForm = document.querySelector("#SignUpForm");
signUpForm.addEventListener("submit", function(e) {

    if (!checkId) {
        e.preventDefault();   // 폼 제출 막기
        alert("아이디 중복확인을 진행해주세요.");
        return;
    }

    if (!checkPw) {
        e.preventDefault();   // 폼 제출 막기
        alert("비밀번호 형식을 확인하거나 일치 여부를 확인해주세요.");
        return;
    }

    if (!checkNickname) {
        e.preventDefault();   // 폼 제출 막기
        alert("닉네임 중복확인을 진행해주세요.");
        return;
    }

    if (!checkEmail) {
        e.preventDefault();   // 폼 제출 막기
        alert("이메일 중복확인을 진행해주세요.");
        return;
    }

    if (!checkPhone) {
        e.preventDefault();   // 폼 제출 막기
        alert("연락처 중복확인을 진행해주세요.");
        return;
    }

});
