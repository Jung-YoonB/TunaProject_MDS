package com.kh.sajotuna.mds.member.controller;

import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.util.SessionConst;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/member")
public class MemberController {
	private final MemberService service;
	public MemberController (MemberService service) {
		this.service = service;
	}
	
	// GET: 화면 요청 / 데이터 조회
	@GetMapping("/signUp")
	public String signUpForm() {
		return "member/signUp";
	}
	
	@GetMapping("/login")
	public String loginForm() {
		return "member/login";
	}
	
	@GetMapping("/mypage")
	public String mypageForm(HttpSession session) {
		long memberId = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_MEMBER)).getMemberId();
		session.setAttribute(SessionConst.LOGIN_MEMBER, (service.getMemberByMemberId(memberId)));
		System.out.println("세션 정보 갱신"); // 추적용 출력
		return "member/mypage";
	}
	
	// POST: CUD 기능
	
	@PostMapping("/signUp")
	public String signUp(@ModelAttribute @Valid MemberDTO member,
						BindingResult bindingResult,
						RedirectAttributes redirectAttr) {
		
		if (bindingResult.hasErrors()) {
			String eMsg = bindingResult.getFieldError().getDefaultMessage();
			redirectAttr.addFlashAttribute("error", eMsg);
			return "redirect:/member/signUp";
		}
		
		try {
				service.signUp(member);
		} catch(IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/member/signUp";
		}
				
		redirectAttr.addFlashAttribute("signUpSuccess", true);
		return "redirect:/member/login";
	}
	
	@GetMapping("/checkId")
	@ResponseBody
	public ApiResponse<Boolean> checkId(String loginId) {
		
		boolean isDuplicate = service.isLoginIdCheck(loginId);
		
		String message = isDuplicate ? "이미 사용중인 아이디입니다." : "사용 가능한 아이디입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@GetMapping("/checkNickname")
	@ResponseBody
	public ApiResponse<Boolean> checkNickname(String nickname) {
		
		boolean isDuplicate = service.isNicknameCheck(nickname);
		
		String message = isDuplicate ? "이미 사용중인 닉네임입니다." : "사용 가능한 닉네임입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@GetMapping("/checkEmail")
	@ResponseBody
	public ApiResponse<Boolean> checkEmail(String email) {
		
		boolean isDuplicate = service.isEmailCheck(email);
		
		String message = isDuplicate ? "이미 사용중인 이메일입니다." : "사용 가능한 이메일입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@GetMapping("/checkPhone")
	@ResponseBody
	public ApiResponse<Boolean> checkPhone(String phone) {
		
		boolean isDuplicate = service.isPhoneCheck(phone);
		
		String message = isDuplicate ? "이미 사용중인 연락처입니다." : "사용 가능한 연락처입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@PostMapping("/login")
	public String login(String loginId, String loginPw
			,@RequestParam(required=false) String redirectURL
			, HttpSession session, RedirectAttributes redirectAttr) {
		try {
		MemberDTO member = service.login(loginId,loginPw);
		
		// 로그인 성공 -> 세션에 저장 / 실패 -> 에러 메시지 전달
		session.setAttribute(SessionConst.LOGIN_MEMBER, member);
		System.out.println("세션 저장 완료: " + session.getAttribute(SessionConst.LOGIN_MEMBER)); // 로그인 체크용 나중에 삭제
		} catch(IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/member/login";
		}
		
		if (redirectURL != null && !redirectURL.isBlank()) {
			return "redirect:" + redirectURL;
		}
		
		return "redirect:/";
	}
	
	@GetMapping("/logout")
	public String logout(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if(session != null) {
			session.invalidate();
		}
		
		return "redirect:/";
	}
}
