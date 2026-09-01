// 관리자 마이페이지 프로필 데이터 조회.
//
// TODO(server binding): 지금은 아래 목업을 그대로 반환한다. 실제 데이터는 이미 준비돼 있어서
// (MemberController.myPageForm()이 model에 SessionConst.LOGIN_MEMBER = "loginMember"로
// 실제 MemberDTO를 담아 admin/adminPage.jsp로 넘긴다) 연동은 두 가지 중 하나면 된다:
//   1) JSP에서 EL로 직접 렌더링하고 이 서비스를 걷어내거나,
//   2) fetchProfile()의 내부만 실제 조회로 교체.
// Promise를 반환하는 시그니처는 유지되므로 호출부(views/adminPage.js)는 안 건드려도 된다.
//
// 주의: memberName/loginId만 Member 테이블에 실제 컬럼이 존재한다.
(function () {

    var MOCK_ADMIN = {
        memberName: '관리자',
        loginId: 'admin'
    };

    function fetchProfile() {
        return Promise.resolve(MOCK_ADMIN);
    }

    window.AdminMypageService = {
        fetchProfile: fetchProfile
    };

})();
