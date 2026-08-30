package com.kh.sajotuna.mds.member.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.coupon.model.dto.MyPageCouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;

@Mapper
public interface MemberMapper {

	// 회원 가입
	int insertMember(MemberDTO member);
	
	// 가입 시 포인트 초기화
	int insertPoint(Long memberId);
	
	// 중복 확인
	int countByLoginId(String loginId);
	int countByNickname(String nickname);
	int countByEmail(String email);
	int countByPhone(String phone);
	
	// 로그인 아이디를 통한 회원 조회
	MemberDTO selectByLoginId(String loginId);
	
	// 멤버 아이디를 통한 회원 조회
	MemberDTO selectByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 보유 쿠폰 조회
	List<MyPageCouponDTO> selectCouponsByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 찜 목록 조회
	List<MyPageWishDTO> selectWishesByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 장바구니 조회
	List<MyPageCartDTO> selectCartsByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 배송데이터 조회
	List<MyPageDeliveryDTO> selectDeliveriesByMemberId(Long memberId);
	
	// 오더 아이디를 통한 대표 상품정보 조회
	MyPageDeliveryDTO selectProductByOrderId(Long orderId);
	
	// 회원 정보 수정
	int updateNickname(@Param("memberId") Long memberId, @Param("nickname") String nickname);
	int updatePhone(@Param("memberId") Long memberId, @Param("phone") String phone);
	int updateEmail(@Param("memberId") Long memberId, @Param("email") String email);
	int updateName(@Param("memberId") Long memberId, @Param("memberName") String memberName);
	int updateBirth(@Param("memberId") Long memberId, @Param("birth") String birth);
	int updateGender(@Param("memberId") Long memberId, @Param("gender") String gender);
	int updatePassword(@Param("memberId") Long memberId, @Param("newPassword") String newPassword);
	
	// 회원 탈퇴
	int withdrawMember(Long memberId);
}