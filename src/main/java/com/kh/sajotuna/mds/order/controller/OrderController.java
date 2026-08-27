package com.kh.sajotuna.mds.order.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.order.model.dto.OrderRequestDTO;
import com.kh.sajotuna.mds.util.SessionConst;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/order")
@RequiredArgsConstructor
public class OrderController {
	
	private final  MemberService memberService;

	@GetMapping("/cartPayment")

	public String paymentForm(HttpSession session, Model model) {

	// 세션의 정보에서 memberId를 받아 회원 정보 받아오기

	MemberDTO loginMember = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
	MemberDTO member = memberService.getMemberByMemberId(loginMember.getMemberId());
	
	//model에 키 값 "shoppingList"으로 저장했다고 가정   <- 뷰에서 저렇게 전달 안된다함 내일 수정
	List<OrderRequestDTO> shoppingList = (List<OrderRequestDTO>)model.getAttribute("shoppingList");
	
	// 회원 정보와 구매하려는 정보 저장하기
	model.addAttribute("member", member);
	model.addAttribute("shoppingList", shoppingList);

	return "/order/payment";
	// 로그인 된 멤버의 회원 정보와 구매하려는 옵션id와 개수 전달
	}
	
	@GetMapping("/directPayment")
	public String cartPaymentForm(HttpSession session, Model model ) {
		
		
		
		return "order/payment";
	}
	
}
