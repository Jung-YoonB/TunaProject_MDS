// 회원 - 중복확인 서버 통신. DOM을 건드리지 않고, signUp.jsp가 쓰는 인터랙션
// 스크립트(views/signUp.js)에서 window.MemberService를 통해 호출한다.
(function () {

    function checkDuplicate(url, paramName, value) {
        return fetch(url + '?' + paramName + '=' + encodeURIComponent(value), {
            method: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        }).then(function (response) { return response.json(); });
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

    window.MemberService = {
        checkId: checkId,
        checkNickname: checkNickname,
        checkEmail: checkEmail,
        checkPhone: checkPhone
    };

})();
