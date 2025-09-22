const students = [
    "Adewuyi Adetunji Quadri", "Au Anh Vu", "Galushka Ekaterina", "Ho Ngoc Bao Quy", 
    "Luong Hoang Thao", "Luong Tran Minh Chau", "Luu Hoang Phuong Linh", "Nghiem Pham Phuc Anh", 
    "Ngo Vu Nhat Anh", "Nguyen Ha Chi", "Nguyen Anh Thu", "Nguyen Hoang Long", 
    "Nguyen Huong Giang", "Nguyen Lam Thanh", "Nguyen Ngoc Mai Anh", "Nguyen Ngoc Yen", 
    "Nguyen Nhu Anh", "Nguyen Nhuan Phat", "Nguyen Phuong Nga", "Nguyen Thanh Truc", 
    "Nguyen Thao Hien", "Nguyen Thi Anh Nga", "Nguyen Thi Hong Nhung", "Nguyen Thi Phuong Trang", 
    "Nguyen Tran Nhat Minh", "Nguyen Tue Nhi", "Nguyen Vu Nhu Y", "Nguyen Yen Nhi", 
    "Ong Quynh Tram"
];

function shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

function createGroups() {
    const shuffledStudents = shuffleArray(students);
    const groups = [];
    
    // First 5 groups get 5 students each
    for (let i = 0; i < 5; i++) {
        groups.push(shuffledStudents.slice(i * 5, (i + 1) * 5));
    }
    
    // Last group gets remaining 4 students
    groups.push(shuffledStudents.slice(25));
    
    return groups;
}

function renderGroups() {
    const groups = createGroups();
    const container = document.getElementById('groupsContainer');
    
    container.innerHTML = groups.map((group, index) => `
        <div class="group group${index + 1}">
            <div class="group-title">Group ${index + 1}</div>
            ${group.map(student => `
                <div class="student-card">${student}</div>
            `).join('')}
        </div>
    `).join('');
}

function shuffleGroups() {
    renderGroups();
}

// Initial render
renderGroups();