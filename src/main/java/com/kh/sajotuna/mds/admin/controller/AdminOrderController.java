package com.kh.sajotuna.mds.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kh.sajotuna.mds.admin.model.dto.AdminOrderListResponseDTO;
import com.kh.sajotuna.mds.admin.model.dto.DeliveryUpdateRequestDTO;
import com.kh.sajotuna.mds.admin.model.service.AdminOrderService;
import com.kh.sajotuna.mds.util.AdminAuthUtil;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/order")
public class AdminOrderController {

	private final AdminOrderService service;

	@GetMapping
	public String listPage(HttpSession session) {
		String guard = checkAdminPage(session);
		return guard != null ? guard : "admin/adminOrderDelivery";
	}

	@GetMapping("/list")
	@ResponseBody
	public ApiResponse<AdminOrderListResponseDTO> list(HttpSession session) {
		String failMessage = checkAdminApi(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}
		return ApiResponse.success(service.getOrderList());
	}

	@PostMapping("/delivery/{orderId}")
	@ResponseBody
	public ApiResponse<Void> updateDelivery(HttpSession session, @PathVariable Long orderId,
			@RequestBody DeliveryUpdateRequestDTO request) {
		String failMessage = checkAdminApi(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}

		try {
			service.updateDeliveryStatus(orderId, request.getDeliveryStatus(), request.getTrackingNo());
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}

		return ApiResponse.success("배송 정보가 저장되었습니다.", null);
	}

	private String checkAdminPage(HttpSession session) {
		return AdminAuthUtil.isAdmin(session) ? null : "redirect:/member/login";
	}

	private String checkAdminApi(HttpSession session) {
		return AdminAuthUtil.isAdmin(session) ? null : "관리자만 접근할 수 있습니다.";
	}
}
