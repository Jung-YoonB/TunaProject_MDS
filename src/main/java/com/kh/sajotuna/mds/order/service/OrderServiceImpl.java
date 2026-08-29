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
	    
	    // memberId로 정보 찾아와서 저장
	    CheckoutDTO verifiedData = mapper.selectByMemberIdForCheckout(checkoutInputData.getMemberId());
	    
	    // 뷰에서 넘겨준 데이터 중 popId만 뽑아서 최신 정보인지, 수량이 남아있는지 등 확인 
	    List<OrderItemDTO> itemList = mapper.selectItems(checkoutInputData.getItemList());
	    
	    // popId로 조회한 List에 수량을 넣어주는 작업
	    Map<Long, Long> qtyMap = checkoutInputData.getItemList().stream()
	            .collect(Collectors.toMap(OrderItemDTO::getPopId, OrderItemDTO::getQty));
	    for (OrderItemDTO item : itemList) {
	        Long qty = qtyMap.get(item.getPopId());
	        item.setQty(qty);
	    }
	    verifiedData.setItemList(itemList);
	    
	    // 쿠폰 확인
	    double couponValue = 0.0;
	    verifiedData.setChistId(checkoutInputData.getChistId());
	    if (checkoutInputData.getChistId() != null) {
	        couponValue = mapper.selectByChistId(checkoutInputData.getMemberId(), checkoutInputData.getChistId());
	        verifiedData.setCouponValue(couponValue);
	    } else {
	        verifiedData.setCouponValue(0.0);
	    }
	    
	    // 총 가격 계산
	    long totalPrice = 0L;
	    for (OrderItemDTO i : itemList) {
	        totalPrice += i.getOptionPrice() * i.getQty();
	    }
	    totalPrice = (long) (totalPrice * (1.0 - verifiedData.getCouponValue()) * (1.0 - verifiedData.getDiscountRate())); 
	    verifiedData.setTotalPrice(totalPrice);

	    // 확인이 불필요한 정보 옮기기
	    verifiedData.setUsedPoint(checkoutInputData.getUsedPoint());
	    verifiedData.setAddressNameFix(checkoutInputData.getAddressNameFix());
	    verifiedData.setDetailAddressFix(checkoutInputData.getDetailAddressFix());
	    verifiedData.setPaymentId(checkoutInputData.getPaymentId());		
	            
	    // 주문 테이블 입력
	    int result = mapper.insertProductOrder(verifiedData); 
	    
	    // 주문 상세 테이블 입력
	    for (OrderItemDTO item : verifiedData.getItemList()) {
	        item.setOrderId(verifiedData.getOrderId());
	        item.setPriceFix(item.getOptionPrice());
	        item.setGradeDisAmount((long) (item.getOptionPrice() * item.getQty() *
	                                (1.0 - verifiedData.getCouponValue()) * verifiedData.getDiscountRate()));
	        result = mapper.insertOrderDetail(item);
	    }
	    
	    // 사용한 쿠폰 상태 업데이트
	    if (verifiedData.getChistId() != null) {
	        result = mapper.updateCouponStatus(verifiedData);
	    }
	    
	    // null 방지
	    Integer usedPoint = (verifiedData.getUsedPoint() != null) ? verifiedData.getUsedPoint() : 0;
	    
	    // 포인트 사용 처리 및 이력 기록 (사용한 포인트가 있을 경우만)
	    if (usedPoint > 0) {
	        int balanceAfterUse = (int) (verifiedData.getPoint() - usedPoint);
	        verifiedData.setBalance(balanceAfterUse);
	        result = mapper.insertPointHistoryUse(verifiedData); 
	    }
	    
	    // 포인트 적립 처리 및 이력 기록
	    int earnPoint = (int) (verifiedData.getTotalPrice() * 0.01);
	    verifiedData.setEarnPoint(earnPoint);
	    
	    // 적립 후 잔액 계산 (기존포인트 - 사용포인트 + 적립포인트)
	    int balanceAfterEarn = (int) (verifiedData.getPoint() - usedPoint + earnPoint);
	    verifiedData.setBalance(balanceAfterEarn);
	    result = mapper.insertPointHistoryEarn(verifiedData);
	    
	    // 회원 최종 포인트 DB 업데이트
	    int changePoint = balanceAfterEarn; 
	    result = mapper.updatePoint(verifiedData.getMemberId(), changePoint);
	    
	    return verifiedData;
	}
	
}
