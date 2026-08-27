package com.kh.sajotuna.mds.member.service;

import java.util.List;

import com.kh.sajotuna.mds.coupon.model.dto.MyPageCouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;

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
	
	// 멤버id로 보유 쿠폰 검색
	List<MyPageCouponDTO> listCoupon(Long memberId);
	
	// 멤버id로 찜하기 검색
	List<MyPageWishDTO> listWish(Long memberId);
	
	// 멤버id로 장바구니 검색
	List<MyPageCartDTO> listCart(Long memberId);
	
	// 멤버id로 배송데이터 검색
	List<MyPageDeliveryDTO> listDelivery(Long memberId);
}
