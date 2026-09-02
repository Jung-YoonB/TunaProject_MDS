package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;

import org.apache.ibatis.type.Alias;
import org.springframework.format.annotation.DateTimeFormat;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("MemberDTO")
public class MemberDTO {

	private Long memberId;
	private Long gradeId;
	private String gradeName; // GRADE.GRADE_NAME, 마이페이지 표시용 (selectByMemberId에서만 채워짐)
	private Long totalAmount;
	@NotBlank(message = "이름을 입력해주세요.")
	@Pattern(regexp = "^[가-힣]{2,4}$", message = "이름은 한글 2~4자로 입력해주세요.")
	private String memberName;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate birth;
	private String gender;
	@NotBlank(message = "아이디를 입력해주세요.")
	@Pattern(regexp="^[a-z][a-z0-9_]{5,19}$", message="아이디는 영문 소문자로 시작하며, 영문 소문자·숫자·언더바(_)를 사용한 6~20자로 입력해주세요.")
	private String loginId;
	@NotBlank(message = "비밀번호를 입력해주세요.")
	@Pattern(regexp="^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$", message="비밀번호는 영문, 숫자, 특수문자를 각각 하나 이상 포함한 8~16자로 입력해주세요.")
	private String loginPw;
	@NotBlank(message = "닉네임을 입력해주세요.")
	@Pattern(regexp = "^[가-힣a-zA-Z0-9_]{2,8}$", message = "닉네임은 한글, 영문, 숫자, 언더바(_)를 사용하여 2~8자로 입력해주세요.")
	private String nickname;
	@Pattern(regexp="^$|^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", message="올바른 이메일 형식이 아닙니다.")
	private String email;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate createdAt;
	@NotBlank(message = "연락처를 입력해주세요.")
	@Pattern(regexp="^01[0-9]{8,9}$", message="휴대폰 번호는 숫자만 입력해주세요. (예: 01012345678)")
	private String phone;
	private String role;
	private Integer memberStatus;
	private Integer point;
	
	private String birthStr;
	private String createdAtStr;
	
	public MemberDTO(Long memberId, String memberName, String role) {
		this.memberId = memberId;
		this.memberName = memberName;
		this.role = role;
	}
}