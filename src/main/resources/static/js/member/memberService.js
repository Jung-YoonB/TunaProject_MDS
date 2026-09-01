// 회원 관련 서버 통신.
// DOM은 직접 건드리지 않고, 화면별 JS에서 window.MemberService를 통해 호출한다.
// - 아이디/닉네임/이메일/휴대폰 중복확인
// - 회원정보 수정
// - 비밀번호 변경
(function () {

    function checkDuplicate(url, paramName, value) {
        return fetch(url + '?' + paramName + '=' + encodeURIComponent(value), {
            method: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        }).then(function (response) {
            return response.json();
        });
    }

    function checkId(loginId) {
        return checkDuplicate('/member/checkId', 'loginId', loginId);
    }

    function checkNickname(nickname) {
        return checkDuplicate('/member/checkNickname', 'nickname', nickname);
    }

    function checkEmail(email) {
        return checkDuplicate('/member/checkEmail', 'email', email);
    }

    function checkPhone(phone) {
        return checkDuplicate('/member/checkPhone', 'phone', phone);
    }

    // 회원정보 수정
    function updateMember(url, paramName, value) {
        return fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams({
                [paramName]: value
            })
        }).then(function (response) {
            return response.json();
        });
    }

    function updateName(memberName) {
        return updateMember('/member/updateName', 'memberName', memberName);
    }

    function updateBirth(birth) {
        return updateMember('/member/updateBirth', 'birth', birth);
    }

    function updateGender(gender) {
        return updateMember('/member/updateGender', 'gender', gender);
    }

    function updateNickname(nickname) {
        return updateMember('/member/updateNickname', 'nickname', nickname);
    }

    function updatePhone(phone) {
        return updateMember('/member/updatePhone', 'phone', phone);
    }

    function updateEmail(email) {
        return updateMember('/member/updateEmail', 'email', email);
    }

    function updatePassword(currentPassword, newPassword) {
        return fetch('/member/updatePassword', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams({
                currentPassword: currentPassword,
                newPassword: newPassword
            })
        }).then(function (response) {
            return response.json();
        });
    }
	
	function withdraw() {
	    return fetch('/member/withdraw', {
	        method: 'POST',
	        headers: {
	            'X-Requested-With': 'XMLHttpRequest'
	        }
	    }).then(function (response) {
	        return response.json();
	    });
	}

    window.MemberService = {
        checkId: checkId,
        checkNickname: checkNickname,
        checkEmail: checkEmail,
        checkPhone: checkPhone,
		
        updateName: updateName,
        updateBirth: updateBirth,
        updateGender: updateGender,
        updateNickname: updateNickname,
        updatePhone: updatePhone,
        updateEmail: updateEmail,
        updatePassword: updatePassword,
		
		withdraw: withdraw
    };

})();
