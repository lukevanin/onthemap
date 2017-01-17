# On the Map

On the Map iOS app for Udacity nanodegree.

Add your location and URL to a world map. See locations and web sites of other students.

## Features

1. Log in with your Udacity credentials, or with your Facebook account. Activity indicator is shown during login.
2. See locations of students as pins on a map. Tap on a pin to see the student's web site.
3. See a list of students. Tap on a student to see their web site.
4. Tap the Logout button on the toolbar to log out. All toolbar buttons are disabled while logging out.
5. Tap the refresh button to reload the student data. The refresh and logout buttons are disabled while students are loading. Student data is reloaded automatically when switching between screens.
6. Tap the pin button to add your location. The pin button and logout button are disabled while the app checks to see if your location has already been added. If your location already exists on the server, you will see a prompt to overwrite it.
7. A network activity indicator appears in the status bar when logging out, loading students, or checking your location.
8. Enter your address on the location screen. Tap "Find on map" to reverse geocode the address to coordinates. An activity indicator appears while geocoding is in progress.
9. Enter your web site URL on the student info screen. Tap "Submit" to save the location to the server. Your name, surname, and accountID will be included in the new location.
10. App supports landscape and portrait mode.

## Design

Below is a brief summary of the different types of components in the app, and their function. The architecture uses various design patterns, although it is quite loosely defined and not "technically correct" according to any well known standard.

### Models

Simple structures representing data used in the app. Some custom error types are also used for common error cases. Some models include functionality for deserializing from / serializing to JSON data.

### Services

Encapsulate functionality for interacting with web APIs. The sub-sections are:

- **Abstract**: Defines generic protocols which the app uses as dependencies.
- **Concrete**: Implementations of the abstract protocols, for the Udacity API. In theory, other APIs can be supported by different concrete implementations. This group also contains the `HTTPService` helper class which provides basic HTTP functionality.
- **Mock**: Implementations which provide pre-defined behavior. Used during development and testing, to evoke specific UI behaviors.

### Manager

Contains the `AuthenticationManager` which stores login state, and delegates network operations to services.

### Use case

Implementations of specific tasks performed in the app. These are at a higher abstraction level than services, and usually coordinate various services

### Controller

Defines view controllers as well as abstract controller protocols, higher level presentation controllers, and some utility extensions for creating and showing error alerts.

The primary controller is the `StudentsAppController` which coordinates the overall behavior of the application. The controller updates the view by interacting with its delegate, which is currently implemented as `TabViewController`.

The `ListViewController` and `MapViewController` display student locations in a table or on a map respectively. Almost no functionality is implemented in these controllers, as most of the complicated logic is delegated to the `StudentsAppController`.

This design allows the UI components to be separated from the control logic, which potentially leads to higher code reuse. For example, the iPad app could implement a master-detail view controller acting as the delegate for the `StudentsAppController`.

### View

Custom views, usually providing minimal aesthetic changes.


## TODO

- Authentication management when interacting with API: If authentication fails when performing an API request after login (ie posting student information), the app handles this by displaying an alert to the user. The user must then manually log out and then log in. The app should detect an invalid auth response and transition to the logout state.
