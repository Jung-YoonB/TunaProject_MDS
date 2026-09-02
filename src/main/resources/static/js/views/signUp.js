/* 회원가입 페이지 인터랙션
 * 중복확인 서버 통신은 member/memberService.js에 위임
 */


/* =========================================================
 * 비밀번호 검사
 * ========================================================= */

const loginPw = document.querySelector("#login_pw");
const loginPwConfirm = document.querySelector("#login_pw_confirm");

let checkReg = false;
let checkPw = false;

function validatePassword() {

    const confirmRegResult =
        document.querySelector("#pw-reg-check-notice");

    const confirmResult =
        document.querySelector("#pw-check-notice");

    const pwRegex =
        /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$/;


    /* 비밀번호 형식 검사 */

    if (loginPw.value.length === 0) {

        confirmRegResult.textContent = "";
        confirmRegResult.className = "";
        checkReg = false;

    } else if (pwRegex.test(loginPw.value)) {

        confirmRegResult.textContent = "";
        confirmRegResult.className = "";
        checkReg = true;

    } else {

        confirmRegResult.textContent =
            "비밀번호는 영어와 숫자, 특수문자가 최소 하나씩 들어가는 8~16자로 입력해주세요.";

        confirmRegResult.className = "error-message";
        checkReg = false;
    }


    /* 비밀번호 확인 */

    confirmResult.textContent = "";

    if (!loginPwConfirm.value.trim()) {

        checkPw = false;
        return;
    }


    const checkMatch =
        loginPw.value === loginPwConfirm.value;

    checkPw = checkReg && checkMatch;


    if (checkPw) {

        confirmResult.textContent =
            "비밀번호가 정상적으로 확인되었습니다.";

        confirmResult.className = "success-message";

    } else if (!checkReg) {

        confirmResult.textContent =
            "비밀번호의 형식을 확인해주세요.";

        confirmResult.className = "error-message";

    } else {

        confirmResult.textContent =
            "입력하신 비밀번호가 동일하지 않습니다.";

        confirmResult.className = "error-message";
    }
}

loginPw.addEventListener("input", validatePassword);
loginPwConfirm.addEventListener("input", validatePassword);


/* =========================================================
 * 아이디 중복확인
 * ========================================================= */

let checkId = null;

const checkIdResult =
    document.querySelector("#id-message");

const loginIdInput =
    document.querySelector("#login_id");


loginIdInput.addEventListener("input", function() {

    checkIdResult.textContent = "";
    checkIdResult.className = "";
    checkId = null;
});


const idCheckBtn =
    document.querySelector("#CheckId");


idCheckBtn.addEventListener("click", async function() {

    const loginId = loginIdInput.value.trim();


    /* 입력 여부 */

    if (loginId.length === 0) {

        checkIdResult.textContent =
            "아이디를 입력해주세요.";

        checkIdResult.className = "error-message";
        checkId = null;

        return;
    }


    /* DTO와 동일한 정규식 */

    const idRegex =
        /^[a-z][a-z0-9_]{5,19}$/;


    if (!idRegex.test(loginId)) {

        checkIdResult.textContent =
            "아이디는 영문 소문자로 시작하며, 영문 소문자·숫자·언더바(_)를 사용한 6~20자로 입력해주세요.";

        checkIdResult.className = "error-message";
        checkId = null;

        return;
    }


    /* 서버 중복확인 */

    try {

        const result =
            await MemberService.checkId(loginId);

        checkIdResult.textContent =
            result.message;

        checkIdResult.className =
            result.data
                ? "error-message"
                : "success-message";

        checkId =
            result.data
                ? null
                : loginId;

    } catch (error) {

        console.log(error);

        checkIdResult.textContent =
            "중복 확인 중 오류가 발생했습니다.";

        checkIdResult.className =
            "error-message";

        checkId = null;
    }
});


/* =========================================================
 * 닉네임 중복확인
 * ========================================================= */

let checkNickname = null;

const checkNicknameResult =
    document.querySelector("#nickname-message");

const nicknameInput =
    document.querySelector("#nickname");


nicknameInput.addEventListener("input", function() {

    checkNicknameResult.textContent = "";
    checkNicknameResult.className = "";
    checkNickname = null;
});


const nicknameCheckBtn =
    document.querySelector("#CheckNickname");


nicknameCheckBtn.addEventListener("click", async function() {

    const nickname =
        nicknameInput.value.trim();


    if (nickname.length === 0) {

        checkNicknameResult.textContent =
            "닉네임을 입력해주세요.";

        checkNicknameResult.className =
            "error-message";

        checkNickname = null;

        return;
    }


    /* DTO와 동일한 정규식 */

    const nicknameRegex =
        /^[가-힣a-zA-Z0-9_]{2,8}$/;


    if (!nicknameRegex.test(nickname)) {

        checkNicknameResult.textContent =
            "닉네임은 한글, 영문, 숫자, 언더바(_)를 사용하여 2~8자로 입력해주세요.";

        checkNicknameResult.className =
            "error-message";

        checkNickname = null;

        return;
    }


    try {

        const result =
            await MemberService.checkNickname(nickname);

        checkNicknameResult.textContent =
            result.message;

        checkNicknameResult.className =
            result.data
                ? "error-message"
                : "success-message";

        checkNickname =
            result.data
                ? null
                : nickname;

    } catch (error) {

        console.log(error);

        checkNicknameResult.textContent =
            "중복 확인 중 오류가 발생했습니다.";

        checkNicknameResult.className =
            "error-message";

        checkNickname = null;
    }
});


/* =========================================================
 * 이메일 중복확인
 * 이메일은 선택사항
 * ========================================================= */

let checkEmail = null;

const checkEmailResult =
    document.querySelector("#email-message");

const emailInput =
    document.querySelector("#email");


emailInput.addEventListener("input", function() {

	this.value = this.value.replace(/\s/g, "");
	
    checkEmailResult.textContent = "";
    checkEmailResult.className = "";
    checkEmail = null;
});


const emailCheckBtn = document.querySelector("#CheckEmail");

emailCheckBtn.addEventListener("click", async function() {
    const email = emailInput.value.trim();

    // 이메일은 선택사항
    if (email.length === 0) {
        checkEmailResult.textContent = "이메일은 선택사항입니다.";
        checkEmailResult.className = "success-message";
        checkEmail = "";
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
        checkEmailResult.className =
            result.data ? "error-message" : "success-message";

        checkEmail = result.data ? null : email;

    } catch (error) {
        console.log(error);

        checkEmailResult.textContent = "중복 확인 중 오류가 발생했습니다.";
        checkEmailResult.className = "error-message";

        checkEmail = null;
    }
});


/* =========================================================
 * 연락처 중복확인
 * ========================================================= */

let checkPhone = null;

const checkPhoneResult =
    document.querySelector("#phone-message");

const phoneInput =
    document.querySelector("#phone");


phoneInput.addEventListener("input", function() {

    this.value =
        this.value.replace(/[^0-9]/g, "");

    checkPhoneResult.textContent = "";
    checkPhoneResult.className = "";
    checkPhone = null;
});


const phoneCheckBtn =
    document.querySelector("#CheckPhone");


phoneCheckBtn.addEventListener("click", async function() {

    const phone =
        phoneInput.value.trim();


    if (phone.length === 0) {

        checkPhoneResult.textContent =
            "연락처를 입력해주세요.";

        checkPhoneResult.className =
            "error-message";

        checkPhone = null;

        return;
    }


    /* DTO와 동일한 정규식 */

    const phoneRegex =
        /^01[0-9]{8,9}$/;


    if (!phoneRegex.test(phone)) {

        checkPhoneResult.textContent =
            "올바른 전화번호 형식이 아닙니다.";

        checkPhoneResult.className =
            "error-message";

        checkPhone = null;

        return;
    }


    try {

        const result =
            await MemberService.checkPhone(phone);

        checkPhoneResult.textContent =
            result.message;

        checkPhoneResult.className =
            result.data
                ? "error-message"
                : "success-message";

        checkPhone =
            result.data
                ? null
                : phone;

    } catch (error) {

        console.log(error);

        checkPhoneResult.textContent =
            "중복 확인 중 오류가 발생했습니다.";

        checkPhoneResult.className =
            "error-message";

        checkPhone = null;
    }
});


/* =========================================================
 * 회원가입 제출 전 최종 검사
 * ========================================================= */

const signUpForm =
    document.querySelector("#SignUpForm");


signUpForm.addEventListener("submit", function(e) {


    /* 이름 */

    const memberName =
        document.querySelector("#member_name").value.trim();

    const nameRegex =
        /^[가-힣]{2,4}$/;


    if (memberName.length === 0) {

        e.preventDefault();
        alert("이름을 입력해주세요.");

        return;
    }


    if (!nameRegex.test(memberName)) {

        e.preventDefault();
        alert("이름은 한글 2~4자로 입력해주세요.");

        return;
    }


    /* 아이디 */

    if (!checkId) {

        e.preventDefault();
        alert("아이디 중복확인을 진행해주세요.");

        return;
    }


    /* 비밀번호 */

    if (!checkPw) {

        e.preventDefault();
        alert(
            "비밀번호 형식을 확인하거나 일치 여부를 확인해주세요."
        );

        return;
    }


    /* 닉네임 */

    if (!checkNickname) {

        e.preventDefault();
        alert("닉네임 중복확인을 진행해주세요.");

        return;
    }


    /* 이메일
     * 선택사항이므로 비어 있으면 통과
     * 입력했다면 반드시 중복확인까지 완료
     */

    if (emailInput.value.trim() !== "" && !checkEmail) {

        e.preventDefault();
        alert(
            "입력한 이메일의 중복확인을 진행해주세요."
        );

        return;
    }


    /* 연락처 */

    if (!checkPhone) {

        e.preventDefault();
        alert("연락처 중복확인을 진행해주세요.");

        return;
    }


    /* 개인정보 동의 */

    const privacyAgree =
        document.querySelector("#privacy_agree");


    if (!privacyAgree.checked) {

        e.preventDefault();
        alert(
            "개인정보 수집 및 이용에 동의해주세요."
        );

        return;
    }
});
