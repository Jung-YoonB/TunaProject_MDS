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

<%--
    TODO(data binding):
    - 이 화면은 모델 바인딩되는 값이 전혀 없는 "안내 전용" 화면입니다(순수 정적 문구).
    - 실제 탈퇴 처리 백엔드는 #BE014에서 이미 신설됨 — MemberController의
      POST /member/withdraw와 MemberMapper.xml의 <update id="withdrawMember">가 있음.
      다만 views/userUpdateInfo.js의 탈퇴 링크가 아직 그 API를 호출하지 않고 이 화면으로
      바로 이동만 하므로, 연동 시 "요청 성공 후 이 화면으로 이동"하도록 바꿔야 합니다.
    - 2026-09-01 규격화: 원래 전체 JSP 25개 중 유일하게 header.jsp를 include하지 않고
      자기 <head>에서 CSS를 직접 link하던 독립 페이지였으나, 다른 페이지와 동일하게
      header/footer include + wrapper div 방식으로 통일함(HANDOFF.md 3-42 참고).
--%>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>