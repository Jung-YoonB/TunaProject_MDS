/* 회원가입 페이지 */

// css 용 클래스 msg-success, msg-error 로 틀만 잡아둠. 나중에 교체.

// 비밀번호 일치 여부 확인
const loginPw = document.querySelector("#loginPw");  // 비밀번호 입력창
const loginPwConfirm = document.querySelector("#loginPwConfirm"); // 비밀번호 확인 입력창

let checkReg = false; // 정규식 일치 여부 확인용
let checkPw = false; // 비밀번호 일치 여부 확인용

function validatePassword() {
    const confirmRegResult = document.querySelector("#pwRegCheckMsg");
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
        confirmRegResult.className = "msg-error";
        checkReg = false;
    }

    const confirmResult = document.querySelector("#pwCheckMsg");
    confirmResult.textContent = "";

    // 비밀번호 확인 입력창이 비어있을 경우 검사 x
    if (!loginPwConfirm.value.trim()) {
        checkPw = false;
        return;
    }

    let checkMatch = loginPw.value === loginPwConfirm.value;
    checkPw = checkReg && checkMatch;

    // 2. 삼항 연산자 문구 유지 및 클래스 동기화
    confirmResult.textContent = checkPw ? "비밀번호가 정상적으로 확인되었습니다." : (!checkReg ? "비밀번호의 형식을 확인해주세요." : "입력하신 비밀번호가 동일하지 않습니다.");
    // checkPw(최종 성공)일 때만 초록색(msg-success) 부여
    confirmResult.className = checkPw ? "msg-success" : "msg-error";
}

loginPw.addEventListener('input', validatePassword);
loginPwConfirm.addEventListener('input', validatePassword);

let checkId = null;   // 아이디 중복체크 값
const checkIdResult = document.querySelector("#idCheckMsg");
const loginIdInput = document.querySelector("#loginId");
loginIdInput.addEventListener("input", function() {
    checkIdResult.textContent = "";
    checkId = null;
});

// 아이디 중복확인 버튼의 클릭 이벤트 리스너 추가
const idCheckBtn = document.querySelector("#idCheckBtn");
idCheckBtn.addEventListener("click", async function() {
    const loginId = loginIdInput.value.trim();
    // 아이디 값이 입력되지 않았을 경우, 요청 x
    if (loginId.length === 0) {
        checkIdResult.textContent = "아이디를 입력해주세요.";
        checkIdResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용
        checkId = null;
        return;
    }

    const idRegex = /^[a-z][a-z0-9]{5,19}$/;
    if (!idRegex.test(loginId)) {
        checkIdResult.textContent = "첫글자를 영어로 하는 6~20자로 입력해주세요.";
        checkIdResult.className = "msg-error";
        checkId = null;
        return;
    }


    // 입력된 아이디값이 중복되는 지 서버로 요청
    try {
        const response = await fetch("/member/checkId?loginId=" + encodeURIComponent(loginId), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });

        // response.json() : json 응답을 자바스크립트 객체로 변경
        const result = await response.json();

        // console.log(result);
        checkIdResult.textContent = result.message;
        checkIdResult.className = result.data ? "msg-error" : "msg-success"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용 

        checkId = result.data ? null : loginId;
    } catch (error) {
        console.log(error);

        checkIdResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkIdResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용

        checkId = null;
    }

});

let checkNickname = null;   // 닉네임 중복체크 값
const checkNicknameResult = document.querySelector("#nicknameCheckMsg");
const nicknameInput = document.querySelector("#nickname");
nicknameInput.addEventListener("input", function() {
    checkNicknameResult.textContent = "";
    checkNickname = null;
});

// 닉네임 중복확인 버튼의 클릭 이벤트 리스너 추가
const nicknameCheckBtn = document.querySelector("#nicknameCheckBtn");
nicknameCheckBtn.addEventListener("click", async function() {
    const nickname = nicknameInput.value.trim();
    // 닉네임 값이 입력되지 않았을 경우, 요청 x
    if (nickname.length === 0) {
        checkNicknameResult.textContent = "닉네임을 입력해주세요.";
        checkNicknameResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용
        checkNickname = null;
        return;
    }

    // 입력된 닉네임값이 중복되는 지 서버로 요청
    try {
        const response = await fetch("/member/checkNickname?nickname=" + encodeURIComponent(nickname), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });

        const result = await response.json();

        checkNicknameResult.textContent = result.message;
        checkNicknameResult.className = result.data ? "msg-error" : "msg-success"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용 

        checkNickname = result.data ? null : nickname;
    } catch (error) {
        console.log(error);

        checkNicknameResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkNicknameResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용

        checkNickname = null;
    }

});

let checkEmail = null;   // 이메일 중복체크 값
const checkEmailResult = document.querySelector("#emailCheckMsg");
const emailInput = document.querySelector("#email");
emailInput.addEventListener("input", function() {
    checkEmailResult.textContent = "";
    checkEmail = null;
});

const emailCheckBtn = document.querySelector("#emailCheckBtn");
emailCheckBtn.addEventListener("click", async function() {
    const email = emailInput.value.trim();

    if (email.length === 0) {
        checkEmailResult.textContent = "이메일을 입력해주세요.";
        checkEmailResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용
        checkEmail = null;
        return;
    }

    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
        checkEmailResult.textContent = "올바른 이메일 형식이 아닙니다.";
        checkEmailResult.className = "msg-error";
        checkEmail = null;
        return;
    }

    try {
        const response = await fetch("/member/checkEmail?email=" + encodeURIComponent(email), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });

        const result = await response.json();

        checkEmailResult.textContent = result.message;
        checkEmailResult.className = result.data ? "msg-error" : "msg-success"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용 

        checkEmail = result.data ? null : email;
    } catch (error) {
        console.log(error);

        checkEmailResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkEmailResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용

        checkEmail = null;
    }

});

let checkPhone = null;   // 연락처 중복체크 값
const checkPhoneResult = document.querySelector("#phoneCheckMsg");
const phoneInput = document.querySelector("#phone");
phoneInput.addEventListener("input", function() {
    this.value = this.value.replace(/[^0-9]/g, '');  // 숫자 이외의 입력 막기
    checkPhoneResult.textContent = "";
    checkPhone = null;
});

const phoneCheckBtn = document.querySelector("#phoneCheckBtn");
phoneCheckBtn.addEventListener("click", async function() {
    const phone = phoneInput.value.trim();

    if (phone.length === 0) {
        checkPhoneResult.textContent = "연락처를 입력해주세요.";
        checkPhoneResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용
        checkPhone = null;
        return;
    }

    const phoneRegex = /^01[0-9]{8,9}$/;
    if (!phoneRegex.test(phone)) {
        checkPhoneResult.textContent = "올바른 전화번호 형식이 아닙니다.";
        checkPhoneResult.className = "msg-error";
        checkPhone = null;
        return;
    }

    try {
        const response = await fetch("/member/checkPhone?phone=" + encodeURIComponent(phone), {
            method: "GET",
            headers: { "X-Requested-With": "XMLHttpRequest" }
        });

        const result = await response.json();

        checkPhoneResult.textContent = result.message;
        checkPhoneResult.className = result.data ? "msg-error" : "msg-success"; // 성공 실패에 따른 css 적용을 위한 클래스 추가용 

        checkPhone = result.data ? null : phone;
    } catch (error) {
        console.log(error);

        checkPhoneResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkPhoneResult.className = "msg-error"; // 오류용 css 적용을 위한 클래스 추가용

        checkPhone = null;
    }

});


const signUpForm = document.querySelector("#signUpForm");
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