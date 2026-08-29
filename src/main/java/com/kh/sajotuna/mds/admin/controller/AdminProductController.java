package com.kh.sajotuna.mds.admin.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.admin.model.service.AdminProductService;
import com.kh.sajotuna.mds.util.AdminAuthUtil;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/product")
public class AdminProductController {

	private final AdminProductService service;

	@GetMapping("/add")
	public String addForm(HttpSession session, Model model) {
		String guard = checkAdminPage(session);
		if (guard != null) {
			return guard;
		}

		model.addAttribute("categoryList", service.getCategories());
		model.addAttribute("tagList", service.getTags());
		return "admin/addProduct";
	}

	@PostMapping("/add")
	@ResponseBody
	public ApiResponse<Void> add(HttpSession session,
			@RequestParam String productName,
			@RequestParam int price,
			@RequestParam int stock,
			@RequestParam(required = false) Long categoryId,
			@RequestParam(required = false) String productContent,
			@RequestParam(required = false) String tagsJson,
			@RequestParam(required = false) MultipartFile mainImage,
			@RequestParam(required = false) List<MultipartFile> subImages,
			@RequestParam(required = false) List<MultipartFile> descriptionImages) {

		String failMessage = checkAdminApi(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}

		try {
			service.registerProduct(productName, price, stock, categoryId, productContent, tagsJson,
					mainImage, subImages, descriptionImages);
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}

		return ApiResponse.success("상품이 등록되었습니다.", null);
	}

	// 로그인 안 됐거나 ADMIN이 아니면 리다이렉트 view 이름을, 통과하면 null을 반환
	private String checkAdminPage(HttpSession session) {
		return AdminAuthUtil.isAdmin(session) ? null : "redirect:/member/login";
	}

	// 로그인 안 됐거나 ADMIN이 아니면 에러 메시지를, 통과하면 null을 반환
	private String checkAdminApi(HttpSession session) {
		return AdminAuthUtil.isAdmin(session) ? null : "관리자만 접근할 수 있습니다.";
	}
}
