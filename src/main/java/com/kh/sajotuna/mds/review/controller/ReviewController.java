package com.kh.sajotuna.mds.review.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewWriteInfoDTO;
import com.kh.sajotuna.mds.review.model.service.ReviewService;
import com.kh.sajotuna.mds.util.SessionConst;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/review")
public class ReviewController {

	private final ReviewService reviewService;

	@GetMapping("/write")
	public String writeForm(@RequestParam Long odId, @RequestParam(required = false) String returnUrl,
			HttpSession session, Model model, RedirectAttributes redirectAttr) {
		MemberDTO loginMember = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		Long memberId = (loginMember != null) ? loginMember.getMemberId() : null;
		if (memberId == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
			return "redirect:/member/login";
		}

		String safeReturnUrl = isSafeRedirect(returnUrl) ? returnUrl : null;

		try {
			ReviewWriteInfoDTO writeInfo = reviewService.getWriteInfo(odId, memberId);
			model.addAttribute("writeInfo", writeInfo);
		} catch (IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:" + (safeReturnUrl != null ? safeReturnUrl : "/");
		}

		if (safeReturnUrl != null) {
			model.addAttribute("returnUrl", safeReturnUrl);
		}

		return "review/addReview";
	}

	@PostMapping("/write")
	public String write(@RequestParam Long odId,
						@RequestParam int score,
						@RequestParam String reviewText,
						@RequestParam(name = "reviewImages", required = false) List<MultipartFile> reviewImages,
						@RequestParam(required = false) String returnUrl,
						HttpSession session,
						RedirectAttributes redirectAttr) {
		MemberDTO loginMember = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		Long memberId = (loginMember != null) ? loginMember.getMemberId() : null;
		if (memberId == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
			return "redirect:/member/login";
		}

		String safeReturnUrl = isSafeRedirect(returnUrl) ? returnUrl : null;

		try {
			reviewService.writeReview(memberId, odId, score, reviewText, reviewImages);
		} catch (IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			String retryUrl = "redirect:/review/write?odId=" + odId;
			if (safeReturnUrl != null) {
				retryUrl += "&returnUrl=" + URLEncoder.encode(safeReturnUrl, StandardCharsets.UTF_8);
			}
			return retryUrl;
		}

		redirectAttr.addFlashAttribute("success", "리뷰가 등록되었습니다.");
		return "redirect:" + (safeReturnUrl != null ? safeReturnUrl : "/");
	}

	@GetMapping("/myReviews")
	public String myReviewsForm(@RequestParam(defaultValue = "1") int page,
			HttpSession session, Model model, RedirectAttributes redirectAttr) {
		MemberDTO loginMember = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		Long memberId = (loginMember != null) ? loginMember.getMemberId() : null;
		if (memberId == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
			return "redirect:/member/login";
		}

		int totalPages = reviewService.totalMyReviewPages(memberId);
		int currentPage = Math.min(Math.max(page, 1), totalPages);
		int windowSize = 5;
		int windowStart = Math.max(1, currentPage - windowSize / 2);
		int windowEnd = Math.min(totalPages, windowStart + windowSize - 1);
		windowStart = Math.max(1, windowEnd - windowSize + 1);

		model.addAttribute("myReviews", reviewService.listMyReviews(memberId, currentPage));
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageWindowStart", windowStart);
		model.addAttribute("pageWindowEnd", windowEnd);
		return "review/myReviews";
	}

	@PostMapping("/delete/{reviewId}")
	public String deleteReview(@PathVariable Long reviewId, HttpSession session, RedirectAttributes redirectAttr) {
		MemberDTO loginMember = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		Long memberId = (loginMember != null) ? loginMember.getMemberId() : null;
		if (memberId == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
			return "redirect:/member/login";
		}

		try {
			reviewService.deleteReview(reviewId, memberId);
			redirectAttr.addFlashAttribute("success", "리뷰가 삭제되었습니다.");
		} catch (IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
		}

		return "redirect:/review/myReviews";
	}

	// 오픈 리다이렉트 방지: MemberController.isSafeRedirect와 동일 기준(우리 사이트 내부 경로만 허용)
	private boolean isSafeRedirect(String url) {
		return url != null && !url.isBlank() && url.startsWith("/") && !url.startsWith("//") && !url.contains("\\");
	}
}
