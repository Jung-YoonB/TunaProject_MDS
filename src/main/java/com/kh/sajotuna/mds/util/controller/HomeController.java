package com.kh.sajotuna.mds.util.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.kh.sajotuna.mds.util.LoginUtil;
import com.kh.sajotuna.mds.util.PageWindow;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import com.kh.sajotuna.mds.product.model.service.ProductService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class HomeController {

	private final ProductService service;

	// 8개 → "더보기"로 16개(이어서 표시) → 그 뒤론 번호 페이지네이션. 새 쿼리 없이
	// service.getList()의 전체 목록(찜 많은 순)을 여기서 8개 단위로 잘라 쓴다.
	private static final int HOME_PAGE_SIZE = 8;

	@GetMapping("/")
	public String home(Model model, HttpSession session, @RequestParam(defaultValue = "1") int page) {
		Long memberId = LoginUtil.memberId(session);
		MainPageDTO mainPage = service.getList(memberId);
		List<ProductListDTO> all = mainPage.getProduct();
		int totalCount = all.size();
		PageWindow paging = PageWindow.of(page,
				PageWindow.totalPages(totalCount, HOME_PAGE_SIZE));
		int currentPage = paging.currentPage();

		List<ProductListDTO> visible;
		boolean showLoadMore;

		if (currentPage == 1) {
			// 기본 화면: 맨 앞 8개만.
			visible = all.subList(0, Math.min(HOME_PAGE_SIZE, totalCount));
			showLoadMore = totalCount > HOME_PAGE_SIZE;
		} else if (currentPage == 2) {
			// "더보기" 클릭 직후: 8개를 이어서 더 보여준다(1~16번을 한 화면에 누적 표시).
			int end = Math.min(HOME_PAGE_SIZE * 2, totalCount);
			visible = all.subList(0, end);
			showLoadMore = false;
		} else {
			// 그 이후부터는 번호 페이지네이션 - 더는 누적하지 않고 8개짜리 구간만 보여준다.
			// (currentPage=3의 offset이 16이라 위 2단계에서 이미 보여준 16개와 정확히 이어진다)
			int start = Math.min((currentPage - 1) * HOME_PAGE_SIZE, totalCount);
			int end = Math.min(currentPage * HOME_PAGE_SIZE, totalCount);
			visible = all.subList(start, end);
			showLoadMore = false;
		}

		boolean showPagination = currentPage >= 2;


		model.addAttribute("productList", visible);
		// 배너는 검색 결과 페이지 사이드바와 같은 목록(최근 등록 상품 대표이미지 최대 5장)
		model.addAttribute("bannerList", mainPage.getBanner());
		model.addAttribute("categoryList", service.getCategories());
		model.addAttribute("showLoadMore", showLoadMore);
		model.addAttribute("showPagination", showPagination);
		paging.addTo(model);
		return "home/home";
	}
}
