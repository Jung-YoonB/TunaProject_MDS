// 배송지 추가 화면(utill/deliveryAddress.jsp) - 우편번호 검색 팝업 연동.
// zipcode/address 두 입력칸은 readonly라 이 팝업으로만 채울 수 있는데, 지금까지 버튼에
// 아무 JS도 안 붙어 있어서 눌러도 아무 반응이 없었다(AUDIT 신규 버그 - "배송지 추가가 안 됨"의
// 실제 원인 중 하나: 컨트롤러/서비스는 이미 있어도 이 팝업이 없으면 폼 자체를 채울 수 없었다).
(function () {

    var searchButton = document.getElementById('address-search-button');
    if (!searchButton) return;

    var zipcodeInput = document.getElementById('zipcode');
    var addressInput = document.getElementById('address');
    var detailAddressInput = document.getElementById('detail-address');

    searchButton.addEventListener('click', function () {

        if (typeof daum === 'undefined' || !daum.Postcode) {
            alert('우편번호 검색 서비스를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
            return;
        }

        new daum.Postcode({
            oncomplete: function (data) {
                zipcodeInput.value = data.zonecode;
                addressInput.value = data.address;
                if (detailAddressInput) {
                    detailAddressInput.focus();
                }
            }
        }).open();
    });

})();
