package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;

import org.apache.ibatis.type.Alias;
import org.springframework.format.annotation.DateTimeFormat;

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
	@Pattern(regexp = "^[가-힣]{2,4}$", message = "이름은 한글 2~4자로 입력해주세요.")
	private String memberName;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate birth;
	private String gender;
	@Pattern(regexp="^[a-z][a-z0-9]{5,19}$", message="첫글자를 영어로 하는 6~20자로 입력해주세요.")
	private String loginId;
	@Pattern(regexp="^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$", message="영어와 숫자, 특수문자가 최소 하나씩 들어가는 8~16자로 입력해주세요.")
	private String loginPw;
	@Pattern(regexp = "^[가-힣a-zA-Z0-9_]{2,8}$", message = "닉네임은 한글, 영문, 숫자, 언더바(_)를 사용하여 2~8자로 입력해주세요.")
	private String nickname;
	@Pattern(regexp="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", message="올바른 이메일 형식이 아닙니다.")
	private String email;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate createdAt;
	@Pattern(regexp="^01[0-9]{8,9}$", message="올바른 전화번호 형식이 아닙니다.")
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