<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="auth-shell auth-shell-wide">
	<div class="auth-visual">
		<div class="auth-visual-inner">
			<span class="auth-visual-mark">MDS</span>
			<h2>마음을 고르는 첫걸음</h2>
			<p>가입하고 취향에 맞는 선물을 만나보세요.</p>
		</div>
	</div>
	<div class="auth-form-panel">
		<div class="signup-card">
			<!-- 회원가입 제목 -->
			<div id="title">회원가입</div>

			<c:if test="${not empty error}">
			    <div class="error-message">
			        ${error}
			    </div>
			</c:if>

			<form id="SignUpForm" action="/member/signUp" method="post">
			    <input type="hidden" name="role" value="USER">

			    <!-- 이름 -->
			    <div id="Name">
			        <label for="member_name">이름</label>
			        <input type="text"
			               id="member_name"
			               name="memberName"
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
			        <div class="gender-pill-group">
			            <input type="radio"
			                   id="gender-male"
			                   name="gender"
			                   value="M"
			                   class="gender-radio" checked>
			            <label for="gender-male" class="gender-pill">남성</label>

			            <input type="radio"
			                   id="gender-female"
			                   name="gender"
			                   value="F"
			                   class="gender-radio">
			            <label for="gender-female" class="gender-pill">여성</label>
			        </div>
			    </div>

			    <!-- 닉네임 -->
			    <div id="Nickname">
			        <label for="nickname">닉네임</label>
					<div class="id-input-box">
			       		<input type="text"
			            		id="nickname"
			            	  	name="nickname"
			              		class="signup-input"
			              	 	placeholder="닉네임을 입력해주세요">
						<button type="button" id="CheckNickname" class="dup-check-btn">중복확인</button>
					</div>
			    <p id="nickname-message" class="check-message"></p>
			    </div>

			    <!-- 아이디 -->
			    <div id="Username">
			        <label for="login_id">아이디</label>
			        <div class="id-input-box">
			            <input type="text"
			                   id="login_id"
			                   name="loginId"
			                   class="signup-input"
			                   placeholder="아이디를 입력해주세요">
			            <button type="button" id="CheckId" class="dup-check-btn">중복확인</button>
			        </div>
			        <p id="id-message" class="check-message"></p>
			    </div>

			    <!-- 비밀번호 -->
			    <div id="Password">
			        <label for="login_pw">비밀번호</label>
			        <input type="password"
			               id="login_pw"
			               name="loginPw"
			               class="signup-input"
			               placeholder="비밀번호를 입력해주세요">
			        <p id="pw-reg-check-notice"></p>
			    </div>

			    <!-- 비밀번호 확인 -->
			    <div id="ConfirmPassword">
			        <label for="login_pw_confirm">비밀번호 확인</label>
			        <input type="password"
			               id="login_pw_confirm"
			               name="login_pw_confirm"
			               class="signup-input"
			               placeholder="비밀번호를 다시 입력해주세요">
			        <p id="pw-check-notice" class="check-message"></p>
			    </div>

			    <!-- 휴대폰 번호 -->
			    <div id="PhoneNumber">
			        <label for="phone">휴대폰 번호</label>
					<div class="id-input-box">
			        	<input type="tel"
			             	  id="phone"
			              	 name="phone"
			             	  class="signup-input"
			            	   placeholder="휴대폰 번호를 입력해주세요">
						<button type="button" id="CheckPhone" class="dup-check-btn">중복확인</button>
			    	</div>
					<p id="phone-message" class="check-message"></p>
				</div>

				<!-- 이메일 -->
				<div id="Email">
				    <label for="email">이메일 <span>(선택)</span></label>

				    <div class="id-input-box">
				        <input type="email"
				               id="email"
				               name="email"
				               class="signup-input"
				               placeholder="이메일을 입력해주세요">

				        <button type="button"
				                id="CheckEmail"
				                class="dup-check-btn">
				            중복확인
				        </button>
				    </div>
				    <p id="email-message" class="check-message"></p>
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
			    <button type="button" onclick="location.href='/member/login'">기존 회원 로그인</button>
			</div>
		</div>
	</div>
</div>

<script src="<c:url value='/js/member/memberService.js'/>"></script>
<script src="<c:url value='/js/views/signUp.js'/>"></script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
