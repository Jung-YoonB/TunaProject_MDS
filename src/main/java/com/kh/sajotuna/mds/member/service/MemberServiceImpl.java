package com.kh.sajotuna.mds.member.service;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;

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
		
		// role에 user 부여
		member.setRole("USER");
				
		// 체크 된 데이터를 저장
		try {
			mapper.insertMember(member);
			mapper.insertPoint(member.getMemberId()); // 회원의 포인트도 초기화
		} catch (DuplicateKeyException e) {
	        // 동시에 가입하여 UNIQUE 제약조건에 걸린 경우
	        throw new IllegalStateException("동시 가입으로 인해 이미 등록된 정보가 존재합니다. 다시 확인해주세요.");
	    }
		
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
	@Transactional
	public boolean nicknameUpdate(Long memberId, String nickname) {
		if (nickname == null
				|| !nickname.matches("^[가-힣a-zA-Z0-9_]{2,8}$")) {
			throw new IllegalArgumentException(
					"닉네임은 한글, 영문, 숫자, 언더바(_)를 사용하여 2~8자로 입력해주세요.");
		}
		
		MemberDTO currentMember = mapper.selectByMemberId(memberId);
		
		if (currentMember == null) {
			throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
		}
		
		if (nickname.equals(currentMember.getNickname())) {
			return true;
		}
		
		if (isNicknameCheck(nickname)) {
			throw new IllegalStateException("이미 사용 중인 닉네임입니다.");
		}
		
		return mapper.updateNickname(memberId, nickname) > 0;
	}
	
	@Override
	@Transactional
	public boolean phoneUpdate(Long memberId, String phone) {
		if (phone == null || phone.isBlank() || !phone.matches("^01[0-9]{8,9}$")) {
			throw new IllegalArgumentException("올바른 전화번호 형식이 아닙니다.");
		}
		
		MemberDTO currentMember = mapper.selectByMemberId(memberId);
		if (currentMember == null) {
			throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
		}
		
		if (phone.equals(currentMember.getPhone())) {
			return true; // 기존 값과 동일하면 그대로 성공 처리
		}
		
		if (isPhoneCheck(phone)) {
			throw new IllegalStateException("이미 사용 중인 연락처입니다.");
		}
		
		return mapper.updatePhone(memberId, phone) > 0;
	}

	@Override
	@Transactional
	public boolean emailUpdate(Long memberId, String email) {
		if (email == null || email.isBlank() || !email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
			throw new IllegalArgumentException("올바른 이메일 형식이 아닙니다.");
		}
		
		MemberDTO currentMember = mapper.selectByMemberId(memberId);
		if (currentMember == null) {
			throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
		}
		
		if (email.equals(currentMember.getEmail())) {
			return true; // 기존 값과 동일하면 그대로 성공 처리
		}
		
		if (isEmailCheck(email)) {
			throw new IllegalStateException("이미 사용 중인 이메일입니다.");
		}
		
		return mapper.updateEmail(memberId, email) > 0;
	}

	@Override
	@Transactional
	public boolean nameUpdate(Long memberId, String memberName) {
		if (memberName == null
				|| !memberName.matches("^[가-힣]{2,4}$")) {
			throw new IllegalArgumentException(
					"이름은 한글 2~4자로 입력해주세요.");
		}

		MemberDTO currentMember = mapper.selectByMemberId(memberId);

		if (currentMember == null) {
			throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
		}

		if (memberName.equals(currentMember.getMemberName())) {
			return true;
		}

		return mapper.updateName(memberId, memberName) > 0;
	}

	@Override
	@Transactional
	public boolean birthUpdate(Long memberId, String birthStr) {
	    if (birthStr == null || birthStr.isBlank()) {
	        throw new IllegalArgumentException("생년월일은 비워둘 수 없습니다.");
	    }
	    
	    LocalDate birthDate;
	    try {
	        birthDate = LocalDate.parse(birthStr);
	    } catch (DateTimeParseException e) {
	        throw new IllegalArgumentException("올바른 생년월일 형식이 아닙니다.");
	    }

	    MemberDTO currentMember = mapper.selectByMemberId(memberId);
	    if (currentMember == null) {
	        throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
	    }
	    
	    // LocalDate 타입끼리 직접 비교가 가능해집니다
	    if (birthDate.equals(currentMember.getBirth())) {
	        return true;
	    }
	    
	    return mapper.updateBirth(memberId, birthDate) > 0;
	}

	@Override
	@Transactional
	public boolean genderUpdate(Long memberId, String gender) {
	if (gender == null || gender.isBlank() || (!gender.equals("M") && !gender.equals("F"))) {
	throw new IllegalArgumentException("유효하지 않은 성별 형식입니다.");
	}
	
	MemberDTO currentMember = mapper.selectByMemberId(memberId);
	
	if (currentMember == null) {
		throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
	}
	
	if (currentMember != null && gender.equals(currentMember.getGender())) {
	return true; // 이미 동일한 값인 경우 불필요한 업데이트 생략
	}
	return mapper.updateGender(memberId, gender) > 0;
	}

	@Override
	@Transactional
	public boolean passwordUpdate(Long memberId, String currentPassword, String newPassword) {
	    if (newPassword == null || !newPassword.matches("^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$")) {
	        throw new IllegalArgumentException("영어, 숫자, 특수문자를 포함한 8~16자로 입력해주세요.");
	    }

	    MemberDTO currentMember = mapper.selectByMemberId(memberId);
	    if (currentMember == null) {
	        throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
	    }

	    // 현재 비밀번호 일치 여부 확인 (PasswordEncoder의 matches 활용)
	    if (!passwordEncoder.matches(currentPassword, currentMember.getLoginPw())) {
	        throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
	    }

	    // 새 비밀번호가 기존 비밀번호와 동일한지 확인 (선택 사항)
	    if (passwordEncoder.matches(newPassword, currentMember.getLoginPw())) {
	        throw new IllegalArgumentException("기존 비밀번호와 다른 새로운 비밀번호를 입력해주세요.");
	    }

	    // 새 비밀번호 암호화 후 업데이트
	    String encodedNewPassword = passwordEncoder.encode(newPassword);
	    return mapper.updatePassword(memberId, encodedNewPassword) > 0;
	}
	
	@Override
	@Transactional
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

