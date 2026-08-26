package com.kh.sajotuna.mds.util.interceptor;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.web.servlet.HandlerInterceptor;

import com.kh.sajotuna.mds.util.SessionConst;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LoginInterceptor implements HandlerInterceptor {
	// 이 인터셉터를 통해 로그인이 필요한 경로와 아닌 경로를 분리하여 로그인 여부 검사
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
		HttpSession session = request.getSession(false);
		
		boolean isLoggedIn = session != null && session.getAttribute(SessionConst.LOGIN_MEMBER) != null;
		
		// 로그인 되어 있을 경우 컨트롤러 경로 진행
		if (isLoggedIn) return true;
		
		// 로그인 후 기존에 요청했던 주소로 리다이렉트 처리
		String redirectURL = URLEncoder.encode(request.getRequestURI(), StandardCharsets.UTF_8);
		response.sendRedirect("/member/login?redirectURL=" + redirectURL);
		
		return false;
	}
	
}
