package com.kh.sajotuna.mds.util;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

import jakarta.servlet.http.HttpSession;

// admin.controller의 각 컨트롤러가 공통으로 쓰는 관리자 권한 체크
public class AdminAuthUtil {

	private AdminAuthUtil() {}

	public static boolean isAdmin(HttpSession session) {
		MemberDTO member = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		return member != null && "ADMIN".equals(member.getRole());
	}
}
