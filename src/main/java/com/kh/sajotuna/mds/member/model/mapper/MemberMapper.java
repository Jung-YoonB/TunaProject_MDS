package com.kh.sajotuna.mds.member.model.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

@Mapper
public interface MemberMapper {

	// 회원 가입
	int insertMember(MemberDTO member);
	
	// 아이디 중복 확인
	int countByLoginId(String loginId);
		
	// 닉네임 중복 확인
	int countByNickname(String nickname);
				
	// 이메일 중복 확인
	int countByEmail(String email);
				
	// 연락처 중복 확인
	int countByPhone(String phone);
	
	// 아이디를 통한 회원 조회
	MemberDTO selectByLoginId(String loginId);
}