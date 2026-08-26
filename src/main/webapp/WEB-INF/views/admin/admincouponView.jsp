<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<div id="title">
            쿠폰관리
        </div>


        <!-- 쿠폰 등록 -->

        <div id="CouponRegister">

            <button
                type="button"
                class="register-button">

                <span class="register-icon">＋</span>
                쿠폰 등록

            </button>

        </div>


        <!-- 쿠폰 검색 -->

        <div id="SearchCoupons">

            <input
                type="text"
                id="coupon-search"
                placeholder="쿠폰 이름을 검색해주세요">

            <button
                type="button"
                id="search-button">

                검색

            </button>

        </div>


        <!-- 등록된 쿠폰 -->

        <div id="CouponList">


            <!-- 제목 -->

            <div class="coupon-list-header">

                <h2>
                    등록된 쿠폰
                    <span class="coupon-count">(3)</span>
                </h2>

            </div>


            <!-- 전체 선택 / 삭제 -->

            <div class="list-control">


                <div class="select-menu">

                    <button type="button">
                        전체선택
                    </button>

                    <button type="button">
                        전체선택취소
                    </button>

                </div>


                <button
                    type="button"
                    class="delete-button">

                    <span class="delete-icon">🗑</span>
                    선택 삭제

                </button>

            </div>


            <!-- ================================
                 여름 특별 쿠폰
            ================================= -->

            <div class="coupon-card">


                <input
                    type="checkbox"
                    class="coupon-check"
                    name="coupon"
                    value="1">


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


            


                <button
                    type="button"
                    class="edit-button"
                    title="쿠폰 수정">

                    ✎

                </button>

            </div>


            <!-- ================================
                 신규회원 쿠폰
            ================================= -->

            <div class="coupon-card">


                <input
                    type="checkbox"
                    class="coupon-check"
                    name="coupon"
                    value="2">


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


               


                <button
                    type="button"
                    class="edit-button"
                    title="쿠폰 수정">

                    ✎

                </button>

            </div>


            <!-- ================================
                 주말 할인 쿠폰
            ================================= -->

            <div class="coupon-card">


                <input
                    type="checkbox"
                    class="coupon-check"
                    name="coupon"
                    value="3">


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




                <button
                    type="button"
                    class="edit-button"
                    title="쿠폰 수정">

                    ✎

                </button>

            </div>


        </div>
		
		<jsp:include page="/WEB-INF/views/common/footer.jsp"/> 
