/* 회원가입 페이지 */

// 비밀번호 일치 여부 확인
const loginPw = document.querySelector("#loginPw");  // 비밀번호 입력창
const loginPwConfirm = document.querySelector("#loginPwConfirm"); // 비밀번호 확인 입력창


let checkPw = false; // 비밀번호 일치 여부 확인용

function validatePwConfirm() {
	const confirmResult = document.querySelector("#pwCheckMsg");
	
	// 비밀번호 확인 입력창이 비어있을 경우 검사 x
	if (!loginPwConfirm.value.trim()){
		confirmResult.textContent = "";
		checkPw = false;
		return;
	}
	
	checkPw = loginPw.value === loginPwConfirm.value;
	
	confirmResult.textContent = checkPw ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.";
	confirmResult.className = checkPw ? "" : ""; // css 적용을 위해 클래스 추가용 
}

loginPw.addEventListener('input', validatePwConfirm);
loginPwConfirm.addEventListener('input', validatePwConfirm);

let checkId = null;   // 아이디 중복체크 값
const checkIdResult = document.querySelector("#idCheckMsg");
const loginIdInput = document.querySelector("#loginId");
loginIdInput.addEventListener("input", function(){
	checkIdResult.textContent = "";
	checkId = null;
});

// 아이디 [중복확인] 버튼의 클릭 이벤트 리스너 추가
const checkIdBtn = document.querySelector("#idCheckBtn");
checkIdBtn.addEventListener("click", async function(){
	const loginId = loginIdInput.value.trim();
	// 아이디 값이 입력되지 않았을 경우, 요청 x
	if (loginId.length === 0) {
		checkIdResult.textContent = "아이디를 입력해주세요.";
		checkIdResult.className = ""; // 오류용 css 적용을 위한 클래스 추가용
		checkId = null;
		return;
	}
	
	// 입력된 아이디값이 중복되는 지 서버로 요청
	try{
	const response = await fetch("/member/checkId?loginId=" + encodeURIComponent(loginId), {
		method: "GET",
		headers: {  "X-Requested-With": "XMLHttpRequest" }
	});
	
	// response.json() : json 응답을 자바스크립트 객체로 변경
	const result = await response.json();
	
	// console.log(result);
	checkIdResult.textContent = result.message;
	checkIdResult.className = result.data ? "" : ""; // 성공 실패에 따른 css 적용을 위한 클래스 추가용 
	
	checkId = result.data ? null : loginId; 
	} catch(error) {
		console.log(error);
		
		checkIdResult.textContent = "중복 확인 중 오류가 발생했습니다.";
		checkIdResult.className = ""; // 오류용 css 적용을 위한 클래스 추가용
		
		checkId = null;
	}
	
});


// 회원가입 폼 제출 => 비밀번호가 일치했을 때, 사용 가능한 아이디인 경우 제출하도록 처리
const joinForm = document.querySelector("#joinForm");
joinForm.addEventListener("submit", function(e){
	

	if(!checkId) {
			e.preventDefault();   // 폼 제출 막기
			alert("아이디 중복확인을 진행해주세요.");
			return;
		}
	
	if(!checkPw) {
		e.preventDefault();   // 폼 제출 막기
		alert("비밀번호가 일치하지 않습니다.");
		return;
	}
	
	
});