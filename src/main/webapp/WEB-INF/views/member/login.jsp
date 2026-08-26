<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>메종 드 사조 쇼핑몰</title>
		<link rel="stylesheet" href="/css/join.css">
	</head>
	<body>
		<header>
			<h1>메종 드 사조 쇼핑몰</h1>
		</header>
		
		<main>
			<%-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> --%>
			<h2>로그인</h2>
			<c:if test="${ error != null }">
				<p>${error}</p>
			</c:if>


			<c:if test="${ joinSuccess != null }">
					<p>
						회원가입이 완료되었습니다. 로그인 해주세요.
					</p>
				</c:if>

				<form action="/member/login" method="post">
				       <input type="hidden" name="redirectURL" value="${param.redirectURL}">

				       <div>
				           <label for="login-id">아이디</label>
				           <input type="text" id="login-id" name="loginId" required autofocus>
				       </div>

				       <div>
				           <label for="login-pw">비밀번호</label>
				           <input type="password" id="login-pw" name="loginPw" required>
				       </div>

				       <div>
				           <button type="submit">로그인</button>
				           <a href="/member/join">회원가입</a>
				       </div>
				   </form>
			
			<%-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> --%>
		</main>

		<footer class="site-footer">
			<p>Copyright 2026 커뮤니티 실습 - All Right Reserved.</p>
		</footer>	
	</body>
</html>