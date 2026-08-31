// 관리자 - 파일 정합성 검사: 서버 통신을 담당하는 비즈니스 로직.
// DOM을 직접 건드리지 않고, adminMaintenance.jsp가 쓰는 인터랙션 스크립트에서
// window.AdminMaintenanceService를 통해 호출한다.
(function () {

    function checkIntegrity(url) {
        return fetch(url)
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '검사에 실패했습니다.');
                }
                return result.data || [];
            });
    }

    function deleteOrphanFile(url, category, fileName) {
        return fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ category: category, fileName: fileName })
        })
            .then(function (response) { return response.json(); })
            .then(function (result) {
                if (!result.success) {
                    throw new Error(result.message || '삭제에 실패했습니다.');
                }
                return result;
            });
    }

    window.AdminMaintenanceService = {
        checkIntegrity: checkIntegrity,
        deleteOrphanFile: deleteOrphanFile
    };

})();
