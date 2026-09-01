<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- TODO(data binding): 로그인 세션이 없거나 값이 비어 있을 때 화면 확인용 예시값으로 대체.
     실제 로그인 상태에서는 loginMember의 실제 값이 그대로 사용됨(아래 empty 조건에서 걸러짐). --%>
<c:set var="displayName" value="${empty loginMember.memberName ? '홍길동' : loginMember.memberName}"/>
<c:set var="displayBirth" value="${empty loginMember.birth ? '1998-05-14' : loginMember.birth}"/>
<c:set var="displayGender" value="${empty loginMember.gender ? 'M' : loginMember.gender}"/>
<c:set var="displayNickname" value="${empty loginMember.nickname ? 'gildong99' : loginMember.nickname}"/>
<c:set var="displayLoginId" value="${empty loginMember.loginId ? 'hong123' : loginMember.loginId}"/>
<c:set var="displayPhone" value="${empty loginMember.phone ? '01012345678' : loginMember.phone}"/>
<c:set var="displayEmail" value="${empty loginMember.email ? 'hong123@example.com' : loginMember.email}"/>

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
                <span class="password-hint">변경하지 않으려면 비워두고 저장을 눌러주세요.</span>
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
                <span class="info-edit-current" id="current-email">${displayEmail}</span>
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
        <a href="${pageContext.request.contextPath}/member/mypage">마이페이지로 돌아가기</a>
    </div>

    <!-- 회원 탈퇴 -->
    <div id="WithdrawLink">
        <a href="${pageContext.request.contextPath}/member/userWithdraw" id="withdrawLink">회원 탈퇴</a>
    </div>

</div>

<%-- TODO(data binding): 프리필 값(display***)은 MemberController.updateInfoForm()이
     mypageForm()과 동일하게 service.getMemberByMemberId(...)를 호출해 채우는 실제 세션 데이터(
     loginMember)를 우선 사용함 — 목업 아님. 다만 로그인하지 않은 상태로 열람하거나 특정 값이
     비어 있을 때도 화면을 확인할 수 있도록, 상단의 <c:set> 블록에서 각 필드가 비어 있으면
     예시값(홍길동/1998-05-14/M/gildong99/hong123/01012345678/hong123@example.com)으로
     대체함 — 실제 로그인 상태에서는 이 예시값이 쓰이지 않음.
     - 항목을 탭하면 하위 패널이 펼쳐지고, 그 안에서만 값을 수정한 뒤 "저장"을 눌러야 반영되는
       구글 계정 정보 화면과 동일한 UX. "취소"를 누르면 입력값을 되돌리고 패널을 접음.
     - 닉네임/이메일/휴대폰 중복확인: 이미 존재하는 실제 API(/member/checkNickname,
       /member/checkEmail, /member/checkPhone)를 그대로 호출함. 다만 서버에 "본인 제외" 로직이
       없어 값이 바뀌지 않은 경우 자기 자신과 충돌해 오탐(중복)으로 표시될 수 있으므로,
       userUpdateInfo.js에서 "현재 저장된 값과 동일하면 서버 호출 없이 자동 통과" 로직으로
       우회함(저장에 성공할 때마다 기준값을 최신값으로 갱신) — 근본 해결은 추후 서버 측
       "본인 제외" 파라미터 추가가 필요.
     - 아이디는 상단에 변경 불가 고정 블록으로만 표시하며 목록/수정 대상이 아님.
     - 새 비밀번호: 두 칸 모두 비어 있으면 변경하지 않음(선택 입력). 입력 시 MemberDTO.loginPw와
       동일한 정규식/일치 검증만 프론트에서 수행.
     - 배송지: DeliveryAddress 테이블(add_id/member_id/address_name/detail_address/is_default)에
       대응하는 컨트롤러/서비스/매퍼가 전혀 없음 — 현재는 완전히 목업(저장해도 DB 미반영, 새로고침
       시 사라짐). 실제 구현 시 DeliveryAddress 전용 CRUD API 신설 필요.
     - 각 항목의 "저장" 버튼: 화면 표시값만 갱신하고 DB에는 반영되지 않는 no-op.
       단 백엔드는 #BE014에서 이미 신설됨 — MemberController에 POST /member/updateName,
       /updateBirth, /updateGender, /updateNickname, /updatePhone, /updateEmail,
       /updatePassword, /withdraw 8개와 MemberMapper.xml의 대응 <update> 문이 전부 있음.
       프론트에서 이 엔드포인트들을 호출하기만 하면 되는 상태(연동은 이번 범위 밖). --%>
<script src="<c:url value='/js/member/memberService.js'/>"></script>
<script src="<c:url value='/js/views/userUpdateInfo.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>