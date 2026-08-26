<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <!-- 로그인 제목 -->
        <div id="title">로그인</div>

        <form>
            <!-- 아이디 -->
            <div class="login-field">
                <label for="login_id">아이디</label>
                <input type="text"
                       id="login_id"
                       name="login_id"
                       class="login-input"
                       placeholder="아이디를 입력해주세요">
            </div>

            <!-- 비밀번호 -->
            <div class="login-field">
                <label for="login_pw">비밀번호</label>
                <input type="password"
                       id="login_pw"
                       name="login_pw"
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

		<jsp:include page="/WEB-INF/views/common/footer.jsp"/>