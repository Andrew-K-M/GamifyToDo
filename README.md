# Project: Achievr
## The Goals
Our goal is to gamify the traditional todo app. Traditional todo apps usually have an interface for creating tasks with a due date, priority, and details. The user can mark tasks as completed, in progress, or not started by updating the status. Usually you can sort them into categories, and the more critical tasks are displayed first. We plan on letting the user earn XP when they finish tasks. When the user gains 100/100 XP they will level up. After leveling up a number of times they will gain access to different cosmetics and be able to equip them.
## Functionalities
- Add task
- Remove task
- Set Priority for a task
- Mark a task as completed
- Unmark a task
- Gain XP
- Level up
- Complete challenges
- View Profile
- View tasks
- View calendar view
## Architecture and design
The application follows a modern iOS 26 architecture built around SwiftUI for the user interface and Core Data for persistent data storage. SwiftUI ensures that views automatically update in response to underlying data changes, while Core Data manages user information, tasks, and progression. To maintain code quality and consistency across the project, SwiftLint is integrated, enforcing style guidelines and helping prevent common programming errors. 

## Documentation
Github Link: https://github.com/Andrew-K-M/GamifyToDo

## Deployment Instructions:
- To run the app, you must be running MacOS and have XCode installed
- Clone the GitHub repository to your machine
- Open the folder in XCode
- Run the project (iOS target) 

## Application Instructions:
- The initial view is the home screen. You can add your first task by pressing the plus icon in the top right corner.
- Set the title, due date, and priority (medium by default)
- The task is added and unfinished. When you complete the task, you will earn XP that will count towards leveling up.
- To delete a task, you can swipe left on the task in the home screen, exposing the delete button.
- You can filter finished, unfinished, or all tasks by pressing the filter button in the top left corner.
- The calendar tab will show you a calendar view. Pressing any of the days will show you the tasks due that day.
- The challenges tabs will show you daily and weekly challenges for completing tasks. These tasks will also give you XP for leveling up.
- In the profile tab, you will see your current avatar, level, XP, and completed tasks. You will also be able to choose between different avatars based on what you have unlocked through leveling up.
