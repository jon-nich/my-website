# Student Groups Application

A simple, interactive web application for managing and displaying student groups organized into 6 teams.

## Features

- **6 Team Display**: Automatically organizes students into 6 balanced teams
- **Random Shuffle**: Reassign students to different teams with new roles
- **Responsive Design**: Works on desktop and mobile devices
- **Role Assignment**: Each student gets a random role (Team Lead, Designer, Developer, Researcher, Analyst, Coordinator)
- **Visual Feedback**: Smooth animations and hover effects

## Files

- `student-groups.html` - Main HTML structure
- `styles.css` - Responsive CSS styling with dark theme
- `script.js` - JavaScript functionality for group management

## Usage

1. Open `student-groups.html` in a web browser
2. View the 6 teams with evenly distributed students
3. Click "🔀 Shuffle Groups" to randomly reassign students
4. Use keyboard shortcuts:
   - Press 'S' to shuffle groups
   - Press 'E' to export group data as JSON

## Design

The application uses a modern dark theme with:
- Gradient backgrounds and subtle animations
- Card-based layout for each team
- Responsive grid that adapts to screen size
- Consistent with the existing dashboard design system

## Customization

To modify the student list, edit the `students` array in `script.js`:

```javascript
this.students = [
    "Your Student Name",
    // Add more students here...
];
```

To change the number of teams, modify the loop in the `generateInitialGroups()` method.