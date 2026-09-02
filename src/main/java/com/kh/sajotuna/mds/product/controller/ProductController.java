package com.kh.sajotuna.mds.product.controller;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.util.SessionConst;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.product.model.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;


@Controller
@RequiredArgsConstructor
@RequestMapping("/mds")
public class ProductController {

	private final ProductService service;
	private final int MY_REVIEWS_PAGE_SIZE = 5;
	
	@GetMapping("/list")
	public String getList(Model model) {
		
		MainPageDTO list = service.getList();
		model.addAttribute("productList", list);
		System.out.println("컨트롤러 :: " + list);

		return"home/home";
	}
	
	@GetMapping("/detail/{productId}")
	public String detailPage(@PathVariable Long productId, Model model, HttpSession session,
							@RequestParam(defaultValue = "1") int page) {
		// 상품 정보(이미지/옵션/쿠폰)와 리뷰를 한 번에 담는다. 예전에는 조회만 하고 model에 안 실어서
		// JSP의 ${detail...}이 전부 빈 값으로 나왔고, 리뷰는 /mds/review/{id}로 따로 들어가야만 보였다.
		DetailPageDTO detail = service.detailPage(productId);
		if (detail == null) { // 없는 상품 번호 - 500 대신 목록으로 돌려보낸다
			return "redirect:/mds/searchList";
		}
		model.addAttribute("detail", detail);

		addReviewPage(model, session, productId, page);
		return"product/productDetail";
	}

	// 상세 페이지와 /mds/review/{productId}가 같은 JSP를 쓰므로 리뷰 목록 + 페이지 정보를
	// 담는 부분을 공유한다(한쪽만 고쳐서 어긋나는 걸 막는다).
	private void addReviewPage(Model model, HttpSession session, Long productId, int page) {
		MemberDTO user = (MemberDTO) session.getAttribute(SessionConst.LOGIN_MEMBER);
		Long memberId = (user != null) ? user.getMemberId() : null;

		int totalPages = service.totalReviewPages(productId);
		int currentPage = Math.min(Math.max(page, 1), totalPages);
		int windowSize = 5;
		int windowStart = Math.max(1, currentPage - windowSize / 2);
		int windowEnd = Math.min(totalPages, windowStart + windowSize - 1);
		windowStart = Math.max(1, windowEnd - windowSize + 1);

		model.addAttribute("reviewList", service.getReviewList(productId, memberId, currentPage));
		model.addAttribute("productId", productId);
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageWindowStart", windowStart);
		model.addAttribute("pageWindowEnd", windowEnd);
	}

	@GetMapping("/coupon/{couponId}")
	public String getCoupon(HttpSession session, Model model, @PathVariable Long couponId) {
		MemberDTO user = (MemberDTO)session.getAttribute(SessionConst.LOGIN_MEMBER);

		if (user.getMemberId() == null) {
			model.addAttribute("message", "로그인이 필요합니다.");
			System.out.println(model.getAttribute("message"));
			return "redirect:/member/login";
		}
		String message = service.getCoupons(user.getMemberId(), couponId);
		System.out.println("message:: " + message);
		return"home/home";
	}

	// 리뷰 페이지 번호를 눌렀을 때 들어오는 경로. 같은 JSP를 쓰므로 상품 정보도 함께 담아야
	// 상단(이미지/옵션/가격)이 빈 화면이 되지 않는다.
	@GetMapping("/review/{productId}")
	public String reviewPage(@PathVariable Long productId, Model model, HttpSession session,
							@RequestParam(defaultValue = "1") int page) {
		DetailPageDTO detail = service.detailPage(productId);
		if (detail == null) {
			return "redirect:/mds/searchList";
		}
		model.addAttribute("detail", detail);
		addReviewPage(model, session, productId, page);
		return"product/productDetail";
	}


	@GetMapping("/review/like/{reviewId}")
	public String reviewLike(@PathVariable Long reviewId, HttpSession session) {
		Long memberId  = null;
		MemberDTO user = (MemberDTO) session.getAttribute(SessionConst.LOGIN_MEMBER);
		if(user.getMemberId() != null) {
			memberId = user.getMemberId();
		}
		String result = service.increaseReviewLike(reviewId, memberId);

		System.out.println("result :: " + result);
		return result;
	}


	@GetMapping("/searchList")
	public String getSearchList(Model model, SearchDTO searchDTO, @RequestParam(defaultValue = "1") int page) {
		int totalPages = service.totalPages(searchDTO);
		int currentPage = Math.min(Math.max(page, 1), totalPages);
		int windowSize = 5;
		int windowStart = Math.max(1, currentPage - windowSize / 2);
		int windowEnd = Math.min(totalPages, windowStart + windowSize - 1);
		windowStart = Math.max(1, windowEnd - windowSize + 1);

		List<ProductListDTO> searchList = service.getSearchList(searchDTO, currentPage);

		model.addAttribute("searchList", searchList);
		model.addAttribute("categoryList", service.getCategories());
		model.addAttribute("tagList", service.getTags());
		model.addAttribute("bannerList", service.getBanners());
		System.out.println("searchList :: " + searchList);
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageWindowStart", windowStart);
		model.addAttribute("pageWindowEnd", windowEnd);
		return "product/searchProduct";
	}
}
