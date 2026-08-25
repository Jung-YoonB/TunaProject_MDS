package com.kh.sajotuna.mds.member.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService{

	// MemberMapper DI
	private final MemberMapper mapper;
	// PasswordEncoder DI
	private final PasswordEncoder passwordEncoder;
	
	@Override
	@Transactional
	public void signUp(MemberDTO member) {
		// 아이디 중복검사
		if(isLoginIdCheck(member.getLoginId())) {
			throw new IllegalStateException("이미 사용중인 아이디입니다.");
		}
		
		// 닉네임 중복검사
		if(isNicknameCheck(member.getNickname())) {
			throw new IllegalStateException("이미 사용중인 닉네임입니다.");
		}
		
		// 이메일 중복검사
		if(isEmailCheck(member.getEmail())) {
			throw new IllegalStateException("이미 사용중인 이메일입니다.");
		}
		
		// 연락처 중복검사
		if(isPhoneCheck(member.getPhone())) {
			throw new IllegalStateException("이미 사용중인 연락처입니다.");
		}
				
		// 비밀번호 암호화 처리
		String encodePw = passwordEncoder.encode(member.getLoginPw());
		member.setLoginPw(encodePw);
				
		// 체크 된 데이터를 저장
		mapper.insertMember(member);
		mapper.insertPoint(member.getMemberId()); // 회원의 포인트도 초기화
		
	}

	@Override
	public boolean isLoginIdCheck(String loginId) {
		// 중복된 아이디가 있으면 검색 결과가 0이 아님.
		return mapper.countByLoginId(loginId) > 0;
	}

	@Override
	public boolean isNicknameCheck(String nickname) {
		return mapper.countByNickname(nickname) > 0;
	}

	@Override
	public boolean isEmailCheck(String email) {
		return mapper.countByEmail(email) > 0;
	}

	@Override
	public boolean isPhoneCheck(String phone) {
		return mapper.countByPhone(phone) > 0;
	}

	@Override
	public MemberDTO login(String loginId, String loginPw) throws IllegalStateException{
		MemberDTO member = mapper.selectByLoginId(loginId);
		
		if (member == null || !passwordEncoder.matches(loginPw, member.getLoginPw())) {
			throw new IllegalStateException("아이디 또는 비밀번호가 일치하지 않습니다.");
		}
		
		return member;
	}

	@Override
	public MemberDTO getMemberByMemberId(Long memberId) {
		MemberDTO member = mapper.selectByMemberId(memberId);
		
		return member;
	}
	
}
