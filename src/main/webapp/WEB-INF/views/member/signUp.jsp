<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>

    <link rel="stylesheet" href="../css/default.css">
    <link rel="stylesheet" href="../css/style_member.css">
</head>

<body>

    <main>

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
                <button type="submit">회원가입</button>
            </div>

        </form>

        <!-- 기존 회원 로그인 -->
        <div id="Login">
            <button type="button">기존 회원 로그인</button>
        </div>

    </main>

</body>
</html>