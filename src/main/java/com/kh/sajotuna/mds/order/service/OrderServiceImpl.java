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
	    
	    // [예외 방어 추가] 입력 객체 null 체크
	    if (checkoutInputData == null) {
	        throw new IllegalArgumentException("주문 요청 정보가 유효하지 않습니다.");
	    }
	    if (checkoutInputData.getMemberId() == null) {
	        throw new IllegalArgumentException("회원 정보가 누락되었습니다.");
	    }

	    // memberId로 정보 찾아와서 저장
	    CheckoutDTO verifiedData = mapper.selectByMemberIdForCheckout(checkoutInputData.getMemberId());
	    
	    // [예외 방어 추가] 조회된 회원 정보 검증
	    if (verifiedData == null) {
	        throw new IllegalArgumentException("존재하지 않거나 탈퇴한 회원입니다.");
	    }
	    
	    // [예외 방어 추가] 주문 상품 목록 null/empty 체크
	    if (checkoutInputData.getItemList() == null || checkoutInputData.getItemList().isEmpty()) {
	        throw new IllegalArgumentException("주문할 상품 목록이 존재하지 않습니다.");
	    }

	    // 뷰에서 넘겨준 데이터 중 popId만 뽑아서 최신 정보인지, 수량이 남아있는지 등 확인 
	    List<OrderItemDTO> itemList = mapper.selectItems(checkoutInputData.getItemList());
	    
	    // [예외 방어 추가] DB 조회 상품과 요청 상품 수 비교
	    if (itemList == null || itemList.size() != checkoutInputData.getItemList().size()) {
	        throw new IllegalArgumentException("판매 중지되었거나 존재하지 않는 상품이 포함되어 있습니다.");
	    }

	    // popId로 조회한 List에 수량을 넣어주는 작업
	    Map<Long, Long> qtyMap = checkoutInputData.getItemList().stream()
	            .collect(Collectors.toMap(OrderItemDTO::getPopId, OrderItemDTO::getQty));
	    for (OrderItemDTO item : itemList) {
	        Long qty = qtyMap.get(item.getPopId());
	        
	        // [예외 방어 추가] 수량 유효성 검증
	        if (qty == null || qty <= 0) {
	            throw new IllegalArgumentException("상품 수량은 1개 이상이어야 합니다.");
	        }
	        
	        item.setQty(qty);
	    }
	    verifiedData.setItemList(itemList);
	    
	    // 쿠폰 확인
	    double couponValue = 0.0;
	    verifiedData.setChistId(checkoutInputData.getChistId());
	    if (checkoutInputData.getChistId() != null) {
	        couponValue = mapper.selectByChistId(checkoutInputData.getMemberId(), checkoutInputData.getChistId());
	        
	        // [예외 방어 추가] 쿠폰 적용 가능 여부(음수나 유효하지 않은 할인율) 검증
	        if (couponValue < 0.0 || couponValue > 1.0) {
	            throw new IllegalArgumentException("유효하지 않거나 이미 사용된 쿠폰입니다.");
	        }
	        
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
	    
	    // [예외 방어 추가] 최종 금액 음수 방지
	    if (totalPrice < 0L) {
	        throw new IllegalStateException("계산된 총 결제 금액이 올바르지 않습니다.");
	    }
	    
	    verifiedData.setTotalPrice(totalPrice);

	    // 확인이 불필요한 정보 옮기기
	    verifiedData.setUsedPoint(checkoutInputData.getUsedPoint());
	    verifiedData.setAddressNameFix(checkoutInputData.getAddressNameFix());
	    verifiedData.setDetailAddressFix(checkoutInputData.getDetailAddressFix());
	    verifiedData.setPaymentId(checkoutInputData.getPaymentId());		
	            
	    // null 방지
	    Integer usedPoint = (verifiedData.getUsedPoint() != null) ? verifiedData.getUsedPoint() : 0;
	    
	    // [예외 방어 추가] 음수 포인트 사용 방지 및 보유 포인트 초과 사용 방지
	    if (usedPoint < 0) {
	        throw new IllegalArgumentException("사용할 포인트는 음수일 수 없습니다.");
	    }
	    if (usedPoint > verifiedData.getPoint()) {
	        throw new IllegalArgumentException("보유한 포인트(" + verifiedData.getPoint() + "p)보다 많은 포인트를 사용할 수 없습니다.");
	    }

	    // 주문 테이블 입력
	    int result = mapper.insertProductOrder(verifiedData); 
	    
	    // [예외 방어 추가] DB Insert 결과 검증
	    if (result <= 0) {
	        throw new RuntimeException("주문 정보 등록 중 오류가 발생했습니다.");
	    }
	    
	    // 주문 상세 테이블 입력
	    for (OrderItemDTO item : verifiedData.getItemList()) {
	        item.setOrderId(verifiedData.getOrderId());
	        item.setPriceFix(item.getOptionPrice());
	        item.setGradeDisAmount((long) (item.getOptionPrice() * item.getQty() *
	                                (1.0 - verifiedData.getCouponValue()) * verifiedData.getDiscountRate()));
	        result = mapper.insertOrderDetail(item);
	        
	        // [예외 방어 추가] DB Insert 결과 검증
	        if (result <= 0) {
	            throw new RuntimeException("주문 상세 내역 등록 중 오류가 발생했습니다.");
	        }
	    }
	    
	    // 사용한 쿠폰 상태 업데이트
	    if (verifiedData.getChistId() != null) {
	        result = mapper.updateCouponStatus(verifiedData);
	        
	        // [예외 방어 추가] DB Update 결과 검증
	        if (result <= 0) {
	            throw new RuntimeException("쿠폰 상태 변경 중 오류가 발생했습니다.");
	        }
	    }
	    
	    // 포인트 사용 처리 및 이력 기록 (사용한 포인트가 있을 경우만)
	    if (usedPoint > 0) {
	        int balanceAfterUse = (int) (verifiedData.getPoint() - usedPoint);
	        verifiedData.setBalance(balanceAfterUse);
	        result = mapper.insertPointHistoryUse(verifiedData); 
	        
	        // [예외 방어 추가] DB Insert 결과 검증
	        if (result <= 0) {
	            throw new RuntimeException("포인트 차감 이력 등록 중 오류가 발생했습니다.");
	        }
	    }
	    
	    // 포인트 적립 처리 및 이력 기록
	    int earnPoint = (int) (verifiedData.getTotalPrice() * 0.01);
	    verifiedData.setEarnPoint(earnPoint);
	    
	    // 적립 후 잔액 계산 (기존포인트 - 사용포인트 + 적립포인트)
	    int balanceAfterEarn = (int) (verifiedData.getPoint() - usedPoint + earnPoint);
	    verifiedData.setBalance(balanceAfterEarn);
	    result = mapper.insertPointHistoryEarn(verifiedData);
	    
	    // [예외 방어 추가] DB Insert 결과 검증
	    if (result <= 0) {
	        throw new RuntimeException("포인트 적립 이력 등록 중 오류가 발생했습니다.");
	    }
	    
	    // 회원 최종 포인트 DB 업데이트
	    int changePoint = balanceAfterEarn; 
	    result = mapper.updatePoint(verifiedData.getMemberId(), changePoint);
	    
	    // [예외 방어 추가] DB Update 결과 검증
	    if (result <= 0) {
	        throw new RuntimeException("회원 최종 포인트 갱신 중 오류가 발생했습니다.");
	    }
	    
	    return verifiedData;
	}
	
}
