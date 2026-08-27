package com.kh.sajotuna.mds.order.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.util.SessionConst;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/order")
@RequiredArgsConstructor
public class OrderController {
	
	private final  MemberService memberService;

	@GetMapping("/cartPayment")
	public String paymentForm(HttpSession session, Model model,
			@RequestParam(value = "cartIds", required = false) List<Long> cartIds) {

		// 세션의 정보에서 memberId를 받아 회원 정보 받아오기

		MemberDTO loginMember = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
		MemberDTO member = memberService.getMemberByMemberId(loginMember.getMemberId());
	
		//jsp 에서 name = "cartIds" 로 값이 전달 된다고 가정, 카트 테이블에 사려는 개수도 저장될테니 아이디만 받는걸로
		
		// 회원 정보와 구매하려는 정보 저장하기
		model.addAttribute("member", member);
		model.addAttribute("cartIds", cartIds);

		return "order/payment";
		// 로그인 된 멤버의 회원 정보와 구매하려는 장바구니id 전달
	}
	
	@GetMapping("/directPayment")
	public String directPaymentForm(HttpSession session, Model model ) {
		
		// 세션의 정보에서 memberId를 받아 회원 정보 받아오기

		MemberDTO loginMember = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
		MemberDTO member = memberService.getMemberByMemberId(loginMember.getMemberId());	
		
		//
		
		return "order/payment";
	}
	
}
