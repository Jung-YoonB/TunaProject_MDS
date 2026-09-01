package com.kh.sajotuna.mds.admin.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kh.sajotuna.mds.admin.model.dto.CouponDeleteRequestDTO;
import com.kh.sajotuna.mds.admin.model.service.AdminCouponService;
import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.util.AdminAuthUtil;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/coupon")
public class AdminCouponController {

	private final AdminCouponService service;

	@GetMapping
	public String listPage(HttpServletRequest request, HttpSession session) {
		String guard = AdminAuthUtil.pageGuard(request, session);
		return guard != null ? guard : "admin/admincouponView";
	}

	@GetMapping("/list")
	@ResponseBody
	public ApiResponse<List<CouponDTO>> list(HttpSession session) {
		String failMessage = AdminAuthUtil.apiGuard(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}
		return ApiResponse.success(service.getCoupons());
	}

	@GetMapping("/add")
	public String addForm(HttpServletRequest request, HttpSession session) {
		String guard = AdminAuthUtil.pageGuard(request, session);
		return guard != null ? guard : "admin/addCoupon";
	}

	@PostMapping("/add")
	@ResponseBody
	public ApiResponse<Void> add(HttpSession session,
			@RequestParam String couponName,
			@RequestParam int discountPercent,
			@RequestParam(required = false) String couponText,
			@RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
			@RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {

		String failMessage = AdminAuthUtil.apiGuard(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}

		try {
			service.registerCoupon(couponName, discountPercent, couponText, startDate, endDate);
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}

		return ApiResponse.success("쿠폰이 등록되었습니다.", null);
	}

	@PostMapping("/delete")
	@ResponseBody
	public ApiResponse<Void> delete(HttpSession session, @RequestBody CouponDeleteRequestDTO request) {
		String failMessage = AdminAuthUtil.apiGuard(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}

		if (request.getCouponIds() == null || request.getCouponIds().isEmpty()) {
			return ApiResponse.fail("삭제할 쿠폰을 선택해 주세요.");
		}

		try {
			service.deleteCoupons(request.getCouponIds());
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}

		return ApiResponse.success("선택한 쿠폰이 삭제되었습니다.", null);
	}
}
