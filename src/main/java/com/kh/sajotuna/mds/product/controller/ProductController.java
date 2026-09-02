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
	public String detailPage(@PathVariable Long productId) {
		System.out.println("컨트롤러 productId :: " + productId);

		DetailPageDTO detail = service.detailPage(productId);
		System.out.println("컨트롤러 detail :: " + detail);
		return"product/productDetail";
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

	@GetMapping("/review/{productId}")
	public String reviewPage(@PathVariable Long productId, Model model, HttpSession session,
							@RequestParam(defaultValue = "1") int page) {
		System.out.println("page Number :: " + page);
		MemberDTO user = (MemberDTO) session.getAttribute(SessionConst.LOGIN_MEMBER);
		Long memberId  = null;
		if(user != null) {
			memberId = user.getMemberId();
		}
		int totalPages = service.totalReviewPages(productId);
		int currentPage = Math.min(Math.max(page, 1), totalPages);
		int windowSize = 5;
		int windowStart = Math.max(1, currentPage - windowSize / 2);
		int windowEnd = Math.min(totalPages, windowStart + windowSize - 1);
		windowStart = Math.max(1, windowEnd - windowSize + 1);

		List<ReviewDTO> reviewList = service.getReviewList(productId, memberId, currentPage);

		model.addAttribute("reviewList", reviewList);
		System.out.println("reviewList :: " + reviewList);
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageWindowStart", windowStart);
		model.addAttribute("pageWindowEnd", windowEnd);
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

		List<ProductListDTO> searchList = service.getSearchList(searchDTO, page);

		model.addAttribute("searchList", searchList);
		System.out.println("reviewList :: " + searchList);
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageWindowStart", windowStart);
		model.addAttribute("pageWindowEnd", windowEnd);
		return "product/searchProduct";
	}
}
