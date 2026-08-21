package com.kh.sajotuna.mds.member.model.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

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
	private String memberName;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private LocalDate birth;
	private Character gender;
	private String loginId;
	private String loginPw;
	private String nickname;
	private String email;
	private LocalDateTime createdAt;
	private String phone;
	private String role;
	private Integer memberStatus;
	
	private String birthStr;
	private String createdAtStr;
}
