package com.kh.sajotuna.mds.order.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.order.model.dto.CheckoutDTO;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;
import com.kh.sajotuna.mds.order.service.OrderService;
import com.kh.sajotuna.mds.util.SessionConst;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/order")
@RequiredArgsConstructor
public class OrderController {
	
	private final MemberService memberService;
	private final OrderService service;
	
	@GetMapping("/completed")
	public String completed(@RequestParam Long orderId,
	                        HttpSession session,
	                        Model model,
	                        RedirectAttributes redirectAttr) {

	    MemberDTO member =
	            (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);

	    if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
	        return "redirect:/member/login";
	    }

	    try {
	    	Long validOrderId =
	    	        service.getOrderIdForMember(orderId, member.getMemberId());

	    	model.addAttribute("orderId", validOrderId);

	        return "order/orderComplete";

	    } catch (Exception e) {
	        redirectAttr.addFlashAttribute("error", e.getMessage());
	        return "redirect:/";
	    }
	}
	
	@PostMapping("/payment")
	public String paymentForm(HttpSession session, Model model,
			@RequestParam(value = "cartId", required = false) List<Long> cartIds,
			@ModelAttribute OrderItemDTO orderItem,
			RedirectAttributes redirectAttr) {

		PaymentViewDTO pvData = null;
		// 세션의 정보에서 memberId를 받아 회원 정보 받아오기
		MemberDTO loginMember = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
		
		if (loginMember == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
	        return "redirect:/member/login";
	    }
		
		if (cartIds != null && !cartIds.isEmpty()) { // 장바구니로 넘어온 경우
			pvData = service.cartPrepare(loginMember.getMemberId(), cartIds);
			
		} else if (orderItem.getPopId() != null) { // 바로구매로 넘어온 경우
			pvData = service.directPrepare(loginMember.getMemberId(), orderItem);
		} else { // 장바구니가 0 인채로 넘어왔거나 이상한 접근
			redirectAttr.addFlashAttribute("error", "장바구니에 담은게 없거나 잘못된 접근입니다.");
			return "redirect:/product/cart"; // 카트 주소 생기면 수정
		}
		model.addAttribute("pvData", pvData);
		return "order/payment";
	}
	
	@PostMapping("/checkout")
	public String checkout(HttpSession session,
	                       @ModelAttribute CheckoutDTO checkoutData,
	                       RedirectAttributes redirectAttr) {

	    MemberDTO member =
	            (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);

	    if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
	        return "redirect:/member/login";
	    }

	    checkoutData.setMemberId(member.getMemberId());

	    try {
	        CheckoutDTO resultData = service.checkout(checkoutData);

	        return "redirect:/order/completed?orderId=" + resultData.getOrderId();

	    } catch (Exception e) {
	        e.printStackTrace();
	        redirectAttr.addFlashAttribute("error", e.getMessage());
	        return "redirect:/order/payment";
	    }
	}
}