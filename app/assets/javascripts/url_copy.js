function urlCopy(string) {
    var temp = document.createElement('div');

    temp.appendChild(document.createElement('pre')).textContent = string;

    var s = temp.style;
    s.position = 'fixed';
    s.left = '-100%';

    document.body.appendChild(temp);
    document.getSelection().selectAllChildren(temp);

    var result = document.execCommand('copy');

    document.body.removeChild(temp);

    if (result) {
        alert('URLをコピーしました');
    }
    else {
        alert('このブラウザでは対応していません');
    }
}