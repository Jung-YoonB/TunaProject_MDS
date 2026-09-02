<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="auth-shell">
	<div class="auth-visual">
		<div class="auth-visual-inner">
			<span class="auth-visual-mark">MDS</span>
			<h2>다시 만나 반가워요</h2>
			<p>취향을 담은 선물을 이어서 골라보세요.</p>
		</div>
	</div>
	<div class="auth-form-panel">
		<div class="login-card">
			<!-- 로그인 제목 -->
			<div id="title">로그인</div>
			
			<c:if test="${not empty signUpSuccess}">
			    <div class="success-message">
			        ${signUpSuccess}
			    </div>
			</c:if>

			<c:if test="${not empty error}">
			    <div class="error-message">
			        ${error}
			    </div>
			</c:if>

			<form action="/member/login" method="post">
			    <c:if test="${not empty redirectURL}">
			        <input type="hidden" name="redirectURL" value="${fn:escapeXml(redirectURL)}">
			    </c:if>

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
			    <button type="button" onclick="location.href='/member/signUp'">회원가입</button>
			</div>
		</div>
	</div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
