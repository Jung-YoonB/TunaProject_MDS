package com.kh.sajotuna.mds.product.controller;

import com.kh.sajotuna.mds.util.LoginUtil;
import com.kh.sajotuna.mds.util.PageWindow;
import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import com.kh.sajotuna.mds.util.dto.ApiResponse;
import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;


@Controller
@RequiredArgsConstructor
@RequestMapping("/mds")
public class ProductController {

	private final ProductService service;
	
	@GetMapping("/detail/{productId}")
	public String detailPage(@PathVariable Long productId, Model model, HttpSession session,
							@RequestParam(defaultValue = "1") int page) {
		// 상품 정보(이미지/옵션/쿠폰)와 리뷰를 한 번에 담는다. 예전에는 조회만 하고 model에 안 실어서
		// JSP의 ${detail...}이 전부 빈 값으로 나왔고, 리뷰는 /mds/review/{id}로 따로 들어가야만 보였다.
		Long memberId = LoginUtil.memberId(session);
		DetailPageDTO detail = service.detailPage(productId, memberId);
		if (detail == null) { // 없는 상품 번호 - 500 대신 목록으로 돌려보낸다
			return "redirect:/mds/searchList";
		}
		model.addAttribute("detail", detail);
		addMemberGrade(model, memberId);

		addReviewPage(model, session, productId, page);
		return"product/productDetail";
	}

	// 등급 할인 표시(정상가/할인가) - 로그인 상태일 때만 실제 회원 등급을 조회한다. 비로그인이면
	// model에 아예 안 실어서 JSP의 <c:if test="${not empty memberGrade}">가 그 줄 전체를 숨긴다.
	private void addMemberGrade(Model model, Long memberId) {
		if (memberId != null) {
			model.addAttribute("memberGrade", service.getMemberGrade(memberId));
		}
	}

	// 상세 페이지와 /mds/review/{productId}가 같은 JSP를 쓰므로 리뷰 목록 + 페이지 정보를
	// 담는 부분을 공유한다(한쪽만 고쳐서 어긋나는 걸 막는다).
	private void addReviewPage(Model model, HttpSession session, Long productId, int page) {
		Long memberId = LoginUtil.memberId(session);

		PageWindow paging = PageWindow.of(page, service.totalReviewPages(productId));

		model.addAttribute("reviewList", service.getReviewList(productId, memberId, paging.currentPage()));
		model.addAttribute("productId", productId);
		paging.addTo(model);
	}

	// "쿠폰 받기" 모달을 열 때 먼저 부른다 - 지금 새로 받을 수 있는 쿠폰 목록(이름+할인율)만 보여준다.
	@GetMapping("/coupon/issuable")
	@ResponseBody
	public ApiResponse<List<CouponDTO>> getIssuableCoupons(HttpSession session) {
		MemberDTO user = LoginUtil.member(session);

		if (user == null) {
			return ApiResponse.fail("로그인이 필요합니다.");
		}

		return ApiResponse.success(service.getIssuableCoupons(user.getMemberId()));
	}

	// 상품 상세의 "쿠폰 받기" 버튼 - 이 상품에 딸린 쿠폰이 아니라(COUPON 테이블에 PRODUCT_ID가 없다),
	// 지금 발급 가능한(유효기간 남은) 쿠폰 중 이 회원이 아직 안 받은 걸 전부 발급한다.
	@PostMapping("/coupon/issue")
	@ResponseBody
	public ApiResponse<Integer> issueCoupons(HttpSession session) {
		MemberDTO user = LoginUtil.member(session);

		if (user == null) {
			return ApiResponse.fail("로그인이 필요합니다.");
		}

		int issued = service.issueAllCoupons(user.getMemberId());

		String message = issued > 0
				? issued + "개의 쿠폰이 발급되었습니다."
				: "받을 수 있는 새 쿠폰이 없습니다.";

		return ApiResponse.success(message, issued);
	}

	// 리뷰 페이지 번호를 눌렀을 때 들어오는 경로. 같은 JSP를 쓰므로 상품 정보도 함께 담아야
	// 상단(이미지/옵션/가격)이 빈 화면이 되지 않는다.
	@GetMapping("/review/{productId}")
	public String reviewPage(@PathVariable Long productId, Model model, HttpSession session,
							@RequestParam(defaultValue = "1") int page) {
		Long memberId = LoginUtil.memberId(session);
		DetailPageDTO detail = service.detailPage(productId, memberId);
		if (detail == null) {
			return "redirect:/mds/searchList";
		}
		model.addAttribute("detail", detail);
		addMemberGrade(model, memberId);
		addReviewPage(model, session, productId, page);
		return"product/productDetail";
	}


	// 좋아요 토글 결과("on"/"off")를 그대로 응답 본문으로 돌려준다.
	// @ResponseBody가 없으면 반환 문자열이 뷰 이름으로 취급돼 화면을 못 찾는다.
	@GetMapping("/review/like/{reviewId}")
	@ResponseBody
	public String reviewLike(@PathVariable Long reviewId, HttpSession session) {
		// 세션 키는 LOGIN_SESSION - LOGIN_MEMBER는 Model attribute 이름이라 세션엔 안 담긴다
		MemberDTO user = LoginUtil.member(session);
		if (user == null) {
			return "login-required";
		}
		return service.increaseReviewLike(reviewId, user.getMemberId());
	}


	@GetMapping("/searchList")
	public String getSearchList(Model model, HttpSession session, SearchDTO searchDTO, @RequestParam(defaultValue = "1") int page) {
		PageWindow paging = PageWindow.of(page, service.totalPages(searchDTO));

		List<ProductListDTO> searchList = service.getSearchList(searchDTO, paging.currentPage(), LoginUtil.memberId(session));

		model.addAttribute("searchList", searchList);
		model.addAttribute("categoryList", service.getCategories());
		model.addAttribute("tagList", service.getTags());
		model.addAttribute("bannerList", service.getBanners());
		paging.addTo(model);
		return "product/searchProduct";
	}
}
