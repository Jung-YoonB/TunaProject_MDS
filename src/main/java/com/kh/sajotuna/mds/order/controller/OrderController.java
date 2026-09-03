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

import com.kh.sajotuna.mds.util.LoginUtil;
import com.kh.sajotuna.mds.util.PageWindow;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.order.model.dto.CheckoutDTO;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;
import com.kh.sajotuna.mds.order.model.dto.PendingCheckoutDTO;
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
	            LoginUtil.member(session);
	    
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
	
	// 진행 중인 결제를 세션에 붙잡아 두는 시간. 결제 화면을 잠깐 벗어났다가 헤더의 결제
	// 아이콘으로 돌아와 이어서 결제할 수 있게 하기 위한 값이다.
	private static final long PENDING_CHECKOUT_TTL_MS = 30 * 60 * 1000L;

	// 장바구니 화면 경로. 예전 "redirect:/product/cart"는 컨트롤러가 없어 404였다.
	private static final String CART_URL = "redirect:/cart/my-cart";

	// 뷰를 직접 그리지 않고 리다이렉트한다(Post-Redirect-Get). 이 POST가 히스토리에 남으면
	// 뒤로가기·새로고침 때 브라우저가 "양식을 다시 제출하시겠습니까?"를 띄운다.
	// 아래 GET(paymentResume)이 같은 세션 데이터로 같은 화면을 그리므로 로직 중복은 없다.
	@PostMapping("/payment")
	public String paymentForm(HttpSession session,
			@RequestParam(value = "cartId", required = false) List<Long> cartIds,
			@ModelAttribute OrderItemDTO orderItem,
			RedirectAttributes redirectAttr) {

		MemberDTO loginMember = LoginUtil.member(session);

		if (loginMember == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
	        return "redirect:/member/login";
	    }

		PendingCheckoutDTO pending = new PendingCheckoutDTO();

		if (cartIds != null && !cartIds.isEmpty()) { // 장바구니로 넘어온 경우
			pending.setCartIds(cartIds);
		} else if (orderItem.getPopId() != null) { // 바로구매로 넘어온 경우
			pending.setPopId(orderItem.getPopId());
			pending.setQty(orderItem.getQty());
		} else { // 장바구니가 0 인채로 넘어왔거나 이상한 접근
			redirectAttr.addFlashAttribute("error", "장바구니에 담은게 없거나 잘못된 접근입니다.");
			return CART_URL;
		}

		pending.setSavedAt(System.currentTimeMillis());

		// 다른 화면에 갔다가 돌아올 수 있도록 "무엇을 사려던 중인지"를 남겨둔다.
		// 화면이 아니라 선택만 담아야 다시 열 때 가격·재고·포인트가 최신으로 다시 계산된다.
		session.setAttribute(SessionConst.PENDING_CHECKOUT, pending);

		return "redirect:/order/payment";
	}


	/**
	 * 헤더의 결제 아이콘으로 돌아왔을 때 - 세션에 남은 선택으로 결제 화면을 다시 연다.
	 * 담아둔 게 없거나 시간이 지났으면 장바구니로 보낸다.
	 */
	@GetMapping("/payment")
	public String paymentResume(HttpSession session, Model model, RedirectAttributes redirectAttr) {

		MemberDTO loginMember = LoginUtil.member(session);

		if (loginMember == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
			return "redirect:/member/login";
		}

		PendingCheckoutDTO pending =
				(PendingCheckoutDTO) session.getAttribute(SessionConst.PENDING_CHECKOUT);

		if (pending == null) {
			redirectAttr.addFlashAttribute("error", "진행 중인 결제가 없습니다. 상품을 선택해 주세요.");
			return CART_URL;
		}

		if (pending.isExpired(PENDING_CHECKOUT_TTL_MS)) {
			session.removeAttribute(SessionConst.PENDING_CHECKOUT);
			redirectAttr.addFlashAttribute("error", "결제 진행 시간이 지났습니다. 다시 선택해 주세요.");
			return CART_URL;
		}

		try {
			model.addAttribute("pvData", buildPaymentView(loginMember.getMemberId(), pending));
		} catch (RuntimeException e) {
			// 담아둔 사이에 상품이 내려갔거나 장바구니에서 빠진 경우
			session.removeAttribute(SessionConst.PENDING_CHECKOUT);
			redirectAttr.addFlashAttribute("error", "선택하신 상품을 다시 확인해 주세요.");
			return CART_URL;
		}

		return "order/payment";
	}


	/** 장바구니/바로구매 어느 쪽이든 같은 결제 화면 데이터를 만든다 */
	private PaymentViewDTO buildPaymentView(Long memberId, PendingCheckoutDTO pending) {

		if (pending.isFromCart()) {
			PaymentViewDTO pvData = service.cartPrepare(memberId, pending.getCartIds());
			pvData.setCartIds(pending.getCartIds());
			return pvData;
		}

		OrderItemDTO item = new OrderItemDTO();
		item.setPopId(pending.getPopId());
		item.setQty(pending.getQty());
		return service.directPrepare(memberId, item);
	}
	
	// 주문 실행은 결제 버튼 클릭(POST)으로만 일어나야 하므로 GET으로 처리하면 안 된다.
	// 다만 새로고침·주소창 재입력으로 GET이 들어오면 날것의 405가 뜨므로 결제 화면으로 돌려보낸다.
	@GetMapping("/checkout")
	public String checkoutWrongMethod() {
		return "redirect:/order/payment";
	}

	@PostMapping("/checkout")
	public String checkout(HttpSession session,
	                       @ModelAttribute CheckoutDTO checkoutData,
	                       RedirectAttributes redirectAttr) {

	    MemberDTO member =
	            LoginUtil.member(session);

	    if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
	        return "redirect:/member/login";
	    }

	    checkoutData.setMemberId(member.getMemberId());

	    try {
	        CheckoutDTO resultData = service.checkout(checkoutData);

	        // 결제가 끝났으니 "진행 중인 결제"는 비운다.
	        // 안 비우면 헤더의 결제 아이콘이 이미 산 주문을 다시 열어준다.
	        session.removeAttribute(SessionConst.PENDING_CHECKOUT);

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
	            LoginUtil.member(session);

	    if (member == null) {
	        return "redirect:/member/login";
	    }

	    Long memberId = member.getMemberId();

	    List<MyPageDeliveryDTO> deliveryList =
	            memberService.listDelivery(memberId, status, page);

	    model.addAttribute("deliveryList", deliveryList);
	    model.addAttribute("currentStatus", status);

	    // MemberController.userOrderDeliveryForm 과 같은 화면(order/userOrderDelivery)을 그리므로
	    // 페이지 번호 계산도 같아야 한다. 예전엔 여기만 블록 방식(1-5, 6-10)이라 어느 경로로
	    // 들어왔는지에 따라 같은 화면의 페이지 번호가 다르게 보였다.
	    PageWindow.of(page, memberService.totalDeliveryPages(memberId, status)).addTo(model);

	    return "order/userOrderDelivery";
	}

}
