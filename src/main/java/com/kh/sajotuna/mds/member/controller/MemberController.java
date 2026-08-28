package com.kh.sajotuna.mds.member.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.coupon.model.dto.MypageCouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.util.SessionConst;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/member")
public class MemberController {
	private final MemberService service;
	public MemberController (MemberService service) {
		this.service = service;
	}
	
	// GET: 화면 요청 / 데이터 조회
	@GetMapping("/signUp")
	public String signUpForm() {
		return "member/signUp";
	}
	
	@GetMapping("/login")
	public String loginForm() {
		return "member/login";
	}
	
	@GetMapping("/myPage")
	public String myPageForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
		model.addAttribute(SessionConst.LOGIN_MEMBER, (service.getMemberByMemberId(member.getMemberId())));
		System.out.println("마이페이지용 모델로 저장" + (MemberDTO)model.getAttribute(SessionConst.LOGIN_MEMBER)); // 추적용 출력
				
		if(member.getRole().equals("USER")) {
			model.addAttribute("couponList", (service.listCoupon(member.getMemberId())));
			return "member/myPage";
		} else {
			return "admin/adminPage";
		}
		// 유저는 loginMember 에 유저DTO, couponList에 List<CouponDTO> 가 모델에 저장되고 넘어감
	}
	
	@GetMapping("/couponView")
	public String userCouponViewForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
				
		if(member.getRole().equals("USER")) {
			model.addAttribute("couponList", (service.listCoupon(member.getMemberId())));
			System.out.println("유저쿠폰뷰용 모델로 저장" + (List<MypageCouponDTO>)model.getAttribute("couponList")); // 추적용 출력
			return "member/usercouponView";
		} else {
			return "admin/admincouponView";
		}
		// 유저는 couponList에 List<CouponDTO> 가 모델에 최신화 되어 넘어감
	}
	
	@GetMapping("/wish")
	public String wishlistForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
		
		if(member.getRole().equals("USER")) {
			model.addAttribute("wishList", (service.listWish(member.getMemberId())));
			System.out.println("찜하기용 모델로 저장" + (List<MyPageWishDTO>)model.getAttribute("wishList")); // 추적용 출력
			return "member/wish"; 
		}  else {
			return "admin/adminPage"; // 관리자용 찜 화면이 없어 대시보드로
		} 
		
		// 유저는 wishList에 List<CouponDTO> 가 모델에 최신화 되어 넘어감
	}
	
	@GetMapping("/cart")
	public String cartForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
				
		if(member.getRole().equals("USER")) {
			model.addAttribute("cartList", (service.listCart(member.getMemberId())));
			System.out.println("장바구니용 모델로 저장" + (List<MyPageCartDTO>)model.getAttribute("cartList")); // 추적용 출력
			return "member/cart"; 
		}  else {
			return "admin/adminPage"; // 관리자용 장바구니 화면이 없어 대시보드로
		} 
		// 유저는 cartList에 List<CartDTO> 가 모델에 최신화 되어 넘어감
	}
	
	@GetMapping("/orderDelivery")
	public String userOrderDeliveryForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
		
		
		
		if(member.getRole().equals("USER")) {
			model.addAttribute("deliveryList", (service.listDelivery(member.getMemberId())));
			System.out.println("배송관리 모델로 저장" + (List<MyPageDeliveryDTO>)model.getAttribute("deliveryList")); // 추적용 출력
			return "member/orderDelivery"; 
		}  else {
			return "admin/adminOrderDelivery";
		} 
		
		// 유저는 cartList에 List<CouponDTO> 가 모델에 최신화 되어 넘어감
	}
	
	
	// POST: CUD 기능
	
	@PostMapping("/signUp")
	public String signUp(@ModelAttribute @Valid MemberDTO member,
						BindingResult bindingResult,
						Model model,
						RedirectAttributes redirectAttr) {
		
		if (bindingResult.hasErrors()) {
			String eMsg = bindingResult.getFieldError().getDefaultMessage();
			model.addAttribute("error", eMsg);
			return "member/signUp";
		}
		
		try {
				service.signUp(member);
		} catch(IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/member/signUp";
		}
				
		redirectAttr.addFlashAttribute("signUpSuccess", true);
		return "redirect:/member/login";
	}
	
	@GetMapping("/checkId")
	@ResponseBody
	public ApiResponse<Boolean> checkId(String loginId) {
		
		boolean isDuplicate = service.isLoginIdCheck(loginId);
		
		String message = isDuplicate ? "이미 사용중인 아이디입니다." : "사용 가능한 아이디입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@GetMapping("/checkNickname")
	@ResponseBody
	public ApiResponse<Boolean> checkNickname(String nickname) {
		
		boolean isDuplicate = service.isNicknameCheck(nickname);
		
		String message = isDuplicate ? "이미 사용중인 닉네임입니다." : "사용 가능한 닉네임입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@GetMapping("/checkEmail")
	@ResponseBody
	public ApiResponse<Boolean> checkEmail(String email) {
		
		boolean isDuplicate = service.isEmailCheck(email);
		
		String message = isDuplicate ? "이미 사용중인 이메일입니다." : "사용 가능한 이메일입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@GetMapping("/checkPhone")
	@ResponseBody
	public ApiResponse<Boolean> checkPhone(String phone) {
		
		boolean isDuplicate = service.isPhoneCheck(phone);
		
		String message = isDuplicate ? "이미 사용중인 연락처입니다." : "사용 가능한 연락처입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	@PostMapping("/login")
	public String login(String loginId, String loginPw
			,@RequestParam(required=false) String redirectURL
			, HttpSession session, RedirectAttributes redirectAttr) {
		try {
			MemberDTO member = service.login(loginId,loginPw);
		// 로그인 성공 -> 세션에 저장 / 실패 -> 에러 메시지 전달
		session.setAttribute(SessionConst.LOGIN_SESSION, member );
		System.out.println("세션 저장 완료: " + session.getAttribute(SessionConst.LOGIN_SESSION)); // 로그인 체크용 나중에 삭제
		} catch(IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/member/login";
		}
		
		if (redirectURL != null && !redirectURL.isBlank()) {
			return "redirect:" + redirectURL;
		}
		
		return "redirect:/";
	}
	
	@GetMapping("/logout")
	public String logout(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if(session != null) {
			session.invalidate();
		}
		System.out.println("로그아웃 완료");
		return "redirect:/";
	}
}