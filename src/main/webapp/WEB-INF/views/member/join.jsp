<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

	<!-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> -->

	
	
	<c:if test="${ error != null }"> <!-- 에러 발생 시 안내할 부분 -->
		<p>
			${ error }
		</p>
	</c:if>
	
	<form action="/member/join" method="post">
		<div>  <!-- 최외곽박스 -->
			<div>  <!-- 제목 -->
				<h2>회원가입</h2>
			</div>

			<div> <!-- 아이디 입력 + 중복체크 버튼 -->
				<label for="memberId">아이디</label>
				<div> 
					<input type="text" id="memberId" name="memberId" required autocomplete="off">
					<button type="button">중복확인</button>
				</div>
				<p></p> <!--중복 확인 체크 후 표시할 영역-->
			</div>

			<div> <!--비밀번호 입력-->
				<label for="memberPw">비밀번호</label>
				<input type="password" id="memberPw" name="memberPw" required>
			</div>

			<div> <!--비밀번호 확인 입력-->
				<label for="memberPwConfirm">비밀번호 확인</label>
				<input type="password" id="memberPwConfirm" name="memberPwConfirm" required>
				<p><!--비밀번호 확인 후 표시할 영역--></p>
			</div>

			<div> <!-- 이름 입력 -->
				<label for="memberName">이름</label>
				<input type="text" id="memberName" name="memberName" required>
			</div>

			<div>  <!-- 주민 번호 입력 -->
				<label for="residentRegiNoFront">주민등록 번호</label>
				<input type="text" id="residentRegiNo" name="residentRegiNoFront" maxlength="6" required>
				-
				<input type="password" id="residentRegiNo" name="residentRegiNoRear" maxlength="7" required>
				<!-- 주민번호 앞은 일반 텍스트 / 뒤는 패스워드 방식으로 *** 으로 가림 -->
			</div>
			
			<div> <!-- 닉네임 입력 -->
				<label for="nickname">닉네임</label>
				<input type="text" id="nickname" name="nickname" required>
			</div>
			
			<div> <!-- 이메일 입력 -->
				<label for="email">이메일</label>
				<input type="text" id="email" name="email" autocomplete="off">
			</div>
			
			<div> <!-- 전화번호 입력 -->
				<label for="phone">전화번호 (* 숫자만 입력해 주세요 *)</label>
				<input type="text" id="phone" pattern="[0-9]*" name="phone" required>
			</div>

			<div> <!-- 가입 버튼 -->
				<button type="submit">가입하기</button>
			</div>
		</div> <!--최외곽 박스-->	
	</form>
	
	<script src="/js/member.js"></script>
	
	<!-- <jsp:include page="/WEB-INF/views/common/footer.jsp" /> -->