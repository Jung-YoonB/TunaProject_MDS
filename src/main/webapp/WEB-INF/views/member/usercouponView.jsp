<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>내 쿠폰</title>

    <link rel="stylesheet" href="../css/default.css">
    <link rel="stylesheet" href="../css/style_coupon.css">
</head>

<body>

    <main>

        <!-- 제목 -->
        <div id="title">내 쿠폰</div>

        <!-- 쿠폰 요약 -->
        <div id="CouponSummary">

            <div class="summary-box">
                <span class="summary-title">보유쿠폰</span>
                <span class="summary-value">5</span>
            </div>

            <div class="summary-box">
                <span class="summary-title">사용가능</span>
                <span class="summary-value">2</span>
            </div>

            <div class="summary-box">
                <span class="summary-title">사용완료</span>
                <span class="summary-value">1</span>
            </div>

            <div class="summary-box">
                <span class="summary-title">만료쿠폰</span>
                <span class="summary-value">2</span>
            </div>

        </div>

        <!-- 쿠폰 검색 -->
        <div id="SearchCoupons">

            <input
                type="text"
                id="coupon-search"
                placeholder="쿠폰 이름을 검색해주세요">

            <button type="button" id="search-button">
                검색
            </button>

        </div>

        <!-- 사용 가능한 쿠폰 -->
        <div id="CouponList">

            <h2>사용 가능한 쿠폰</h2>

            <!-- 여름 특별 쿠폰 -->
            <div class="coupon-card">

                <div class="coupon-info">

                    <div class="coupon-name">
                        여름특별쿠폰
                    </div>

                    <div class="coupon-description">
                        여름 시즌 특별 할인 쿠폰
                    </div>

                    <div class="coupon-deadline">
                        사용기한 : 2026.08.31
                    </div>

                </div>

                <div class="coupon-discount">
                    10%
                </div>

                <div class="coupon-status active">
                    사용가능
                </div>

                <button
                    type="button"
                    class="coupon-use">
                    사용
                </button>

            </div>

            <!-- 신규회원 쿠폰 -->
            <div class="coupon-card">

                <div class="coupon-info">

                    <div class="coupon-name">
                        신규회원 환영 쿠폰
                    </div>

                    <div class="coupon-description">
                        신규 가입 회원 전용 할인 쿠폰
                    </div>

                    <div class="coupon-deadline">
                        사용기한 : 2026.09.15
                    </div>

                </div>

                <div class="coupon-discount">
                    15%
                </div>

                <div class="coupon-status active">
                    사용가능
                </div>

                <button
                    type="button"
                    class="coupon-use">
                    사용
                </button>

            </div>

        </div>

        <!-- 만료된 쿠폰 -->
        <div id="ExpiredCouponList">

            <h2>만료된 쿠폰</h2>

            <!-- 주말 할인 쿠폰 -->
            <div class="coupon-card expired-card">

                <div class="coupon-info">

                    <div class="coupon-name">
                        주말할인쿠폰
                    </div>

                    <div class="coupon-description">
                        주말에 사용할 수 있는 할인 쿠폰
                    </div>

                    <div class="coupon-deadline">
                        사용기한 : 2026.08.25
                    </div>

                </div>

                <div class="coupon-discount">
                    20%
                </div>

                <div class="coupon-status expired">
                    만료
                </div>

                <button
                    type="button"
                    class="coupon-use"
                    disabled>
                    사용불가
                </button>

            </div>

        </div>

    </main>

</body>
</html>