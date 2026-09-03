package com.kh.sajotuna.mds.member.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.util.LoginUtil;
import com.kh.sajotuna.mds.util.PageWindow;
import com.kh.sajotuna.mds.member.model.dto.DeliveryAddressDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.service.MemberService;
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

		MemberDTO member = LoginUtil.member(session);
		
		if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }

		MemberDTO loginMember = service.getMemberByMemberId(member.getMemberId());
		if (loginMember == null) {
			// 세션은 살아있는데 회원 행 자체가 없어진 경우(탈퇴/삭제 등) - 세션을 무효화하고 다시 로그인하게 함
			session.invalidate();
			redirectAttr.addFlashAttribute("error", "회원 정보를 찾을 수 없습니다. 다시 로그인해주세요.");
			return "redirect:/member/login";
		}
		model.addAttribute(SessionConst.LOGIN_MEMBER, loginMember);

		if(member.getRole().equals("USER")) {
			model.addAttribute("couponCount", service.countCoupons(member.getMemberId()));
			model.addAttribute("activeOrderCount", service.countActiveDeliveries(member.getMemberId()));
			model.addAttribute("reviewableCount", service.countReviewableOrderDetails(member.getMemberId()));
			// 빠른메뉴 "리뷰 작성" 타일이 작성 화면으로 바로 보낼 대상. 없으면 null이라 JSP가 주문·배송으로 분기한다
			model.addAttribute("nextReviewableOdId", service.nextReviewableOdId(member.getMemberId()));
			return "member/myPage";
		} else {
			return "admin/adminPage";
		}
	}

	@GetMapping("/couponView")
	public String userCouponViewForm(@RequestParam(defaultValue = "1") int page,
			HttpSession session, Model model, RedirectAttributes redirectAttr) {

		MemberDTO member = LoginUtil.member(session);

		if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }
		
		if(member.getRole().equals("USER")) {

			PageWindow paging = PageWindow.of(page, service.totalCouponPages(member.getMemberId()));
			int currentPage = paging.currentPage();

			model.addAttribute("couponList", (service.listCoupon(member.getMemberId(), currentPage)));
			model.addAttribute("couponCount", service.countCoupons(member.getMemberId()));
			paging.addTo(model);
			return "member/usercouponView";
		} else {
			return "admin/admincouponView";
		}
	}
	
	@GetMapping("/orderDelivery")
	public String userOrderDeliveryForm(
			@RequestParam(defaultValue = "all") String status,
			@RequestParam(defaultValue = "1") int page,
			HttpSession session, Model model,
			RedirectAttributes redirectAttr) {

		MemberDTO member = LoginUtil.member(session);

		if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }


		if(member.getRole().equals("USER")) {
			model.addAttribute("deliveryList", (service.listDelivery(member.getMemberId(), status, page)));

			model.addAttribute("currentStatus", status);
			PageWindow.of(page, service.totalDeliveryPages(member.getMemberId(), status)).addTo(model);
			return "order/userOrderDelivery";
		}  else {
			return "admin/adminOrderDelivery";
		}
	}
	
	// 다른 회원 화면과 달리 로그인 가드가 없어 비로그인 상태에서도 탈퇴 화면이 그대로 열렸다.
	// 실제 탈퇴(POST /member/withdraw)는 막혀 있었지만, 화면이 열리는 것 자체가 혼란을 준다.
	@GetMapping("/userWithdraw")
	public String userWithdraw(HttpSession session, RedirectAttributes redirectAttr) {
	    if (session.getAttribute(SessionConst.LOGIN_SESSION) == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }
	    return "member/userWithdraw";
	}

	// returnUrl은 "배송지 추가를 끝내고 돌아갈 화면". 결제 화면에서 들어오면 결제 화면으로
	// 돌려보내야 한다(예전엔 어디서 들어오든 회원정보 수정으로 보내고 있었다).
	@GetMapping("/deliveryAddress")
	public String deliveryAddressForm(@RequestParam(required = false) String returnUrl,
	        HttpSession session, Model model, RedirectAttributes redirectAttr) {
	    if (LoginUtil.member(session) == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }
	    if (isSafeRedirect(returnUrl)) {
	        model.addAttribute("returnUrl", returnUrl);
	    }
	    return "utill/deliveryAddress";
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
				
		redirectAttr.addFlashAttribute("signUpSuccess", "회원가입에 성공하셨습니다. 로그인해주세요");
		return "redirect:/member/login";
	}
	
	@GetMapping("/checkId")
	@ResponseBody
	public ApiResponse<Boolean> checkId(String loginId) {
		
		boolean isDuplicate = service.isLoginIdCheck(loginId);
		
		String message = isDuplicate ? "이미 사용중인 아이디입니다." : "사용 가능한 아이디입니다.";
		
		return ApiResponse.success(message, isDuplicate);
	}
	
	// 중복확인 3종은 회원가입/회원정보 수정이 같은 주소를 쓴다. 로그인 상태면 본인은 안 센다
	// (안 그러면 자기 값을 그대로 다시 확인했을 때도 "이미 사용중"이 뜬다)
	@GetMapping("/checkNickname")
	@ResponseBody
	public ApiResponse<Boolean> checkNickname(String nickname, HttpSession session) {

		boolean isDuplicate = service.isNicknameCheck(nickname, LoginUtil.memberId(session));

		String message = isDuplicate ? "이미 사용중인 닉네임입니다." : "사용 가능한 닉네임입니다.";

		return ApiResponse.success(message, isDuplicate);
	}

	@GetMapping("/checkEmail")
	@ResponseBody
	public ApiResponse<Boolean> checkEmail(String email, HttpSession session) {

		boolean isDuplicate = service.isEmailCheck(email, LoginUtil.memberId(session));

		String message = isDuplicate ? "이미 사용중인 이메일입니다." : "사용 가능한 이메일입니다.";

		return ApiResponse.success(message, isDuplicate);
	}

	@GetMapping("/checkPhone")
	@ResponseBody
	public ApiResponse<Boolean> checkPhone(String phone, HttpSession session) {

		boolean isDuplicate = service.isPhoneCheck(phone, LoginUtil.memberId(session));

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
		return "redirect:/";
	}
	
	@GetMapping("/updateInfo")
	public String updateInfoForm(HttpSession session, Model model,
					RedirectAttributes redirectAttr) {
		
		MemberDTO member = LoginUtil.member(session);
		
		if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }
		
		if("ADMIN".equals(member.getRole())) {
			return "admin/adminPage";  // 관리자 데이터 수정은 미구현
		} else {
			model.addAttribute(SessionConst.LOGIN_MEMBER, (service.getMemberByMemberId(member.getMemberId())));
			// 배송지 드롭다운 초기 목록 - 기본 배송지가 항상 맨 위(매퍼 ORDER BY)
			model.addAttribute("deliveryAddressList", service.listDeliveryAddresses(member.getMemberId()));
			return "member/userUpdateInfo";
		}
	}
	
	@PostMapping("/updateNickname")
	@ResponseBody
	public ApiResponse<Boolean> updateNickname(HttpSession session, String nickname) {
	try {
	MemberDTO member = LoginUtil.member(session);
	if (member == null) {
	return ApiResponse.fail("로그인 정보가 존재하지 않습니다.");
	}
	boolean isUpdate = service.nicknameUpdate(member.getMemberId(), nickname);

			// 헤더가 세션의 nickname을 "OOO님"으로 노출하므로(#TB006_TC-12),
			// 세션 값을 같이 갱신하지 않으면 다시 로그인하기 전까지 옛 닉네임이 계속 보인다
			if (isUpdate) {
				member.setNickname(nickname);
			}

			String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패하셨습니다.";
			return ApiResponse.success(message, isUpdate);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
	}

	@PostMapping("/updatePhone")
	@ResponseBody
	public ApiResponse<Boolean> updatePhone(HttpSession session, String phone) {
		try {
			MemberDTO member = LoginUtil.member(session);
			if (member == null) {
				return ApiResponse.fail("로그인 정보가 존재하지 않습니다.");
			}
			boolean isUpdate = service.phoneUpdate(member.getMemberId(), phone);

			String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
			return ApiResponse.success(message, isUpdate);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
	}

	@PostMapping("/updateEmail")
	@ResponseBody
	public ApiResponse<Boolean> updateEmail(HttpSession session, String email) {
		try {
			MemberDTO member = LoginUtil.member(session);
			if (member == null) {
				return ApiResponse.fail("로그인 정보가 존재하지 않습니다.");
			}
			boolean isUpdate = service.emailUpdate(member.getMemberId(), email);

			String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
			return ApiResponse.success(message, isUpdate);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
	}

	@PostMapping("/updateName")
	@ResponseBody
	public ApiResponse<Boolean> updateName(HttpSession session, String memberName) {
		try {
			MemberDTO member = LoginUtil.member(session);
			if (member == null) {
				return ApiResponse.fail("로그인 정보가 존재하지 않습니다.");
			}
			boolean isUpdate = service.nameUpdate(member.getMemberId(), memberName);

			if (isUpdate) {
				member.setMemberName(memberName); // 세션 동기화
			}

			String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
			return ApiResponse.success(message, isUpdate);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
	}

	@PostMapping("/updateBirth")
	@ResponseBody
	public ApiResponse<Boolean> updateBirth(HttpSession session, String birth) {
		try {
			MemberDTO member = LoginUtil.member(session);
			if (member == null) {
				return ApiResponse.fail("로그인 정보가 존재하지 않습니다.");
			}
			boolean isUpdate = service.birthUpdate(member.getMemberId(), birth);

			String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
			return ApiResponse.success(message, isUpdate);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
	}

	@PostMapping("/updateGender")
	@ResponseBody
	public ApiResponse<Boolean> updateGender(HttpSession session, String gender) {
		try {
			MemberDTO member = LoginUtil.member(session);
			if (member == null) {
				return ApiResponse.fail("로그인 정보가 존재하지 않습니다.");
			}
			boolean isUpdate = service.genderUpdate(member.getMemberId(), gender);

			String message = isUpdate ? "정보 변경에 성공하셨습니다." : "정보 변경에 실패했습니다.";
			return ApiResponse.success(message, isUpdate);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
	}

	@PostMapping("/updatePassword")
	@ResponseBody
	public ApiResponse<Boolean> updatePassword(
	        HttpSession session,
	        @RequestParam String currentPassword,
	        @RequestParam String newPassword) {
	    
	    MemberDTO member = LoginUtil.member(session);
	    if (member == null) {
	        return ApiResponse.fail("로그인이 필요합니다.");
	    }
	    
	    try {
	        boolean result = service.passwordUpdate(member.getMemberId(), currentPassword, newPassword);
	        return ApiResponse.success(result);
	    } catch (IllegalArgumentException | IllegalStateException e) {
	        return ApiResponse.fail(e.getMessage());
	    }
	}
	
	// 스키마(DELIVERYADDRESS)에 수취인/전화번호/우편번호 컬럼이 없어 zipcode+address+detailAddress를
	// DETAIL_ADDRESS 한 문자열로 합쳐서 저장한다 (recipient/phone은 저장할 컬럼이 없어 미반영).
	@PostMapping("/addAddress")
	public String addAddress(
	        HttpSession session,
	        @RequestParam String addressName,
	        @RequestParam String zipcode,
	        @RequestParam String address,
	        @RequestParam(required = false) String detailAddress,
	        @RequestParam(required = false) String isDefault,
	        @RequestParam(required = false) String returnUrl,
	        RedirectAttributes redirectAttr) {

	    MemberDTO member = LoginUtil.member(session);
	    if (member == null) {
	        redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
	        return "redirect:/member/login";
	    }

	    String combinedDetailAddress = ("[" + zipcode + "] " + address
	            + (detailAddress == null || detailAddress.isBlank() ? "" : " " + detailAddress)).trim();

	    DeliveryAddressDTO deliveryAddress = new DeliveryAddressDTO();
	    deliveryAddress.setMemberId(member.getMemberId());
	    deliveryAddress.setAddressName(addressName);
	    deliveryAddress.setDetailAddress(combinedDetailAddress);
	    deliveryAddress.setIsDefault("Y".equals(isDefault) ? "Y" : "N");

	    service.addDeliveryAddress(deliveryAddress);

	    redirectAttr.addFlashAttribute("addAddressSuccess", "배송지가 추가되었습니다.");

	    // 들어온 화면으로 돌려보낸다. returnUrl이 없거나 우리 사이트 경로가 아니면 회원정보 수정으로.
	    return "redirect:" + (isSafeRedirect(returnUrl) ? returnUrl : "/member/updateInfo");
	}

	// 회원정보 수정 화면의 배송지 드롭다운 - 기본 배송지 변경/삭제 후 목록을 다시 그리는 용도.
	// 초기 목록은 updateInfoForm이 JSTL로 서버 렌더링하고, 이 둘은 그 이후의 조작만 처리한다.
	@PostMapping("/address/{addId}/default")
	@ResponseBody
	public ApiResponse<Void> setDefaultAddress(@PathVariable Long addId, HttpSession session) {
		MemberDTO member = LoginUtil.member(session);
		if (member == null) {
			return ApiResponse.fail("로그인이 필요합니다.");
		}
		try {
			service.setDefaultAddress(member.getMemberId(), addId);
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
		return ApiResponse.success("기본 배송지로 설정되었습니다.", null);
	}

	@PostMapping("/address/{addId}/delete")
	@ResponseBody
	public ApiResponse<Void> deleteAddress(@PathVariable Long addId, HttpSession session) {
		MemberDTO member = LoginUtil.member(session);
		if (member == null) {
			return ApiResponse.fail("로그인이 필요합니다.");
		}
		try {
			service.deleteDeliveryAddress(member.getMemberId(), addId);
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}
		return ApiResponse.success("배송지가 삭제되었습니다.", null);
	}

	// 배송지 목록 재조회 - 기본 설정/삭제 성공 후 JS가 패널을 다시 그릴 때 호출한다.
	// (페이지 전체를 새로고침하면 펼쳐둔 패널이 다시 접혀버려서 AJAX로 목록만 새로 받는다.)
	@GetMapping("/addresses")
	@ResponseBody
	public ApiResponse<List<DeliveryAddressDTO>> listAddresses(HttpSession session) {
		MemberDTO member = LoginUtil.member(session);
		if (member == null) {
			return ApiResponse.fail("로그인이 필요합니다.");
		}
		return ApiResponse.success(service.listDeliveryAddresses(member.getMemberId()));
	}

	@PostMapping("/withdraw")
	@ResponseBody
	public ApiResponse<Boolean> withdraw(HttpSession session) {
	    MemberDTO member = LoginUtil.member(session);
	    
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