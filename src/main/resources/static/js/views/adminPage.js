// 관리자 마이페이지 인터랙션 - 프로필 영역 렌더링 + placeholder 링크 처리.
// 프로필 데이터 자체는 static/js/admin/adminMypageService.js가 담당하고,
// 이 파일은 그 결과를 DOM에 그리는 것만 다룬다.
(function () {

    var page = document.querySelector('.admin-mypage-page');
    if (!page || !window.AdminMypageService) return;

    function render(admin) {
        document.getElementById('profile-name').textContent = admin.memberName;
        document.getElementById('profile-subtitle').textContent =
            admin.memberName + ' (' + admin.loginId + ')';

        document.getElementById('val-name').textContent = admin.memberName;
        document.getElementById('val-login-id').textContent = admin.loginId;
    }

    window.AdminMypageService.fetchProfile().then(render);

    if (window.PlaceholderLinks) {
        window.PlaceholderLinks.disable('.admin-mypage-page');
    }

})();
