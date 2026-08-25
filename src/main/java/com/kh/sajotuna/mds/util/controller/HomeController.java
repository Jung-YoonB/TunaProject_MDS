package com.kh.sajotuna.mds.util.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
	
	@GetMapping("/")
	public String home() {
		// webapp/WEB-INK/views/home/index.jsp
		// TODO : jsp 업로드 후 네이밍 맞춰 경로 변경
		return "home/index";
	}
}
