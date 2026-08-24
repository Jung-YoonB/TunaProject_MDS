<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

	<!-- <jsp:include page="/WEB-INF/views/common/header.jsp" /> -->

	
	
	<c:if test="${ error != null }"> <!-- 에러 발생 시 안내할 부분 -->
		<p>
			${ error }
		</p>
	</c:if>
	
	<form id="joinForm" action="/member/join" method="post">
		<div>  <!-- 최외곽박스 -->
			<div>  <!-- 제목 -->
				<h2>회원가입</h2>
			</div>
			
			<!-- 히든 타입으로 초기값 세팅 -->
			<input type="hidden" name="gradeId" value="1">
			<input type="hidden" name="totalAmount" value="0">
			<input type="hidden" name="role" value="USER">
			<input type="hidden" name="memberStatus" value="1">
			
			<div> <!-- 아이디 입력 + 중복체크 버튼 -->
				<label for="loginId">아이디</label>
				<div> 
					<input type="text" id="loginId" name="loginId" required autocomplete="off">
					<button type="button" id="idCheckBtn">중복확인</button>
				</div>
				<p id="idCheckMsg"></p> <!--중복 확인 체크 후 표시할 영역-->
			</div>

			<div> <!--비밀번호 입력-->
				<label for="loginPw">비밀번호</label>
				<input type="password" id="loginPw" name="loginPw" required>
			</div>

			<div> <!--비밀번호 확인 입력-->
				<label for="loginPwConfirm">비밀번호 확인</label>
				<input type="password" id="loginPwConfirm" name="loginPwConfirm" required>
				<p id="pwCheckMsg"><!--비밀번호 확인 후 표시할 영역--></p>
			</div>

			<div> <!-- 이름 입력 / 한글 2~5자만 -->
				<label for="memberName">이름</label>
				<input type="text" id="memberName" name="memberName" pattern="^[가-힣]{2,5}$" title="이름은 한글 2~5자 이내로 입력해주세요." required>
			</div>

			<div>  <!-- 생일 입력 -->
				<label for="birth">생일</label>
				<input type="date" id="birth" name="birth" required>
			</div>
			
			<div>  <!-- 성별 입력 -->
				<span> 성별 </span>
				<input type="radio" id="genderM" name="gender" value="M" checked>
				<label for="genderM">남자</label>
				<input type="radio" id="genderF" name="gender" value="F">
				<label for="genderF">여자</label>
			</div>
			
			<div> <!-- 닉네임 입력 + 중복체크 버튼 -->
				<label for="nickname">닉네임</label>
				<div>
					<input type="text" id="nickname" name="nickname" required>
					<button type="button" id="nickCheckBtn">중복확인</button>
				</div>
				<p id="nickCheckMsg"></p> <!--중복 확인 체크 후 표시할 영역-->
			</div>
			
			<div> <!-- 이메일 입력 + 중복체크 버튼 -->
				<label for="email">이메일</label>
				<div>
					<input type="email" id="email" name="email" pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" title="올바른 이메일 형식으로 작성해주세요." required>
					<button type="button" id="emailCheckBtn">중복확인</button>
				</div>
				<p id="emailCheckMsg"></p> <!--중복 확인 체크 후 표시할 영역-->
			</div>
			
			<div> <!-- 전화번호 입력 + 중복체크 버튼 -->
				<label for="phone">전화번호(* '-' 없이 숫자만 입력)</label>
				<div>
					<input type="text" id="phone" inputmode="numeric" pattern="01[0-9]{8,9}" maxlength="11" name="phone" required>
					<button type="button" id="phoneCheckBtn">중복확인</button>
				</div>
				<p id="phoneCheckMsg"></p> <!--중복 확인 체크 후 표시할 영역-->
			</div>

			<div> <!-- 가입 버튼 -->
				<button type="submit">가입하기</button>
			</div>
		</div> <!--최외곽 박스-->	
	</form>
	
	<script src="/js/member.js"></script>
	
	<!-- <jsp:include page="/WEB-INF/views/common/footer.jsp" /> -->