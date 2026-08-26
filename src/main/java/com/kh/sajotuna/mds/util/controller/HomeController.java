package com.kh.sajotuna.mds.util.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
	
	@GetMapping("/")
	public String home() {
		// webapp/WEB-INK/views/home/home.jsp
		return "member/signUp";
	}
}
