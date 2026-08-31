package com.kh.sajotuna.mds.util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.http.HttpServletRequest;

// 로그인이 필요해서 로그인 페이지로 보낼 때, 원래 가려던 주소(+쿼리스트링)를 redirectURL로 담아
// 되돌아올 경로를 만든다. LoginInterceptor(일반 회원 페이지)와 AdminAuthUtil(관리자 페이지)이
// 공통으로 쓴다 - 로그인 후 복귀라는 개념 자체가 관리자 전용이 아니라 사이트 전체 공통이라 여기 둠
public class RedirectUtil {

	private RedirectUtil() {}

	public static String buildLoginRedirectPath(HttpServletRequest request) {
		String path = request.getRequestURI();
		String queryString = request.getQueryString();
		if (queryString != null) {
			path += "?" + queryString;
		}
		String redirectURL = URLEncoder.encode(path, StandardCharsets.UTF_8);
		return "/member/login?redirectURL=" + redirectURL;
	}
}
