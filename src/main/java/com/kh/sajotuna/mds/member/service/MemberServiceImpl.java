package com.kh.sajotuna.mds.member.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

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
	public void join(MemberDTO member) {

		
	}

	
}
