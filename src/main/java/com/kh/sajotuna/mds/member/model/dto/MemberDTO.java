package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;

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
	private String loginId;
	private String loginPw;
	private String nickname;
	private String email;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate createdAt;
	private String phone;
	private String role;
	private Integer memberStatus;
	
	private String birthStr;
	private String createdAtStr;
}