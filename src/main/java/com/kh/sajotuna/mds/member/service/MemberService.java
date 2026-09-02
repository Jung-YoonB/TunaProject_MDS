package com.kh.sajotuna.mds.member.service;

import java.util.List;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.DeliveryAddressDTO;

public interface MemberService {

	// 회원 가입
	void signUp(MemberDTO member);
	
	// 중복체크용
	boolean isLoginIdCheck(String loginId);
	boolean isNicknameCheck(String nickname);
	boolean isEmailCheck(String email);
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
	
	// 회원 정보 수정용
	boolean nicknameUpdate(Long memberId, String nickname);
	boolean phoneUpdate(Long memberId, String phone);
	boolean emailUpdate(Long memberId, String email);
	boolean nameUpdate(Long memberId, String memberName);
	boolean birthUpdate(Long memberId, String birth);
	boolean genderUpdate(Long memberId, String gender);
	boolean passwordUpdate(Long memberId, String currentPassword, String newPassword);
	
	//회원 탈퇴
	boolean withdrawMember(Long memberId);
	
	// 멤버id로 배송데이터 검색 (상태 필터 + 페이징)
	List<MyPageDeliveryDTO> listDelivery(Long memberId, String status, int page);

	// 위 조회 조건의 전체 페이지 수
	int totalDeliveryPages(Long memberId, String status);

	// 마이페이지 "주문/배송 조회" 배지: 진행중인 주문 건수
	int countActiveDeliveries(Long memberId);

	// 마이페이지 "리뷰 작성" 배지: 작성 가능한 리뷰 건수
	int countReviewableOrderDetails(Long memberId);

	// 빠른메뉴 "리뷰 작성" 타일이 바로 보낼 주문상세 1건 (없으면 null)
	Long nextReviewableOdId(Long memberId);

	// 배송지 추가 (utill/deliveryAddress.jsp) - isDefault='Y'면 기존 기본 배송지를 먼저 해제한다
	void addDeliveryAddress(DeliveryAddressDTO address);
}
