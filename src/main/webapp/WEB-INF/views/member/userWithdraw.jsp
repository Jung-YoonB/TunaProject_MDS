<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>회원 탈퇴 완료</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/default.css">

    <!-- 회원 전용 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style_member.css">

</head>

<body class="withdraw-page">

    <main>

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
                ✓
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

    </main>

</body>

</html>

<%--
    TODO(data binding):
    - 현재 이 화면은 실제 탈퇴 처리 백엔드가 없는 상태에서 만들어진 "안내 전용" 화면입니다.
      모델 바인딩되는 값이 전혀 없으며, 순수 정적 문구만 표시합니다.
    - 실제 회원 탈퇴 기능을 구현할 경우 MemberController에 POST /member/withdraw 매핑,
      MemberService의 탈퇴 처리 메서드(세션 무효화 + Member 삭제/비활성화),
      MemberMapper.xml의 관련 SQL이 추가되어야 하며, 처리 성공 후 이 화면(member/userWithdraw)
      으로 forward 또는 redirect 하도록 연결하면 됩니다.
--%>