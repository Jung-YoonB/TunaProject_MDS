// 관리자 - 파일 정합성 검사(adminMaintenance.jsp) 화면 인터랙션.
// 서버 통신은 window.AdminMaintenanceService(admin/adminMaintenanceService.js)에 위임한다.
(function () {
    var root = document.querySelector('.admin-maintenance-page');
    var CHECK_URL = root.dataset.checkUrl;
    var DELETE_URL = root.dataset.deleteUrl;

    var checkButton = document.getElementById('checkButton');
    var resultIdle = document.getElementById('resultIdle');
    var resultEmpty = document.getElementById('resultEmpty');
    var issueTable = document.getElementById('issueTable');
    var issueTableBody = document.getElementById('issueTableBody');

    var ISSUE_LABEL = {
        ORPHAN_FILE: { text: '파일만 있음', className: 'orphan' },
        MISSING_FILE: { text: 'DB만 있음', className: 'missing' }
    };

    function buildRow(issue) {
        var label = ISSUE_LABEL[issue.issueType] || { text: issue.issueType, className: '' };

        var row = document.createElement('tr');

        var typeCell = document.createElement('td');
        var badge = document.createElement('span');
        badge.className = 'issue-badge ' + label.className;
        badge.textContent = label.text;
        typeCell.appendChild(badge);
        row.appendChild(typeCell);

        var categoryCell = document.createElement('td');
        categoryCell.textContent = issue.category === 'product' ? '상품 이미지' : '리뷰 이미지';
        row.appendChild(categoryCell);

        var fileNameCell = document.createElement('td');
        fileNameCell.textContent = issue.fileName;
        row.appendChild(fileNameCell);

        var actionCell = document.createElement('td');
        if (issue.issueType === 'ORPHAN_FILE') {
            var deleteButton = document.createElement('button');
            deleteButton.type = 'button';
            deleteButton.className = 'delete-orphan-button';
            deleteButton.textContent = '파일 삭제';
            deleteButton.addEventListener('click', function () {
                if (!confirm('이 파일을 삭제하시겠습니까? (' + issue.fileName + ')')) {
                    return;
                }
                deleteButton.disabled = true;
                AdminMaintenanceService.deleteOrphanFile(DELETE_URL, issue.category, issue.fileName)
                    .then(function () {
                        row.remove();
                    })
                    .catch(function (error) {
                        alert(error.message || '삭제 중 오류가 발생했습니다.');
                        deleteButton.disabled = false;
                    });
            });
            actionCell.appendChild(deleteButton);
        } else {
            // DB엔 있는데 파일이 없는 경우 - 실제 데이터(상품/리뷰)에 영향을 줄 수 있어 자동 삭제 대상이 아님
            actionCell.textContent = '재업로드 필요';
        }
        row.appendChild(actionCell);

        return row;
    }

    function render(issues) {
        issueTableBody.innerHTML = '';

        if (issues.length === 0) {
            resultIdle.hidden = true;
            resultEmpty.hidden = false;
            issueTable.hidden = true;
            return;
        }

        resultIdle.hidden = true;
        resultEmpty.hidden = true;
        issueTable.hidden = false;

        issues.forEach(function (issue) {
            issueTableBody.appendChild(buildRow(issue));
        });
    }

    checkButton.addEventListener('click', function () {
        checkButton.disabled = true;
        AdminMaintenanceService.checkIntegrity(CHECK_URL)
            .then(render)
            .catch(function (error) {
                alert(error.message || '검사 중 오류가 발생했습니다.');
            })
            .finally(function () {
                checkButton.disabled = false;
            });
    });
})();
