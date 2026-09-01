// 아직 대응 화면/라우트가 없어 href="#"로 남겨둔 placeholder 링크가 클릭 시 페이지 맨 위로
// 점프하지 않도록 막는다. adminPage / myPage가 각각 따로 갖고 있던 같은 코드를 합친 것.
//
// 반드시 페이지 wrapper 안으로 스코프해서 부르는 것을 원칙으로 한다 - footer.jsp에도
// href="#" 링크가 8개 있어서(이용안내/고객센터/SNS 등) 문서 전체에 걸면 25개 페이지 전부의
// 푸터 동작까지 한꺼번에 바뀐다.
//
// 참고: href="#"는 브라우저가 클릭 없이도 :visited로 취급하므로, 이런 링크에 색을 입힐 때는
// default.css:22의 a:visited{color:#333}(명시도 0,1,1)를 이길 수 있게 ID 스코프 등으로
// 명시도를 올려야 한다. (PROJECT_AUDIT.md 잠재적 위험 19번)
(function () {

    // scopeSelector 안쪽의 href="#" 링크만 대상으로 한다.
    function disable(scopeSelector) {
        var scope = document.querySelector(scopeSelector);
        if (!scope) return;

        scope.querySelectorAll('a[href="#"]').forEach(function (a) {
            a.addEventListener('click', function (e) { e.preventDefault(); });
        });
    }

    window.PlaceholderLinks = {
        disable: disable
    };

})();
