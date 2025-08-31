const QRCode = require('qrcode');

async function generateQRCode(classInfo) {
    try {
        const qrCodeData = JSON.stringify(classInfo);
        const qrCodeUrl = await QRCode.toDataURL(qrCodeData);
        return qrCodeUrl;
    } catch (error) {
        console.error('Error generating QR code:', error);
        return null;
    }
}

function displayQRCode(classInfo, containerId) {
    const container = document.getElementById(containerId);
    if (!container) {
        console.error('Container not found:', containerId);
        return;
    }

    generateQRCode(classInfo).then(qrCodeUrl => {
        if (qrCodeUrl) {
            const img = document.createElement('img');
            img.src = qrCodeUrl;
            img.alt = 'QR Code for ' + classInfo.name;
            container.appendChild(img);
        }
    });
}

export { generateQRCode, displayQRCode };