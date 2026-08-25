package com.kh.sajotuna.mds.util.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurytiConfig {

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) {
		// 세션 기반 인증 + fetch(REST API) 사용 예정이므로 비활성화
		http.csrf(AbstractHttpConfigurer::disable)
		// 시큐리티 기본 로그인 폼 비활성화
		.formLogin(AbstractHttpConfigurer::disable)
		// http basic 인증 - 인증 헤더에 id/pw를 Base64 로 인코딩해서 보내는 인증 방식 비활성화 
		.httpBasic(AbstractHttpConfigurer::disable)
		// 시큐리티 기본 로그아웃 처리 비활성화
		.logout(AbstractHttpConfigurer::disable)
		// 인증 여부에 따른 접근 제어 모든 요청 허용
		.authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
		
		return http.build();
	}
	
	/**
	 * 비밀번호 단반향 해시 암호화
	 * @return new BCryptPasswordEncoder()
	 */
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
}
