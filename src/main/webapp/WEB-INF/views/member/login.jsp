<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인</title>

    <link rel="stylesheet" href="/css/default.css">
    <link rel="stylesheet" href="/css/style_member.css">
</head>

<body>

    <main>
        <!-- 로그인 제목 -->
        <div id="title">로그인</div>
		
		<c:if test="${not empty error}">
		    <div class="error-message">
		        ${error}
		    </div>
		</c:if>

        <form action="/member/login" method="post">
            <!-- 아이디 -->
            <div class="login-field">
                <label for="login_id">아이디</label>
                <input type="text"
                       id="login_id"
                       name="loginId"
                       class="login-input"
                       placeholder="아이디를 입력해주세요">
            </div>

            <!-- 비밀번호 -->
            <div class="login-field">
                <label for="login_pw">비밀번호</label>
                <input type="password"
                       id="login_pw"
                       name="loginPw"
                       class="login-input"
                       placeholder="비밀번호를 입력해주세요">
            </div>

            <!-- 로그인 버튼 -->
            <div id="SignIn">
                <button type="submit">로그인</button>
            </div>
        </form>

        <!-- 계정 관련 메뉴 -->
        <div id="AccountInfo">
            <button type="button">아이디 찾기</button>
            <button type="button">비밀번호 찾기</button>
            <button type="button">회원가입</button>
        </div>

    </main>

</body>
</html>