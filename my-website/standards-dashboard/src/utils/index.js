import { format } from 'date-fns';

// Utility function to format dates
export function formatDate(date) {
    return format(new Date(date), 'MMMM dd, yyyy');
}

// Utility function to generate a unique QR code data string for a class
export function generateQrCodeData(classId, date) {
    return JSON.stringify({
        classId,
        date: formatDate(date),
    });
}

// Utility function to check if a date is today
export function isToday(date) {
    const today = new Date();
    return date.getFullYear() === today.getFullYear() &&
           date.getMonth() === today.getMonth() &&
           date.getDate() === today.getDate();
}

// Utility function to get the current date
export function getCurrentDate() {
    return new Date();
}