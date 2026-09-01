// 상품 광고 배너 자동 슬라이드 - 페이지 안의 .banner-slider 요소를 전부 찾아 각각 독립적으로 동작시킨다.
// (home.jsp 메인 배너, searchProduct.jsp 사이드바 배너 등 여러 곳에서 재사용)
(function () {
    function initSlider(slider) {
        var slides = slider.querySelectorAll('.banner-slide');
        var dots = slider.querySelectorAll('.banner-dot');
        var current = 0;
        var timer = null;
        var INTERVAL = 4500;

        function goTo(index) {
            if (!slides.length) return;
            slides[current].classList.remove('is-active');
            if (dots[current]) dots[current].classList.remove('is-active');
            current = (index + slides.length) % slides.length;
            slides[current].classList.add('is-active');
            if (dots[current]) dots[current].classList.add('is-active');
        }

        function next() { goTo(current + 1); }

        function startAuto() {
            stopAuto();
            if (slides.length > 1) {
                timer = setInterval(next, INTERVAL);
            }
        }

        function stopAuto() {
            if (timer) {
                clearInterval(timer);
                timer = null;
            }
        }

        dots.forEach(function (dot, i) {
            dot.addEventListener('click', function () {
                goTo(i);
                startAuto();
            });
        });

        slider.addEventListener('mouseenter', stopAuto);
        slider.addEventListener('mouseleave', startAuto);

        startAuto();
    }

    document.querySelectorAll('.banner-slider').forEach(initSlider);
})();
