// calendar.js

document.addEventListener('DOMContentLoaded', () => {
    const calendarElement = document.getElementById('calendar');
    const attendanceStatus = {};

    // Initialize the calendar
    function initCalendar() {
        const today = new Date();
        const month = today.getMonth();
        const year = today.getFullYear();
        renderCalendar(month, year);
    }

    // Render the calendar for a specific month and year
    function renderCalendar(month, year) {
        const firstDay = new Date(year, month).getDay();
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const calendarBody = document.createElement('tbody');

        let date = 1;

        // Create the calendar rows
        for (let i = 0; i < 6; i++) {
            const row = document.createElement('tr');

            // Create cells for each day of the week
            for (let j = 0; j < 7; j++) {
                const cell = document.createElement('td');

                if (i === 0 && j < firstDay) {
                    cell.textContent = '';
                } else if (date > daysInMonth) {
                    cell.textContent = '';
                } else {
                    cell.textContent = date;
                    cell.classList.add('calendar-day');
                    cell.addEventListener('click', () => toggleAttendance(date, month, year));
                    date++;
                }

                row.appendChild(cell);
            }

            calendarBody.appendChild(row);
        }

        // Clear previous calendar and append new one
        calendarElement.innerHTML = '';
        calendarElement.appendChild(calendarBody);
    }

    // Toggle attendance status for a specific date
    function toggleAttendance(date, month, year) {
        const key = `${year}-${month + 1}-${date}`;
        attendanceStatus[key] = attendanceStatus[key] === 'Present' ? 'Absent' : 'Present';
        alert(`Attendance for ${key}: ${attendanceStatus[key]}`);
    }

    // Initialize the calendar on page load
    initCalendar();
});