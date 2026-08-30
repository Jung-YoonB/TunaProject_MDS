package com.kh.sajotuna.mds.member.service;

import java.util.List;

import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;
import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;

public interface MemberService {

	// 회원 가입
	void signUp(MemberDTO member);
	
	// 아이디 중복체크
	boolean isLoginIdCheck(String loginId);
	
	// 닉네임 중복 체크
	boolean isNicknameCheck(String nickname);
	
	// 이메일 중복 체크
	boolean isEmailCheck(String email);
		
	// 연락처 중복 체크
	boolean isPhoneCheck(String phone);
	
	// 로그인
	MemberDTO login(String loginId, String loginPw);
	
	// 멤버id로 회원 정보 검색
	MemberDTO getMemberByMemberId(Long memberId);
	
	// 멤버id로 사용 가능한 보유 쿠폰 검색 (페이징)
	List<CouponDTO> listCoupon(Long memberId, int page);

	// 위 조회 조건의 전체 페이지 수
	int totalCouponPages(Long memberId);

	// 마이페이지 배지용 - 사용 가능한 보유 쿠폰 건수
	int countCoupons(Long memberId);
	
	// 멤버id로 찜하기 검색
	List<MyPageWishDTO> listWish(Long memberId);
	
	// 멤버id로 장바구니 검색
	List<MyPageCartDTO> listCart(Long memberId);
	
	// 멤버id로 배송데이터 검색 (상태 필터 + 페이징)
	List<MyPageDeliveryDTO> listDelivery(Long memberId, String status, int page);

	// 위 조회 조건의 전체 페이지 수
	int totalDeliveryPages(Long memberId, String status);

	// 마이페이지 "주문/배송 조회" 배지: 진행중인 주문 건수
	int countActiveDeliveries(Long memberId);

	// 마이페이지 "리뷰 작성" 배지: 작성 가능한 리뷰 건수
	int countReviewableOrderDetails(Long memberId);
}
