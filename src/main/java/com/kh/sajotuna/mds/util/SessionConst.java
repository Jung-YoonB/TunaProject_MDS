package com.kh.sajotuna.mds.util;


public class SessionConst {
	// 세션 키 값 상수 정의
	public static final String LOGIN_SESSION = "loginSession";
	public static final String LOGIN_MEMBER = "loginMember";

	// 진행 중인 결제(무엇을 사려던 중인지). 결제 화면을 벗어났다가 헤더의 결제 아이콘으로
	// 돌아와 이어서 결제할 수 있게 하려고 담아둔다. 담기는 값은 PendingCheckoutDTO.
	public static final String PENDING_CHECKOUT = "pendingCheckout";
	
	// 객체 생성 막기
	private SessionConst() {}
}
