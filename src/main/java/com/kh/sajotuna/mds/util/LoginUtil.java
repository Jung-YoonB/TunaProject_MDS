package com.kh.sajotuna.mds.util;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

import jakarta.servlet.http.HttpSession;

/**
 * 로그인 회원을 세션에서 꺼낼 때 쓰는 공통 진입점. (관리자 권한 판정은 {@link AdminAuthUtil})
 *
 * 세션 키를 여기 한 곳에서만 다루려고 만들었다. 예전에 컨트롤러가 {@code LOGIN_MEMBER}로 읽어
 * 항상 null이 되는 바람에 NPE로 500이 난 적이 있는데, {@code LOGIN_MEMBER}는 세션 키가 아니라
 * Model attribute 이름이다. 이 클래스를 거치면 그런 실수 자체가 불가능하다.
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
