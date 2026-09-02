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
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
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
		

	    System.out.println("===== completed 진입 =====");  //추적용
	    System.out.println("orderId = " + orderId);    //추적용

	    MemberDTO member =
	            (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
	    
	    System.out.println("memberId = " +
	            (member != null ? member.getMemberId() : null));  // 추적용

	    if (member == null) {
	    	 System.out.println(">>> 로그인 세션 없음"); //추적
	        redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
	        return "redirect:/member/login";
	    }

	    try {
	    	Long validOrderId =
	    	        service.getOrderIdForMember(member.getMemberId(), orderId);

	        System.out.println(">>> 조회된 validOrderId = " + validOrderId); //추적

	    	model.addAttribute("orderId", validOrderId);
	    	
	        System.out.println(">>> orderComplete.jsp 이동");  //추적


	        return "order/orderComplete";

	    } catch (Exception e) {
	        System.out.println("===== 주문 완료 페이지 진입 실패 ====="); //추적

	    	e.printStackTrace(); //추적
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
			pvData.setCartIds(cartIds);
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
	
	@GetMapping("/userOrderDelivery")
	public String userOrderDelivery(
	        HttpSession session,
	        Model model,
	        @RequestParam(defaultValue = "all") String status,
	        @RequestParam(defaultValue = "1") int page) {

	    MemberDTO member =
	            (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);

	    if (member == null) {
	        return "redirect:/member/login";
	    }

	    Long memberId = member.getMemberId();

	    List<MyPageDeliveryDTO> deliveryList =
	            memberService.listDelivery(memberId, status, page);

	    int totalPages =
	            memberService.totalDeliveryPages(memberId, status);

	    int currentPage =
	            Math.max(1, Math.min(page, totalPages));

	    int pageWindowSize = 5;

	    int pageWindowStart =
	            ((currentPage - 1) / pageWindowSize)
	            * pageWindowSize + 1;

	    int pageWindowEnd =
	            Math.min(
	                    pageWindowStart + pageWindowSize - 1,
	                    totalPages
	            );

	    model.addAttribute("deliveryList", deliveryList);
	    model.addAttribute("currentStatus", status);
	    model.addAttribute("currentPage", currentPage);
	    model.addAttribute("totalPages", totalPages);
	    model.addAttribute("pageWindowStart", pageWindowStart);
	    model.addAttribute("pageWindowEnd", pageWindowEnd);

	    return "order/userOrderDelivery";
	}

}