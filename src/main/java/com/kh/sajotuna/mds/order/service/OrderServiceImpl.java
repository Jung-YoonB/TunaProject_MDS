package com.kh.sajotuna.mds.order.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;
import com.kh.sajotuna.mds.order.model.dto.CheckoutDTO;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;
import com.kh.sajotuna.mds.order.model.mapper.OrderMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor	
public class OrderServiceImpl implements OrderService {

	// 배송비 정책 (담당자 확정, 2026-09-02)
	//
	// 무료배송 여부는 "할인 전" 상품금액(옵션가 x 수량의 합)으로 판정한다.
	// 쿠폰/등급 할인을 뺀 금액으로 판정하면 같은 장바구니가 쿠폰 유무에 따라 배송비가 달라져,
	// 결제 화면에 보이던 금액과 실제 저장 금액이 어긋난다(실제로 주문 47번과 49번이 3,000원 갈렸음).
	//
	// 값을 바꿀 땐 화면 계산도 같이 고칠 것 - static/js/product/cartService.js 가 같은 기준을 쓴다.
	private static final long FREE_SHIPPING_THRESHOLD = 50_000L;
	private static final long SHIPPING_FEE = 3_000L;

	// 포인트 최소 사용 단위. 화면(안내 문구·입력 검증)도 이 값을 써야 하므로
	// PaymentViewDTO.pointMinUse 로 내려보낸다 - JSP/JS 에 숫자를 따로 적지 말 것.
	private static final long POINT_MIN_USE = 1_000L;

	// 결제 금액의 1%를 적립한다
	private static final double POINT_EARN_RATE = 0.01;

	private final OrderMapper mapper;
	private final MemberMapper memberMapper;

	/** 배송비. 반드시 할인 전 상품금액을 넘길 것 */
	private long calcDeliveryFee(long productTotalPriceBeforeDiscount) {
		return productTotalPriceBeforeDiscount >= FREE_SHIPPING_THRESHOLD ? 0L : SHIPPING_FEE;
	}

	@Override
	public PaymentViewDTO cartPrepare(Long memberId, List<Long> cartIds) {

	    // 멤버 정보 조회
	    PaymentViewDTO pvData = mapper.selectByMemberIdForPay(memberId);

	    // 장바구니 조회
	    List<OrderItemDTO> itemList = mapper.selectCartIds(memberId, cartIds);

	    // 상품 금액 계산
	    long totalPrice = 0L;

	    for (OrderItemDTO i : itemList) {
	        totalPrice += i.getOptionPrice() * i.getQty();
	    }

	    // 배송비 (아직 할인 적용 전 금액이라 그대로 넘기면 된다)
	    long deliveryFee = calcDeliveryFee(totalPrice);

	    // 보유 쿠폰 조회
	    List<CouponDTO> couponList =
	            memberMapper.selectAllCouponsByMemberId(memberId);

	    // 데이터 통합
	    pvData.setItemList(itemList);
	    pvData.setTotalPrice(totalPrice);
	    pvData.setDeliveryFee(deliveryFee);
	    pvData.setCouponList(couponList);
	    pvData.setPointMinUse(POINT_MIN_USE);

	    // 장바구니 ID
	    pvData.setCartIds(cartIds);

	    return pvData;
	}


	@Override
	public PaymentViewDTO directPrepare(Long memberId, OrderItemDTO orderItem) {
		// 멤버 정보 조회
		PaymentViewDTO pvData = mapper.selectByMemberIdForPay(memberId);
		// 바로구매 상품 조회
		List<OrderItemDTO> itemList = new ArrayList<>();
		OrderItemDTO result = mapper.selectPopId(orderItem.getPopId());
		result.setQty(orderItem.getQty());
		itemList.add(result);
				
		// 총 가격 계산
		long totalPrice = 0L;

		for (OrderItemDTO i : itemList) {
		    totalPrice += i.getOptionPrice() * i.getQty();
		}

		// 배송비 (아직 할인 적용 전 금액이라 그대로 넘기면 된다)
		long deliveryFee = calcDeliveryFee(totalPrice);

		// 보유 쿠폰 조회
		List<CouponDTO> couponList =
		        memberMapper.selectAllCouponsByMemberId(memberId);

		// 데이터 통합
		pvData.setItemList(itemList);
		pvData.setTotalPrice(totalPrice);
		pvData.setDeliveryFee(deliveryFee);
		pvData.setCouponList(couponList);
		pvData.setPointMinUse(POINT_MIN_USE);

		return pvData;
	}

	/**
	 * 결제. 크게 네 단계다.
	 *   1) 입력 검증 + 서버 기준 데이터 조회 (verifyAndLoad)
	 *   2) 결제 금액 계산 (calcTotalPrice)
	 *   3) 주문/주문상세/재고/쿠폰 저장 (saveOrder)
	 *   4) 포인트·등급·장바구니 뒷정리 (applyPointsAndGrade)
	 *
	 * 화면이 보내온 값은 믿지 않는다 - 가격·재고·쿠폰·포인트를 전부 DB에서 다시 읽어 계산한다.
	 */
	@Override
	@Transactional
	public CheckoutDTO checkout(CheckoutDTO checkoutInputData) {

		CheckoutDTO verifiedData = verifyAndLoad(checkoutInputData);

		calcTotalPrice(verifiedData);

		saveOrder(verifiedData);

		applyPointsAndGrade(verifiedData, checkoutInputData.getCartIds());

		return verifiedData;
	}


	/** 1) 입력을 검증하면서 서버 기준 데이터로 채운 CheckoutDTO를 만든다 */
	private CheckoutDTO verifyAndLoad(CheckoutDTO input) {

		// 최소 사용 단위 확인 (0은 "사용 안 함"이라 통과시킨다)
		if (input.getUsedPoint() != null && input.getUsedPoint() != 0
				&& input.getUsedPoint() < POINT_MIN_USE) {
			throw new IllegalArgumentException("포인트는 " + POINT_MIN_USE + "P 이상부터 사용할 수 있습니다.");
		}

		CheckoutDTO verifiedData = mapper.selectByMemberIdForCheckout(input.getMemberId());

		if (verifiedData == null) {
			throw new IllegalArgumentException("회원 정보를 찾을 수 없습니다.");
		}

		if (input.getItemList() == null || input.getItemList().isEmpty()) {
			throw new IllegalArgumentException("구매할 상품이 없습니다.");
		}

		// 가격·재고는 화면 값이 아니라 지금 시점의 DB 값을 쓴다
		List<OrderItemDTO> itemList = mapper.selectItems(input.getItemList());

		if (itemList == null || itemList.size() != input.getItemList().size()) {
			throw new IllegalArgumentException("상품 정보를 찾을 수 없습니다.");
		}

		Map<Long, Long> qtyMap = input.getItemList().stream()
				.collect(Collectors.toMap(OrderItemDTO::getPopId, OrderItemDTO::getQty));

		for (OrderItemDTO item : itemList) {
			Long qty = qtyMap.get(item.getPopId());

			if (qty == null || qty <= 0) {
				throw new IllegalArgumentException("상품 수량이 올바르지 않습니다.");
			}

			if (item.getOptionStock() < qty) {
				throw new IllegalArgumentException(item.getOptionName() + " 상품의 재고가 부족합니다.");
			}

			item.setQty(qty);
		}

		verifiedData.setItemList(itemList);

		// 쿠폰 - 실제 보유분인지 확인하고 할인율도 DB에서 가져온다
		verifiedData.setChistId(input.getChistId());

		if (input.getChistId() != null) {
			BigDecimal couponValue = mapper.selectByChistId(verifiedData.getMemberId(), input.getChistId());

			if (couponValue == null) {
				throw new IllegalArgumentException("사용할 수 없는 쿠폰입니다.");
			}
			verifiedData.setCouponValue(couponValue);
		} else {
			verifiedData.setCouponValue(BigDecimal.ZERO);
		}

		int usedPoint = input.getUsedPoint() != null ? input.getUsedPoint() : 0;

		if (usedPoint < 0 || usedPoint > verifiedData.getPoint()) {
			throw new IllegalArgumentException("사용할 수 없는 포인트입니다.");
		}
		verifiedData.setUsedPoint(usedPoint);

		// 검증할 게 없는 값들
		verifiedData.setPaymentId(input.getPaymentId());
		verifiedData.setAddressNameFix(input.getAddressNameFix());
		verifiedData.setDetailAddressFix(input.getDetailAddressFix());
		verifiedData.setClientPaidAmount(input.getClientPaidAmount());

		return verifiedData;
	}


	/**
	 * 2) 결제 금액을 계산해 deliveryFee / totalPrice 를 채운다.
	 *
	 * 쿠폰과 등급 할인은 BigDecimal로 한 번에 곱한 뒤 마지막에 한 번만 HALF_UP 한다.
	 * 화면(views/payment.js)도 같은 방식으로 계산해야 보이는 금액과 결제 금액이 어긋나지 않는다.
	 */
	private void calcTotalPrice(CheckoutDTO verifiedData) {

		long productTotalPrice = 0L;
		for (OrderItemDTO item : verifiedData.getItemList()) {
			productTotalPrice += item.getOptionPrice() * item.getQty();
		}

		// 배송비는 할인 전 상품금액 기준
		long deliveryFee = calcDeliveryFee(productTotalPrice);
		verifiedData.setDeliveryFee(deliveryFee);

		long discountedProductPrice = BigDecimal.valueOf(productTotalPrice)
				.multiply(BigDecimal.ONE.subtract(couponRateOf(verifiedData)))
				.multiply(BigDecimal.ONE.subtract(gradeRateOf(verifiedData)))
				.setScale(0, RoundingMode.HALF_UP)
				.longValue();

		long usedPoint = verifiedData.getUsedPoint() != null ? verifiedData.getUsedPoint() : 0;
		long totalPrice = discountedProductPrice + deliveryFee - usedPoint;

		if (totalPrice < 0) {
			throw new IllegalArgumentException("사용 포인트가 결제 금액보다 많습니다.");
		}

		verifiedData.setTotalPrice(totalPrice);
	}


	/** 3) 주문 → 주문상세 + 재고 차감 → 쿠폰 사용 처리 */
	private void saveOrder(CheckoutDTO verifiedData) {

		if (mapper.insertProductOrder(verifiedData) == 0) {
			throw new RuntimeException("주문 처리에 실패했습니다.");
		}

		BigDecimal couponRate = couponRateOf(verifiedData);
		BigDecimal gradeRate = gradeRateOf(verifiedData);

		for (OrderItemDTO item : verifiedData.getItemList()) {
			item.setOrderId(verifiedData.getOrderId());
			// 주문 시점 단가를 박아 둔다(상품 가격이 나중에 바뀌어도 지난 주문서는 그대로여야 한다)
			item.setPriceFix(item.getOptionPrice());

			BigDecimal gradeDisAmount = BigDecimal.valueOf(item.getOptionPrice() * item.getQty())
					.multiply(BigDecimal.ONE.subtract(couponRate))
					.multiply(gradeRate)
					.setScale(0, RoundingMode.HALF_UP);
			item.setGradeDisAmount(gradeDisAmount.longValue());

			if (mapper.insertOrderDetail(item) == 0) {
				throw new RuntimeException("주문 상세 처리에 실패했습니다.");
			}

			// 재고가 모자라면 0건이 갱신된다(쿼리에 OPTION_STOCK >= qty 조건이 있음)
			if (mapper.updateProductStock(item) == 0) {
				throw new RuntimeException("재고가 부족합니다.");
			}
		}

		if (verifiedData.getChistId() != null && mapper.updateCouponStatus(verifiedData) == 0) {
			throw new RuntimeException("쿠폰 사용 처리에 실패했습니다.");
		}
	}


	/** 4) 포인트 사용·적립 이력, 잔액/누적구매금액/등급 갱신, 장바구니 비우기 */
	private void applyPointsAndGrade(CheckoutDTO verifiedData, List<Long> cartIds) {

		long usedPoint = verifiedData.getUsedPoint() != null ? verifiedData.getUsedPoint() : 0;

		if (usedPoint > 0) {
			verifiedData.setBalance(verifiedData.getPoint() - usedPoint);
			if (mapper.insertPointHistoryUse(verifiedData) == 0) {
				throw new RuntimeException("포인트 사용 처리에 실패했습니다.");
			}
		}

		long earnPoint = (long) (verifiedData.getTotalPrice() * POINT_EARN_RATE);
		verifiedData.setEarnPoint(earnPoint);

		long balance = verifiedData.getPoint() - usedPoint + earnPoint;
		verifiedData.setBalance(balance);

		if (mapper.insertPointHistoryEarn(verifiedData) == 0) {
			throw new RuntimeException("포인트 적립 처리에 실패했습니다.");
		}

		if (mapper.updatePoint(verifiedData.getMemberId(), (int) balance) == 0) {
			throw new RuntimeException("포인트 업데이트에 실패했습니다.");
		}

		if (mapper.updateTotalAmount(verifiedData.getMemberId(), verifiedData.getTotalPrice()) == 0) {
			throw new RuntimeException("누적 구매금액 업데이트에 실패했습니다.");
		}

		// 누적 구매금액이 바뀌었으니 등급도 다시 매긴다
		if (mapper.updateMemberGrade(verifiedData.getMemberId()) == 0) {
			throw new RuntimeException("회원 등급 업데이트에 실패했습니다.");
		}

		// 장바구니에서 넘어온 결제만 해당 - 바로구매는 지울 게 없다
		if (cartIds != null && !cartIds.isEmpty()) {
			mapper.deleteCartItems(verifiedData.getMemberId(), cartIds);
		}
	}


	/** 쿠폰 할인율(없으면 0) */
	private BigDecimal couponRateOf(CheckoutDTO data) {
		return data.getCouponValue() != null ? data.getCouponValue() : BigDecimal.ZERO;
	}

	/** 회원 등급 할인율(없으면 0) */
	private BigDecimal gradeRateOf(CheckoutDTO data) {
		return data.getDiscountRate() != null ? data.getDiscountRate() : BigDecimal.ZERO;
	}

	
	@Override
	public Long getOrderIdForMember(Long memberId, Long orderId) {

	    System.out.println("===== getOrderIdForMember =====");
	    System.out.println("orderId = " + orderId);
	    System.out.println("memberId = " + memberId);

	    Long result = mapper.getOrderIdForMember(memberId, orderId);

	    System.out.println("mapper result = " + result);

	    if (result == null) {
	        throw new IllegalArgumentException(
	            "존재하지 않는 주문이거나 접근할 수 없는 주문입니다."
	        );
	    }

	    return result;
	}

}