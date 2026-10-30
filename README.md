
# Student Feedback Routing System

A web-based Student Feedback Routing System developed using Flutter Web, Laravel REST API, and MySQL.

## Project Overview

The system allows students to submit feedback and automatically routes each submission to the appropriate university office based on its category.

## Technologies Used

- Frontend: Flutter Web (Dart)
- Backend: Laravel (PHP)
- Database: MySQL
- API: RESTful API

## Main Features

- Student feedback submission
- Feedback category selection
- Automatic office assignment
- Feedback status monitoring
- Staff feedback management
- Automation logging
- Retry and escalation handling

## Project Structure

- `frontend/` - Flutter Web application
- `backend/` - Laravel API and database components

## Feedback Routing

| Category | Assigned Office |
|---|---|
| Academic | Academic Affairs Office |
| Facilities | Facilities Management Office |
| Student Services | Student Services Office |
| Others | General Administration Office |

## Installation

### Backend

1. Open the `backend` directory.
2. Run `composer install`.
3. Copy `.env.example` to `.env`.
4. Configure the MySQL database connection.
5. Run `php artisan key:generate`.
6. Run `php artisan migrate`.
7. Start the server using `php artisan serve`.

### Frontend

1. Open the `frontend` directory.
2. Run `flutter pub get`.
3. Configure the API base URL for your environment.
4. Run `flutter run -d chrome`.

## Current Limitations

- Authentication and role-based access control are not yet implemented.
- Real email and push notifications are not integrated.
- The system is intended for academic demonstration and testing.

## Developer

GitHub: [jagarma](https://github.com/jagarma)
