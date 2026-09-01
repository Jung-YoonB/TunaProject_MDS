// 유저 마이페이지 인터랙션. 현재는 placeholder 링크 처리뿐이고, 나머지 값은 전부
// JSP가 서버 모델(loginMember/couponCount/activeOrderCount/reviewableCount)로 직접
// 렌더링하고 있어 JS가 관여하지 않는다.
(function () {

    if (!window.PlaceholderLinks) return;

    window.PlaceholderLinks.disable('.member-mypage-page');

})();
