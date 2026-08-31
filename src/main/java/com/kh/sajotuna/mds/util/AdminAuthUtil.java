package com.kh.sajotuna.mds.util;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

// admin.controller의 각 컨트롤러가 공통으로 쓰는 관리자 권한 체크
public class AdminAuthUtil {

	private AdminAuthUtil() {}

	public static boolean isAdmin(HttpSession session) {
		MemberDTO member = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		return member != null && "ADMIN".equals(member.getRole());
	}

	// 로그인 안 됐거나 ADMIN이 아닐 때 보낼 리다이렉트 view 이름.
	// 원래 가려던 주소(+쿼리스트링)를 redirectURL로 담아서 보낸다 (RedirectUtil을 LoginInterceptor와 공유)
	public static String loginRedirect(HttpServletRequest request) {
		return "redirect:" + RedirectUtil.buildLoginRedirectPath(request);
	}

	// 관리자 페이지 접근 전 공통 가드: 통과하면 null, 아니면 로그인 페이지로 보낼 view 이름
	public static String pageGuard(HttpServletRequest request, HttpSession session) {
		return isAdmin(session) ? null : loginRedirect(request);
	}

	// 관리자 전용 API 접근 전 공통 가드: 통과하면 null, 아니면 에러 메시지
	public static String apiGuard(HttpSession session) {
		return isAdmin(session) ? null : "관리자만 접근할 수 있습니다.";
	}
}
