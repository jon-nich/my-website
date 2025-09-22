// Student Groups Script
class StudentGroupsManager {
    constructor() {
        this.students = [
            // Sample students - in a real application, these would come from a database
            "Alice Johnson", "Bob Smith", "Carol Davis", "David Wilson",
            "Emma Brown", "Frank Miller", "Grace Lee", "Henry Garcia",
            "Iris Rodriguez", "Jack Thompson", "Kelly Martinez", "Leo Anderson",
            "Maya Patel", "Noah White", "Olivia Harris", "Paul Clark",
            "Quinn Taylor", "Ruby Lewis", "Sam Walker", "Tina Hall",
            "Uma Singh", "Victor Chen", "Wendy Kim", "Xavier Lopez",
        ];
        
        this.groups = [];
        this.init();
    }

    init() {
        this.generateInitialGroups();
        this.renderGroups();
    }

    generateInitialGroups() {
        // Create 6 empty groups
        this.groups = [];
        for (let i = 1; i <= 6; i++) {
            this.groups.push({
                id: i,
                name: `Team ${i}`,
                members: []
            });
        }

        // Distribute students evenly across groups
        const shuffledStudents = [...this.students].sort(() => Math.random() - 0.5);
        shuffledStudents.forEach((student, index) => {
            const groupIndex = index % 6;
            this.groups[groupIndex].members.push({
                name: student,
                role: this.getRandomRole()
            });
        });
    }

    getRandomRole() {
        const roles = ['Team Lead', 'Designer', 'Developer', 'Researcher', 'Analyst', 'Coordinator'];
        return roles[Math.floor(Math.random() * roles.length)];
    }

    shuffleGroups() {
        // Add shuffling animation
        const container = document.getElementById('groupsContainer');
        container.classList.add('shuffling');

        // Collect all members from all groups
        const allMembers = [];
        this.groups.forEach(group => {
            allMembers.push(...group.members);
            group.members = [];
        });

        // Shuffle the members array
        const shuffledMembers = allMembers.sort(() => Math.random() - 0.5);

        // Redistribute members with new roles
        shuffledMembers.forEach((member, index) => {
            const groupIndex = index % 6;
            this.groups[groupIndex].members.push({
                name: member.name,
                role: this.getRandomRole() // Assign new random role
            });
        });

        // Re-render after animation
        setTimeout(() => {
            this.renderGroups();
            container.classList.remove('shuffling');
        }, 600);
    }

    renderGroups() {
        const container = document.getElementById('groupsContainer');
        container.innerHTML = '';

        this.groups.forEach(group => {
            const groupElement = this.createGroupElement(group);
            container.appendChild(groupElement);
        });
    }

    createGroupElement(group) {
        const groupDiv = document.createElement('div');
        groupDiv.className = 'group-box';
        groupDiv.innerHTML = `
            <div class="group-title">
                <span>${group.name}</span>
                <span class="group-number">${group.members.length} members</span>
            </div>
            <ul class="group-members">
                ${group.members.length > 0 
                    ? group.members.map(member => `
                        <li class="group-member">
                            <div class="member-name">${member.name}</div>
                            <div class="member-role">${member.role}</div>
                        </li>
                    `).join('')
                    : '<li class="empty-group">No members assigned</li>'
                }
            </ul>
        `;
        return groupDiv;
    }
}

// Initialize the application when the page loads
let groupsManager;

document.addEventListener('DOMContentLoaded', function() {
    groupsManager = new StudentGroupsManager();
});

// Global function for the shuffle button
function shuffleGroups() {
    if (groupsManager) {
        groupsManager.shuffleGroups();
    }
}

// Additional utility functions
function exportGroups() {
    if (!groupsManager) return;
    
    const groupsData = groupsManager.groups.map(group => ({
        name: group.name,
        members: group.members.map(member => `${member.name} (${member.role})`)
    }));
    
    const dataStr = JSON.stringify(groupsData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    
    const link = document.createElement('a');
    link.href = URL.createObjectURL(dataBlob);
    link.download = 'student-groups.json';
    link.click();
}

// Add keyboard shortcuts
document.addEventListener('keydown', function(event) {
    // Press 'S' to shuffle
    if (event.key.toLowerCase() === 's' && !event.ctrlKey && !event.metaKey) {
        shuffleGroups();
    }
    
    // Press 'E' to export
    if (event.key.toLowerCase() === 'e' && !event.ctrlKey && !event.metaKey) {
        exportGroups();
    }
});