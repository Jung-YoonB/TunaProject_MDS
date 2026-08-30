package com.kh.sajotuna.mds.order.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.coupon.model.dto.MyPageCouponDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;
import com.kh.sajotuna.mds.order.model.dto.CheckoutDTO;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;
import com.kh.sajotuna.mds.order.model.mapper.OrderMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor	
public class OrderServiceImpl implements OrderService {
	private final OrderMapper mapper;
	private final MemberMapper memberMapper;
	
	@Override
	public PaymentViewDTO cartPrepare(Long memberId, List<Long> cartIds) {
		// 멤버 정보 조회
		PaymentViewDTO pvData = mapper.selectByMemberIdForPay(memberId);
		// 장바구니 조회
		List<OrderItemDTO> itemList = mapper.selectCartIds(cartIds);
		// 총 가격 계산
		long totalPrice = 0L;
		for(OrderItemDTO i : itemList) {
			totalPrice += i.getOptionPrice() * i.getQty();
		}
		// 보유 쿠폰 조회
		List<MyPageCouponDTO> couponList = memberMapper.selectCouponsByMemberId(memberId);
		
		// 데이터 통합
		pvData.setItemList(itemList);
		pvData.setTotalPrice(totalPrice);
		pvData.setCouponList(couponList);
		
		return pvData;
	}

	@Override
	public PaymentViewDTO directPrepare(Long memberId, OrderItemDTO orderItem) {
		// 멤버 정보 조회
		PaymentViewDTO pvData = mapper.selectByMemberIdForPay(memberId);
		// 장바구니 조회
		List<OrderItemDTO> itemList = new ArrayList<>();
		OrderItemDTO result = mapper.selectPopId(orderItem.getPopId());
		result.setQty(orderItem.getQty());
		itemList.add(result);
				
		// 총 가격 계산
		long totalPrice = 0L;
		for(OrderItemDTO i : itemList) {
			totalPrice += i.getOptionPrice() * i.getQty();
		}
		// 보유 쿠폰 조회
		List<MyPageCouponDTO> couponList = memberMapper.selectCouponsByMemberId(memberId);
				
		// 데이터 통합
		pvData.setItemList(itemList);
		pvData.setTotalPrice(totalPrice);
		pvData.setCouponList(couponList);
				
		return pvData;
	}

	@Override
	@Transactional
	public CheckoutDTO checkout(CheckoutDTO checkoutInputData) {
	
	// sql 조회 전 사용한 포인트 1000 이상인지 체크
	if (checkoutInputData.getUsedPoint() != null && checkoutInputData.getUsedPoint() != 0
			&& checkoutInputData.getUsedPoint() < 1000) {  // 뷰에서 넘겨줄 데이터에 따라 null이나 0 조건 하나 삭제
		throw new IllegalArgumentException("포인트는 1000 이상부터 사용할 수 있습니다.");
	}
		
	// 회원 정보 조회
	CheckoutDTO verifiedData = mapper.selectByMemberIdForCheckout(checkoutInputData.getMemberId());

	if (verifiedData == null) {
		throw new IllegalArgumentException("회원 정보를 찾을 수 없습니다.");
	}

	// 구매할 상품 최신 정보 조회
	List<OrderItemDTO> itemList = mapper.selectItems(checkoutInputData.getItemList());

	if (itemList == null
			|| itemList.size() != checkoutInputData.getItemList().size()) {

		throw new IllegalArgumentException("상품 정보를 찾을 수 없습니다.");
	}

	// 조회한 상품에 요청 수량 저장
	Map<Long, Long> qtyMap = checkoutInputData.getItemList().stream()
					.collect(Collectors.toMap(OrderItemDTO::getPopId, OrderItemDTO::getQty));

	for (OrderItemDTO item : itemList) {
		Long qty = qtyMap.get(item.getPopId());
		if (qty == null || qty <= 0) {
			throw new IllegalArgumentException("상품 수량이 올바르지 않습니다.");
		}

		if (item.getOptionStock() < qty) {
			throw new IllegalArgumentException(
					item.getOptionName() + " 상품의 재고가 부족합니다.");
		}

		item.setQty(qty);
	}

	verifiedData.setItemList(itemList);

	// 쿠폰 확인
	verifiedData.setChistId(checkoutInputData.getChistId());

	if (checkoutInputData.getChistId() != null) {
		Double couponValue = mapper.selectByChistId(
						verifiedData.getMemberId(), checkoutInputData.getChistId());

		if (couponValue == null) {
			throw new IllegalArgumentException("사용할 수 없는 쿠폰입니다.");
		}
		verifiedData.setCouponValue(couponValue);
	} else {
		verifiedData.setCouponValue(0.0);
	}

	// 사용할 포인트 확인
	int usedPoint =	checkoutInputData.getUsedPoint() != null ? checkoutInputData.getUsedPoint() : 0;

	if (usedPoint < 0
			|| usedPoint > verifiedData.getPoint()) {
		throw new IllegalArgumentException("사용할 수 없는 포인트입니다.");
	}

	verifiedData.setUsedPoint(usedPoint);

	// 확인이 필요 없는 정보 옮기기
	verifiedData.setPaymentId(checkoutInputData.getPaymentId());
	verifiedData.setAddressNameFix(checkoutInputData.getAddressNameFix());
	verifiedData.setDetailAddressFix(checkoutInputData.getDetailAddressFix());
	verifiedData.setClientPaidAmount(checkoutInputData.getClientPaidAmount());

	// 총 가격 계산
	long totalPrice = 0L;

	for (OrderItemDTO item : itemList) {
		totalPrice += item.getOptionPrice() * item.getQty();
	}
	System.out.println("" + totalPrice);
	
	// 쿠폰 할인
	totalPrice = (long) (totalPrice	* (1.0 - verifiedData.getCouponValue()));
	System.out.println("" + totalPrice + ", " + verifiedData.getCouponValue());
	
	// 회원 등급 할인
	totalPrice = (long) (totalPrice	* (1.0 - verifiedData.getDiscountRate()));
	System.out.println("" + totalPrice + ", " + verifiedData.getDiscountRate());
	
	// 포인트 사용
	totalPrice -= usedPoint;
	System.out.println("" + totalPrice + ", " + usedPoint);
	
	if (totalPrice < 0) {
		throw new IllegalArgumentException("사용 포인트가 결제 금액보다 많습니다.");
	}
	
	// 클라이언트가 결제한 금액과 최종 계산된 비용 확인
		if (totalPrice != verifiedData.getClientPaidAmount()) {
		throw new IllegalArgumentException("결제한 금액과 지불할 금액이 같지 않습니다.");
	}

	verifiedData.setTotalPrice(totalPrice);

	// 주문 테이블 입력
	int result = mapper.insertProductOrder(verifiedData);

	if (result == 0) {
		throw new RuntimeException("주문 처리에 실패했습니다.");
	}

	// 주문 상세 입력 및 재고 차감
	for (OrderItemDTO item : verifiedData.getItemList()) {

		item.setOrderId(verifiedData.getOrderId());
		item.setPriceFix(item.getOptionPrice());
		item.setGradeDisAmount((long)(item.getOptionPrice() * item.getQty()
						* (1.0 - verifiedData.getCouponValue()) * verifiedData.getDiscountRate()));

		result = mapper.insertOrderDetail(item);

		if (result == 0) {
			throw new RuntimeException("주문 상세 처리에 실패했습니다.");
		}

		result = mapper.updateProductStock(item);

		if (result == 0) {
			throw new RuntimeException("재고가 부족합니다.");
		}
	}

	// 쿠폰 사용 처리
	if (verifiedData.getChistId() != null) {
		result = mapper.updateCouponStatus(verifiedData);
		if (result == 0) {
			throw new RuntimeException("쿠폰 사용 처리에 실패했습니다.");
		}
	}

	// 포인트 사용 처리
	if (usedPoint > 0) {
		verifiedData.setBalance(verifiedData.getPoint() - usedPoint);
		result = mapper.insertPointHistoryUse(verifiedData);
		if (result == 0) {
			throw new RuntimeException("포인트 사용 처리에 실패했습니다.");
		}
	}

	// 포인트 적립
	long earnPoint =(long)(verifiedData.getTotalPrice() * 0.01);
	verifiedData.setEarnPoint(earnPoint);

	// 최종 포인트
	long balance = verifiedData.getPoint() - usedPoint + earnPoint;
	verifiedData.setBalance(balance);
	result = mapper.insertPointHistoryEarn(verifiedData);
	if (result == 0) {
		throw new RuntimeException("포인트 적립 처리에 실패했습니다.");
	}

	// 회원 포인트 업데이트
	result = mapper.updatePoint(verifiedData.getMemberId(), (int) balance);

	if (result == 0) {
		throw new RuntimeException("포인트 업데이트에 실패했습니다.");
	}
	
	// 회원 누적구매금액 업데이트
	result = mapper.updateTotalAmount(verifiedData.getMemberId(), totalPrice);

		if (result == 0) {
			throw new RuntimeException("누적 구매금액 업데이트에 실패했습니다.");
		}
	
	// 회원 누적구매금액 업데이트
	result = mapper.updateMemberGrade(verifiedData.getMemberId());

		if (result == 0) {
			throw new RuntimeException("회원 등급 업데이트에 실패했습니다.");
		}
	

	// 장바구니 상품 삭제
	if (checkoutInputData.getCartIds() != null	&& !checkoutInputData.getCartIds().isEmpty()) {
		mapper.deleteCartItems(verifiedData.getMemberId(), checkoutInputData.getCartIds());
	}

	return verifiedData;

	}

}
