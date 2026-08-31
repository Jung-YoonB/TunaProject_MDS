package com.kh.sajotuna.mds.member.service;

import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageCartDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageWishDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;
import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService{

	// MemberMapper DI
	private final MemberMapper mapper;
	// PasswordEncoder DI
	private final PasswordEncoder passwordEncoder;
	
	@Override
	@Transactional
	public void signUp(MemberDTO member) {
		// 아이디 중복검사
		if(isLoginIdCheck(member.getLoginId())) {
			throw new IllegalStateException("이미 사용중인 아이디입니다.");
		}
		
		// 닉네임 중복검사
		if(isNicknameCheck(member.getNickname())) {
			throw new IllegalStateException("이미 사용중인 닉네임입니다.");
		}
		
		// 이메일 중복검사
		if(isEmailCheck(member.getEmail())) {
			throw new IllegalStateException("이미 사용중인 이메일입니다.");
		}
		
		// 연락처 중복검사
		if(isPhoneCheck(member.getPhone())) {
			throw new IllegalStateException("이미 사용중인 연락처입니다.");
		}
				
		// 비밀번호 암호화 처리
		String encodePw = passwordEncoder.encode(member.getLoginPw());
		member.setLoginPw(encodePw);
				
		// 체크 된 데이터를 저장
		mapper.insertMember(member);
		mapper.insertPoint(member.getMemberId()); // 회원의 포인트도 초기화
		
	}

	@Override
	public boolean isLoginIdCheck(String loginId) {
		// 중복된 아이디가 있으면 검색 결과가 0이 아님.
		return mapper.countByLoginId(loginId) > 0;
	}

	@Override
	public boolean isNicknameCheck(String nickname) {
		return mapper.countByNickname(nickname) > 0;
	}

	@Override
	public boolean isEmailCheck(String email) {
		return mapper.countByEmail(email) > 0;
	}

	@Override
	public boolean isPhoneCheck(String phone) {
		return mapper.countByPhone(phone) > 0;
	}

	@Override
	public MemberDTO login(String loginId, String loginPw) throws IllegalStateException{

		MemberDTO member = mapper.selectByLoginId(loginId);
		if (member == null || !passwordEncoder.matches(loginPw, member.getLoginPw())) {
			throw new IllegalStateException("아이디 또는 비밀번호가 일치하지 않습니다.");
		}
		
		if (member.getMemberStatus() != 1) { 
		    throw new IllegalStateException("정지되었거나 탈퇴한 회원입니다.");
		}
		
		MemberDTO sessionMember = new MemberDTO(member.getMemberId(),
				member.getMemberName(), member.getRole());
		return sessionMember;
	}


	@Override
	public MemberDTO getMemberByMemberId(Long memberId) {
		MemberDTO member = mapper.selectByMemberId(memberId);
		
		return member;
	}

	private static final int COUPON_PAGE_SIZE = 10;

	@Override

	public List<CouponDTO> listCoupon(Long memberId, int page) {
		int safePage = Math.max(page, 1);
		int offset = (safePage - 1) * COUPON_PAGE_SIZE;
		return mapper.selectCouponsByMemberId(memberId, offset, COUPON_PAGE_SIZE);
	}

	@Override
	public int totalCouponPages(Long memberId) {
		int totalCount = mapper.countCouponsByMemberId(memberId);
		return Math.max(1, (int) Math.ceil((double) totalCount / COUPON_PAGE_SIZE));
	}

	@Override
	public int countCoupons(Long memberId) {
		return mapper.countCouponsByMemberId(memberId);
	}

	@Override
	public List<MyPageWishDTO> listWish(Long memberId) {
		List<MyPageWishDTO> wishList = mapper.selectWishesByMemberId(memberId);
		
		return wishList;
	}
	
	@Override
	public List<MyPageCartDTO> listCart(Long memberId) {
		List<MyPageCartDTO> cartList = mapper.selectCartsByMemberId(memberId);
		
		return cartList;
	}

	private static final int DELIVERY_PAGE_SIZE = 10;

	@Override
	public List<MyPageDeliveryDTO> listDelivery(Long memberId, String status, int page) {
		// 대표 상품 정보(이름/이미지/수량/건수)는 selectDeliveriesByMemberId 쿼리에 이미 조인되어 있음
		// (주문 건수만큼 반복 조회하던 N+1 쿼리를 단일 쿼리로 정리). 주문이 쌓여도 느려지지 않도록
		// 상태 필터 + 페이징은 서버(SQL의 WHERE/OFFSET-FETCH)에서 처리한다
		int safePage = Math.max(page, 1);
		int offset = (safePage - 1) * DELIVERY_PAGE_SIZE;
		return mapper.selectDeliveriesByMemberId(memberId, status, offset, DELIVERY_PAGE_SIZE);
	}

	@Override
	public boolean nicknameUpdate(Long memberId, String nickname) {
		return mapper.updateNickname(memberId, nickname) < 0;
	}
	
	@Override
	public boolean phoneUpdate(Long memberId, String phone) {
	    return mapper.updatePhone(memberId, phone) > 0;
	}

	@Override
	public boolean emailUpdate(Long memberId, String email) {
	    return mapper.updateEmail(memberId, email) > 0;
	}

	@Override
	public boolean nameUpdate(Long memberId, String memberName) {
	    return mapper.updateName(memberId, memberName) > 0;
	}

	@Override
	public boolean birthUpdate(Long memberId, String birth) {
	    return mapper.updateBirth(memberId, birth) > 0;
	}

	@Override
	public boolean genderUpdate(Long memberId, String gender) {
	    return mapper.updateGender(memberId, gender) > 0;
	}

	@Override
	public boolean passwordUpdate(Long memberId, String newPassword) {
		String encodePw = passwordEncoder.encode(newPassword);
	    return mapper.updatePassword(memberId, encodePw) > 0;
	}
	
	@Override
	public boolean withdrawMember(Long memberId) {
	    return mapper.withdrawMember(memberId) > 0;
	}
	
	public int totalDeliveryPages(Long memberId, String status) {
		int totalCount = mapper.countDeliveriesByMemberId(memberId, status);
		return Math.max(1, (int) Math.ceil((double) totalCount / DELIVERY_PAGE_SIZE));
	}

	@Override
	public int countActiveDeliveries(Long memberId) {
		return mapper.countActiveDeliveries(memberId);
	}

	@Override
	public int countReviewableOrderDetails(Long memberId) {
		return mapper.countReviewableOrderDetails(memberId);
	}
}

