package com.kh.sajotuna.mds.util;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

import jakarta.servlet.http.HttpSession;

/**
 * 로그인 회원을 세션에서 꺼낼 때 쓰는 공통 진입점(관리자 권한 판정은 {@link AdminAuthUtil}).
 * 세션 키(SessionConst.LOGIN_SESSION)를 여기 한 곳에서만 다뤄, 다른 키와 헷갈릴 여지를 없앤다.
 */
public final class LoginUtil {

	private LoginUtil() {}

	/** 로그인 회원. 비로그인이면 null */
	public static MemberDTO member(HttpSession session) {
		return (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
	}

	/** 로그인 회원의 memberId. 비로그인이면 null (조회 쿼리에 그대로 넘겨도 되는 형태) */
	public static Long memberId(HttpSession session) {
		MemberDTO member = member(session);
		return member != null ? member.getMemberId() : null;
	}
}
