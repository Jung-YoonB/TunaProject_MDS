package com.kh.sajotuna.mds.product.controller;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.Review.ReviewDTO;
import com.kh.sajotuna.mds.util.SessionConst;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.product.model.service.ProductService;
import lombok.RequiredArgsConstructor;
import java.util.List;


@Controller
@RequiredArgsConstructor
@RequestMapping("/mds")
public class ProductController {

	private final ProductService service;
	
	@GetMapping("/list")
	public String getList(Model model, SearchDTO searchDTO) {
		
		MainPageDTO list = service.getList(searchDTO);
		
		model.addAttribute("productList", list);
		System.out.println("컨트롤러 :: " + list);
		return"redirect:home/home";
	}
	
	@GetMapping("/detail/{productId}")
	public String detailPage(@PathVariable Long productId) {
		System.out.println("컨트롤러 productId :: " + productId);

		DetailPageDTO detail = service.detailPage(productId);
		System.out.println("컨트롤러 detail :: " + detail);
		return"redirect:home/home";
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
		return"redirect:home/home";
	}

	@GetMapping("/review/{productId}")
	public String reviewPage(@PathVariable Long productId, Model model, HttpSession session) {
		MemberDTO user = (MemberDTO) session.getAttribute(SessionConst.LOGIN_MEMBER);
		Long memberId  = null;
		if(user.getMemberId() != null) {
			memberId = user.getMemberId();
		}
		List<ReviewDTO> reviewList = service.getReviewList(productId, memberId);
		model.addAttribute("reviewList", reviewList);
		System.out.println("reviewList :: " + reviewList);
		return"redirect:home/home";
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
}
