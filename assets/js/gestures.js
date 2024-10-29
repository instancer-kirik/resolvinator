// // assets/js/gestures.js

// document.addEventListener('DOMContentLoaded', () => {
//     const fingersPressed = [0, 0, 0, 0, 0];
  
//     function updateFingersPressed(key, isPressed) {
//       switch (key) {
//         case '1': fingersPressed[0] = isPressed ? 1 : 0; break;
//         case '2': fingersPressed[1] = isPressed ? 1 : 0; break;
//         case '3': fingersPressed[2] = isPressed ? 1 : 0; break;
//         case '4': fingersPressed[3] = isPressed ? 1 : 0; break;
//         case '5': fingersPressed[4] = isPressed ? 1 : 0; break;
//         default: break;
//       }
//       filterGestures();
//     }
  
//     function filterGestures() {
//       const currentFilter = fingersPressed.join('');
//       const items = document.querySelectorAll('.gesture-item');
//       items.forEach(item => {
//         if (item.dataset.fingersUp === currentFilter) {
//           item.style.display = 'block';
//         } else {
//           item.style.display = 'none';
//         }
//       });
//     }
  
//     document.addEventListener('keydown', (event) => {
//       if (event.key >= '1' && event.key <= '5') {
//         updateFingersPressed(event.key, true);
//       }
//     });
  
//     document.addEventListener('keyup', (event) => {
//       if (event.key >= '1' && event.key <= '5') {
//         updateFingersPressed(event.key, false);
//       }
//     });
//   });
  