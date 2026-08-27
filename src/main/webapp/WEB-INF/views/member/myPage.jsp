<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

	<!-- 마이페이지 제목 -->
	<div id="title">마이페이지</div>
	
	<!-- 회원 정보 -->
	<div id="MemberInfo">
	    <h2>회원 정보</h2>
	    <div class="member-info-list">
	        <div class="member-info-item">
	            <span class="member-label">이름</span>
	            <span class="member-value">이름값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">닉네임</span>
	            <span class="member-value">닉네임값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">회원 등급</span>
	            <span class="member-value">등급값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">아이디</span>
	            <span class="member-value">아이디값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">휴대폰</span>
	            <span class="member-value">휴대폰값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">이메일</span>
	            <span class="member-value">이메일값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">포인트</span>
	            <span class="member-value">포인트값</span>
	        </div>
	
	        <div class="member-info-item">
	            <span class="member-label">쿠폰</span>
	            <span class="member-value">사용 가능한 5장 >상세보기</span>
	        </div>
	
	    </div>
	
	    <div id="EditMember">
	        <a href="${pageContext.request.contextPath}/member/updateInfo">정보 수정</a>
	    </div>
	</div>
	
	<!-- 빠른 메뉴 -->
	<div id="QuickMenu">
	    <h2>빠른 메뉴</h2>
	    <div class="quick-menu-list">
	        <div class="quick-menu-item">주문·배송 조회</div>
	        <div class="quick-menu-item">리뷰 작성</div>
	        <div class="quick-menu-item">문의사항</div>
	        <div class="quick-menu-item">문의내역</div>
	    </div>
	</div>
	
	<!-- 주문 관리 -->
	<div id="MyOrder" class="my-section">
	    <h2>내 선물 관리</h2>
	    <div class="menu-list">
	        <div class="menu-item">
				<h4>주문·배송 조회</h4>
				<br>
				주문한 상품의 배송을 추적 관찰하세요
			</div>
	        <div class="menu-item">
				<h4>주문 취소 / 환불</h4>
				<br>
				언니 저 마음에 안들죠? 취소 환불 하실게요
			</div>
			<div class="menu-item">
				<h4>나의 장바구니</h4>
				<br>
				나의 장바구니 상품을 추적 관찰하세요
			</div>
			<div class="menu-item">
				<h4>나의 찜 목록</h4>
				<br>
				나의 찜 목록을 추적 관찰하세요
			</div>
	    </div>
	</div>
	
	<!-- 고객센터 -->
	<div id="UserCS" class="my-section">
	    <h2>고객센터</h2>
	    <div class="menu-list">
	        <div class="menu-item">문의사항</div>
	        <div class="menu-item">문의내역</div>
	        <div class="menu-item">공지사항</div>
	    </div>
	</div>
	
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>