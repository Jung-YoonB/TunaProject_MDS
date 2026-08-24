<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>메종 드 사조 쇼핑몰 - 로그인</title>
		
		<!-- 통합된 member.css 연결 -->
		<link rel="stylesheet" href="/css/default.css">
		<link rel="stylesheet" href="/css/member.css">
	</head>
	
	<body>
		<header>
			<%-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> --%>
		</header>
		
		<main class="login-card">
			<div id="title">로그인</div>

			<!-- 에러 메시지 출력 -->
			<c:if test="${ error != null }">
				<p class="msg-error">${error}</p>
			</c:if>

			<!-- 회원가입 성공 후 이동 시 메시지 출력 -->
			<c:if test="${ joinSuccess != null }">
				<p class="msg-success">회원가입이 완료되었습니다. 로그인 해주세요.</p>
			</c:if>

			<!-- 로그인 폼 -->
			<form action="/member/login" method="post">
				<!-- 로그인 후 이전 페이지 리다이렉트용 히든 필드 -->
				<input type="hidden" name="redirectURL" value="${param.redirectURL}">

				<!-- 아이디 입력 -->
				<div class="login-field">
					<label for="login-id">아이디</label>
					<input type="text" id="login-id" name="loginId" class="login-input" 
						   placeholder="아이디를 입력해주세요" required autofocus>
				</div>

				<!-- 비밀번호 입력 -->
				<div class="login-field">
					<label for="login-pw">비밀번호</label>
					<input type="password" id="login-pw" name="loginPw" class="login-input" 
						   placeholder="비밀번호를 입력해주세요" required>
				</div>

				<!-- 로그인 버튼 -->
				<div id="SignIn">
					<button type="submit">로그인</button>
				</div>
			</form>

			<!-- 하단 계정 관련 버튼 영역 -->
			<div id="AccountInfo">
				<button type="button" onclick="alert('아이디 찾기 기능 준비 중입니다.');">아이디 찾기</button>
				<button type="button" onclick="alert('비밀번호 찾기 기능 준비 중입니다.');">비밀번호 찾기</button>
				<button type="button" onclick="location.href='/member/join'">회원가입</button>
			</div>
		</main>

		<footer class="site-footer">
			<p>Copyright 2026 커뮤니티 실습 - All Right Reserved.</p>
		</footer>	
	</body>
</html>