package com.kh.sajotuna.mds.member.service;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

public interface MemberService {

	// 회원 가입
		void join(MemberDTO member);
	
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
}
