<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="order-complete-page">
<div class="order-complete-card">
        <!-- 주문 완료 제목 -->
        <div id="title">

            <h1>주문 완료!</h1>

            <p>
                주문이 정상적으로 완료되었습니다.
            </p>

        </div>


        <!-- 주문 완료 안내 -->
        <div id="OrderComplete">

            <div class="complete-icon">
                <svg class="icon-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                    <path d="M20 6L9 17l-5-5"/>
                </svg>
            </div>

            <div class="complete-message">

                <strong>감사합니다!</strong>

                <p>
                    고객님의 주문번호 : <strong>${orderId}</strong> 주문이 정상적으로 접수되었습니다.
                </p>

            </div>

        </div>


        <!-- 공유 -->
        <div id="ShareLink">

            <h2>주문 완료 소식 공유하기</h2>

            <p>
                가족이나 친구에게 주문 완료 소식을 공유해보세요.
            </p>


            <!-- 공유 버튼 -->
            <div id="ShareButtons">

                <!-- 카카오톡 -->
                <div id="kakao">

                    <button type="button">

                        <span class="share-icon">
                            kakao
                        </span>

                        <span>
                            카카오톡 공유
                        </span>

                    </button>

                </div>


                <!-- 메시지 -->
                <div id="message">

                    <button type="button">

                        <span class="share-icon">
                            message
                        </span>

                        <span>
                            메시지 공유
                        </span>

                    </button>

                </div>


                <!-- 다른 방법 -->
                <div id="Other">

                    <button type="button">

                        <span class="share-icon">
                            ↗
                        </span>

                        <span>
                            다른 방법으로 공유
                        </span>

                    </button>

                </div>

            </div>

        </div>


        <!-- 공유 링크 -->
        <div id="ShareUrl">

            <label for="share-url">
                공유 링크
            </label>

            <div class="share-url-box">

                <input
                    type="text"
                    id="share-url"
                    value="주문 완료 페이지 링크"
                    readonly>

                <button type="button">
                    링크 복사
                </button>

            </div>

        </div>


        <!-- 하단 버튼 -->
        <div id="OrderHistory">

            <button type="button">
                주문내역 확인
            </button>

            <button type="button">
                쇼핑 계속하기
            </button>

        </div>
</div>
</div>

		<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
