package com.kh.sajotuna.mds.member.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;
import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;

@Mapper
public interface MemberMapper {

	// 회원 가입
	int insertMember(MemberDTO member);
	
	// 가입 시 포인트 초기화
	int insertPoint(Long memberId);
	
	// 중복 확인
	int countByLoginId(String loginId);
	int countByNickname(String nickname);
	int countByEmail(String email);
	int countByPhone(String phone);
	
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
	
	// 멤버 아이디를 통한 찜 목록 조회
	List<MyPageWishDTO> selectWishesByMemberId(Long memberId);
	
	// 멤버 아이디를 통한 장바구니 조회
	List<MyPageCartDTO> selectCartsByMemberId(Long memberId);
	
	// 회원 정보 수정
	int updateNickname(@Param("memberId") Long memberId, @Param("nickname") String nickname);
	int updatePhone(@Param("memberId") Long memberId, @Param("phone") String phone);
	int updateEmail(@Param("memberId") Long memberId, @Param("email") String email);
	int updateName(@Param("memberId") Long memberId, @Param("memberName") String memberName);
	int updateBirth(@Param("memberId") Long memberId, @Param("birth") String birth);
	int updateGender(@Param("memberId") Long memberId, @Param("gender") String gender);
	int updatePassword(@Param("memberId") Long memberId, @Param("newPassword") String newPassword);
	
	// 회원 탈퇴
	int withdrawMember(Long memberId);
	
	// 멤버 아이디를 통한 배송데이터 조회 (대표 상품 1건 포함, 상태 필터 + 페이징)
	List<MyPageDeliveryDTO> selectDeliveriesByMemberId(@Param("memberId") Long memberId, @Param("status") String status,
			@Param("offset") int offset, @Param("pageSize") int pageSize);

	// 위 조회 조건(회원+상태)에 해당하는 전체 건수 (페이지네이션 계산용)
	int countDeliveriesByMemberId(@Param("memberId") Long memberId, @Param("status") String status);

	// 마이페이지 "주문/배송 조회" 배지용 - 배송완료/취소환불 이전 단계(진행중)인 주문 건수
	int countActiveDeliveries(@Param("memberId") Long memberId);

	// 마이페이지 "리뷰 작성" 배지용 - 배송완료된 주문 상세 중 아직 리뷰를 안 쓴 건수
	int countReviewableOrderDetails(@Param("memberId") Long memberId);
}