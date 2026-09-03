package com.kh.sajotuna.mds.util;

import org.springframework.ui.Model;

/**
 * 페이지 번호 목록("이전 1 2 3 4 5 다음")에 필요한 값 묶음.
 *
 * 같은 계산이 컨트롤러 6곳(쿠폰/주문배송/리뷰목록/검색/내리뷰/홈)에 그대로 복붙돼 있었다.
 * 모델 속성 이름(currentPage / totalPages / pageWindowStart / pageWindowEnd)도 JSP와 짝이라
 * 한 곳에서만 정해야 한다 - 한 컨트롤러에서 이름을 잘못 쓰면 그 화면의 페이지 번호만 조용히 사라진다.
 */
public record PageWindow(int currentPage, int totalPages, int windowStart, int windowEnd) {

	/** 한 번에 보여줄 페이지 번호 개수 */
	private static final int WINDOW_SIZE = 5;

	/**
	 * @param page       요청받은 페이지(범위를 벗어나면 알아서 잘린다)
	 * @param totalPages 전체 페이지 수. 서비스가 최소 1을 보장한다
	 */
	public static PageWindow of(int page, int totalPages) {
		int safeTotal = Math.max(1, totalPages);
		int current = Math.min(Math.max(page, 1), safeTotal);

		// 현재 페이지를 가운데 두되, 끝에 가까우면 창을 안쪽으로 밀어 항상 WINDOW_SIZE개를 채운다
		int start = Math.max(1, current - WINDOW_SIZE / 2);
		int end = Math.min(safeTotal, start + WINDOW_SIZE - 1);
		start = Math.max(1, end - WINDOW_SIZE + 1);

		return new PageWindow(current, safeTotal, start, end);
	}

	/**
	 * 전체 건수 → 전체 페이지 수. 0건이어도 1페이지로 친다(화면에 "1"은 항상 보여야 한다).
	 * 서비스 5곳이 같은 식을 복붙하고 있었다.
	 */
	public static int totalPages(int totalCount, int pageSize) {
		return Math.max(1, (int) Math.ceil((double) totalCount / pageSize));
	}

	/** 페이지 번호 → SQL OFFSET. 1보다 작은 페이지는 1페이지로 본다 */
	public static int offset(int page, int pageSize) {
		return (Math.max(page, 1) - 1) * pageSize;
	}

	/** JSP가 읽는 이름으로 모델에 담는다 */
	public void addTo(Model model) {
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageWindowStart", windowStart);
		model.addAttribute("pageWindowEnd", windowEnd);
	}
}
