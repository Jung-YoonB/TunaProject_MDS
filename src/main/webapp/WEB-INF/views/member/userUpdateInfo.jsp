<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<c:set var="displayName" value="${loginMember.memberName}"/>
<c:set var="displayBirth" value="${loginMember.birth}"/>
<c:set var="displayGender" value="${loginMember.gender}"/>
<c:set var="displayNickname" value="${loginMember.nickname}"/>
<c:set var="displayLoginId" value="${loginMember.loginId}"/>
<c:set var="displayPhone" value="${loginMember.phone}"/>
<c:set var="displayEmail" value="${loginMember.email}"/>

<div class="update-page">

    <!-- 회원정보 수정 제목 -->
    <div id="title">회원정보 수정</div>

    <!-- 아이디 (변경 불가 고정 블록) -->
    <div class="fixed-id-block">
        <span class="fixed-id-label">아이디</span>
        <span class="fixed-id-value">${displayLoginId}</span>
        <span class="fixed-id-badge">변경 불가</span>
    </div>

    <!-- 항목을 탭하면 하위에서 수정 가능 (구글 계정 정보 화면 참고) -->
    <ul class="info-edit-list">

        <!-- 이름 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">이름</span>
                <span class="info-edit-current" id="current-name">${displayName}</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <input type="text" id="member_name" class="signup-input"
                       value="${displayName}" placeholder="이름을 입력해주세요">
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="name">저장</button>
                </div>
            </div>
        </li>

        <!-- 생년월일 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">생년월일</span>
                <span class="info-edit-current" id="current-birth">${displayBirth}</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <input type="date" id="birth" class="signup-input" value="${displayBirth}">
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="birth">저장</button>
                </div>
            </div>
        </li>

        <!-- 성별 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">성별</span>
                <span class="info-edit-current" id="current-gender">${displayGender eq 'M' ? '남성' : '여성'}</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <div id="Gender">
                    <input type="radio" id="gender-male" name="gender" value="M"
                           ${displayGender eq 'M' ? 'checked' : ''}>
                    <label for="gender-male">남성</label>

                    <input type="radio" id="gender-female" name="gender" value="F"
                           ${displayGender eq 'F' ? 'checked' : ''}>
                    <label for="gender-female">여성</label>
                </div>
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="gender">저장</button>
                </div>
            </div>
        </li>

        <!-- 닉네임 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">닉네임</span>
                <span class="info-edit-current" id="current-nickname">${displayNickname}</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <div class="id-input-box">
                    <input type="text" id="nickname" class="signup-input"
                           value="${displayNickname}" placeholder="닉네임을 입력해주세요">
                    <button type="button" id="nicknameCheckBtn" class="dup-check-btn">중복확인</button>
                </div>
                <span id="nicknameCheckMsg"></span>
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="nickname">저장</button>
                </div>
            </div>
        </li>

        <!-- 비밀번호 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">비밀번호</span>
                <span class="info-edit-current">********</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
				<input type="password" id="currentPassword" class="signup-input" placeholder="현재 비밀번호">
                <input type="password" id="newPassword" class="signup-input" placeholder="새 비밀번호">
                <span id="pwRegCheckMsg"></span>
                <input type="password" id="newPasswordConfirm" class="signup-input" placeholder="새 비밀번호 확인">
                <span id="pwCheckMsg"></span>
                <span class="password-hint">비밀번호를 변경하시려면 현재 비밀번호와 새로운 비밀번호를 입력해주세요.</span>
				<span class="password-hint">비밀번호를 유지하시려면 모두 공란으로 저장해주세요.</span>
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="password">저장</button>
                </div>
            </div>
        </li>

        <!-- 휴대폰 번호 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">휴대폰 번호</span>
                <span class="info-edit-current" id="current-phone">${displayPhone}</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <div class="id-input-box">
                    <input type="tel" id="phone" class="signup-input"
                           value="${displayPhone}" placeholder="휴대폰 번호를 입력해주세요">
                    <button type="button" id="phoneCheckBtn" class="dup-check-btn">중복확인</button>
                </div>
                <span id="phoneCheckMsg"></span>
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="phone">저장</button>
                </div>
            </div>
        </li>

        <!-- 이메일 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">이메일</span>
				<span class="info-edit-current" id="current-email"> 
					${empty displayEmail ? '등록된 이메일이 없습니다' : displayEmail}
				</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <div class="id-input-box">
                    <input type="email" id="email" class="signup-input"
                           value="${displayEmail}" placeholder="이메일을 입력해주세요">
                    <button type="button" id="emailCheckBtn" class="dup-check-btn">중복확인</button>
                </div>
                <span id="emailCheckMsg"></span>
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="email">저장</button>
                </div>
            </div>
        </li>

        <!-- 배송지 -->
        <li class="info-edit-item">
            <button type="button" class="info-edit-header" aria-expanded="false">
                <span class="info-edit-label">배송지</span>
                <span class="info-edit-current" id="current-address">등록된 배송지가 없습니다</span>
                <svg class="info-edit-chevron" viewBox="0 0 24 24" focusable="false"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <div class="info-edit-panel" hidden>
                <input type="text" id="addressName" class="signup-input" placeholder="배송지 이름 (예: 우리집, 회사)">
                <input type="text" id="detailAddress" class="signup-input" placeholder="상세 주소를 입력해주세요">
                <label class="address-default-check">
                    <input type="checkbox" id="isDefaultAddress">
                    기본 배송지로 설정
                </label>
                <div class="edit-actions">
                    <button type="button" class="btn-cancel-edit">취소</button>
                    <button type="button" class="btn-save-field" data-field="address">저장</button>
                </div>
            </div>
        </li>

    </ul>

    <!-- 취소 -->
    <div id="Cancel">
        <a href="${pageContext.request.contextPath}/member/myPage">마이페이지로 돌아가기</a>
    </div>

    <!-- 회원 탈퇴 -->
    <div id="WithdrawLink">
        <a href="${pageContext.request.contextPath}/member/userWithdraw" id="withdrawLink">회원 탈퇴</a>
    </div>

</div>

<%-- 항목을 탭하면 패널이 펼쳐지고 그 안에서 값을 고친 뒤 "저장"을 눌러야 반영된다.
     저장 버튼은 실제 API(POST /member/updateName·updateNickname·updatePhone·updateEmail·
     updateBirth·updateGender·updatePassword)를 호출한다.

     ⚠️ 닉네임/이메일/휴대폰 중복확인은 서버에 "본인 제외" 조건이 없다
     (countByNickname 등이 MEMBER 전체를 세므로 값을 안 바꿔도 자기 자신과 충돌해 "중복"으로 뜬다).
     그래서 userUpdateInfo.js가 "현재 저장된 값과 같으면 서버를 부르지 않고 통과"로 우회한다.
     근본 해결은 서버 쪽에 본인 제외(memberId) 파라미터를 추가하는 것. --%>
<script src="<c:url value='/js/member/memberService.js'/>"></script>
<script src="<c:url value='/js/views/userUpdateInfo.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>