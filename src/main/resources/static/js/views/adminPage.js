// 관리자 마이페이지 인터랙션.
// 프로필 값(이름/아이디)은 서버가 JSP에서 직접 렌더링하므로 여기서 손대지 않는다.
(function () {

    var page = document.querySelector('.admin-mypage-page');
    if (!page) return;

    if (window.PlaceholderLinks) {
        window.PlaceholderLinks.disable('.admin-mypage-page');
    }

})();
