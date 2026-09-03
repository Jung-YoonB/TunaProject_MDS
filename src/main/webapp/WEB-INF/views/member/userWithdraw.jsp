<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <div class="withdraw-page">

        <!-- 탈퇴 완료 제목 -->
        <div id="title">

            <h1>회원 탈퇴가 완료되었습니다</h1>

            <p>
                그동안 저희 서비스를 이용해주셔서 감사합니다.
            </p>

        </div>


        <!-- 탈퇴 완료 안내 -->
        <div id="WithdrawComplete">

            <div class="complete-icon">
                <svg class="icon-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                    <path d="M20 6L9 17l-5-5"/>
                </svg>
            </div>

            <div class="complete-message">

                <strong>탈퇴 처리가 정상적으로 완료되었습니다.</strong>

                <p>
                    입력하신 회원 정보는 관련 법령 및 방침에 따라 처리됩니다.
                </p>

            </div>

        </div>


        <!-- 하단 버튼 -->
        <div id="WithdrawActions">

            <a class="btn-outline" href="<c:url value='/'/>">
                홈으로 돌아가기
            </a>

            <a class="btn-solid" href="<c:url value='/member/login'/>">
                로그인 페이지로
            </a>

        </div>

    </div>

<%-- 탈퇴 완료 안내 전용 화면(모델 바인딩 없음).
     실제 탈퇴는 회원정보 수정 화면의 탈퇴 링크가 POST /member/withdraw를 호출해 성공한 뒤
     이리로 넘어온다(views/userUpdateInfo.js). 이 화면을 직접 열어도 탈퇴되지 않는다. --%>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>