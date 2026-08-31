package com.kh.sajotuna.mds.member.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;
import com.kh.sajotuna.mds.util.SessionConst;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/member")
@RequiredArgsConstructor
public class MemberController {
	private final MemberService service;
	
	// GET: 화면 요청 / 데이터 조회
	@GetMapping("/signUp")
	public String signUpForm() {
		return "member/signUp";
	}
	
	@GetMapping("/login")
	public String loginForm(@RequestParam(required = false) String redirectURL, Model model) {
		if (isSafeRedirect(redirectURL)) {
			model.addAttribute("redirectURL", redirectURL);
		}
		return "member/login";
	}
	
	@GetMapping("/myPage")
	public String myPageForm(HttpSession session, Model model, RedirectAttributes redirectAttr) {

		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));

		MemberDTO loginMember = service.getMemberByMemberId(member.getMemberId());
		if (loginMember == null) {
			// 세션은 살아있는데 회원 행 자체가 없어진 경우(탈퇴/삭제 등) - 세션을 무효화하고 다시 로그인하게 함
			session.invalidate();
			redirectAttr.addFlashAttribute("error", "회원 정보를 찾을 수 없습니다. 다시 로그인해주세요.");
			return "redirect:/member/login";
		}
		model.addAttribute(SessionConst.LOGIN_MEMBER, loginMember);
		System.out.println("마이페이지용 모델로 저장" + loginMember); // 추적용 출력

		if(member.getRole().equals("USER")) {
			model.addAttribute("couponCount", service.countCoupons(member.getMemberId()));
			model.addAttribute("activeOrderCount", service.countActiveDeliveries(member.getMemberId()));
			model.addAttribute("reviewableCount", service.countReviewableOrderDetails(member.getMemberId()));
			return "member/myPage";
		} else {
			return "admin/adminPage";
		}
		
		// 유저는 loginMember 에 유저DTO가 모델에 저장되고 넘어감
	} 

	@GetMapping("/couponView")
	public String userCouponViewForm(@RequestParam(defaultValue = "1") int page,
			HttpSession session, Model model) {

		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));

		if(member.getRole().equals("USER")) {

			int totalPages = service.totalCouponPages(member.getMemberId());
			int currentPage = Math.min(Math.max(page, 1), totalPages);
			int windowSize = 5;
			int windowStart = Math.max(1, currentPage - windowSize / 2);
			int windowEnd = Math.min(totalPages, windowStart + windowSize - 1);
			windowStart = Math.max(1, windowEnd - windowSize + 1);

			model.addAttribute("couponList", (service.listCoupon(member.getMemberId(), currentPage)));
			System.out.println("유저쿠폰뷰용 모델로 저장" + (List<CouponDTO>)model.getAttribute("couponList")); // 추적용 출력
			model.addAttribute("couponCount", service.countCoupons(member.getMemberId()));
			model.addAttribute("currentPage", currentPage);
			model.addAttribute("totalPages", totalPages);
			model.addAttribute("pageWindowStart", windowStart);
			model.addAttribute("pageWindowEnd", windowEnd);
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
			return "product/wish"; 
		}  else {
			return "admin/adminPage"; // 관리자용 찜 화면이 없어 대시보드로
		} 
		
		// 유저는 wishList에 List<MyPageWishDTO> 가 모델에 최신화 되어 넘어감
	}
	
	@GetMapping("/cart")
	public String cartForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
				
		if(member.getRole().equals("USER")) {
			model.addAttribute("cartList", (service.listCart(member.getMemberId())));
			System.out.println("장바구니용 모델로 저장" + (List<MyPageCartDTO>)model.getAttribute("cartList")); // 추적용 출력
			return "product/cart"; 
		}  else {
			return "admin/adminPage"; // 관리자용 장바구니 화면이 없어 대시보드로
		} 
		// 유저는 cartList에 List<MyPageCartDTO> 가 모델에 최신화 되어 넘어감
	}
	
	@GetMapping("/orderDelivery")
	public String userOrderDeliveryForm(
			@RequestParam(defaultValue = "all") String status,
			@RequestParam(defaultValue = "1") int page,
			HttpSession session, Model model) {

		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));



		if(member.getRole().equals("USER")) {
			model.addAttribute("deliveryList", (service.listDelivery(member.getMemberId(), status, page)));
			System.out.println("배송관리 모델로 저장" + (List<MyPageDeliveryDTO>)model.getAttribute("deliveryList")); // 추적용 출력

			int totalPages = service.totalDeliveryPages(member.getMemberId(), status);
			int currentPage = Math.min(Math.max(page, 1), totalPages);
			int windowSize = 5;
			int windowStart = Math.max(1, currentPage - windowSize / 2);
			int windowEnd = Math.min(totalPages, windowStart + windowSize - 1);
			windowStart = Math.max(1, windowEnd - windowSize + 1);

			model.addAttribute("currentStatus", status);
			model.addAttribute("currentPage", currentPage);
			model.addAttribute("totalPages", totalPages);
			model.addAttribute("pageWindowStart", windowStart);
			model.addAttribute("pageWindowEnd", windowEnd);
			return "order/userOderDelivery";
		}  else {
			return "admin/adminOrderDelivery";
		}

		// 유저는 deliveryList에 List<MyPageDeliveryDTO> 가 모델에 최신화 되어 넘어감
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
			e.printStackTrace();
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
			e.printStackTrace();
			redirectAttr.addFlashAttribute("error", e.getMessage());
			// 로그인 실패 후 재시도할 수 있게, 원래 가려던 곳도 같이 들고 돌아간다
			if (isSafeRedirect(redirectURL)) {
				return "redirect:/member/login?redirectURL=" + URLEncoder.encode(redirectURL, StandardCharsets.UTF_8);
			}
			return "redirect:/member/login";
		}

		if (isSafeRedirect(redirectURL)) {
			return "redirect:" + redirectURL;
		}

		return "redirect:/";
	}

	// 오픈 리다이렉트 방지: 우리 사이트 내부 경로("/"로 시작하되 "//"는 아닌 것)만 리다이렉트 대상으로 허용.
	// "\"도 막아야 함 - 브라우저(특히 Chromium 계열)가 Location 헤더의 백슬래시를 슬래시로 정규화해서,
	// "/\evil.com"처럼 "/"로 시작하지만 "//"는 아닌 값도 "//evil.com"(프로토콜 상대 URL)으로 취급될 수 있음
	private boolean isSafeRedirect(String url) {
		return url != null && !url.isBlank() && url.startsWith("/") && !url.startsWith("//") && !url.contains("\\");
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
	
	@GetMapping("/updateInfo")
	public String updateInfoForm(HttpSession session, Model model) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
		
		if("ADMIN".equals(member.getRole())) {
			return "admin/adminPage";  // 관리자 데이터 수정은 미구현
		} else {
			model.addAttribute(SessionConst.LOGIN_MEMBER, (service.getMemberByMemberId(member.getMemberId())));
			System.out.println("회원 정보 수정용 모델로 저장" + (MemberDTO)model.getAttribute(SessionConst.LOGIN_MEMBER)); // 추적용 출력
			return "member/userUpdateInfo";
		}
		// 관리자 상태 수정은 미구현
		// 유저는 loginMember 에 유저DTO가 모델에 저장되고 넘어감
	}
	
	@PostMapping("/updateNickname")
	@ResponseBody
	public ApiResponse<Boolean> updateNickname(HttpSession session, String nickname) {
		
		MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
		boolean isUpdate = service.nicknameUpdate(member.getMemberId(), nickname);
		
		String message = isUpdate ? "정보 변경에 성공했습니다." : "정보 변경에 실패하셨습니다.";
		
		return ApiResponse.success(message, isUpdate);
	}
	
	@PostMapping("/updatePhone")
	@ResponseBody
	public ApiResponse<Boolean> updatePhone(HttpSession session, String phone) {
	    
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    boolean isUpdate = service.phoneUpdate(member.getMemberId(), phone);
	    
	    String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
	    
	    return ApiResponse.success(message, isUpdate);
	}

	@PostMapping("/updateEmail")
	@ResponseBody
	public ApiResponse<Boolean> updateEmail(HttpSession session, String email) {
	    
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    boolean isUpdate = service.emailUpdate(member.getMemberId(), email);
	    
	    String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
	    
	    return ApiResponse.success(message, isUpdate);
	}

	@PostMapping("/updateName")
	@ResponseBody
	public ApiResponse<Boolean> updateName(HttpSession session, String memberName) {
	    
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    boolean isUpdate = service.nameUpdate(member.getMemberId(), memberName);
	    
	    String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
	    
	    return ApiResponse.success(message, isUpdate);
	}

	@PostMapping("/updateBirth")
	@ResponseBody
	public ApiResponse<Boolean> updateBirth(HttpSession session, String birth) {
	    
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    boolean isUpdate = service.birthUpdate(member.getMemberId(), birth);
	    
	    String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
	    
	    return ApiResponse.success(message, isUpdate);
	}

	@PostMapping("/updateGender")
	@ResponseBody
	public ApiResponse<Boolean> updateGender(HttpSession session, String gender) {
	    
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    boolean isUpdate = service.genderUpdate(member.getMemberId(), gender);
	    
	    String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
	    
	    return ApiResponse.success(message, isUpdate);
	}

	@PostMapping("/updatePassword")
	@ResponseBody
	public ApiResponse<Boolean> updatePassword(HttpSession session, String newPassword) {
	    
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    boolean isUpdate = service.passwordUpdate(member.getMemberId(), newPassword);
	    
	    String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
	    
	    return ApiResponse.success(message, isUpdate);
	}
	
	@PostMapping("/withdraw")
	@ResponseBody
	public ApiResponse<Boolean> withdraw(HttpSession session) {
	    MemberDTO member = ((MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION));
	    
	    if (member == null) {
	        return ApiResponse.fail("로그인 정보가 없습니다.");
	    }
	    
	    boolean isWithdrawn = service.withdrawMember(member.getMemberId());
	    
	    if (isWithdrawn) {
	        session.invalidate(); // 탈퇴 성공 시 세션 무효화
	        return ApiResponse.success("회원 탈퇴가 완료되었습니다.", true);
	    } else {
	        return ApiResponse.fail("회원 탈퇴에 실패했습니다.");
	    }
	}
}