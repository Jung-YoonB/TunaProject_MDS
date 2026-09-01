package com.kh.sajotuna.mds.admin.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kh.sajotuna.mds.admin.model.dto.DeleteOrphanFileRequestDTO;
import com.kh.sajotuna.mds.admin.model.dto.FileIntegrityIssueDTO;
import com.kh.sajotuna.mds.admin.model.service.AdminMaintenanceService;
import com.kh.sajotuna.mds.util.AdminAuthUtil;
import com.kh.sajotuna.mds.util.dto.ApiResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/maintenance")
public class AdminMaintenanceController {

	private final AdminMaintenanceService service;

	@GetMapping
	public String page(HttpServletRequest request, HttpSession session) {
		String guard = AdminAuthUtil.pageGuard(request, session);
		return guard != null ? guard : "admin/adminMaintenance";
	}

	@GetMapping("/check")
	@ResponseBody
	public ApiResponse<List<FileIntegrityIssueDTO>> check(HttpSession session) {
		String failMessage = AdminAuthUtil.apiGuard(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}
		return ApiResponse.success(service.checkFileIntegrity());
	}

	@PostMapping("/delete-orphan")
	@ResponseBody
	public ApiResponse<Void> deleteOrphan(HttpSession session, @RequestBody DeleteOrphanFileRequestDTO request) {
		String failMessage = AdminAuthUtil.apiGuard(session);
		if (failMessage != null) {
			return ApiResponse.fail(failMessage);
		}

		try {
			service.deleteOrphanFile(request.getCategory(), request.getFileName());
		} catch (IllegalStateException e) {
			return ApiResponse.fail(e.getMessage());
		}

		return ApiResponse.success("삭제되었습니다.", null);
	}
}
