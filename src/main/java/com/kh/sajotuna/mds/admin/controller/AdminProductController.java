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

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/product")
public class AdminProductController {

	private final AdminProductService service;

	@GetMapping("/add")
	public String addForm(HttpServletRequest request, HttpSession session, Model model) {
		String guard = AdminAuthUtil.pageGuard(request, session);
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
			@RequestParam String productTitle,
			@RequestParam String productName,
			@RequestParam(required = false) String optionsJson,
			@RequestParam(required = false) Long categoryId,
			@RequestParam(required = false) String productContent,
			@RequestParam(required = false) String tagsJson,
			@RequestParam(required = false) MultipartFile mainImage,
			@RequestParam(required = false) List<MultipartFile> subImages,
			@RequestParam(required = false) List<MultipartFile> descriptionImages) {

		String failMessage = AdminAuthUtil.apiGuard(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}

		try {
			service.registerProduct(productTitle, productName, optionsJson, categoryId, productContent,
					tagsJson, mainImage, subImages, descriptionImages);
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}

		return ApiResponse.success("상품이 등록되었습니다.", null);
	}
}
