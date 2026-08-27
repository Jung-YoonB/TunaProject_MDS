package com.kh.sajotuna.mds.coupon.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/coupon")
public class CouponController {

	@GetMapping("/couponview")
	public String couponViewForm(HttpSession session, Model model) {
		System.out.println("=== 쿠폰뷰 컨트롤러 진입 성공 ===");
		
		return "coupon/couponview";
	}
	
}
