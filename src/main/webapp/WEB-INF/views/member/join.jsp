<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>메종 드 사조 쇼핑몰</title>
		<link rel="stylesheet" href="/css/member.css">
	</head>
	<body>
		<header>
			<h1>메종 드 사조 쇼핑몰</h1>
		</header>
		
		<main>
			<%-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> --%>

			<c:if test="${ error != null }"> <!-- 에러 발생 시 안내할 부분 -->
				<p class="msg-error">
					${ error }
				</p>
			</c:if>
	
			<!-- 회원가입 제목 -->
			<div id="title">
				회원가입
			</div>
			
			<form id="joinForm" action="/member/join" method="post">
				
				<!-- 히든 타입으로 초기값 세팅 -->
				<input type="hidden" name="role" value="USER">
				
				<!-- 아이디 -->
				<div id="Username"> 
					<label for="loginId">아이디</label>
					<div class="id-input-box"> 
						<input type="text" id="loginId" name="loginId" class="signup-input" placeholder="아이디를 입력해주세요" required autocomplete="off">
						<button type="button" id="idCheckBtn" class="check-btn">중복확인</button>
					</div>
					<p id="idCheckMsg" class="msg-error"></p>
				</div>

				<!-- 비밀번호 -->
				<div id="Password"> 
					<label for="loginPw">비밀번호</label>
					<input type="password" id="loginPw" name="loginPw" class="signup-input" placeholder="비밀번호를 입력해주세요" required>
					<p id="pwRegCheckMsg" class="msg-error"></p>
				</div>

				<!-- 비밀번호 확인 -->
				<div id="ConfirmPassword"> 
					<label for="loginPwConfirm">비밀번호 확인</label>
					<input type="password" id="loginPwConfirm" name="loginPwConfirm" class="signup-input" placeholder="비밀번호를 다시 입력해주세요" required>
					<p id="pwCheckMsg" class="msg-error"></p>
				</div>

				<!-- 이름 -->
				<div id="Name"> 
					<label for="memberName">이름</label>
					<input type="text" id="memberName" name="memberName" class="signup-input" placeholder="이름을 입력해주세요" pattern="^[가-힣]{2,5}$" title="이름은 한글 2~5자 이내로 입력해주세요." required>
				</div>

				<!-- 생일 -->
				<div id="Birth">  
					<label for="birth">생일</label>
					<input type="date" id="birth" name="birth" class="signup-input">
				</div>
				
				<!-- 성별 -->
				<div id="Gender">  
					<span>성별</span>
					<input type="radio" id="genderM" name="gender" value="M" checked>
					<label for="genderM">남자</label>
					<input type="radio" id="genderF" name="gender" value="F">
					<label for="genderF">여자</label>
				</div>
				
				<!-- 닉네임 -->
				<div id="Nickname"> 
					<label for="nickname">닉네임</label>
					<div class="id-input-box">
						<input type="text" id="nickname" name="nickname" class="signup-input" placeholder="닉네임을 입력해주세요" required>
						<button type="button" id="nicknameCheckBtn" class="check-btn">중복확인</button>
					</div>
					<p id="nicknameCheckMsg" class="msg-error"></p>
				</div>
				
				<!-- 이메일 -->
				<div id="Email"> 
					<label for="email">이메일</label>
					<div class="id-input-box">
						<input type="email" id="email" name="email" class="signup-input" placeholder="이메일을 입력해주세요" pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" title="올바른 이메일 형식으로 작성해주세요.">
						<button type="button" id="emailCheckBtn" class="check-btn">중복확인</button>
					</div>
					<p id="emailCheckMsg" class="msg-error"></p>
				</div>
				
				<!-- 전화번호 -->
				<div id="PhoneNumber"> 
					<label for="phone">전화번호 (* '-' 없이 숫자만 입력)</label>
					<div class="id-input-box">
						<input type="text" id="phone" inputmode="numeric" pattern="01[0-9]{8,9}" maxlength="11" name="phone" class="signup-input" placeholder="휴대폰 번호를 입력해주세요" required>
						<button type="button" id="phoneCheckBtn" class="check-btn">중복확인</button>
					</div>
					<p id="phoneCheckMsg" class="msg-error"></p>
				</div>

				<!-- 가입 버튼 -->
				<div id="SignUp"> 
					<button type="submit">가입하기</button>
				</div>
			</form>
			
			<script src="/js/member.js"></script>
			
			<%-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> --%>
		</main>

		<footer class="site-footer">
			<p>Copyright 2026 커뮤니티 실습 - All Right Reserved.</p>
		</footer>	
	</body>
</html>