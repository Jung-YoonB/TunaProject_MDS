package com.kh.sajotuna.mds.member.service;

import com.kh.sajotuna.mds.util.PageWindow;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.member.model.dto.DeliveryAddressDTO;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageDeliveryDTO;
import com.kh.sajotuna.mds.member.model.dto.MyPageOrderItemDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService{

	// MemberMapper DI
	private final MemberMapper mapper;
	// PasswordEncoder DI
	private final PasswordEncoder passwordEncoder;

	/**
	 * 입력된 연락처를 검증하고 DB 저장 형식으로 맞춘다. 형식이 아니면 예외.
	 *
	 * 가입(signUp)과 연락처 변경(phoneUpdate)이 이 규칙을 똑같이 써야 한다. 예전엔 같은 20줄이
	 * 양쪽에 복붙돼 있어서, 한쪽만 고치면 저장 형식이 갈리고 중복검사(isPhoneCheck)가 못 잡는다.
	 */
	private String normalizePhone(String phone) {

	    if (phone == null || phone.isBlank()) {
	        throw new IllegalArgumentException("전화번호를 입력해주세요.");
	    }

	    String formatted = formatPhone(phone);

	    if (formatted == null) {
	        throw new IllegalArgumentException("올바른 전화번호 형식이 아닙니다.");
	    }
	    return formatted;
	}

	/**
	 * 연락처를 DB 저장 형식(010-1234-5678)으로 맞춘다. 형식이 아니면 null.
	 *
	 * PHONE 컬럼엔 하이픈이 들어간 형태로만 저장되므로, 조회할 때도 반드시 이 형식으로 바꿔서
	 * 비교해야 한다. 가입 폼은 숫자만 받는데(MemberDTO의 {@code ^01[0-9]{8,9}$}) 중복확인이
	 * 그 값을 그대로 넘기는 바람에, 이미 쓰는 번호인데도 늘 "사용 가능"으로 나오고 있었다.
	 *
	 * 숫자만 먼저 걸러내므로 이미 하이픈이 붙은 값을 다시 넣어도 결과가 같다(멱등).
	 */
	private static String formatPhone(String phone) {

	    if (phone == null) {
	        return null;
	    }

	    String digits = phone.replaceAll("[^0-9]", "");

	    if (!digits.matches("^01[0-9]{8,9}$")) {
	        return null;
	    }

	    if (digits.length() == 11) {
	        return digits.replaceFirst("(\\d{3})(\\d{4})(\\d{4})", "$1-$2-$3");
	    }
	    return digits.replaceFirst("(\\d{3})(\\d{3})(\\d{4})", "$1-$2-$3");
	}

	@Override
	@Transactional
	public void signUp(MemberDTO member) {

	    // 가입과 연락처 변경이 같은 규칙을 써야 중복검사(isPhoneCheck)가 맞아떨어진다
	    member.setPhone(normalizePhone(member.getPhone()));


	    // 아이디 중복검사
	    if (isLoginIdCheck(member.getLoginId())) {
	        throw new IllegalStateException("이미 사용중인 아이디입니다.");
	    }

	    // 닉네임 중복검사
	    if (isNicknameCheck(member.getNickname(), null)) {
	        throw new IllegalStateException("이미 사용중인 닉네임입니다.");
	    }

	    // 이메일 중복검사
	    if (isEmailCheck(member.getEmail(), null)) {
	        throw new IllegalStateException("이미 사용중인 이메일입니다.");
	    }

	    // 연락처 중복검사
	    if (isPhoneCheck(member.getPhone(), null)) {
	        throw new IllegalStateException("이미 사용중인 연락처입니다.");
	    }


	    // 비밀번호 암호화 처리
	    String encodePw = passwordEncoder.encode(member.getLoginPw());
	    member.setLoginPw(encodePw);

	    // role에 user 부여
	    member.setRole("USER");


	    // 체크된 데이터를 저장
	    try {
	        mapper.insertMember(member);
	        mapper.insertPoint(member.getMemberId());

	    } catch (DuplicateKeyException e) {

	        // 동시에 가입하여 UNIQUE 제약조건에 걸린 경우
	        throw new IllegalStateException(
	            "동시 가입으로 인해 이미 등록된 정보가 존재합니다. 다시 확인해주세요."
	        );
	    }
	}


	@Override
	public boolean isLoginIdCheck(String loginId) {
		// 중복된 아이디가 있으면 검색 결과가 0이 아님.
		return mapper.countByLoginId(loginId) > 0;
	}

	@Override
	public boolean isNicknameCheck(String nickname, Long excludeMemberId) {
		return mapper.countByNickname(nickname, excludeMemberId) > 0;
	}

	@Override
	public boolean isEmailCheck(String email, Long excludeMemberId) {
		return mapper.countByEmail(email, excludeMemberId) > 0;
	}

	@Override
	public boolean isPhoneCheck(String phone, Long excludeMemberId) {
		// PHONE은 하이픈이 붙은 형태로만 저장되므로 조회값도 같은 형태로 맞춰서 넘긴다.
		// 형식이 아니면(중복확인 버튼을 다 입력하기 전에 누른 경우 등) 들어온 값 그대로 조회한다 -
		// 어차피 못 찾고, 형식 안내는 폼 검증이 따로 한다.
		String formatted = formatPhone(phone);
		return mapper.countByPhone(formatted != null ? formatted : phone, excludeMemberId) > 0;
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
				member.getMemberName(), member.getNickname(), member.getRole());
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
		int offset = PageWindow.offset(page, COUPON_PAGE_SIZE);
		return mapper.selectCouponsByMemberId(memberId, offset, COUPON_PAGE_SIZE);
	}

	@Override
	public int totalCouponPages(Long memberId) {
		int totalCount = mapper.countCouponsByMemberId(memberId);
		return PageWindow.totalPages(totalCount, COUPON_PAGE_SIZE);
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
		int offset = PageWindow.offset(page, DELIVERY_PAGE_SIZE);
		List<MyPageDeliveryDTO> deliveries = mapper.selectDeliveriesByMemberId(memberId, status, offset, DELIVERY_PAGE_SIZE);

		if (deliveries.isEmpty()) {
			return deliveries;
		}

		// 카드를 펼쳤을 때 보여줄 품목 목록을 붙인다. 주문마다 조회하면 N+1이 되므로
		// 이 페이지에 보이는 주문 ID를 한 번에 넘겨 1회 조회하고 주문별로 나눠 담는다
		List<Long> orderIds = deliveries.stream()
				.map(MyPageDeliveryDTO::getOrderId)
				.toList();

		Map<Long, List<MyPageOrderItemDTO>> itemsByOrder = mapper.selectOrderItemsByOrderIds(orderIds).stream()
				.collect(Collectors.groupingBy(MyPageOrderItemDTO::getOrderId));

		for (MyPageDeliveryDTO delivery : deliveries) {
			delivery.setItems(itemsByOrder.getOrDefault(delivery.getOrderId(), List.of()));
		}

		return deliveries;
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
		
		if (isNicknameCheck(nickname, memberId)) {
			throw new IllegalStateException("이미 사용 중인 닉네임입니다.");
		}
		
		return mapper.updateNickname(memberId, nickname) > 0;
	}
	
	@Override
	@Transactional
	public boolean phoneUpdate(Long memberId, String phone) {

	    phone = normalizePhone(phone);

	    MemberDTO currentMember = mapper.selectByMemberId(memberId);

	    if (currentMember == null) {
	        throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
	    }

	    // 기존 전화번호와 동일하면 성공 처리
	    if (phone.equals(currentMember.getPhone())) {
	        return true;
	    }

	    // 중복 검사
	    if (isPhoneCheck(phone, memberId)) {
	        throw new IllegalStateException("이미 사용 중인 연락처입니다.");
	    }

	    return mapper.updatePhone(memberId, phone) > 0;
	}


	@Override
	@Transactional
	public boolean emailUpdate(Long memberId, String email) {

	    // 이메일은 선택사항이므로 빈 값이면 NULL로 저장
	    if (email != null && email.isBlank()) {
	        email = null;
	    }

	    // 값이 들어온 경우에만 이메일 형식 검사
	    if (email != null && !email.matches(MemberDTO.EMAIL_REGEX)) {
	        throw new IllegalArgumentException("올바른 이메일 형식이 아닙니다.");
	    }

	    MemberDTO currentMember = mapper.selectByMemberId(memberId);

	    if (currentMember == null) {
	        throw new IllegalStateException("회원 정보를 찾을 수 없습니다.");
	    }

	    // 기존 이메일과 동일한 경우
	    if (email == null
	            ? currentMember.getEmail() == null
	            : email.equals(currentMember.getEmail())) {
	        return true;
	    }

	    // 이메일을 새로 입력한 경우에만 중복 확인
	    if (email != null && isEmailCheck(email, memberId)) {
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
		return PageWindow.totalPages(totalCount, DELIVERY_PAGE_SIZE);
	}

	@Override
	public int countActiveDeliveries(Long memberId) {
		return mapper.countActiveDeliveries(memberId);
	}

	@Override
	public int countReviewableOrderDetails(Long memberId) {
		return mapper.countReviewableOrderDetails(memberId);
	}

	@Override
	public Long nextReviewableOdId(Long memberId) {
		return mapper.selectNextReviewableOdId(memberId);
	}

	@Override
	@Transactional
	public void addDeliveryAddress(DeliveryAddressDTO address) {
		if ("Y".equalsIgnoreCase(address.getIsDefault())) {
			mapper.clearDefaultAddress(address.getMemberId());
		}
		mapper.insertDeliveryAddress(address);
	}
}

