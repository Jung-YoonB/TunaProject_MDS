package com.kh.sajotuna.mds.member.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.kh.sajotuna.mds.member.service.MemberService;

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
	
}
