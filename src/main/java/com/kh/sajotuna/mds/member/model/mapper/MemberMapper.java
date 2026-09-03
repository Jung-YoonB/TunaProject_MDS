package com.kh.sajotuna.mds.member.model.mapper;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.member.model.dto.DeliveryAddressDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageOrderItemDTO;

@Mapper
public interface MemberMapper {

	// 회원 가입
	int insertMember(MemberDTO member);
	
	// 가입 시 포인트 초기화
	int insertPoint(Long memberId);
	
	// 중복 확인. excludeMemberId는 "본인 제외" - 회원정보 수정에서 자기 값을 다시 확인해도
	// 중복으로 잡히지 않게 한다. 회원가입은 본인이 없으므로 null을 넘긴다.
	int countByLoginId(String loginId);
	int countByNickname(@Param("nickname") String nickname, @Param("excludeMemberId") Long excludeMemberId);
	int countByEmail(@Param("email") String email, @Param("excludeMemberId") Long excludeMemberId);
	int countByPhone(@Param("phone") String phone, @Param("excludeMemberId") Long excludeMemberId);
	
	// 로그인 아이디를 통한 회원 조회
	MemberDTO selectByLoginId(String loginId);
	
	// 멤버 아이디를 통한 회원 조회
	MemberDTO selectByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 보유 쿠폰 조회 (사용 가능한 것만, 뷰가 아니라 결제용)
	List<CouponDTO> selectAllCouponsByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 보유 쿠폰 조회 (사용 가능한 것만, 페이징)
	List<CouponDTO> selectCouponsByMemberId(@Param("memberId") Long memberId, @Param("offset") int offset, @Param("pageSize") int pageSize);

	// 위 조회 조건의 전체 건수 (페이지네이션 계산용)
	int countCouponsByMemberId(@Param("memberId") Long memberId);
	
	// 회원 정보 수정
	int updateNickname(@Param("memberId") Long memberId, @Param("nickname") String nickname);
	int updatePhone(@Param("memberId") Long memberId, @Param("phone") String phone);
	int updateEmail(@Param("memberId") Long memberId, @Param("email") String email);
	int updateName(@Param("memberId") Long memberId, @Param("memberName") String memberName);
	int updateBirth(@Param("memberId") Long memberId, @Param("birth") LocalDate birth);
	int updateGender(@Param("memberId") Long memberId, @Param("gender") String gender);
	int updatePassword(@Param("memberId") Long memberId, @Param("newPassword") String newPassword);
	
	// 회원 탈퇴
	int withdrawMember(Long memberId);
	
	// 멤버 아이디를 통한 배송데이터 조회 (대표 상품 1건 포함, 상태 필터 + 페이징)
	List<MyPageDeliveryDTO> selectDeliveriesByMemberId(@Param("memberId") Long memberId, @Param("status") String status,
			@Param("offset") int offset, @Param("pageSize") int pageSize);

	// 주문 카드를 펼쳤을 때 보여줄 품목 목록. 주문마다 따로 부르면 N+1이므로
	// 한 페이지에 보이는 주문 ID를 모아 한 번에 조회한다 (orderIds가 비면 호출하지 말 것)
	List<MyPageOrderItemDTO> selectOrderItemsByOrderIds(@Param("orderIds") List<Long> orderIds);

	// 위 조회 조건(회원+상태)에 해당하는 전체 건수 (페이지네이션 계산용)
	int countDeliveriesByMemberId(@Param("memberId") Long memberId, @Param("status") String status);

	// 마이페이지 "주문/배송 조회" 배지용 - 배송완료/취소환불 이전 단계(진행중)인 주문 건수
	int countActiveDeliveries(@Param("memberId") Long memberId);

	// 마이페이지 "리뷰 작성" 배지용 - 배송완료된 주문 상세 중 아직 리뷰를 안 쓴 건수
	int countReviewableOrderDetails(@Param("memberId") Long memberId);

	// 위 건수와 같은 조건에서 가장 먼저 리뷰를 쓸 주문상세 1건 (없으면 null)
	Long selectNextReviewableOdId(@Param("memberId") Long memberId);

	// 새 배송지 추가 전, 기본 배송지로 체크했으면 기존 기본 배송지를 먼저 해제한다
	// (UX_DELIVERYADDRESS_IS_DEFAULT 조건부 유니크 인덱스 - 회원당 Y는 1개뿐).
	int clearDefaultAddress(@Param("memberId") Long memberId);

	int insertDeliveryAddress(DeliveryAddressDTO address);
}