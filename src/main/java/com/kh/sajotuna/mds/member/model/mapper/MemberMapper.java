package com.kh.sajotuna.mds.member.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.kh.sajotuna.mds.coupon.model.dto.CouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

@Mapper
public interface MemberMapper {

	// 회원 가입
	int insertMember(MemberDTO member);
	
	// 가입 시 포인트 초기화
	int insertPoint(Long memberId);
	
	// 아이디 중복 확인
	int countByLoginId(String loginId);
		
	// 닉네임 중복 확인
	int countByNickname(String nickname);
				
	// 이메일 중복 확인
	int countByEmail(String email);
				
	// 연락처 중복 확인
	int countByPhone(String phone);
	
	// 로그인 아이디를 통한 회원 조회
	MemberDTO selectByLoginId(String loginId);
	
	// 멤버 아이디를 통한 회원 조회
	MemberDTO selectByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 보유 쿠폰 조회
	List<CouponDTO> selectCouponsByMemberId(Long memberId);
}