# Student Groups Generator

A colorful, interactive web application for randomly organizing students into groups.

## Features

- 🎨 **Colorful Design**: Each group has its own distinct color theme
- 🔀 **Random Shuffling**: Click the shuffle button to create new random groupings
- 📱 **Responsive Layout**: Works on desktop, tablet, and mobile devices
- 🎯 **Slide-Friendly**: 2x3 grid layout optimized for presentations

## Usage

1. Open `index.html` in your web browser
2. View the automatically generated random groups
3. Click "🔀 Shuffle Groups" to create new random groupings

## Customization

### Adding/Removing Students
Edit the `students` array in `script.js`:
```javascript
const students = [
    "Student Name 1",
    "Student Name 2",
    // Add or remove names as needed
];
```

### Changing Group Sizes
Modify the `createGroups()` function in `script.js` to adjust how students are distributed among groups.

### Styling
Edit `styles.css` to customize colors, fonts, and layout.

## File Structure
```
student-groups/
├── index.html      # Main HTML structure
├── styles.css      # Styling and layout
├── script.js       # JavaScript functionality
└── README.md       # This file
```

## Browser Compatibility
- Chrome (recommended)
- Firefox
- Safari
- Edge

## License
Free to use and modify for educational purposes.