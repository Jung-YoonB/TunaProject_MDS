package com.kh.sajotuna.mds.product.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.product.model.service.ProductService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/mds")
public class ProductController {

	private final ProductService service;
	
	@GetMapping("/list")
	public String getList(Model model) {
		
		MainPageDTO list = service.getList();
		
		model.addAttribute("productList", list);
		System.out.println("컨트롤러 :: " + list);
		return"redirect:home/test";
	}
	
	@GetMapping("/detail/{productId}")
	public String detailPage(@PathVariable Long productId) {
		System.out.println("컨트롤러 productId :: " + productId);
		
		DetailPageDTO detail = service.detailPage(productId);
		System.out.println("컨트롤러 detail :: " + detail);
		return"redirect:home/test";
	}
}
