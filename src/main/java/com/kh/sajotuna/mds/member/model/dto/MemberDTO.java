package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;

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
public class MemberDTO {

	private Long memberId;
	private Long gradeId;
	private Long totalAmount;
	private String memberName;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate birth;
	private String gender;
	@Pattern(regexp="^[a-z][a-z0-9]{5,19}$", message="첫글자를 영어로 하는 6~20자로 입력해주세요.")
	private String loginId;
	@Pattern(regexp="^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()])[a-zA-Z0-9!@#$%^&*()]{8,16}$", message="영어와 숫자, 특수문자가 최소 하나씩 들어가는 8~16자로 입력해주세요.")
	private String loginPw;
	private String nickname;
	private String email;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate createdAt;
	private String phone;
	private String role;
	private Integer memberStatus;
	private Integer point;
	private Integer couponQty;
	
	private String birthStr;
	private String createdAtStr;
}