package com.kh.sajotuna.mds.order.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.order.model.dto.CheckoutDTO;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;

@Mapper
public interface OrderMapper {
	
	// 멤버id로 결제창에 표시할 정보 받아오기 
	PaymentViewDTO selectByMemberIdForPay(Long memberId);
	
	// 카트id들 정보 받아오기
	List<OrderItemDTO> selectCartIds(@Param("cartIds") List<Long> cartIds);
	
	// popId로 검색해오기
	OrderItemDTO selectPopId(Long popId);
	
	// 멤버id로 결제용 정보 받아오기
	CheckoutDTO selectByMemberIdForCheckout(Long memberId);
	
	// 구매할 목록 정보 받아오기
	List<OrderItemDTO> selectItems(@Param("itemList") List<OrderItemDTO> itemList);
	
	// 쿠폰히스토리id로 쿠폰 할인율 받아오기
	Double selectByChistId(@Param("memberId") Long memberId,@Param("chistId") Long chistId);
	
	// 검증한 데이터로 productorder테이블에 입력
	int insertProductOrder(CheckoutDTO verifiedData);
	
	// 구매한 양만큼 보유량 수정
	int updateProductStock(OrderItemDTO item);
		
	// 검증한 데이터로 orderdetail테이블에 입력
	int insertOrderDetail(OrderItemDTO item);
	
	// 사용한 쿠폰 사용처리
	int updateCouponStatus(CheckoutDTO verifiedData);
	
	// 포인트 변동
	int updatePoint(@Param("memberId") Long memberId, @Param("changePoint") int changePoint);
	
	// 포인트 사용 이력 기록
	int insertPointHistoryUse(CheckoutDTO verifiedData);
	
	// 포인트 적립 이력 기록
	int insertPointHistoryEarn(CheckoutDTO verifiedData);
	
	// 누적구매금액 업데이트
	int updateTotalAmount(@Param("memberId") Long memberId, @Param("totalPrice") long totalPrice);
	
	// 누적구매금액에 따른 회원 등급 재조정
	int updateMemberGrade(Long memberId);
	
	// 결제 후 장바구니에서 제거
	int deleteCartItems(@Param("memberId") Long memberId,@Param("cartIds") List<Long> cartIds);
}
