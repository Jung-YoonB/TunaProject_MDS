/*
 * 주문/배송내역 - 주문 카드의 품목 목록 펼치기/접기
 *
 * 목록 쿼리가 주문당 대표 상품 1건만 보여줘서, 한 번에 여러 상품을 산 주문은
 * 나머지를 확인할 방법이 없었다. 품목은 서버(userOderDelivery.jsp)가 이미 다 그려 두므로
 * 여기서는 추가 요청 없이 표시만 토글한다.
 *
 * 카드가 페이지마다 새로 그려지므로 버튼마다 리스너를 다는 대신 document에 한 번만 위임한다.
 */
(function(){

    "use strict";

    document.addEventListener("click", function(event){

        const button = event.target.closest(".btn-order-items");
        if(!button) return;

        const panel = document.getElementById(button.getAttribute("aria-controls"));
        if(!panel) return;

        // style.display 대신 hidden 속성을 쓴다(마크업의 기본 상태와 같은 방식이라
        // CSS가 없어도 접힌 상태가 유지된다)
        const willOpen = panel.hidden;
        panel.hidden = !willOpen;

        // 화살표 회전은 CSS가 이 값을 보고 처리한다
        button.setAttribute("aria-expanded", String(willOpen));

        const label = button.querySelector(".btn-order-items-text");
        if(label){
            label.textContent = willOpen ? label.dataset.opened : label.dataset.closed;
        }
    });

})();
