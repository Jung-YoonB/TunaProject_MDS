package com.kh.sajotuna.mds.member.model.mapper;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

	public interface MemberMapper {

		// 회원 가입 -> 데이터를 추가
		int insertMember(MemberDTO member);
}
