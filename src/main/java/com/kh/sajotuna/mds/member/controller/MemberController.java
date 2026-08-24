package com.kh.sajotuna.mds.member.controller;

import java.io.IOException;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
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
	
	@PostMapping("/join")
	public String join(@ModelAttribute MemberDTO member,
						RedirectAttributes redirectAttr) {
		
		System.out.println(member);
		
		try {
				service.join(member);
		} catch(IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/member/join";
		}
				
		redirectAttr.addFlashAttribute("joinSuccess", true);
		return "redirect:/member/login";
	}
}
