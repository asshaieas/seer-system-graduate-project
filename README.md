# SEER Smart School Bus System

SEER is a Smart School Bus Safety and Tracking System designed to improve student transportation safety through RFID/NFC attendance, GPS bus tracking, real-time notifications, and a Tally-Based Safety Protocol.

## Development Process

The project will be developed from **Week 2 to Week 13**, starting on **August 30, 2026**.

The development follows a logical technical order:

**System Setup → Database and Core Features → RFID/NFC Integration → GPS Tracking → Safety Protocol → Notifications → AI Integration → Final Testing and Documentation**

Each week contains three assigned tasks:

- **Sunday — Abdulbaset**
- **Tuesday — Hamad**
- **Thursday — Ali**

All our tasks initially start with the status **❌ No** and we will be updated them as the project progresses. As well as the ` **code** ` for each task by each member will be commited to this private ` **repository** `.

## Development Schedule

| Week | Date | Day | Member | Task | Technologies | Status |
|---|---|---|---|---|---|---|
| **Week 2** | Aug 30, 2026 | Sunday | **Abdulbaset** | Set up the ESP32 development environment and test hardware communication. | ESP32, Arduino IDE | ❌ No |
| **Week 2** | Sep 1, 2026 | Tuesday | **Hamad** | Create the Flutter project and basic structure for the Parent and Driver applications. | Flutter, Dart | ❌ No |
| **Week 2** | Sep 3, 2026 | Thursday | **Ali** | Create the Firebase project and prepare the Admin Dashboard project. | Firebase, Flutter Web | ❌ No |
| **Week 3** | Sep 6, 2026 | Sunday | **Abdulbaset** | Test the RFID/NFC reader with ESP32 and read student card or bracelet UID values. | ESP32, MFRC522 RFID/NFC | ❌ No |
| **Week 3** | Sep 8, 2026 | Tuesday | **Hamad** | Develop authentication screens and role-based navigation for Parent and Driver users. | Flutter, Firebase Authentication | ❌ No |
| **Week 3** | Sep 10, 2026 | Thursday | **Ali** | Design the database structure for users, students, buses, trips, and scan events. | Firebase, Cloud Firestore | ❌ No |
| **Week 4** | Sep 13, 2026 | Sunday | **Abdulbaset** | Connect RFID/NFC UID values to student identification records. | ESP32, RFID/NFC, Firebase | ❌ No |
| **Week 4** | Sep 15, 2026 | Tuesday | **Hamad** | Develop the Parent App student list and child information screens. | Flutter, Firebase | ❌ No |
| **Week 4** | Sep 17, 2026 | Thursday | **Ali** | Develop Admin Dashboard management features for schools, students, drivers, and buses. | Flutter Web, Firebase | ❌ No |
| **Week 5** | Sep 20, 2026 | Sunday | **Abdulbaset** | Integrate RFID/NFC scanning with the backend and store boarding and scan events. | ESP32, Firebase API | ❌ No |
| **Week 5** | Sep 22, 2026 | Tuesday | **Hamad** | Develop the Driver App assigned student list and absence information display. | Flutter, Firebase | ❌ No |
| **Week 5** | Sep 24, 2026 | Thursday | **Ali** | Implement student-to-bus and driver-to-bus assignments. | Flutter Web, Firebase | ❌ No |
| **Week 6** | Sep 27, 2026 | Sunday | **Abdulbaset** | Integrate and test the GPS module with ESP32 for bus location tracking. | ESP32, GPS Module | ❌ No |
| **Week 6** | Sep 29, 2026 | Tuesday | **Hamad** | Develop the Parent App absence request feature. | Flutter, Firebase | ❌ No |
| **Week 6** | Oct 1, 2026 | Thursday | **Ali** | Develop trip and route management features in the Admin Dashboard. | Flutter Web, Firebase | ❌ No |
| **Week 7** | Oct 4, 2026 | Sunday | **Abdulbaset** | Send GPS location data to Firebase and test simulated and real bus coordinates. | ESP32, GPS, Firebase API | ❌ No |
| **Week 7** | Oct 6, 2026 | Tuesday | **Hamad** | Develop the Parent App bus tracking screen. | Flutter, Firebase | ❌ No |
| **Week 7** | Oct 8, 2026 | Thursday | **Ali** | Develop the Admin Dashboard bus monitoring and trip status screen. | Flutter Web, Firebase | ❌ No |
| **Week 8** | Oct 11, 2026 | Sunday | **Abdulbaset** | Implement RFID-based boarding and alighting events and begin the Tally-Based Safety Protocol. | ESP32, RFID/NFC, Firebase | ❌ No |
| **Week 8** | Oct 13, 2026 | Tuesday | **Hamad** | Develop Parent App boarding and leaving notifications. | Flutter, Firebase Cloud Messaging | ❌ No |
| **Week 8** | Oct 15, 2026 | Thursday | **Ali** | Implement trip records and safety monitoring data for Tally Protocol validation. | Firebase, Flutter Web | ❌ No |
| **Week 9** | Oct 18, 2026 | Sunday | **Abdulbaset** | Complete and test the Tally-Based Safety Protocol and prevent trip completion when counts do not match. | ESP32, Firebase API | ❌ No |
| **Week 9** | Oct 20, 2026 | Tuesday | **Hamad** | Develop Driver App trip controls: start trip, update status, and confirm the bus is empty. | Flutter, Firebase | ❌ No |
| **Week 9** | Oct 22, 2026 | Thursday | **Ali** | Develop transportation reports and safety incident views. | Flutter Web, Firebase | ❌ No |
| **Week 10** | Oct 25, 2026 | Sunday | **Abdulbaset** | Prepare the secure AI integration layer with backend-only AI requests, data minimization, and privacy protection. | Firebase API, Cloud Functions, AI API | ❌ No |
| **Week 10** | Oct 27, 2026 | Tuesday | **Hamad** | Complete testing of Parent App core features including tracking, absence requests, and notifications. | Flutter, Firebase | ❌ No |
| **Week 10** | Oct 29, 2026 | Thursday | **Ali** | Complete testing of Admin Dashboard management, assignments, monitoring, and reports. | Flutter Web, Firebase | ❌ No |
| **Week 11** | Nov 1, 2026 | Sunday | **Abdulbaset** | Integrate initial AI features for absence request parsing and plain-language trip summaries. | Cloud Functions, AI API | ❌ No |
| **Week 11** | Nov 3, 2026 | Tuesday | **Hamad** | Integrate and test AI-generated absence results and trip summaries in the Parent App. | Flutter, Firebase API | ❌ No |
| **Week 11** | Nov 5, 2026 | Thursday | **Ali** | Prepare aggregated reporting and incident data for AI-assisted Dashboard features. | Firebase, Flutter Web | ❌ No |
| **Week 12** | Nov 8, 2026 | Sunday | **Abdulbaset** | Integrate AI features for driver pre-trip briefings, incident drafting, and narrative reporting. | Cloud Functions, AI API | ❌ No |
| **Week 12** | Nov 10, 2026 | Tuesday | **Hamad** | Perform end-to-end testing of the Parent and Driver applications with RFID, GPS, trips, notifications, and safety events. | Flutter, Firebase | ❌ No |
| **Week 12** | Nov 12, 2026 | Thursday | **Ali** | Perform end-to-end testing of the Admin Dashboard, reports, incidents, and monitoring features. | Flutter Web, Firebase | ❌ No |
| **Week 13** | Nov 15, 2026 | Sunday | **Abdulbaset** | Perform final hardware and AI integration testing and fix critical issues. | ESP32, RFID/NFC, GPS, Firebase API, AI API | ❌ No |
| **Week 13** | Nov 17, 2026 | Tuesday | **Hamad** | Perform final mobile application testing, bug fixing, and prepare Parent and Driver App demo scenarios. | Flutter, Firebase | ❌ No |
| **Week 13** | Nov 19, 2026 | Thursday | **Ali** | Perform final Dashboard testing, update documentation, and prepare the final project demonstration. | Flutter Web, Firebase, GitHub | ❌ No |
