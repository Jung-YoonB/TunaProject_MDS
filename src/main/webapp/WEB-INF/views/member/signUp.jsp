<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- 회원가입 제목 -->
<div id="title">회원가입</div>
<form>

    <!-- 이름 -->
    <div id="Name">
        <label for="member_name">이름</label>
        <input type="text"
               id="member_name"
               name="member_name"
               class="signup-input"
               placeholder="이름을 입력해주세요">
    </div>

    <!-- 생년월일 -->
    <div id="Birth">
        <label for="birth">생년월일</label>
        <input type="date"
               id="birth"
               name="birth"
               class="signup-input">
    </div>

    <!-- 성별 -->
    <div id="Gender">
        <span>성별</span>
        <input type="radio"
               id="gender-male"
               name="gender"
               value="M">

        <label for="gender-male">남성</label>

        <input type="radio"
               id="gender-female"
               name="gender"
               value="F">

        <label for="gender-female">여성</label>
    </div>

    <!-- 닉네임 -->
    <div id="Nickname">
        <label for="nickname">닉네임</label>

        <input type="text"
               id="nickname"
               name="nickname"
               class="signup-input"
               placeholder="닉네임을 입력해주세요">

        <!-- 닉네임 확인 메시지 -->
        <p id="nickname-message" class="check-message"></p>

    </div>


    <!-- 아이디 -->
    <div id="Username">

        <label for="login_id">아이디</label>

        <div class="id-input-box">

            <input type="text"
                   id="login_id"
                   name="login_id"
                   class="signup-input"
                   placeholder="아이디를 입력해주세요">

            <button type="button" id="CheckId">
                중복확인
            </button>

        </div>

        <!-- 아이디 확인 메시지 -->
        <p id="id-message" class="check-message"></p>

    </div>


    <!-- 비밀번호 -->

    <div id="Password">

        <label for="login_pw">비밀번호</label>

        <input type="password"
               id="login_pw"
               name="login_pw"
               class="signup-input"
               placeholder="비밀번호를 입력해주세요">

    </div>


    <!-- 비밀번호 확인 -->

    <div id="ConfirmPassword">

        <label for="login_pw_confirm">비밀번호 확인</label>

        <input type="password"
               id="login_pw_confirm"
               name="login_pw_confirm"
               class="signup-input"
               placeholder="비밀번호를 다시 입력해주세요">

        <!-- 비밀번호 확인 메시지 -->
        <p id="password-message" class="check-message"></p>

    </div>


    <!-- 휴대폰 번호 -->

    <div id="PhoneNumber">

        <label for="phone">휴대폰 번호</label>

        <input type="tel"
               id="phone"
               name="phone"
               class="signup-input"
               placeholder="휴대폰 번호를 입력해주세요">

    </div>


    <!-- 이메일 -->

    <div id="Email">

        <label for="email">이메일</label>

        <input type="email"
               id="email"
               name="email"
               class="signup-input"
               placeholder="이메일을 입력해주세요">

    </div>


    <!-- 개인정보 동의 -->

    <div id="PrivacyBox">

        <input type="checkbox"
               id="privacy_agree"
               name="privacy_agree">

        <label for="privacy_agree">
            개인정보 수집 및 이용에 동의합니다.
        </label>

    </div>


    <!-- 개인정보처리방침 -->

    <div id="PrivacyPolicy">

        <a href="#">개인정보처리방침</a>

    </div>


    <!-- 회원가입 버튼 -->

    <div id="SignUp">

        <button type="submit">
            회원가입
        </button>

    </div>

</form>


<!-- 기존 회원 로그인 -->

<div id="Login">

    <button type="button">
        기존 회원 로그인
    </button>

</div>


<script>

    /* ================================
       닉네임 확인
    ================================= */

    const nickname = document.getElementById("nickname");
    const nicknameMessage = document.getElementById("nickname-message");

    nickname.addEventListener("input", function () {

        if (nickname.value.trim() !== "") {

            nicknameMessage.textContent =
                "* 사용가능한 닉네임입니다.";

            nicknameMessage.className =
                "check-message success";

        } else {

            nicknameMessage.textContent = "";
            nicknameMessage.className = "check-message";
        }

    });


    /* ================================
       아이디 중복확인
    ================================= */

    const loginId = document.getElementById("login_id");
    const checkId = document.getElementById("CheckId");
    const idMessage = document.getElementById("id-message");


    checkId.addEventListener("click", function () {

        const idValue = loginId.value.trim();

        if (idValue === "") {

            idMessage.textContent =
                "* 아이디를 입력해주세요.";

            idMessage.className =
                "check-message error";

            return;
        }


        /*
         * 현재는 화면 테스트용입니다.
         * 나중에 DB와 연결하면 여기서
         * 실제 중복확인 요청을 보내면 됩니다.
         */

        if (idValue === "admin") {

            idMessage.textContent =
                "* 사용불가한 아이디입니다.";

            idMessage.className =
                "check-message error";

        } else {

            idMessage.textContent =
                "* 사용가능한 아이디입니다.";

            idMessage.className =
                "check-message success";

        }

    });


    /* ================================
       비밀번호 확인
    ================================= */

    const password = document.getElementById("login_pw");
    const passwordConfirm =
        document.getElementById("login_pw_confirm");

    const passwordMessage =
        document.getElementById("password-message");


    function checkPassword() {

        if (passwordConfirm.value === "") {

            passwordMessage.textContent = "";
            passwordMessage.className =
                "check-message";

            return;

        }


        if (password.value === passwordConfirm.value) {

            passwordMessage.textContent =
                "* 비밀번호가 일치합니다.";

            passwordMessage.className =
                "check-message success";

        } else {

            passwordMessage.textContent =
                "* 비밀번호를 확인해주세요.";

            passwordMessage.className =
                "check-message error";

        }

    }


    password.addEventListener("input", checkPassword);
    passwordConfirm.addEventListener("input", checkPassword);

</script>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
