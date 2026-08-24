package com.kh.sajotuna.mds.member.controller;

import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.common.dto.ApiResponse;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.service.MemberService;

import jakarta.validation.Valid;

@Controller
@RequestMapping("/member")
public class MemberController {
	private final MemberService service;
	public MemberController (MemberService service) {
		this.service = service;
	}
	
	// 단순 화면 이동
	@GetMapping("/join")
	public String joinForm() {
		return "member/join";
	}
	
	//------------------
	
	@PostMapping("/join")
	public String join(@ModelAttribute @Valid MemberDTO member,
						BindingResult bindingResult,
						RedirectAttributes redirectAttr) {
		
		if (bindingResult.hasErrors()) {
			String eMsg = bindingResult.getFieldError().getDefaultMessage();
			redirectAttr.addFlashAttribute("error", eMsg);
			return "redirect:/member/join";
		}
		
		try {
				service.join(member);
		} catch(IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/member/join";
		}
				
		redirectAttr.addFlashAttribute("joinSuccess", true);
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
}
