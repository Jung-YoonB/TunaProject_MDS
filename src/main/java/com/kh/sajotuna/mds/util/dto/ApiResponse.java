package com.kh.sajotuna.mds.util.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ApiResponse<T> {
	private boolean success;	// 성공 여부
	private String message;		// 성공, 실패에 따른 메시지
	private T data;				// 응답 데이터
	
	// 성공 응답 시
	public static <T> ApiResponse<T> success(T data) {
		return new ApiResponse<>(true, null, data);
	}
	
	public static <T> ApiResponse<T> success(String message, T data) {
		return new ApiResponse<> (true, message, data);
	}
	
	// 실패 응답 시
	public static <T> ApiResponse<T> fail(String message) {
		return new ApiResponse<T>(false, message, null);
	}
}
