<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- header.jsp가 이미 모든 페이지 공통 CSS를 로드하므로 별도 link 불필요 --%>
<div class="admin-maintenance-page"
     data-check-url="<c:url value='/admin/maintenance/check'/>"
     data-delete-url="<c:url value='/admin/maintenance/delete-orphan'/>">

    <div class="page-content">

        <h1 class="page-title">파일 정합성 검사</h1>
        <p class="page-subtitle">
            업로드 디렉터리(uploads/product, uploads/review)와 DB(PRODUCTIMAGE, REVIEWIMAGE)를 서로 대조해서
            어긋난 부분을 찾아줍니다. 등록 도중 실패해서 남은 orphan 파일, 또는 파일이 사라진 DB 참조를 확인할 수 있습니다.
        </p>

        <button type="button" class="check-button" id="checkButton">검사 실행</button>

        <section class="result-section" aria-label="검사 결과">
            <p class="result-empty" id="resultEmpty" hidden>이상 없음 — 파일과 DB가 전부 일치합니다.</p>
            <p class="result-idle" id="resultIdle">"검사 실행" 버튼을 눌러 확인하세요.</p>

            <table class="issue-table" id="issueTable" hidden>
                <thead>
                    <tr>
                        <th>구분</th>
                        <th>카테고리</th>
                        <th>파일명</th>
                        <th>조치</th>
                    </tr>
                </thead>
                <tbody id="issueTableBody"></tbody>
            </table>
        </section>

    </div>

</div>

<script src="<c:url value='/js/admin/adminMaintenanceService.js'/>"></script>
<script src="<c:url value='/js/views/adminMaintenance.js'/>"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
