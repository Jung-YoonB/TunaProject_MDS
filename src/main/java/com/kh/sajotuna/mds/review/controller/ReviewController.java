package com.kh.sajotuna.mds.review.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
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
	public String writeForm(@RequestParam Long odId, HttpSession session, Model model, RedirectAttributes redirectAttr) {
		MemberDTO loginMember = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		Long memberId = (loginMember != null) ? loginMember.getMemberId() : null;
		if (memberId == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
			return "redirect:/member/login";
		}

		try {
			ReviewWriteInfoDTO writeInfo = reviewService.getWriteInfo(odId, memberId);
			model.addAttribute("writeInfo", writeInfo);
		} catch (IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/";
		}

		return "review/addReview";
	}

	@PostMapping("/write")
	public String write(@RequestParam Long odId,
						@RequestParam int score,
						@RequestParam String reviewText,
						@RequestParam(name = "reviewImages", required = false) List<MultipartFile> reviewImages,
						HttpSession session,
						RedirectAttributes redirectAttr) {
		MemberDTO loginMember = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
		Long memberId = (loginMember != null) ? loginMember.getMemberId() : null;
		if (memberId == null) {
			redirectAttr.addFlashAttribute("error", "로그인이 필요합니다.");
			return "redirect:/member/login";
		}

		try {
			reviewService.writeReview(memberId, odId, score, reviewText, reviewImages);
		} catch (IllegalStateException e) {
			redirectAttr.addFlashAttribute("error", e.getMessage());
			return "redirect:/review/write?odId=" + odId;
		}

		redirectAttr.addFlashAttribute("success", "리뷰가 등록되었습니다.");
		return "redirect:/";
	}
}
