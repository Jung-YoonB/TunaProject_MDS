(function () {

"use strict";


const data = window.orderCompleteData;

if (!data) {
    return;
}


/*
 * =====================================================
 * 주문내역 확인
 *
 * 주문번호를 다시 Controller로 보낼 필요 없음.
 *
 * /order/orderDelivery로 이동하면
 * Controller가 세션의 memberId를 가져와서
 * 해당 회원의 주문/배송내역을 조회함.
 * =====================================================
 */

const orderHistoryButton =
    document.getElementById("order-history-btn");

if (orderHistoryButton) {

    orderHistoryButton.addEventListener(
        "click",
        function () {

            window.location.href =
                data.orderHistoryUrl;

        }
    );

}


/*
 * =====================================================
 * 쇼핑 계속하기
 * =====================================================
 */

const continueShoppingButton =
    document.getElementById("continue-shopping-btn");

if (continueShoppingButton) {

    continueShoppingButton.addEventListener(
        "click",
        function () {

            window.location.href =
                data.homeUrl;

        }
    );

}


/*
 * =====================================================
 * 공유 링크
 *
 * 현재 주문 완료 페이지 주소를 공유 링크로 사용
 * =====================================================
 */

const shareUrlInput =
    document.getElementById("share-url");

if (shareUrlInput) {

    shareUrlInput.value =
        window.location.href;

}


/*
 * =====================================================
 * 링크 복사
 * =====================================================
 */

const copyButton =
    document.getElementById("copy-share-url");

if (copyButton && shareUrlInput) {

    copyButton.addEventListener(
        "click",
        async function () {

            try {

                await navigator.clipboard.writeText(
                    shareUrlInput.value
                );

                alert("공유 링크가 복사되었습니다.");

            } catch (error) {

                shareUrlInput.select();

                document.execCommand("copy");

                alert("공유 링크가 복사되었습니다.");

            }

        }
    );

}


/*
 * =====================================================
 * 다른 방법으로 공유
 * =====================================================
 */

const otherShareButton =
    document.getElementById("other-share");

if (otherShareButton) {

    otherShareButton.addEventListener(
        "click",
        async function () {

            if (navigator.share) {

                try {

                    await navigator.share({

                        title: "주문 완료",

                        text:
                            "주문이 정상적으로 완료되었습니다.",

                        url:
                            window.location.href

                    });

                } catch (error) {

                    // 사용자가 공유 창을 닫은 경우 무시

                }

            } else {

                alert(
                    "이 브라우저에서는 공유 기능을 지원하지 않습니다."
                );

            }

        }
    );

}


/*
 * =====================================================
 * 메시지 공유
 * =====================================================
 */

const messageShareButton =
    document.getElementById("message-share");

if (messageShareButton) {

    messageShareButton.addEventListener(
        "click",
        async function () {

            if (navigator.share) {

                try {

                    await navigator.share({

                        title: "주문 완료",

                        text:
                            "주문이 정상적으로 완료되었습니다.",

                        url:
                            window.location.href

                    });

                } catch (error) {

                    // 사용자가 공유 창을 닫은 경우 무시

                }

            } else {

                alert(
                    "현재 브라우저에서는 메시지 공유를 지원하지 않습니다."
                );

            }

        }
    );

}


/*
 * =====================================================
 * 카카오톡 공유
 *
 * 현재는 실제 Kakao SDK 연동 전이므로
 * 안내 메시지만 표시
 * =====================================================
 */

const kakaoShareButton =
    document.getElementById("kakao-share");

if (kakaoShareButton) {

    kakaoShareButton.addEventListener(
        "click",
        function () {

            alert(
                "카카오톡 공유 기능은 추후 연동할 수 있습니다."
            );

        }
    );

}


})();